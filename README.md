# oxzoo-ruby-react

Official ox deploy example for a Ruby stack: a Sinatra 4 text API served by Puma 6 plus a React 18 single-page app built with Vite 5, deployed from one `ox.toml` manifest onto a single Ubuntu VPS. nginx serves the built SPA from `dist/` and proxies the `/api` and `/health` prefixes to the Puma process on `127.0.0.1:9111`.

## Stack

| Layer      | Tool                                    | Pinned version            |
| ---------- | --------------------------------------- | ------------------------- |
| Backend    | Ruby (apt `ruby-full`) + Sinatra        | sinatra 4.2.1             |
| App server | Puma                                    | puma 6.6.1                |
| Rack       | rack / rackup                           | rack 3.2.7, rackup 2.3.1  |
| Frontend   | React + Vite (npm)                      | react 18.3.1, react-dom 18.3.1, vite 5.4.21, @vitejs/plugin-react 4.7.0 |
| Runtime    | systemd + nginx via ox, port 9111       | NodeSource node_22.x      |

## Environment flow

- **Backend reads `GREETING_TAG` at runtime.** `app.rb` calls `ENV.fetch("GREETING_TAG")` on every request, so the value comes from the project's environment file (`/etc/ox/apps/oxzoo-ruby-react.env`). A missing variable raises loudly instead of printing `hello world oxzoo-ruby-react_`.
- **Frontend bakes `GREETING_TAG` at build time.** `client/src/App.jsx` builds the string from one template literal, `` `frontend: hello world oxzoo-ruby-react_${import.meta.env.GREETING_TAG}` ``, and `vite.config.js` sets `envPrefix: ["GREETING_", "VITE_"]` so Vite inlines the variable when `npm run build` runs. Changing the tag re-bakes the frontend on the next deploy.
- **Dependencies stay inside the repo.** Deploy hooks run as the unprivileged project user, so nothing is installed globally: `bundle config set --local path vendor/bundle` makes `bundle install` place gems in `vendor/bundle` inside the release, and `npm install` is local to the release too.
- **No committed `Gemfile.lock`** (or `package-lock.json`): tooling differs between machines, so the server-side `bundle install` resolves from the manifest. Every direct gem and npm package is pinned to an exact version, which keeps installs deterministic.
- **Host authorization.** Sinatra 4 enables `Rack::Protection::HostAuthorization` by default and only permits localhost Host headers, so `app.rb` explicitly authorizes the deploy domain (`set :host_authorization, ...`). Without it, every request nginx proxies with a real `Host` header gets a `403 attack prevented` response, while localhost probes (health checks) still pass.

## Deploy with ox

1. Create a project in the ox dashboard and paste the clone URL: `https://github.com/saurav-codes/oxzoo-ruby-react.git`.
2. In the project's Environment editor, set `GREETING_TAG` (for example `w2-01`) **before the first deploy**. The backend reads it from the environment file at runtime, and the frontend build bakes it into the bundle.
3. Press **Deploy**. ox installs `nodejs` (NodeSource), `ruby-full`, and `bundler`, runs the install hooks (`bundle config set --local path vendor/bundle`, `bundle install`, `npm install`), builds the SPA (`npm run build`), starts Puma on `127.0.0.1:9111`, and waits for `GET /health` to return `ok`.

## Expected output

With `GREETING_TAG=<your-tag>` set in the Environment editor, the page shows two labeled lines:

```
frontend: hello world oxzoo-ruby-react_<your-tag>
backend: hello world oxzoo-ruby-react_<your-tag>
```

The frontend line is baked into the bundle at build time; the backend line comes from `GET /api/greeting`, which returns `hello world oxzoo-ruby-react_<your-tag>` as `text/plain` and is re-read from the environment on every request.
