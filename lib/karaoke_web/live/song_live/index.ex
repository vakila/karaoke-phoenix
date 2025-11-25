defmodule KaraokeWeb.SongLive.Index do
  # alias KaraokeWeb.QueuedSongLive
  use KaraokeWeb, :live_view

  alias KaraokeWeb.QueuedSongLive
  alias Karaoke.Party
  alias Karaoke.Party.Song



  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Songs!
      </.header>

      <div class="font-bold grid grid-cols-3 gap-2">
        <span>SONG TITLE</span>
        <span>SINGER</span>
        <span></span>
      </div>

      <div id="queued_songs" >
        <.live_component
          :for={song <- @songs}
          :key={song.id}
          module={QueuedSongLive}
          id={song.id}
          song={song}
          editing={false}
          />
      </div>

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
    dbg(socket)


    # {:ok, party_pid} = Party.start_link([])
    # dbg(party_pid)
    # songs = Party.list_songs(party_pid)
    # dbg(songs)




    if connected?(socket) do
      party = Party.subscribe(Party)

      IO.puts("get the party started")
      dbg(party.queue)
      {:ok, socket |> assign(party: party) |> assign(songs: party.queue)}
    end

    {:ok, socket
      |> assign(:page_title, "Karaoke Songs")
      |> assign(songs: [])
      |> assign(form: to_form(%{}, action: :validate))}


  end


  def handle_event("validate", %{"song" => song}, socket) do
    dbg(song)
    changeset = Song.to_changeset(song)
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
      {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}

    else
      new_queue = Party.add_song(Party, %Song{title: title, singer: singer, id: this_song_id})

      {:noreply, socket
        |> assign(songs: new_queue)
        |> put_flash(:info, "Song added to queue")
        |> assign(form: to_form(%{}, action: :new))}
    end


  end



  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    dom_id = "#songs-#{id}"
    {:noreply, stream_delete_by_dom_id(socket, :songs, dom_id)}
  end


  @impl true
  def handle_info({:updated, new_party}, socket) do
    {:noreply, socket |> assign(party: new_party) |> assign(songs: new_party.queue)}
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
