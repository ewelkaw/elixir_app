defmodule KanbanWeb.Router do
  @moduledoc """
  Defines URL → handler routing. Conceptually identical to Django's `urls.py`
  or Flask's `@app.route`, but laid out as *pipelines* you compose per scope.
  """

  use KanbanWeb, :router

  # A pipeline = an ordered list of plugs to run on a request. Compare to
  # Django middleware, but scoped: different URL groups can use different sets.
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {KanbanWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", KanbanWeb do
    pipe_through :browser

    # `live "/"` mounts a LiveView at `/`. The atom `:index` is the action.
    live "/", BoardLive, :index
  end
end
