defmodule KaraokeWeb.SongLive.Index do
  use KaraokeWeb, :live_view

  alias Karaoke.Songs


  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Karaoke Songs!
      </.header>

      <div class="font-bold grid grid-cols-3 gap-2">
        <span>SONG</span>
        <span>SINGER</span>
        <span></span>
      </div>

      <div id="queued_songs" phx-update="stream" >
        <.live_component
          :for={{id, song} <- @streams.songs}
          :key={id}
          module={KaraokeWeb.QueuedSongLive}
          id={id}
          song={song}
          editing={false}
          />
      </div>

       <.form for={@form} id="song-form-new" phx-submit="new" class="grid grid-cols-3 gap-2">
          <.input field={@form[:title]} type="text" placeholder="song title" />
        <.input field={@form[:singer]} type="text" placeholder="singer name" />
          <.button phx-disable-with="Saving..." variant="primary">
          <.icon name="hero-plus" /> Add Song</.button>
      </.form>




    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Songs")
     |> assign(form: to_form(%{"title" => "", "singer" => ""}, action: :save))
     |> stream(:songs, [%Songs.Song{title: "Closing Time", singer: "Everyone", id: "Everyone-Closing Time"}])}
  end


  @impl true
  def handle_info({:save, data}, socket) do
    {:noreply, stream_insert(socket, :songs, data)}
  end

  @impl true
  def handle_event("new", %{"title" => title, "singer" => singer}, socket) do
    this_song_id = "#{singer}-#{title}"
    new_song = %Songs.Song{title: title, singer: singer, id: this_song_id}
    {:noreply, socket
      |> assign(form: to_form(%{"title" => "", "singer" => ""}, action: :save))
      |> stream_insert(:songs, new_song)
    }
  end

  @impl true
  def handle_event("toggle_edit", %{"id" => id}, socket) do
    dbg("toggle_edit")
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    dom_id = "#songs-#{id}"
    {:noreply, stream_delete_by_dom_id(socket, :songs, dom_id)}
  end

end
