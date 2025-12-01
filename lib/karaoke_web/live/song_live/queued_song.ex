defmodule KaraokeWeb.QueuedSongLive do
  use KaraokeWeb, :live_component

  alias Karaoke.Party
  alias Karaoke.Party.Song

  @impl true
  def render(assigns) do

      ~H"""
      <div id={@song.id} >

      <%!-- Edit Song Form (if editing) --%>
      <.form :if={assigns.editing} id={"edit-queued-" <> @song.id} for={@form}  phx-target={@myself} phx-submit="save" class="edit-queued grid xs:grid-cols-2 sm:grid-cols-3" >
          <%!-- <span>{@song.id}</span> --%>
          <.input field={@form[:singer]} id={@song.id <> "-singer"} type="text" />
          <.input field={@form[:title]} id={@song.id <> "-title"} type="text" placeholder="song title"   />
          <div class="grid grid-cols-2 xs:grid-cols-3 gap-2 mb-2">
          <.button type="submit" variant="primary">Save</.button>
          <.button>Cancel</.button>
          </div>
      </.form>

      <%!-- Song Info + Actions (if not editing) --%>
      <div :if={!assigns.editing} id={"view-queued-" <> @song.id}
        class="w-full flex flex-col xs:flex-row gap-2 py-4">
          <span class="text-xl uppercase neon-text">{@song.singer} </span>
          <span class="text-lg">{@song.title}</span>

        <div class="grid grid-cols-1 xs:grid-cols-2 gap-2 mb-2">
          <.button variant="primary" phx-click="edit" phx-target={@myself}>
            <.icon name="hero-pencil-solid" />
            <span class="hidden xs:inline sm:hidden md:inline">Edit</span>
          </.button>
          <.button variant="primary" phx-click="delete" data-confirm="Delete this song?" phx-target={@myself}>
            <.icon name="hero-trash-solid" />
            <span class="hidden">Delete</span>
          </.button>
        </div>
      </div>


      </div>
      """

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
        |> assign(:form, to_form(changeset, action: :validate))
        # |> put_flash(:error, "Invalid song data"))
      }

    else
      new_song = Ecto.Changeset.apply_changes(changeset)
      dbg(new_song)
      new_queue = Party.edit_song(Party, new_song)

      {:noreply, socket
        |> assign(editing: false)
        |> assign(songs: new_queue)
        # |> put_flash(:info, "Song added to queue")
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
