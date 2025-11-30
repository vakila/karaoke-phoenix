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

      <fieldset class="fieldset neon-box neon-box-pink rounded-box border p-4">
      <legend class="fieldset-legend neon-text uppercase text-3xl">Now Playing</legend>
      <span class="neon-text text-xl">SINGER singing SONG</span>
      </fieldset>

      <fieldset class="fieldset rounded-box border p-4 neon-box neon-box-purple" >
      <legend class="fieldset-legend neon-text text-xl">Up Next</legend>

      <div class="font-bold grid grid-cols-3 gap-2">
        <p class="text-lg border-b">SONG</p>
        <p class="text-lg border-b">SINGER</p>
        <div class=""></div>
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
      </fieldset>

      <fieldset class="fieldset neon-box neon-box-blue rounded-box border p-4">
       <legend class="fieldset-legend neon-text text-xl">Add song</legend>
       <.form for={@form} id="song-form-new" phx-submit="add_song" class="grid grid-cols-3 gap-2 py-2 items-start ">
          <.input field={@form[:title]} type="text" placeholder="song title"  />
          <.input field={@form[:singer]} type="text" placeholder="singer name" />
          <div class="fieldset mb2">
          <.button variant="neon-secondary" phx-disable-with="Saving..." disabled={} >
            <.icon name="hero-plus" /> <span class="hidden sm:inline"> Add <span class="hidden md:inline">to Queue</span></span>
          </.button>
          </div>
      </.form>
      </fieldset>


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
      |> assign(:page_title, "Karaoke Party")
      |> assign(songs: [])
      |> assign(form: to_form(%{}, action: :validate))}


  end

  @impl true
  def handle_event("validate", %{"song" => song}, socket) do
    dbg(song)
    changeset = Song.to_changeset(song)
    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("validate", %{"singer" => singer, "title" => title}, socket) do
    changeset = Song.to_changeset(%{singer: singer, title: title})
    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("add_song", %{"song" => song}, socket) do
    handle_event("add_song",  %{"title" => song["title"], "singer" => song["singer"]}, socket)
  end

  @impl true
  def handle_event("add_song", %{"title" => title, "singer" => singer}, socket) do

    this_song_id = "#{singer}-#{title}"
    changeset = Song.to_changeset(%{title: title, singer: singer, id: this_song_id})

    if !changeset.valid? do
      {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}

    else
      new_queue = Party.add_song(Party, %Song{title: title, singer: singer, id: this_song_id})

      {:noreply, socket
        |> assign(songs: new_queue)
        # |> put_flash(:info, "Song added to queue")
        |> assign(form: to_form(%{}, action: :new))}
    end


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
