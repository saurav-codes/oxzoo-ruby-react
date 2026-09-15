# frozen_string_literal: true

require "sinatra"

set :bind, "127.0.0.1"
set :environment, :production

# Sinatra 4 enables Rack::Protection::HostAuthorization by default and only
# permits localhost Host headers; authorize the deploy domain or every
# request proxied by nginx with a real Host gets a 403.
set :host_authorization, { permitted_hosts: ["ruby-react.oxzoo.sorv.dev", "127.0.0.1"] }

get "/health" do
  "ok"
end

get "/api/greeting" do
  content_type "text/plain"
  "hello world oxzoo-ruby-react_#{ENV.fetch("GREETING_TAG")}"
end
