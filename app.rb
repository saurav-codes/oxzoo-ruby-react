# frozen_string_literal: true

require "sinatra"

set :bind, "127.0.0.1"
set :environment, :production

# Sinatra 4 enables Rack::Protection::HostAuthorization by default and only
# permits localhost Host headers. Caddy passes the real Host, so authorize
# PUBLIC_HOST, the address ox provides, or every request gets a 403.
set :host_authorization, { permitted_hosts: [ENV["PUBLIC_HOST"], "127.0.0.1", "localhost"].compact }

get "/health" do
  "ok"
end

get "/api/greeting" do
  content_type "text/plain"
  "hello world oxzoo-ruby-react_#{ENV.fetch("GREETING_TAG")}"
end
