# `defmodule` declares a module — like `class` in Python, but Elixir modules
# are namespaces for functions, not blueprints for instances. There is no `self`,
# no instance state. Everything is a pure function call: `Module.function(args)`.
defmodule Kanban.MixProject do
  # `use Mix.Project` is *metaprogramming*: it injects code from the `Mix.Project`
  # module into this module. Think of it as a heavyweight decorator/mixin in Python,
  # except it happens at compile time and can inject any code at all.
  use Mix.Project

  # `def` defines a public function. Function definitions look like Python defs,
  # but functions in Elixir cannot be reassigned and the last expression is the
  # return value (no `return` keyword needed — like Ruby).
  def project do
    # A keyword list — looks like a Python dict literal but is an ordered list
    # of `{atom, value}` tuples. `:kanban` is an *atom* (similar to a Python
    # string constant or Ruby symbol — an interned, immutable name).
    [
      app: :kanban,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # `application/0` returns the OTP application config. OTP is Erlang's framework
  # for building fault-tolerant systems — there is no Python equivalent.
  # `mod:` says "when this app starts, call Kanban.Application.start/2".
  def application do
    [
      mod: {Kanban.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Multiple function clauses with *pattern matching* — Elixir picks the clause
  # whose arguments match. This is like Python's `functools.singledispatch`,
  # but built into the language and far more powerful.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # `defp` is a *private* function — only callable inside this module. Python
  # has no real private; here it's enforced by the compiler.
  defp deps do
    [
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.2"},
      {:floki, ">= 0.30.0", only: :test},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:bandit, "~> 1.2"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind kanban", "esbuild kanban"],
      "assets.deploy": [
        "tailwind kanban --minify",
        "esbuild kanban --minify",
        "phx.digest"
      ]
    ]
  end
end
