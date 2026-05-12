# Kanban — A Tiny Phoenix LiveView App for Python Developers

A minimal Kanban board (To Do / Doing / Done) built with **Elixir**, **Phoenix
LiveView**, **Ecto**, and **Postgres**. Every Elixir file is heavily annotated
with comments comparing the concepts to **Python** equivalents so you can pick
up the ideas without leaving familiar mental models behind.

## Running it

```bash
docker compose up --build
```

Then open <http://localhost:4000>. The first start runs migrations and seeds
four example cards.

> The compose file uses `Dockerfile.dev` for an iteration-friendly setup
> (source bind-mounted, hot reload). The root `Dockerfile` builds a slim
> production release.

## Concept tour (Python ↔ Elixir)

| Python idea                         | Elixir/Phoenix counterpart                  | Where to look |
|-------------------------------------|---------------------------------------------|----|
| `class` (namespace)                 | `defmodule`                                 | every `.ex` file |
| `def`                               | `def` / `defp` (private)                    | `lib/kanban/boards.ex` |
| `@staticmethod` / `singledispatch`  | Pattern-matched function clauses            | `lib/kanban/boards.ex`, `core_components.ex` |
| `functools.reduce`                  | `Enum.reduce/3`                             | `lib/kanban/boards.ex` |
| `dict`                              | `Map` (`%{key: value}`)                     | everywhere |
| `Enum` / interned strings           | Atoms (`:ok`, `:error`)                     | everywhere |
| Pydantic validation                 | Ecto Changesets                             | `lib/kanban/boards/card.ex` |
| SQLAlchemy `Session`                | `Ecto.Repo`                                 | `lib/kanban/repo.ex` |
| Django app `services.py`            | A Phoenix "context"                         | `lib/kanban/boards.ex` |
| ABC / Protocol                      | A behaviour (`use Application`, etc.)       | `lib/kanban/application.ex` |
| Decorators / mixins                 | `use Module` (compile-time code injection)  | `lib/kanban_web.ex` |
| `from x import y`                   | `alias` / `import`                          | top of most files |
| Celery worker tree                  | OTP supervision tree                        | `lib/kanban/application.ex` |
| Django Channels + Redis             | `Phoenix.PubSub` (in-process)               | `lib/kanban/boards.ex` |
| `os.environ.get`                    | `System.get_env/2`                          | `config/runtime.exs` |
| HTMX / Hotwire                      | Phoenix **LiveView**                        | `lib/kanban_web/live/board_live.ex` |
| Jinja2 templates                    | HEEx (`~H""" """`)                          | LiveView + components |
| Alembic / Django migrations         | Ecto migrations                             | `priv/repo/migrations/` |
| pytest fixtures                     | `Ecto.Adapters.SQL.Sandbox`                 | `config/test.exs` |
| `black`                             | `mix format` (config in `.formatter.exs`)   | `.formatter.exs` |

### A few "feels different" things to look at

1. **Immutability everywhere.** `card = %{card | title: "new"}` does NOT
   mutate `card`; it builds a new map. There is no shared mutable state.
2. **The pipe operator (`|>`).** `data |> step1() |> step2()` reads
   left-to-right like a Unix pipeline. See `Boards.create_card/1`.
3. **Tagged tuples for results.** Almost every function returns
   `{:ok, value}` or `{:error, reason}`. Pattern matching on these tuples
   (`case ... do ... end`) replaces try/except as the default control flow
   for expected failures.
4. **Processes, not threads.** A LiveView is a server-side process that
   lives as long as the browser tab. PubSub messages between processes are
   how multiple tabs stay in sync (see `Boards.subscribe/0`).
5. **Macros and `use`.** When you see `use Phoenix.LiveView`, treat it as a
   "powerful mixin": it injects functions and callbacks at compile time.

## File tour

```
lib/
  kanban.ex                       # business root (docstring host)
  kanban/
    application.ex                # supervision tree — boot order
    repo.ex                       # Ecto repo (DB session)
    boards.ex                     # context: the public business API
    boards/card.ex                # schema + changeset (model + validation)
  kanban_web.ex                   # macro hub for use KanbanWeb, :live_view
  kanban_web/
    endpoint.ex                   # HTTP entry point (Plug pipeline)
    router.ex                     # URL routing
    telemetry.ex                  # metrics
    live/board_live.ex            # the LiveView itself
    components/                   # HEEx layouts & function components
    controllers/                  # JSON/HTML error renderers
priv/repo/
  migrations/                     # Ecto migrations
  seeds.exs                       # initial data
config/                           # env-specific config
assets/                           # CSS (Tailwind) + JS (LiveView client)
Dockerfile                        # production release image
Dockerfile.dev                    # dev image used by docker-compose
docker-compose.yml                # Postgres + app
```

## Running locally without Docker

You need Elixir 1.15+, Erlang/OTP 26, and Postgres.

```bash
mix setup           # fetch deps, create DB, migrate, seed, build assets
mix phx.server      # start the server at http://localhost:4000
```
