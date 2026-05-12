defmodule Kanban.Boards.Card do
  @moduledoc """
  An Ecto schema — Elixir's equivalent of a SQLAlchemy / Django model.

  Big difference: a `%Card{}` is just an *immutable struct* (a tagged map),
  not a "live" ORM object. There's no `card.save()`. To change one you create
  a *changeset* (a value describing the change + validation results) and pass
  it to the Repo. This separation is what makes Ecto so testable.
  """

  # `use Ecto.Schema` injects the `schema/2` and `field/3` macros below.
  use Ecto.Schema

  # `import` makes another module's functions callable without prefix.
  # Compare to Python's `from module import name`.
  import Ecto.Changeset

  # Module attributes — written `@name value`. At compile time, every reference
  # to `@name` is replaced with `value` (like a Python class-level constant,
  # but resolved at compile time, not by `self.`).
  @statuses ~w(todo doing done)

  # `schema "cards"` declares fields mapped to the `cards` SQL table.
  # `id` is auto-generated. `inserted_at`/`updated_at` come from `timestamps()`.
  schema "cards" do
    field :title, :string
    field :description, :string
    field :status, :string, default: "todo"
    # `position` lets cards be ordered within a column.
    field :position, :integer, default: 0

    # `timestamps/0` adds `inserted_at` and `updated_at` columns automatically.
    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset for inserting/updating a Card.

  In Python you might validate inside `__init__` or `Pydantic`. In Ecto,
  validation is a pure data transformation: `(struct, params) -> changeset`,
  which is easy to test and compose.
  """
  # The `|>` operator is the "pipe". `x |> f(a)` is rewritten to `f(x, a)`.
  # It's like Unix pipes for function calls. Closest Python analogue: the
  # `toolz.pipe` helper, but here it's first-class syntax.
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:title, :description, :status, :position])
    |> validate_required([:title])
    |> validate_length(:title, min: 1, max: 200)
    |> validate_inclusion(:status, @statuses)
  end

  # A simple public accessor for the allowed statuses — used by the UI.
  def statuses, do: @statuses
end
