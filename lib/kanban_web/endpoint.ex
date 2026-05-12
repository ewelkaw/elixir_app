defmodule KanbanWeb.Endpoint do
  @moduledoc """
  The HTTP entry point — equivalent to a WSGI app object in Python plus a
  middleware stack (Plug pipeline). It's a supervised process that owns the
  socket and routes every incoming request through `plug` calls below.
  """

  use Phoenix.Endpoint, otp_app: :kanban

  # Session cookie config. `signing_salt` is read at compile time;
  # `secret_key_base` is configured per environment.
  @session_options [
    store: :cookie,
    key: "_kanban_key",
    signing_salt: "kanbanSS",
    same_site: "Lax"
  ]

  # LiveView WebSocket — clients connect here for real-time updates.
  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve static assets in dev. `from: :kanban` looks in priv/static of this app.
  plug Plug.Static,
    at: "/",
    from: :kanban,
    gzip: false,
    only: KanbanWeb.static_paths()

  # Code reloader for dev — recompiles touched files between requests.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :kanban
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  # Parse incoming request bodies (JSON, urlencoded, multipart) — like Django
  # middleware that fills `request.POST`/`request.body`.
  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug KanbanWeb.Router
end
