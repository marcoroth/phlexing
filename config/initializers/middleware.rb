# frozen_string_literal: true

server_name = ENV["PHLEXING_HOST"] || "www.phlexing.fun"

if server_name && !Rails.env.development?
  Rails.application.config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do
    r301(/.*/, "https://#{server_name}$&", if: proc { |rack_env| rack_env["SERVER_NAME"] != server_name })
  end
end
