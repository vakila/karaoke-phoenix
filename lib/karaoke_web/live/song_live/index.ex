defmodule KaraokeWeb.SongLive.Index do
  # alias KaraokeWeb.QueuedSongLive
  use KaraokeWeb, :live_view

  alias KaraokeWeb.QueuedSongLive
  alias Karaoke.Party
  alias Karaoke.Party.Song

  def get_url(title, artist \\ "") do
    url_base = "https://www.youtube.com/results?search_query=karaoke"
    url = url_base <> "+" <> title

    if artist do
      url <> "+" <> artist
    else
      url
    end
  end

  def blank?(value), do: value in [nil, ""]

  def video_url(%Song{youtube_id: id}) when is_binary(id) and id != "" do
    "https://www.youtube.com/watch?v=#{id}&autoplay=1"
  end

  def video_url(song) do
    get_url(song.title, song.artist)
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

          <%= if Karaoke.YouTube.valid_id?(@playing.youtube_id) and @playing.embeddable != false do %>
            <div class="aspect-video w-full my-3">
              <iframe
                src={"https://www.youtube.com/embed/#{@playing.youtube_id}?autoplay=1&rel=0"}
                title={@playing.youtube_title || @playing.title}
                class="w-full h-full rounded"
                frameborder="0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowfullscreen
              >
              </iframe>
            </div>
          <% else %>
            <.button variant="neon-secondary" href={video_url(@playing)} target="_blank">
              Open on YouTube <.icon name="hero-arrow-top-right-on-square" />
            </.button>
          <% end %>
        </div>
      </fieldset>

      <%!-- QUEUE --%>

      <fieldset id="song-queue" class="fieldset rounded-box border p-4 neon-box neon-box-purple">
        <legend class="fieldset-legend neon-text text-xl">Up Next</legend>

        <.button id="play-next" variant="neon" title="Play next song" phx-click="next">
          <.icon name="hero-forward" />
          <span class="uppercase">Next Song</span>
        </.button>

        <.live_component
          :for={song <- @queue}
          module={QueuedSongLive}
          id={song.id}
          song={song}
          editing={false}
        />
      </fieldset>

      <fieldset id="add-song" class="fieldset neon-box neon-box-blue rounded-box border p-4">
        <legend class="fieldset-legend neon-text text-xl">Add song</legend>
        <.form
          for={@form}
          id="song-form-new"
          phx-change="validate"
          phx-submit="search_videos"
          class="grid sm:grid-cols-4 gap-2 py-2 items-start "
        >
          <.input field={@form[:singer]} type="text" placeholder="performer name" />
          <.input field={@form[:title]} type="text" placeholder="song title" />
          <.input field={@form[:artist]} type="text" placeholder="song artist" />

          <div class="fieldset mb2">
            <.button
              variant="neon-secondary"
              title="Search YouTube for this song"
              phx-disable-with="Searching..."
            >
              <.icon name="hero-magnifying-glass" />
              <span class="hidden xxs:inline sm:max-md:hidden uppercase">
                Search <span class="hidden xs:inline md:max-xl:hidden">YouTube</span>
              </span>
            </.button>
          </div>
        </.form>

        <%= if @searching do %>
          <p class="py-2">Searching YouTube…</p>
        <% end %>

        <%= if @search_error do %>
          <p class="py-2 text-error">{@search_error}</p>
        <% end %>

        <div :if={@search_results != []} class="space-y-2 py-2">
          <div :for={video <- @search_results} class="flex items-center gap-3 border rounded p-2">
            <img src={video.thumbnail} alt="" class="w-24 h-16 object-cover rounded shrink-0" />
            <div class="flex-1 min-w-0">
              <p class="font-semibold truncate">{video.title}</p>
              <p :if={video.channel} class="text-sm opacity-70 truncate">{video.channel}</p>
            </div>
            <.button
              variant="neon-secondary"
              phx-click="select_video"
              phx-value-video_id={video.id}
              phx-value-video_title={video.title}
            >
              Use this
            </.button>
          </div>
          <.button variant="neon-secondary" phx-click="add_without_video">Add without video</.button>
        </div>
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

      new_socket =
        socket
        |> assign(:party, party)
        |> assign(:playing, party.playing)
        |> assign(:queue, party.queue)
        |> assign(:form, to_form(%{}, as: :song, action: :validate))
        |> assign(:search_results, [])
        |> assign(:searching, false)
        |> assign(:search_error, nil)
        |> assign(:pending_song, nil)

      {:ok, new_socket}
    end

    {:ok,
     socket
     |> assign(:page_title, "Karaoke Party")
     |> assign(:party, nil)
     |> assign(:playing, nil)
     |> assign(:queue, [])
     |> assign(:form, to_form(%{}, as: :song, action: :validate))
     |> assign(:search_results, [])
     |> assign(:searching, false)
     |> assign(:search_error, nil)
     |> assign(:pending_song, nil)}
  end

  @impl true
  def handle_event("validate", %{"song" => song}, socket) do
    changeset = Song.to_changeset(song)
    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event(
        "validate",
        %{"singer" => singer, "title" => title, "artist" => artist},
        socket
      ) do
    changeset = Song.to_changeset(%{singer: singer, title: title, artist: artist})
    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("search_videos", %{"song" => song}, socket) do
    handle_event(
      "search_videos",
      %{
        "singer" => song["singer"],
        "title" => song["title"],
        "artist" => song["artist"]
      },
      socket
    )
  end

  @impl true
  def handle_event(
        "search_videos",
        %{"singer" => singer, "title" => title, "artist" => artist},
        socket
      ) do
    changeset = Song.to_changeset(%{singer: singer, title: title, artist: artist})

    if changeset.valid? do
      data = Ecto.Changeset.apply_changes(changeset)
      query = [data.title, data.artist, "karaoke"] |> Enum.reject(&blank?/1) |> Enum.join(" ")

      socket =
        socket
        |> assign(:form, to_form(changeset, action: :validate))
        |> assign(:pending_song, %{singer: data.singer, title: data.title, artist: data.artist})
        |> assign(:searching, true)
        |> assign(:search_results, [])
        |> assign(:search_error, nil)
        |> start_async(:youtube_search, fn -> Karaoke.YouTube.search(query) end)

      {:noreply, socket}
    else
      {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
    end
  end

  @impl true
  def handle_event("select_video", %{"video_id" => vid, "video_title" => vtitle}, socket) do
    case socket.assigns.pending_song do
      %{singer: s, title: t, artist: a} ->
        this_song_id = UUID.uuid4(:hex)

        embeddable = Karaoke.YouTube.embeddable?(vid)

        new_party =
          Party.add_song(Party, %Song{
            title: t,
            singer: s,
            artist: a,
            id: this_song_id,
            youtube_id: vid,
            youtube_title: vtitle,
            embeddable: embeddable
          })

        {:noreply,
         socket
         |> assign(:party, new_party)
         |> assign(:form, to_form(%{}, as: :song, action: :new))
         |> assign(:pending_song, nil)
         |> assign(:search_results, [])
         |> assign(:searching, false)
         |> assign(:search_error, nil)}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("add_without_video", _params, socket) do
    case socket.assigns.pending_song do
      %{singer: s, title: t, artist: a} ->
        this_song_id = UUID.uuid4(:hex)

        new_party =
          Party.add_song(Party, %Song{
            title: t,
            singer: s,
            artist: a,
            id: this_song_id
          })

        {:noreply,
         socket
         |> assign(:party, new_party)
         |> assign(:form, to_form(%{}, as: :song, action: :new))
         |> assign(:pending_song, nil)
         |> assign(:search_results, [])
         |> assign(:searching, false)
         |> assign(:search_error, nil)}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("next", _params, socket) do
    new_party = Party.next_song(Party)
    {:noreply, assign(socket, :party, new_party)}
  end

  @impl true
  def handle_async(:youtube_search, {:ok, {:ok, results}}, socket) do
    {:noreply, socket |> assign(:searching, false) |> assign(:search_results, results)}
  end

  @impl true
  def handle_async(:youtube_search, {:ok, {:error, reason}}, socket) do
    {:noreply, socket |> assign(:searching, false) |> assign(:search_error, inspect(reason))}
  end

  @impl true
  def handle_async(:youtube_search, {:exit, reason}, socket) do
    {:noreply, socket |> assign(:searching, false) |> assign(:search_error, inspect(reason))}
  end

  @impl true
  def handle_info({:updated, new_party}, socket) do
    {:noreply,
     socket
     |> assign(party: new_party)
     |> assign(queue: new_party.queue)
     |> assign(playing: new_party.playing)}
  end
end
