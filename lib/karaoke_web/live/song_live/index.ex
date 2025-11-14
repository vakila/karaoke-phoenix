defmodule KaraokeWeb.SongLive.Index do
  # alias KaraokeWeb.QueuedSongLive
  use KaraokeWeb, :live_view

  alias Karaoke.Party
  alias Karaoke.Party.Song


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

      <%!-- <div id="queued_songs" >
        <.live_component
          :for={song <- @songs}
          :key={song.id}
          module={QueuedSongLive}
          id={song.id}
          song={song}
          editing={false}
          />
      </div> --%>

      <div>
       <.form for={@form} id="song-form-new" phx-change="validate" phx-submit="add_song" class="grid grid-cols-3 gap-2">
          <.input field={@form[:title]} type="text" placeholder="song title"  />
          <.input field={@form[:singer]} type="text" placeholder="singer name" />
          <.button phx-disable-with="Saving..." variant="primary">
          <.icon name="hero-plus" /> Add Song</.button>
      </.form>
    </div>

    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # KaraokeWeb.Endpoint.subscribe("songs")
      IO.puts('CONNECTED')

      {:ok, socket}
    end

    dbg(socket)

    {:ok,
     socket
     |> assign(:page_title, "Karaoke Songs")
    #  |> assign(:party, socket.party)
     |> assign(form: to_form(%{}, action: :validate))}
  end


  def handle_event("validate", %{"song" => song}, socket) do
    dbg(song)
    changeset = Song.changeset(%Song{}, song)
    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  def handle_event("validate", %{"singer" => singer, "title" => title}, socket) do
    dbg(singer)
    dbg(title)
    changeset = Song.to_changeset(%{singer: singer, title: title})
    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  def handle_event("add_song", %{"song" => song}, socket) do
    %{"title" => title, "singer" => singer} = song
    this_song_id = "#{singer}-#{title}"
    changeset = Song.to_changeset(%{title: title, singer: singer, id: this_song_id})

    if !changeset.valid? do
      dbg("INVALID")
      {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}

    else
      dbg("VALID")
      # Karaoke.Endpoint.broadcast("songs", "song_added", song)
      #       Party.cast("songs", "song_added", song)
      Party.add_song(socket.party, song)

      {:noreply, socket
        # |> assign(:songs, %Song{title: title, singer: singer, id: this_song_id})
        # |> put_flash(:info, "Song added to queue")
        |> assign(form: to_form(%{}, action: :new))}
    end


  end



  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    dom_id = "#songs-#{id}"
    {:noreply, stream_delete_by_dom_id(socket, :songs, dom_id)}
  end


  @impl true
  def handle_info("song_updated", socket) do
    dbg("song_updated")
    {:noreply, socket} # actually an upsert
  end

  # def handle_in({:song_added, payload}, socket) do
  #   dbg("song_added");
  #   dbg(payload)
  #   # send_update(
  #   #   QueuedSongLive,
  #   #   id: song.id
  #   # )
  #   {:noreply, stream_insert(socket, :songs, payload.song)}
  # end

end
