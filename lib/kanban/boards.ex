defmodule Kanban.Boards do
  @moduledoc """
  The "Boards" context — Phoenix's recommended way of grouping business logic.

  ## Comparing to Python
  Think of a context module as a Django app's `services.py` or a "use case"
  layer in clean architecture. Everything above (LiveViews, controllers) calls
  *only* into this module. The schema (Card) is an internal detail.
  """

  # `alias` is like Python's `from x.y import Z` — `Kanban.Boards.Card` becomes
  # just `Card` in this module's scope.
  alias Kanban.Repo
  alias Kanban.Boards.Card

  # `import Ecto.Query` brings in macros like `from`, `where`, `order_by`.
  # Ecto queries look declarative but are compiled into safe SQL.
  import Ecto.Query

  @topic "cards"

  @doc "Subscribe the current process to broadcasts about card changes."
  # PubSub is a *publish/subscribe* mechanism. Each LiveView process subscribes
  # so it can re-render when *another* process (another browser session) edits
  # a card. There's no Python stdlib equivalent — closest analogue would be
  # Django Channels + Redis, but here it's an in-memory ETS table.
  def subscribe do
    Phoenix.PubSub.subscribe(Kanban.PubSub, @topic)
  end

  @doc "Return all cards, oldest-first within each column."
  def list_cards do
    # `from c in Card` is an Ecto query expression. Variables inside `where:`
    # are interpolated at compile time with proper escaping — no SQL injection.
    from(c in Card, order_by: [asc: c.position, asc: c.inserted_at])
    |> Repo.all()
  end

  @doc """
  Group cards by status, returning a map like:
      %{"todo" => [...], "doing" => [...], "done" => [...]}
  """
  def list_cards_by_status do
    # `Enum.group_by/2` is like Python's `itertools.groupby` but doesn't
    # require pre-sorted input — closer to `collections.defaultdict(list)`.
    grouped = list_cards() |> Enum.group_by(& &1.status)

    # `Enum.reduce/3` = Python's `functools.reduce`. Here we make sure every
    # status key exists, even if there are no cards in that column.
    Enum.reduce(Card.statuses(), %{}, fn status, acc ->
      Map.put(acc, status, Map.get(grouped, status, []))
    end)
  end

  @doc "Fetch one card by id; raises if not found."
  def get_card!(id), do: Repo.get!(Card, id)

  @doc "Create a card from a plain map of attributes."
  def create_card(attrs \\ %{}) do
    # `\\` provides a default argument value — like Python's `def f(x=None):`.
    %Card{}
    |> Card.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:card_created)
  end

  @doc "Update a card's attributes."
  def update_card(%Card{} = card, attrs) do
    # Pattern match `%Card{} = card` in the parameter asserts the caller passed
    # a Card struct, not just any map. The compiler/runtime will refuse other
    # shapes — no need for `isinstance(card, Card)` guards.
    card
    |> Card.changeset(attrs)
    |> Repo.update()
    |> broadcast(:card_updated)
  end

  @doc "Move a card to a new status (kanban column)."
  def move_card(%Card{} = card, new_status) do
    update_card(card, %{status: new_status})
  end

  @doc "Delete a card."
  def delete_card(%Card{} = card) do
    card
    |> Repo.delete()
    |> broadcast(:card_deleted)
  end

  @doc "Build an empty changeset, used to render the 'new card' form."
  def change_card(%Card{} = card, attrs \\ %{}) do
    Card.changeset(card, attrs)
  end

  # Private helper for broadcasting after a successful write.
  # Pattern matches on the `{:ok, _}` success tuple and ignores `{:error, _}`.
  defp broadcast({:ok, card} = result, event) do
    Phoenix.PubSub.broadcast(Kanban.PubSub, @topic, {event, card})
    result
  end

  defp broadcast({:error, _changeset} = error, _event), do: error
end
