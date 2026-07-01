# AGENTS

## Cursor Cloud specific instructions

This repo is a single Node.js project (no build step) that runs **two Express apps** plus optional background parsers. Frontends are static HTML/JS served by Express.

- **Main auction analytics** — `server.js` → `http://localhost:3001` (serves `public/`).
- **Coin catalog & user collections** — `catalog-server.js` → `http://localhost:3000` (serves `catalog-public/`).
- Run scripts live in `package.json` (`npm start`, `npm run start:catalog`, `npm run dev`, `npm run dev:catalog`). `npm run dev*` uses `nodemon` for hot reload.
- There is **no test suite and no linter**: `npm test` is a no-op, and `npm run build` is just `npm install --production` (do NOT use it for dev). "Verifying" means running the servers and hitting endpoints.

### Database (most important, non-obvious)

- Every entry point does `require('./config')` and reads `config.dbConfig`. **`config.js` is committed to the repo** and currently ships **production Supabase credentials** (security smell — do not point local dev at it, and consider rotating/untracking).
- Production uses a hosted **Supabase** Postgres (see `env.example`). There is **no local DB in production**. `.env` / `dotenv` is largely unused by the running servers — they read `config.js` directly.
- For a self-contained dev environment in the cloud VM, **overwrite `config.js`** to point at a **local PostgreSQL** with `ssl: false` (keep this change local — do not commit it, or you will overwrite the tracked production config).
- The DB schema has drifted from the `CREATE TABLE` statements scattered in the parser/service files (e.g. `auction_lots.weight`, `coin_catalog.country`, and the `lot_price_predictions` table are queried but not in those old CREATEs). A reconstructed local schema + seed lives at `db/local-dev-schema.sql`. It is derived from the actual queries in `server.js`, `catalog-server.js`, `auth-service.js`, `collection-service.js`. If you hit a `column ... does not exist` error, add the column there and reload — do not assume the query is wrong.

### One-time local dev setup (fresh VM; not part of the update script)

The update script only runs `npm install`. Postgres + config + seed are a one-time setup per VM:

```
sudo pg_ctlcluster 16 main start
sudo -u postgres psql -c "CREATE ROLE wolmar WITH LOGIN PASSWORD 'wolmar' CREATEDB;"
sudo -u postgres psql -c "CREATE DATABASE wolmar_auctions OWNER wolmar;"
```

Then create `config.js` from `config.example.js` pointing at `localhost:5432`, db `wolmar_auctions`, user/password `wolmar`, `ssl: false`, and load the schema:

```
PGPASSWORD=wolmar psql -h localhost -U wolmar -d wolmar_auctions -f db/local-dev-schema.sql
```

Seeded demo login for the catalog app: **`demo_user` / `demopass123`**.

### Running the apps

Start each server in its own persistent shell (they block):

```
node server.js          # main site on :3001
node catalog-server.js  # catalog on :3000
```

Note: `nodemon`/hot-reload restarts Node code, but schema/seed changes require reloading `db/local-dev-schema.sql` manually.

### Parsers (optional, usually out of scope)

`wolmar-parser5.js`, `catalog-parser.js`, prediction generators, etc. use **Puppeteer** and scrape `wolmar.ru` / `cbr.ru`. They need a real Chrome and external network. The update script sets `PUPPETEER_SKIP_DOWNLOAD=true`, so Chromium is not installed — install Chrome and set `CHROME_PATH` if you need to run parsers.
