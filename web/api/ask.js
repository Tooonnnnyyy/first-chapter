// Small DeepSeek proxy, so the key stays on the server. Returns 503 until the
// owner sets DEEPSEEK_API_KEY in Vercel; the page then falls back to local search.
// Stores nothing and does not log questions.
const FACTS = `camera: Borrow cameras, mics, tripods, lights. 7-day loan, 2 renewals, Morisset service desk, current students, bring a valid library card, return with all accessories.
room: Book a study room online at Morisset, Law, Learning Crossroads 5th floor or Health Sciences. Up to about 6 people.
podcast: Digital Skills Hub at Learning Crossroads supports podcasting and VR.
cite: Library guides to citation styles, citation software, avoiding plagiarism.
librarian: Text 613-801-5603, phone 613-562-5213, email bibliolibrary@uOttawa.ca, or find the librarian for your subject.
print: Black and white $0.09, 2-sided $0.16. Colour $0.25, 2-sided $0.48. Scanning free. Pay with funds on student card.
hours: Locations and hours are on the Library's page: Morisset, Law, Health Sciences, Learning Crossroads and more.
books: Undergrads get 120 days, 500 items, unlimited renewals.
card: A valid library card is needed to borrow.
reserves: Course materials instructors set aside for short-term use.
workshop: Workshops, orientations and tours at the Library.
software: Public computers with uoAccess sign-in; SPSS, Stata and ArcGIS through uOLabsPlus, down midnight to 3 a.m.
access: Inclusive spaces, services and assistive technology.`;

// Same redaction the page applies, repeated server-side so a direct POST to
// this endpoint cannot bypass it: emails and phone/ID-like numbers never
// reach DeepSeek.
function redact(t) {
  return t
    .replace(/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/g, '[removed]')
    .replace(/\+?\d[\d\s().-]{5,}\d/g, '[removed]');
}

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'POST only' });
  const key = process.env.DEEPSEEK_API_KEY;
  if (!key) return res.status(503).json({ error: 'AI is not configured' });

  const question = redact(String(req.body?.question ?? '').slice(0, 300).trim());
  if (!question) return res.status(400).json({ error: 'Empty question' });

  try {
    const r = await fetch('https://api.deepseek.com/chat/completions', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${key}` },
      body: JSON.stringify({
        model: 'deepseek-chat',
        temperature: 0.2,
        max_tokens: 160,
        messages: [
          {
            role: 'system',
            content: `You help first-year University of Ottawa students find Library services. Reply in at most 2 short, plain sentences using ONLY these facts. Never invent hours, prices, models or availability. If the facts don't cover it, say a librarian can help (text 613-801-5603). End with a new line: SERVICE=<id of the best match>.\n\nFacts:\n${FACTS}`,
          },
          { role: 'user', content: question },
        ],
      }),
    });
    if (!r.ok) return res.status(502).json({ error: 'AI request failed' });
    const data = await r.json();
    const content = String(data?.choices?.[0]?.message?.content ?? '');
    const at = content.indexOf('SERVICE=');
    return res.status(200).json({
      text: (at >= 0 ? content.slice(0, at) : content).trim(),
      service: at >= 0 ? content.slice(at + 8).trim() : null,
    });
  } catch {
    return res.status(502).json({ error: 'AI request failed' });
  }
}
