# ADR 0001: maintainable open-source foundation

Status: accepted for repository setup, 2026-11-04. Product migrations remain proposals until implemented and checked.

- **MIT:** the owner selected a permissive license. Attribution and the license notice travel with copies; third-party brands/content keep their own rights.
- **Keep current source paths:** active native/web/server branches depend on them. Organize documentation by language and purpose now; defer disruptive code moves.
- **Local clients plus separate experimental server:** document both honestly. Do not silently migrate student data or imply OAuth works because tables exist.
- **SQLite and Node 24:** a single process with built-in storage minimizes dependencies for current scope. Before multiple replicas or production traffic, define migrations, backup/restore, concurrency and retention.
- **Explainable ranking:** the existing server uses explicit catalog/plan rules and returns a reason for each result. No additional model or semantic service is introduced by this foundation.
- **README owns usage:** no pitch deck, rehearsal scripts or duplicate getting-started pages. French and Chinese README translations provide the same entry point.
- **CI before integration:** PR checks validate source, API behavior and native compilation. Maintainers distinguish these from UI, hosted-site and production-security verification.
- **Packages only where useful:** the experimental server may be built as an opt-in GHCR container; the Swift app/root workspace are not npm packages. Publishing an image is not deploying it.
