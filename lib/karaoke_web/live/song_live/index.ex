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
    {:ok,
     socket
     |> assign(:page_title, "Listing Songs")
     |> assign(form: to_form(Songs.get_changeset(), action: :validate))
     |> stream(:songs, [%Songs.Song{title: "Closing Time", singer: "Everyone", id: "Everyone-Closing Time"}])}
  end


  def handle_event("validate", %{"song" => song}, socket) do
    dbg(song)
    changeset = Songs.get_changeset(song)
    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  def handle_event("validate", %{"singer" => singer, "title" => title}, socket) do
    dbg(singer)
    dbg(title)
    changeset = Songs.get_changeset(%{singer: singer, title: title})
    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  def handle_event("add_song", %{"song" => song}, socket) do
    %{"title" => title, "singer" => singer} = song
    this_song_id = "#{singer}-#{title}"
    changeset = Songs.get_changeset(%{title: title, singer: singer, id: this_song_id})
    if !changeset.valid? do
            dbg("INVALID")

      {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
    else
      dbg("VALID")

     {:noreply, socket
        |> stream_insert(:songs, %Songs.Song{title: title, singer: singer, id: this_song_id})
        |> assign(form: to_form(Songs.get_changeset(), action: :new))}
    end


  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    dom_id = "#songs-#{id}"
    {:noreply, stream_delete_by_dom_id(socket, :songs, dom_id)}
  end


  @impl true
  def handle_info({:save, data}, socket) do
    {:noreply, stream_insert(socket, :songs, data)}
  end

end
