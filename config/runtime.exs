import Config

# `runtime.exs` runs at boot, both in dev and prod releases — analogous to
# reading env vars in a Python app's `settings.py` at import time, but here
# the build phase and the runtime phase are intentionally separate.

if System.get_env("PHX_SERVER") do
  config :kanban, KanbanWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  # `||` here is the "falsy" or — Elixir treats `nil` and `false` as falsy and
  # everything else (including 0 and "") as truthy.
  config :kanban, Kanban.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise "environment variable SECRET_KEY_BASE is missing."

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :kanban, KanbanWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [ip: {0, 0, 0, 0, 0, 0, 0, 0}, port: port],
    secret_key_base: secret_key_base
end
