# Seeds — run with `mix run priv/repo/seeds.exs`. Idempotent: only seeds if empty.

alias Kanban.Boards

if Boards.list_cards() == [] do
  # `Enum.each/2` is like a Python `for ... in ...:` loop without comprehensions.
  Enum.each(
    [
      %{title: "Read the README", description: "Start here!", status: "todo", position: 0},
      %{title: "Learn pattern matching", status: "todo", position: 1},
      %{title: "Try a LiveView edit", status: "doing", position: 0},
      %{title: "Set up Docker", status: "done", position: 0}
    ],
    fn attrs ->
      # Underscore-prefixed names tell the compiler "I'm intentionally
      # ignoring this binding" — like `_unused` in Python.
      {:ok, _card} = Boards.create_card(attrs)
    end
  )
end
