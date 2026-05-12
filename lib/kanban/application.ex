defmodule Kanban.Application do
  @moduledoc """
  The OTP application entry point.

  ## Comparing to Python
  In Python an app starts when you run a script — top-level code executes top-down.
  An Elixir/OTP app instead starts a *supervision tree*: a tree of long-running
  processes where parents monitor children and restart them on crashes.
  Think of it as if every singleton service in your Django app were a separately
  supervised daemon with automatic restart, and "let it crash" was a design goal.
  """

  # `@moduledoc false` would hide docs; `use Application` injects the Application
  # behaviour callbacks. A *behaviour* is Elixir's interface concept (similar to
  # a Python abc.ABC / Protocol — a contract of required callback functions).
  use Application

  # `@impl true` says "this function implements a callback from the behaviour".
  # The compiler verifies the function signature matches.
  @impl true
  def start(_type, _args) do
    # `children` is the list of supervised processes. Each tuple/atom describes
    # one child the supervisor should start and monitor.
    children = [
      # Telemetry — emits & aggregates runtime metrics.
      KanbanWeb.Telemetry,
      # The Ecto Repo — owns the database connection pool.
      Kanban.Repo,
      # `{module, opts}` is how you pass start options. `Phoenix.PubSub` is the
      # in-process message bus used by LiveView for real-time updates.
      {Phoenix.PubSub, name: Kanban.PubSub},
      # The HTTP endpoint (web server). Put last so DB is up before it accepts.
      KanbanWeb.Endpoint
    ]

    # `:one_for_one` strategy: if a child crashes, only that child is restarted.
    # Other strategies (`:one_for_all`, `:rest_for_one`) restart siblings too.
    opts = [strategy: :one_for_one, name: Kanban.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Called when config changes. Phoenix uses this for hot config reloads.
  @impl true
  def config_change(changed, _new, removed) do
    KanbanWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
