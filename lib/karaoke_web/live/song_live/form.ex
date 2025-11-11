defmodule KaraokeWeb.SongLive.Form do
  use KaraokeWeb, :live_view

  alias Karaoke.Songs
  alias Karaoke.Songs.Song

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage song records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="song-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:singer]} type="text" label="Singer" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Song</.button>
          <.button navigate={return_path(@return_to, @song)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    song = Songs.get_song!(id)

    socket
    |> assign(:page_title, "Edit Song")
    |> assign(:song, song)
    |> assign(:form, to_form(Songs.change_song(song)))
  end

  defp apply_action(socket, :new, _params) do
    song = %Song{}

    socket
    |> assign(:page_title, "New Song")
    |> assign(:song, song)
    |> assign(:form, to_form(Songs.change_song(song)))
  end

  @impl true
  def handle_event("validate", %{"song" => song_params}, socket) do
    changeset = Songs.change_song(socket.assigns.song, song_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"song" => song_params}, socket) do
    save_song(socket, socket.assigns.live_action, song_params)
  end

  defp save_song(socket, :edit, song_params) do
    case Songs.update_song(socket.assigns.song, song_params) do
      {:ok, song} ->
        {:noreply,
         socket
         |> put_flash(:info, "Song updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, song))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_song(socket, :new, song_params) do
    case Songs.create_song(song_params) do
      {:ok, song} ->
        {:noreply,
         socket
         |> put_flash(:info, "Song created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, song))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _song), do: ~p"/songs"
  defp return_path("show", song), do: ~p"/songs/#{song}"
end
