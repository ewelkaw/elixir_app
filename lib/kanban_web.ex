defmodule KanbanWeb do
  @moduledoc """
  Helper module that defines what `use KanbanWeb, :controller`, `:live_view`,
  `:html`, etc. expand into.

  This pattern is unique to Phoenix and unfamiliar to Python devs:
  instead of importing the same 10 helpers into every file, you write
  `use KanbanWeb, :live_view` and get them all. It's a *macro-driven mixin*.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: KanbanWeb.Layouts]

      import Plug.Conn
      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView, layout: {KanbanWeb.Layouts, :app}
      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent
      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component
      import Phoenix.Controller, only: [get_csrf_token: 0, view_module: 1, view_template: 1]
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # `quote do ... end` constructs an AST fragment. `unquote/1` inserts a
      # value into the AST. This is Elixir's macro system — the closest Python
      # equivalent is writing code with `ast` + `compile`, but here it's idiomatic.
      use Phoenix.HTML
      import Phoenix.LiveView.Helpers
      import KanbanWeb.CoreComponents
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: KanbanWeb.Endpoint,
        router: KanbanWeb.Router,
        statics: KanbanWeb.static_paths()
    end
  end

  # `__using__/1` is the callback that runs when another module writes
  # `use KanbanWeb, :live_view`. Pattern matching dispatches to the right block.
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
