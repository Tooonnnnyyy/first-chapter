# Security policy

First Chapter is an early-stage project. The experimental server is not yet ready for an internet-facing production deployment. OAuth, session expiry, rate limits, complete account deletion and community moderation remain release blockers.

## Reporting

Use [GitHub private vulnerability reporting](https://github.com/Tooonnnnyyy/first-chapter/security/advisories/new). Do not open a public issue containing credentials, student data, exploit details or private infrastructure information. If private reporting is unavailable, open a minimal issue asking a maintainer to enable it without including sensitive details.

Include the affected version/commit, reproduction steps, impact, and a proposed fix if available. Reports are handled on a best-effort volunteer basis; there is no guaranteed response time or paid bounty.

## Supported versions

Only the latest `main` and newest prerelease receive fixes. There is no stable production release yet. Earlier prototype archives receive no feature development.

## Secrets and data

Never commit `.env`, `Secrets.plist`, tokens, databases or student records. A client-bundled API key is extractable; use server-side secrets for any shared application. AI redaction is best effort, not an anonymity guarantee.

See [privacy and data boundaries](docs/architecture/overview.md) for the current implementations.
