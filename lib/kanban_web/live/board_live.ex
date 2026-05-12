defmodule KanbanWeb.BoardLive do
  @moduledoc """
  The Kanban board UI as a Phoenix LiveView.

  ## Concept
  A LiveView is a long-running server-side *process* (an Erlang lightweight
  thread — millions can run on one machine) that owns the state for ONE
  browser tab. It renders HTML and pushes diffs over WebSocket. There is no
  Python equivalent: imagine a Django view that stays alive between requests
  and pushes updates to the browser when state changes, without you writing JS.

  ## State
  All state lives in `socket.assigns` — analogous to React's `useState` keys,
  but on the server. Every event handler returns `{:noreply, new_socket}` to
  update state; the framework computes the HTML diff and ships it.
  """

  use KanbanWeb, :live_view

  alias Kanban.Boards
  alias Kanban.Boards.Card

  # `@impl true` says "this implements the LiveView behaviour callback".
  # `mount/3` runs ONCE per session — first as a regular HTTP render, then a
  # second time over the WebSocket. Use `connected?/1` to detect the second.
  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Boards.subscribe()

    # `assign/2` adds key/value pairs to `socket.assigns`. The `~> map syntax`
    # builds a map literal: `%{key: value}` is `{"key": value}` in Python.
    socket =
      socket
      |> assign(:page_title, "Board")
      |> assign(:form, to_form(Boards.change_card(%Card{})))
      |> assign(:editing_id, nil)
      |> load_cards()

    {:ok, socket}
  end

  # Render the template. With `use KanbanWeb, :live_view`, Phoenix calls this
  # to produce HTML. ~H is the HEEx sigil; @assign references socket.assigns.
  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <%= for status <- ["todo", "doing", "done"] do %>
        <section class="bg-white rounded-xl border border-zinc-200 shadow-sm">
          <header class="px-4 py-3 border-b border-zinc-100 flex items-center justify-between">
            <h2 class="font-semibold capitalize text-zinc-700"><%= status %></h2>
            <span class="text-xs text-zinc-500 bg-zinc-100 px-2 py-0.5 rounded-full">
              <%= length(@cards_by_status[status]) %>
            </span>
          </header>

          <ul id={"col-#{status}"} class="p-3 space-y-2 min-h-[60px]">
            <li :for={card <- @cards_by_status[status]} id={"card-#{card.id}"} class="group">
              <article class="border border-zinc-200 rounded-lg p-3 bg-zinc-50 hover:bg-white transition">
                <div class="flex justify-between items-start gap-2">
                  <h3 class="font-medium text-zinc-800"><%= card.title %></h3>
                  <button
                    phx-click="delete"
                    phx-value-id={card.id}
                    data-confirm="Delete this card?"
                    class="opacity-0 group-hover:opacity-100 text-xs text-rose-600 hover:underline"
                  >
                    delete
                  </button>
                </div>
                <p :if={card.description} class="mt-1 text-sm text-zinc-600">
                  <%= card.description %>
                </p>
                <div class="mt-3 flex gap-1 flex-wrap">
                  <button
                    :for={s <- Card.statuses() -- [card.status]}
                    phx-click="move"
                    phx-value-id={card.id}
                    phx-value-status={s}
                    class="text-xs px-2 py-0.5 rounded bg-zinc-200 hover:bg-zinc-300 text-zinc-700"
                  >
                    → <%= s %>
                  </button>
                </div>
              </article>
            </li>
          </ul>
        </section>
      <% end %>
    </div>

    <section class="mt-10 max-w-md">
      <h2 class="font-semibold text-zinc-700 mb-3">New card</h2>
      <.form for={@form} phx-submit="create" phx-change="validate" class="space-y-3">
        <.input field={@form[:title]} label="Title" placeholder="What needs to be done?" />
        <.input field={@form[:description]} type="textarea" label="Description (optional)" />
        <input type="hidden" name="card[status]" value="todo" />
        <.button type="submit" phx-disable-with="Adding...">Add card</.button>
      </.form>
    </section>
    """
  end

  # ============================================================================
  # Event handlers — each LiveView event (button click, form submit) is routed
  # to a `handle_event/3` clause. The compiler picks the clause whose first
  # argument *pattern-matches* the event name. This is the core Elixir idiom.
  # ============================================================================

  @impl true
  def handle_event("create", %{"card" => params}, socket) do
    # `case` evaluates each branch against the value. The `{:ok, _}` / `{:error, _}`
    # convention is universal in Elixir — like Go's `(value, err)` return, but
    # encoded in the type so pattern matching can dispatch on success/failure.
    case Boards.create_card(params) do
      {:ok, _card} ->
        socket =
          socket
          |> put_flash(:info, "Card added")
          |> assign(:form, to_form(Boards.change_card(%Card{})))
          |> load_cards()

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("validate", %{"card" => params}, socket) do
    changeset =
      %Card{}
      |> Boards.change_card(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("move", %{"id" => id, "status" => status}, socket) do
    # `String.to_integer/1` because LiveView params are strings.
    card = Boards.get_card!(String.to_integer(id))
    {:ok, _} = Boards.move_card(card, status)
    {:noreply, load_cards(socket)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    card = Boards.get_card!(String.to_integer(id))
    {:ok, _} = Boards.delete_card(card)
    {:noreply, socket |> put_flash(:info, "Card deleted") |> load_cards()}
  end

  # ============================================================================
  # PubSub messages — broadcasts from `Kanban.Boards` arrive here. Multiple
  # browser tabs stay in sync because each LiveView process re-renders when it
  # receives one of these messages.
  # ============================================================================

  @impl true
  def handle_info({event, _card}, socket)
      when event in [:card_created, :card_updated, :card_deleted] do
    # `when` is a *guard clause* — like a filter on pattern matching.
    {:noreply, load_cards(socket)}
  end

  # Private helper. Reloads card data into the socket.
  defp load_cards(socket) do
    assign(socket, :cards_by_status, Boards.list_cards_by_status())
  end
end
