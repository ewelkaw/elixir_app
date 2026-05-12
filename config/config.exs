# `import Config` brings in the `config/2` macro. In Python you might use
# environment-aware settings modules; here Mix evaluates these files at
# compile time (config.exs) or boot time (runtime.exs) to build app config.
import Config

# Each `config :app_name, key: value` line writes into a global, compile-time
# application environment — think of it like a typed `os.environ` per-app.
config :kanban,
  ecto_repos: [Kanban.Repo],
  generators: [timestamp_type: :utc_datetime]

# Endpoint = the HTTP server config. Phoenix's endpoint is somewhat analogous
# to a Django `wsgi.py` + middleware stack, but it's a *supervised process*.
config :kanban, KanbanWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: KanbanWeb.ErrorHTML, json: KanbanWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Kanban.PubSub,
  live_view: [signing_salt: "kanban-salt-dev-only"]

# Configure esbuild (JS bundler) — version pinned, args declared.
config :esbuild,
  version: "0.17.11",
  kanban: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (CSS framework via Elixir wrapper, no Node needed).
config :tailwind,
  version: "3.4.0",
  kanban: [
    args: ~w(--config=tailwind.config.js --input=css/app.css --output=../priv/static/assets/app.css),
    cd: Path.expand("../assets", __DIR__)
  ]

# Logger config — Elixir has a built-in structured Logger akin to Python's
# `logging` module, but message dispatch is async by default.
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# JSON library used by Phoenix.
config :phoenix, :json_library, Jason

# `import_config` merges another file — like Python's settings/local.py pattern.
import_config "#{config_env()}.exs"
