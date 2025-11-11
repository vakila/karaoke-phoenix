defmodule KaraokeWeb.PartyLive.Show do
  use KaraokeWeb, :live_view

  alias Karaoke.Parties

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Party {@party.id}
        <:subtitle>This is a party record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/parties"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/parties/#{@party}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit party
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@party.name}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Party")
     |> assign(:party, Parties.get_party!(id))}
  end
end
