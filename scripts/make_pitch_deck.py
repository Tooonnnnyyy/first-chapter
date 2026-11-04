import base64, pathlib

root = pathlib.Path("/Users/bjt/Projects/first-chapter/docs/pitch")
raw = root / "raw"

def img(name):
    data = base64.b64encode((raw / name).read_bytes()).decode()
    return f"data:image/jpeg;base64,{data}"

shots = {k: img(f"small{k}.jpg") for k in ["0", "1", "2", "3", "9"]}

slides = [
    dict(
        kicker="The problem",
        title="First-years don’t know what the Library<br>already gives them.",
        lead="Cameras, mics, podcasting, citation help, study rooms. All free to borrow. Almost nobody knows.",
        stat=("5 clicks", "across 2 websites to find a camera and its loan rule"),
        bullets=[
            "You can’t search for a service you don’t know exists.",
            "The website waits for you to know the words.",
        ],
        shot=shots["0"], caption="Find",
    ),
    dict(
        kicker="The answer",
        title="Put the answer on the<br>first screen.",
        lead="Search “camera”. The loan period and the pickup desk are on the row. No second tap, no second site.",
        stat=("1 tap", "from opening the app to the real answer"),
        bullets=[
            "Every service row carries its own rule.",
            "One tap opens the Library’s official page.",
        ],
        shot=shots["1"], caption="Borrow",
    ),
    dict(
        kicker="Why it’s different",
        title="It reaches you before<br>you know to look.",
        lead="Six swipe cards on day one. Swipe right and it lands in your plan. Ask answers only from verified Library facts, and names its source.",
        stat=("6 cards", "under a minute, on first launch"),
        bullets=[
            "Discover what you didn’t know existed.",
            "Answers grounded in uottawa.ca/library, with a link.",
        ],
        shot=shots["2"], caption="Ask",
    ),
    dict(
        kicker="Privacy and feasibility",
        title="Nothing to steal.",
        lead="No login, no student number, no name. One local table of saved services. Erase it and it’s gone.",
        stat=("1 table", "read-only public catalog, no backend, no accounts"),
        bullets=[
            "Encrypted by iOS when the phone is locked.",
            "Left out of device backups. One-tap erase.",
            "Links out to the Library’s real booking systems.",
        ],
        shot=shots["9"], caption="Your Data",
    ),
    dict(
        kicker="Why it wins",
        title="Fewer steps, and it ships<br>without new infrastructure.",
        lead="A running iOS app, not a mock-up. It works with the Library’s systems instead of replacing them.",
        stat=("0", "new servers required to launch"),
        bullets=[
            "Built and demoed today, at the Buildathon.",
            "Next: French strings, then a pilot with first-years.",
        ],
        shot=shots["3"], caption="My Plan",
    ),
]

css = """
@page { size: 1280px 720px; margin: 0 }
* { box-sizing: border-box; -webkit-font-smoothing: antialiased }
html, body { margin: 0; height: 100%; background: #101013; overflow: hidden }
body { font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", Arial, sans-serif; color: #111 }
.stage { position: fixed; inset: 0; display: grid; place-items: center }
.slide {
  width: 1280px; height: 720px; background: #f6f6f7; padding: 64px 72px;
  display: none; grid-template-columns: 1.05fr 0.95fr; gap: 56px; align-items: center;
  position: relative; overflow: hidden;
}
.slide.on { display: grid }
.kicker { font: 600 13px/1 ui-monospace, "SF Mono", Menlo, monospace; letter-spacing: .16em;
  text-transform: uppercase; color: #8f001a; margin-bottom: 22px }
h1 { font-size: 47px; line-height: 1.08; letter-spacing: -.022em; font-weight: 680; margin: 0 0 22px }
.lead { font-size: 20px; line-height: 1.5; color: #4b4b50; margin: 0 0 26px; max-width: 44ch }
.rule { height: 1px; background: #d8d8dc; margin: 0 0 22px }
.stat { display: flex; align-items: baseline; gap: 14px; margin-bottom: 22px }
.stat b { font-size: 40px; letter-spacing: -.03em; color: #8f001a; font-variant-numeric: tabular-nums }
.stat span { font-size: 15px; color: #55555b; max-width: 30ch; line-height: 1.4 }
ul { margin: 0; padding: 0; list-style: none }
li { font-size: 17.5px; line-height: 1.45; color: #2c2c31; padding-left: 22px; position: relative; margin-bottom: 11px }
li::before { content: ""; position: absolute; left: 0; top: .52em; width: 7px; height: 7px; border-radius: 2px; background: #8f001a }
.shot { position: relative; justify-self: center }
.shot img { height: 500px; width: auto; max-width: 100%; border-radius: 30px; display: block;
  box-shadow: 0 26px 60px rgba(16,16,19,.22), 0 0 0 1px rgba(0,0,0,.07) }
.tag { position: absolute; bottom: -34px; left: 0; right: 0; text-align: center;
  font: 500 12px/1 ui-monospace, Menlo, monospace; letter-spacing: .12em; text-transform: uppercase; color: #8a8a90 }
.foot { position: absolute; left: 72px; bottom: 30px; font: 400 12.5px/1.4 ui-monospace, Menlo, monospace; color: #8a8a90 }
.num { position: absolute; right: 40px; bottom: 26px; font: 500 12.5px/1 ui-monospace, Menlo, monospace; color: #a1a1a7 }
.brandline { position: absolute; top: 40px; right: 44px; font: 600 14px/1 -apple-system, sans-serif;
  letter-spacing: -.01em; color: #8f001a }
.cover { grid-template-columns: 1fr; text-align: left }
"""

def slide_html(s, i):
    bullets = "".join(f"<li>{b}</li>" for b in s["bullets"])
    return f"""
<section class="slide{' on' if i == 0 else ''}">
  <div class="copy">
    <div class="kicker">{s['kicker']}</div>
    <h1>{s['title']}</h1>
    <p class="lead">{s['lead']}</p>
    <div class="rule"></div>
    <div class="stat"><b>{s['stat'][0]}</b><span>{s['stat'][1]}</span></div>
    <ul>{bullets}</ul>
  </div>
  <div class="shot">
    <img src="{s['shot']}" alt="{s['caption']} screen">
    <div class="tag">{s['caption']}</div>
  </div>
  <div class="brandline">First Chapter</div>
  <div class="foot">Library facts verified from uottawa.ca/library on 4 Nov 2026. Click counts from page structure.</div>
  <div class="num">{i + 1} / {len(slides)}</div>
</section>"""

body = "".join(slide_html(s, i) for i, s in enumerate(slides))

html = f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<title>First Chapter — Library AI Buildathon pitch</title>
<style>{css}</style></head>
<body>
<div class="stage">{body}</div>
<script>
const slides = [...document.querySelectorAll('.slide')];
let i = 0;
function show(n) {{
  i = Math.max(0, Math.min(slides.length - 1, n));
  slides.forEach((s, k) => s.classList.toggle('on', k === i));
  location.hash = i + 1;
}}
addEventListener('keydown', e => {{
  if (['ArrowRight', 'ArrowDown', 'PageDown', ' '].includes(e.key)) {{ e.preventDefault(); show(i + 1); }}
  if (['ArrowLeft', 'ArrowUp', 'PageUp'].includes(e.key)) {{ e.preventDefault(); show(i - 1); }}
  if (e.key === 'Home') show(0);
  if (e.key === 'End') show(slides.length - 1);
  if (e.key === 'f') document.documentElement.requestFullscreen?.();
}});
addEventListener('click', e => show(e.clientX < innerWidth / 3 ? i - 1 : i + 1));
const scale = () => {{
  const k = Math.min(innerWidth / 1280, innerHeight / 720);
  document.querySelector('.stage').style.transform = `scale(${{k}})`;
}};
addEventListener('resize', scale); scale();
if (location.hash) show(parseInt(location.hash.slice(1)) - 1);
</script>
</body></html>
"""

out = root / "index.html"
out.write_text(html)
print(f"{out} — {out.stat().st_size/1024:.0f} KB, {len(slides)} slides")
