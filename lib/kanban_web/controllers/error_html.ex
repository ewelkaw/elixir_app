defmodule KanbanWeb.ErrorHTML do
  @moduledoc "Renders HTML error pages (404, 500, ...)."
  use KanbanWeb, :html

  # `Phoenix.Controller.status_message_from_template/1` turns "404.html" into
  # "Not Found". Default catch-all: render a plain status string.
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
