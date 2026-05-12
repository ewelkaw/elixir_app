defmodule Kanban.Repo.Migrations.CreateCards do
  # Migrations in Ecto are like Alembic / Django migrations. The `change/0`
  # callback is reversible: Ecto auto-derives `down` from `up` for most ops.
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :title, :string, null: false
      add :description, :text
      add :status, :string, null: false, default: "todo"
      add :position, :integer, null: false, default: 0

      # `timestamps/1` adds `inserted_at` + `updated_at` automatically.
      timestamps(type: :utc_datetime)
    end

    create index(:cards, [:status, :position])
  end
end
