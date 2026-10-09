# oxzoo-ruby-react

Deployed with [ox](https://deploywithox.com): deploy a repo to your own server with one command, no Docker. [Docs](https://deploywithox.com/docs) · [Stack guides](https://deploywithox.com/docs/guides)

An [ox](https://deploywithox.com) deploy example: a Sinatra 4 API on puma with a React 18 SPA built by Vite, deployed to your own Ubuntu server. ox installs Ruby and Node, runs `bundle install` into the release's own `vendor/bundle`, builds the SPA, and runs puma under systemd; Caddy serves the built SPA with an `index.html` fallback while sending only `/api` and `/health` to puma.

For a full Rails app (Solid Queue, PostgreSQL), see [oxzoo-live-rails-queue](https://github.com/saurav-codes/oxzoo-live-rails-queue) and the [Rails guide](https://deploywithox.com/docs/guides/rails).

## Stack

| Layer | Tool | Role |
|---|---|---|
| Frontend | React 18 + Vite 5 | SPA built to `dist/` from `client/` |
| API | Sinatra 4.2 on puma 6.6 | `GET /api/greeting` and `GET /health` |
| Ruby | 3.4.11 | declared in `[tools]`; gems pinned in `Gemfile.lock` |
| Node | 24 | `package-lock.json` is committed |

## ox.toml

```toml
# Sinatra API on puma (bundler) + React SPA (npm) in one repo.

[app]
start  = "bundle exec puma -b tcp://127.0.0.1:$PORT config.ru"
health = "/health"

[static]
dir = "dist"
spa = true
api = ["/api", "/health"]

[build]
commands = ["bundle config set --local deployment true && bundle install", "npm run build"]

[tools]
ruby = "3.4.11"
node = "24"
```

The repo has two languages, so `[build] commands` names both: `npm ci` is detected from `package-lock.json` and runs first, then the gems and the SPA build.

## Environment flow

- **Run time (API):** `app.rb` reads `GREETING_TAG` with `ENV.fetch` on every `GET /api/greeting`.
- **Build time (SPA):** `vite.config.js` sets `envPrefix: ["GREETING_", "VITE_"]`, so `client/src/App.jsx` reads `import.meta.env.GREETING_TAG` and Vite bakes it into `dist/`. ox sets your variables before the build, and changing one with `ox vars set` redeploys, which rebuilds the SPA.
- **Host check:** Sinatra 4 rejects unknown `Host` headers, so `app.rb` permits `PUBLIC_HOST`, which ox provides, plus `127.0.0.1` and `localhost`.

## Deploy with ox

```sh
curl -fsSL https://deploywithox.com/install.sh | sh
ox login
ox new https://github.com/saurav-codes/oxzoo-ruby-react
printf 'GREETING_TAG=demo\n' | ox review oxzoo-ruby-react --from-file - --wait
```

The plan, offline:

```console
$ ox check .
ox check . (manifest: ox.toml)

  app.start                  bundle exec puma -b tcp://127.0.0.1:$PORT config.ru  declared
  app.health                 /health                                              declared
  static.dir                 dist                                                 declared
  static.spa                 true                                                 declared
  static.api                 /api, /health                                        declared
  build.install              npm ci                                               detected:package-lock.json
  build.commands[0]          bundle config set --local deployment true && bundle install declared
  build.commands[1]          npm run build                                        declared
  tools.node                 24                                                   declared
  tools.ruby                 3.4.11                                               declared

  Provided by ox: PORT, HOST, OX_ENV, OX_PROJECT, OX_RELEASE, OX_DATA_DIR, PUBLIC_URL, PUBLIC_HOST
  Set on the dashboard before the first deploy: GREETING_TAG

Ready to deploy.
```

## Expected output

```
oxzoo-ruby-react
frontend: hello world oxzoo-ruby-react_<GREETING_TAG>
backend: hello world oxzoo-ruby-react_<GREETING_TAG>
```

## Local development

```sh
npm ci && GREETING_TAG=dev npm run build
bundle install
GREETING_TAG=dev bundle exec puma -b tcp://127.0.0.1:9111 config.ru
```
