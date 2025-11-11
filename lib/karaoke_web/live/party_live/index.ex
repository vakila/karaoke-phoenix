defmodule KaraokeWeb.PartyLive.Index do
  use KaraokeWeb, :live_view

  alias Karaoke.Parties

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Parties
        <:actions>
          <.button variant="primary" navigate={~p"/parties/new"}>
            <.icon name="hero-plus" /> New Party
          </.button>
        </:actions>
      </.header>

      <.table
        id="parties"
        rows={@streams.parties}
        row_click={fn {_id, party} -> JS.navigate(~p"/parties/#{party}") end}
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
     |> stream(:parties, list_parties())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    party = Parties.get_party!(id)
    {:ok, _} = Parties.delete_party(party)

    {:noreply, stream_delete(socket, :parties, party)}
  end

  defp list_parties() do
    Parties.list_parties()
  end
end
