defmodule KaraokeWeb.SongLive.Show do
  use KaraokeWeb, :live_view

  alias Karaoke.Songs

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Song {@song.id}
        <:subtitle>This is a song record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/songs"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/songs/#{@song}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit song
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@song.title}</:item>
        <:item title="Singer">{@song.singer}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Song")
     |> assign(:song, Songs.get_song!(id))}
  end
end
