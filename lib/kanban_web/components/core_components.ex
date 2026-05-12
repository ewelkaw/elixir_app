defmodule KanbanWeb.CoreComponents do
  @moduledoc """
  A small library of reusable HEEx function components.
  HEEx is Phoenix's HTML template language with compile-time validation.
  Function components are like React function components: pure functions
  returning markup from props (called *assigns* here).
  """

  use Phoenix.Component

  @doc "Renders a button."
  # `attr` declares typed component attributes — like TypeScript prop types
  # or Python dataclass fields. Type errors are surfaced at compile time.
  attr :type, :string, default: "button"
  attr :class, :string, default: ""
  attr :rest, :global, include: ~w(disabled form name value phx-click phx-disable-with)
  slot :inner_block, required: true

  def button(assigns) do
    # `~H""" ... """` is the HEEx sigil — HTML with `<%= ... %>` Elixir interpolations.
    ~H"""
    <button
      type={@type}
      class={[
        "rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc "Renders an input with label."
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any
  attr :type, :string, default: "text"
  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, e.g. @form[:title]"
  attr :errors, :list, default: []
  attr :rest, :global, include: ~w(placeholder required autofocus)

  # Pattern-match clause: when caller passes `field={@form[:title]}`, derive
  # id/name/value/errors from the form field and delegate to the main clause.
  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error/1))
    |> assign(:name, field.name)
    |> assign(:value, field.value)
    |> input()
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div>
      <label :if={@label} for={@id} class="block text-sm font-medium text-zinc-700"><%= @label %></label>
      <textarea
        id={@id}
        name={@name}
        class="mt-1 block w-full rounded-md border border-zinc-300 px-3 py-2 text-sm focus:border-zinc-500 focus:outline-none"
        {@rest}
      ><%= @value %></textarea>
      <p :for={msg <- @errors} class="mt-1 text-xs text-rose-600"><%= msg %></p>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div>
      <label :if={@label} for={@id} class="block text-sm font-medium text-zinc-700"><%= @label %></label>
      <input
        id={@id}
        type={@type}
        name={@name}
        value={@value}
        class="mt-1 block w-full rounded-md border border-zinc-300 px-3 py-2 text-sm focus:border-zinc-500 focus:outline-none"
        {@rest}
      />
      <p :for={msg <- @errors} class="mt-1 text-xs text-rose-600"><%= msg %></p>
    </div>
    """
  end

  @doc "Renders a flash message."
  attr :flash, :map, default: %{}
  attr :kind, :atom, values: [:info, :error]

  def flash(assigns) do
    ~H"""
    <p
      :if={msg = Phoenix.Flash.get(@flash, @kind)}
      class={[
        "fixed top-4 right-4 px-4 py-2 rounded-md shadow-md text-sm",
        @kind == :info && "bg-emerald-50 text-emerald-800",
        @kind == :error && "bg-rose-50 text-rose-800"
      ]}
      phx-click="lv:clear-flash"
      phx-value-key={@kind}
    >
      <%= msg %>
    </p>
    """
  end

  # Translates an Ecto changeset error tuple into a human-readable string.
  # `{msg, opts}` shape comes from Ecto. We do simple interpolation here —
  # Gettext could be plugged in for i18n.
  def translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
