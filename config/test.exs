import Config

config :kanban, Kanban.Repo,
  username: System.get_env("DATABASE_USER", "postgres"),
  password: System.get_env("DATABASE_PASSWORD", "postgres"),
  hostname: System.get_env("DATABASE_HOST", "localhost"),
  database: "kanban_test#{System.get_env("MIX_TEST_PARTITION")}",
  # The SQL sandbox wraps each test in a transaction that is rolled back —
  # like pytest-django's `--reuse-db` + transactional tests.
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :kanban, KanbanWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test-secret-key-base-must-be-at-least-sixty-four-characters-long!",
  server: false

config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime
