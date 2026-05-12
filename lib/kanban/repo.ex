defmodule Kanban.Repo do
  @moduledoc """
  The database repository.

  Ecto's Repo is roughly equivalent to SQLAlchemy's `Session` + engine combined,
  but as a *supervised process*. Instead of `session.add(obj); session.commit()`,
  you write `Repo.insert(changeset)` — Repo is stateless from the caller's view
  and uses an internal connection pool transparently.
  """

  # `use Ecto.Repo` again is metaprogramming — it generates a full Repo API
  # (`insert/2`, `all/1`, `get/2`, `update/2`, `delete/2` …) into this module.
  use Ecto.Repo,
    otp_app: :kanban,
    adapter: Ecto.Adapters.Postgres
end
