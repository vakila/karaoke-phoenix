defmodule KaraokeWeb.SongLive.Index do
  use KaraokeWeb, :live_view

  alias Karaoke.Songs
  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Karaoke Songs!
      </.header>

      <.form for={@form} id="song-form-new" phx-submit="save" class="sm:flex sm:align-center sm:gap-2">
        <div class="flex-grow">
          <.input field={@form[:title]} type="text" label="Title" />
        </div>
        <.input field={@form[:singer]} type="text" label="Singer" />
        <div class="h-full mt-[26px]">
          <.button phx-disable-with="Saving..." variant="primary">
            <.icon name="hero-plus" /> Add Song
          </.button>
        </div>
      </.form>

      <div id="songs" phx-update="stream">
        <.live_component
          :for={{id, song} <- @streams.songs}
          song={song}
          module={KaraokeWeb.QueuedSongLive}
          id={song.id}
        />
      </div>

      <.table
        id="songs"
        rows={@streams.songs}
      >
        <:col :let={{_id, song}} label="Title">
          {song.title}
        </:col>
        <:col :let={{_id, song}} label="Singer">
          {song.singer}
        </:col>
        <:action :let={{_id, song}}>
          <.link phx-click="toggle_edit" phx-value-id={song.id}>Edit</.link>
        </:action>
        <:action :let={{id, song}}>
          <.link
            phx-click={JS.push("delete", value: %{id: song.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Songs")
     |> assign(form: to_form(%{"title" => "", "singer" => ""}, action: :save))
     |> stream(:songs, [])}
  end

  @impl true
  def handle_event("save", %{"title" => title, "singer" => singer}, socket) do
    this_song_id = "#{singer}-#{title}"
    new_song = %Songs.Song{title: title, singer: singer, id: this_song_id}
    {:noreply, stream_insert(socket, :songs, new_song)}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    Logger.info("hello")
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    dom_id = "#songs-#{id}"
    {:noreply, stream_delete_by_dom_id(socket, :songs, dom_id)}
  end

  def add_song() do
  end
end
