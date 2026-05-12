import Config

# Database config. `System.get_env/2` with a default is the Elixir equivalent of
# Python's `os.environ.get("KEY", "default")`.
config :kanban, Kanban.Repo,
  username: System.get_env("DATABASE_USER", "postgres"),
  password: System.get_env("DATABASE_PASSWORD", "postgres"),
  hostname: System.get_env("DATABASE_HOST", "localhost"),
  database: "kanban_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :kanban, KanbanWeb.Endpoint,
  # `~w()` is a sigil — a special literal. `~w(a b c)` returns the list of
  # strings ["a", "b", "c"]. Sigils are like Python's `r""` raw-string idea
  # but extensible: you can define your own (~MY_SIGIL).
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "dev-secret-key-base-must-be-at-least-sixty-four-characters-long!!",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:kanban, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:kanban, ~w(--watch)]}
  ]

# LiveReload watches files and hot-reloads the browser in dev.
config :kanban, KanbanWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/kanban_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :logger, :console, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
