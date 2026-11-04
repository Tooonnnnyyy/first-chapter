# GeeGuide Web prototype archive

This is the earlier React/SQLite prototype created before development converged on the native First Chapter app. It is retained to preserve unique source work during local storage cleanup. The current maintained web app is `../../web/`; this archive is not the production deployment.

## Run locally

Requires Node 24 or later.

```sh
npm ci
npm test
npm run build
npm start
```

Production preview: `http://127.0.0.1:4173`. Development: `npm run dev` (Vite 5173, API 4174).

The SQLite catalog is generated from `data/catalog.json`. Saved plans stay in browser localStorage. No accounts or live AI integration. Official Library systems own reservations and availability.

## Verification

On 2026-11-04, five catalog/API/state tests passed and the TypeScript/Vite production build passed before archiving. Browser verification remained blocked by saved browser permissions; no browser-validation claim is made.

## Not retained

Installed dependencies, generated SQLite files, build output, TypeScript caches, downloaded copies of full official web pages, and requirement photos. Catalog source URLs and checked date are retained in `data/catalog.json`; the main project has the requirements and verified Library facts.
