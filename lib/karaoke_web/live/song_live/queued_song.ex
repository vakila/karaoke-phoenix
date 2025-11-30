defmodule KaraokeWeb.QueuedSongLive do
  use KaraokeWeb, :live_component

  alias Karaoke.Party
  alias Karaoke.Party.Song

  @impl true
  def render(assigns) do
    if assigns.editing do
    ~H"""
    <div id={@song.id} class="flex py2">
    <.form for={@form} id="edit-song-form" phx-target={@myself} phx-submit="save" class="grid grid-cols-3 gap-2 py-4">
          <%!-- <span>{@song.id}</span> --%>
          <.input field={@form[:title]} id={@song.id <> "-title"} type="text" />
          <.input field={@form[:singer]} id={@song.id <> "-singer"} type="text" />
          <.button>Save</.button>
      </.form>
    </div>
    """
    else
      ~H"""
      <div id={@song.id} class="grid grid-cols-4 gap-2 py-4">
        <%!-- <span>{@song.id}</span> --%>
        <span>{@song.title}</span>
        <span>{@song.singer}</span>
        <%!-- <span>Editing? {@editing}</span> --%>
        <.button variant="primary" phx-click="edit" phx-target={@myself}>Edit</.button>
        <.button variant="primary" phx-click="delete" phx-target={@myself}>Delete</.button>
      </div>
      """

    end

  end

  @impl true
  def handle_event("edit", _params, socket) do
    song = socket.assigns.song
    {:noreply, socket
      |> assign(form: to_form(%{"title" => song.title, "singer" => song.singer, "id" => song.id}, action: :save ))
      |> assign(editing: true)
    }
  end

  @impl true
  def handle_event("save", new_params, socket) do
    old_song = socket.assigns.song
    dbg(old_song)
    song_id = old_song.id
    dbg(song_id)
    changeset = Song.changeset(old_song, new_params)
    dbg(changeset)


    if !changeset.valid? do
      {:noreply, socket
        |> assign(:form, to_form(changeset, action: :validate)
        |> put_flash(:error, "Invalid song data"))}

    else
      new_song = Ecto.Changeset.apply_changes(changeset)
      dbg(new_song)
      new_queue = Party.edit_song(Party, new_song)

      {:noreply, socket
        |> assign(editing: false)
        |> assign(songs: new_queue)
        |> put_flash(:info, "Song added to queue")
        |> assign(form: to_form(%{}, action: :new))}
    end

  end


  @impl true
  def handle_event("delete", _params, socket) do
    song = socket.assigns.song
    new_queue = Party.delete_song(Party, song.id)
    {:noreply, assign(socket, songs: new_queue)}
  end


  @impl true
  def update(assigns, socket) do
    assigns |> dbg
    {:ok, assign(socket, assigns)}
  end

  # @impl true
  # def mount(socket) do
  #   {:ok, socket |> assign(socket.assigns)}
  # end
end
