defmodule KaraokeWeb.QueuedSongLive do
  use KaraokeWeb, :live_component

  alias Karaoke.Party.Song

  @impl true
  def render(assigns) do
    editing = assigns.editing
    if editing do
    ~H"""
    <div id={@song.id} class="flex">
    <.form for={@form} id="edit-song-form" phx-target={@myself} phx-submit="save" class="grid grid-cols-3 gap-2 py-2">
          <%!-- <span>{@song.id}</span> --%>
          <.input field={@form[:title]} id={@song.id <> "-title"} type="text" />
          <.input field={@form[:singer]} id={@song.id <> "-singer"} type="text" />
          <.button>Save</.button>
      </.form>
    </div>
    """
    else
      ~H"""
      <div id={@song.id} class="grid grid-cols-3 gap-2 py-2">
        <%!-- <span>{@song.id}</span> --%>
        <span>{@song.title}</span>
        <span>{@song.singer}</span>
        <%!-- <span>Editing? {@editing}</span> --%>
        <.button phx-click="edit" phx-target={@myself}>Edit</.button>

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
  def handle_event("save", %{"title" => title, "singer" => singer}, socket) do
    data = Song.changeset(socket.assigns.song, %{title: title, singer: singer, id: socket.assigns.song.id})
    send(self(), {:save, data})
    {:noreply, socket
      |> assign(editing: false)
    }
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
