defmodule KaraokeWeb.SongLive.Index do
  # alias KaraokeWeb.QueuedSongLive
  use KaraokeWeb, :live_view

  alias KaraokeWeb.QueuedSongLive
  alias Karaoke.Party
  alias Karaoke.Party.Song

  def get_url(title, artist \\ "") do
    url_base = "https://www.youtube.com/results?search_query=karaoke"
    url = url_base <> "+" <> title
    if (artist) do
      url <> "+" <> artist
    else
      url
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>

      <%!-- NOW PLAYING --%>

      <fieldset id="now-playing" class="fieldset neon-box neon-box-pink rounded-box border p-4">
        <legend class="fieldset-legend neon-text uppercase text-xl md:text-3xl ">Now Playing</legend>

        <div :if={@playing}>
          <p class="neon-text text-3xl uppercase">{@playing.singer}</p>
          <p class="text-xl">{@playing.title}</p>
          <p :if={@playing.artist} class="text-xl pb-4">{@playing.artist}</p>
          <.link href={URI.parse(get_url(@playing.title, @playing.artist))} target="_blank">
          Open on YouTube <.icon name="hero-arrow-top-right-on-square" />
          </.link>
        </div>

      </fieldset>

      <%!-- QUEUE --%>

      <fieldset id="song-queue" class="fieldset rounded-box border p-4 neon-box neon-box-purple" >
        <legend class="fieldset-legend neon-text text-xl">Up Next</legend>

        <.button id="play-next" variant="neon" title="Play next song" phx-click="next" >
          <.icon name="hero-forward" />
          <span class="uppercase">Next Song</span>
        </.button>


        <.live_component
          module={QueuedSongLive}
          :for={song <- @queue}
          id={song.id}
          song={song}
          editing={false}
          />

      </fieldset>

      <fieldset id="add-song" class="fieldset neon-box neon-box-blue rounded-box border p-4">
       <legend class="fieldset-legend neon-text text-xl">Add song</legend>
       <.form for={@form} id="song-form-new" phx-submit="add_song" class="grid sm:grid-cols-4 gap-2 py-2 items-start ">
          <.input field={@form[:singer]} type="text" placeholder="performer name" />
          <.input field={@form[:title]} type="text" placeholder="song title"  />
          <.input field={@form[:artist]} type="text" placeholder="song artist"  />

          <div class="fieldset mb2">
          <.button variant="neon-secondary" title="Add song to queue" phx-disable-with="Saving..." >
            <.icon name="hero-plus" />
            <span class="hidden xxs:inline sm:max-md:hidden uppercase"> Add
              <span class="hidden xs:inline md:max-xl:hidden">to Queue</span>
            </span>
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

    if connected?(socket) do
      party = Party.subscribe(Party)

      IO.puts("get the party started")
      dbg(socket)

      new_socket = socket
        |> assign(:party, party)
        |> assign(:playing, party.playing)
        |> assign(:queue, party.queue)
        |> assign(:form, to_form(%{}, action: :validate))

      {:ok, new_socket}

    end

    {:ok, socket
      |> assign(:page_title, "Karaoke Party")
      |> assign(:party, nil)
      |> assign(:playing, nil)
      |> assign(:queue, [])
      |> assign(:form, to_form(%{}, action: :validate))}

  end

  # @impl true
  # def handle_event("open-youtube", %{"singer" => singer, "title" => title, "artist" => artist}, socket) do
  #   url_base = "https://www.youtube.com/results?search_query=karaoke+"

  #   {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  # end




  @impl true
  def handle_event("validate", %{"song" => song}, socket) do
    changeset = Song.to_changeset(song)
    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("validate", %{"singer" => singer, "title" => title, "artist" => artist}, socket) do
    changeset = Song.to_changeset(%{singer: singer, title: title, artist: artist})
    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("add_song", %{"song" => song}, socket) do
    handle_event("add_song",  %{"title" => song["title"], "singer" => song["singer"], "artist" => song["artist"]}, socket)
  end

  @impl true
  def handle_event("add_song", %{"title" => title, "singer" => singer, "artist" => artist }, socket) do

    this_song_id = UUID.uuid4(:hex)
    changeset = Song.to_changeset(%{title: title, singer: singer, artist: artist, id: this_song_id})

    if !changeset.valid? do
      {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}

    else
      new_party = Party.add_song(Party, %Song{title: title, singer: singer, artist: artist, id: this_song_id})

      {:noreply, socket
        |> assign(:party, new_party)
        |> assign(:form, to_form(%{}, action: :new))}
        # |> put_flash(:info, "Song added to queue")
    end
  end


  @impl true
  def handle_event("next", _params, socket) do
    new_party = Party.next_song(Party)
    {:noreply, assign(socket, :party, new_party)}
  end




  @impl true
  def handle_info({:updated, new_party}, socket) do
    {:noreply, socket
      |> assign(party: new_party)
      |> assign(queue: new_party.queue)
      |> assign(playing: new_party.playing)
    }
  end


end
