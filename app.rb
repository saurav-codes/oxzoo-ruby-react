# frozen_string_literal: true

require "sinatra"

set :bind, "127.0.0.1"

get "/health" do
  "ok"
end

get "/api/greeting" do
  content_type "text/plain"
  "hello world oxzoo-ruby-react_#{ENV.fetch("GREETING_TAG")}"
end
