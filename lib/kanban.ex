# The "root" module. By convention, the project's top-level module is just a
# docstring host. Notice modules have no class-style hierarchy in Elixir —
# `Kanban` and `Kanban.Repo` are two independent modules whose names happen
# to share a prefix.
defmodule Kanban do
  @moduledoc """
  Business domain root. In Phoenix this layer is called a "context" —
  conceptually similar to a Django app's `models` + `services` modules,
  but with stricter boundaries: web code (controllers, LiveViews) is
  supposed to call *only* into these context modules, not into Ecto
  schemas directly.
  """
end
