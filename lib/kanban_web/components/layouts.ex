defmodule KanbanWeb.Layouts do
  @moduledoc """
  Hosts the page layouts. `root.html.heex` wraps every response; `app.html.heex`
  wraps LiveView content inside the root. Same idea as Django's base templates
  extended via `{% extends %}`.
  """

  use KanbanWeb, :html

  # `embed_templates` finds .heex files next to this module and turns each into
  # a function. So `layouts/root.html.heex` becomes `Layouts.root/1`.
  embed_templates "layouts/*"
end
