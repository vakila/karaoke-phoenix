defmodule KaraokeWeb.PartyLive.Index do
  use KaraokeWeb, :live_view

  alias Karaoke.Parties
  alias Karaoke.Parties.Party

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        <:actions>
          <.form for={@form} id="party-form-new"  phx-submit="add_party">
          <.input field={@form[:name]} type="text" label="Party name" />
          <footer>
          <.button phx-disable-with="Saving..." variant="primary">
            <.icon name="hero-plus" /> New Party
          </.button>
        </footer>

      </.form>
        </:actions>
      </.header>

      <.table
        id="parties"
        rows={@streams.parties}
        row_id={fn {dom_id, _party} -> dom_id end}
      >
        <:col :let={{_id, party}} label="Name">{party.name}</:col>
        <:action :let={{_id, party}}>
          <div class="sr-only">
            <.link navigate={~p"/parties/#{party}"}>Show</.link>
          </div>
          <.link navigate={~p"/parties/#{party}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, party}}>
          <.link
            phx-click={JS.push("delete", value: %{id: party.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Parties")
     |> assign(form: to_form(%{name: ""}, action: :save))
     |> stream_configure(:parties, dom_id: &("parties-#{&1.name}"))
     |> stream(:parties, [])}
  end

  @impl true
  def handle_event("add_party", %{"name" => name}, socket) do
    id = Enum.count(socket.assigns.streams.parties) + 1
    # changeset = Party.changeset(%Party{}, %{name: name})
    {:noreply, stream_insert(socket, :parties, %Party{id: id, name: name})}
  end

  @impl true
  def handle_event("validate", %{"party" => party_params}, socket) do
    changeset = Party.changeset(%Party{}, party_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"party" => party_params}, socket) do
    changeset = Party.changeset(socket.assigns.party, party_params)

    {:noreply, stream_insert(socket, :parties, changeset)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    party = Parties.get_party!(id)
    {:ok, _} = Parties.delete_party(party)

    {:noreply, stream_delete(socket, :parties, party)}
  end


end
