import Config

# Production-only compile-time settings. Most prod config lives in runtime.exs
# so it can read env vars at boot, not at build time.
config :kanban, KanbanWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"
config :logger, level: :info
