defmodule KaraokeWeb.QueuedSongLive do
  @moduledoc """
  A song waiting in the queue, with inline editing.

  Editing re-searches YouTube when the song itself changes. The edit form's
  main button is in one of three modes:

    * `:save` - the title/artist are unchanged (e.g. only fixing the singer's
      name), so saving keeps the song's current video.
    * `:search` - the title or artist changed, so the old video is probably
      wrong; submitting searches YouTube for the new song.
    * `:pick` - results for the current title/artist are showing; pick one
      or "Save without video". Changing the title/artist again re-enables
      searching.
  """
  use KaraokeWeb, :live_component

  alias Karaoke.Party
  alias Karaoke.Party.Song

  @fields ~w(singer title artist)

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@song.id} class="w-full py-4">
      <%!-- Edit Song Form (if editing) --%>
      <div :if={@editing} id={"editing-queued-" <> @song.id} class="w-full">
        <.form
          id={"edit-queued-" <> @song.id}
          for={@form}
          phx-target={@myself}
          phx-change="change"
          phx-submit="submit"
          class="edit-queued w-full grid sm:grid-cols-4 items-center gap-2"
        >
          <.input
            field={@form[:singer]}
            id={@song.id <> "-singer"}
            type="text"
            placeholder="performer name"
          />
          <.input
            field={@form[:title]}
            id={@song.id <> "-title"}
            type="text"
            placeholder="song title"
          />
          <.input
            field={@form[:artist]}
            id={@song.id <> "-artist"}
            type="text"
            placeholder="song artist"
          />
          <%!-- main button takes the spare width so "Search" fits; X is icon-sized --%>
          <div class="grid xs:grid-cols-[1fr_auto] gap-2 mb-2">
            <.button
              id={"edit-submit-" <> @song.id}
              type="submit"
              variant="primary"
              disabled={@mode == :pick}
              title={submit_title(@mode)}
              phx-disable-with={if @mode == :search, do: "Searching..."}
            >
              <%= if @mode == :save do %>
                <.icon name="hero-check" />
                <span class="hidden xxs:max-sm:inline md:inline uppercase">Save</span>
              <% else %>
                <.icon name="hero-magnifying-glass" />
                <span class="hidden xxs:max-sm:inline md:inline uppercase">Search</span>
              <% end %>
            </.button>
            <.button
              id={"edit-cancel-" <> @song.id}
              type="button"
              phx-click="cancel"
              phx-target={@myself}
            >
              <.icon name="hero-x-mark" />
              <span class="hidden xxs:max-xs:inline uppercase">Cancel</span>
            </.button>
          </div>
        </.form>

        <.video_line song={@song} label="Current video:" />

        <p :if={@searching} class="py-2">Searching YouTube…</p>
        <p :if={@search_error} class="py-2 text-error">{@search_error}</p>

        <div
          :if={!@searching && (@searched_for || @search_error)}
          id={"edit-results-" <> @song.id}
          class="space-y-2 py-2"
        >
          <div :for={video <- @search_results} class="flex items-center gap-3 border rounded p-2">
            <.video_thumbnail_link video={video} />
            <div class="flex-1 min-w-0 text-left">
              <p class="font-semibold truncate">{video.title}</p>
              <p :if={video.channel} class="text-sm opacity-70 truncate">{video.channel}</p>
            </div>
            <.button
              variant="neon-secondary"
              phx-click="use_video"
              phx-target={@myself}
              phx-value-video_id={video.id}
              phx-value-video_title={video.title}
            >
              Use this
            </.button>
          </div>
          <.button
            id={"edit-no-video-" <> @song.id}
            variant="neon-secondary"
            phx-click="save_without_video"
            phx-target={@myself}
          >
            Save without video
          </.button>
        </div>
      </div>

      <%!-- Song Info + Actions (if not editing) --%>
      <div
        :if={!@editing}
        id={"view-queued-" <> @song.id}
        class="view-queued w-full grid sm:grid-cols-4 gap-2"
      >
        <span class="text-xl uppercase neon-text">{@song.singer}</span>
        <span class="text-lg">{@song.title}</span>
        <span :if={@song.artist} class="text-lg">{@song.artist}</span>

        <div class="grid xs:grid-cols-2 gap-2 mb-2">
          <.button variant="primary" phx-click="edit" phx-target={@myself}>
            <.icon name="hero-pencil" />
            <span class="hidden xxs:max-sm:inline md:inline uppercase">Edit</span>
          </.button>
          <.button
            variant="primary"
            phx-click="delete"
            data-confirm="Delete this song?"
            phx-target={@myself}
          >
            <.icon name="hero-trash" />
            <span class="hidden xxs:max-sm:inline md:inline uppercase">Delete</span>
          </.button>
        </div>
      </div>
    </div>
    """
  end

  attr :song, Song, required: true
  attr :label, :string, default: nil

  # which video a song is set to play, shown while editing so you can tell
  # whether it still fits
  defp video_line(assigns) do
    ~H"""
    <div class="flex items-center justify-center sm:justify-start gap-2 text-sm opacity-70 min-w-0">
      <span :if={@label} class="shrink-0">{@label}</span>
      <%= if Karaoke.YouTube.valid_id?(@song.youtube_id) do %>
        <.video_thumbnail_link
          video={
            %{
              id: @song.youtube_id,
              title: @song.youtube_title || @song.title,
              thumbnail: "https://i.ytimg.com/vi/#{@song.youtube_id}/mqdefault.jpg"
            }
          }
          class="w-16 aspect-video"
          icon_class="size-5"
        />
        <span class="truncate">{@song.youtube_title || "YouTube video"}</span>
      <% else %>
        <.icon name="hero-video-camera-slash" class="size-4 shrink-0" />
        <span>No video picked (opens a YouTube search)</span>
      <% end %>
    </div>
    """
  end

  defp submit_title(:save), do: "Save changes"
  defp submit_title(:search), do: "Song changed: search YouTube for a new video"
  defp submit_title(:pick), do: "Pick a video below, or change the song to search again"

  @impl true
  def update(assigns, socket) do
    # `editing` and search state belong to this component, so a re-render of
    # the queue (e.g. someone else adding a song) doesn't close the edit form
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:editing, fn -> false end)
     |> assign_new(:fields, fn -> %{} end)
     |> reset_search()
     |> put_mode()}
  end

  @impl true
  def handle_event("edit", _params, socket) do
    song = socket.assigns.song
    fields = %{"singer" => song.singer, "title" => song.title, "artist" => song.artist}

    {:noreply,
     socket
     |> assign(editing: true)
     |> clear_search()
     |> put_fields(fields)}
  end

  def handle_event("change", %{"edit" => params}, socket) do
    {:noreply, put_fields(socket, Map.take(params, @fields))}
  end

  def handle_event("submit", %{"edit" => params}, socket) do
    socket = put_fields(socket, Map.take(params, @fields))

    case socket.assigns.mode do
      :save -> {:noreply, save(socket, %{})}
      :search -> {:noreply, search(socket)}
      :pick -> {:noreply, socket}
    end
  end

  def handle_event("use_video", %{"video_id" => id, "video_title" => title}, socket) do
    video = %{
      "youtube_id" => id,
      "youtube_title" => title,
      "embeddable" => Karaoke.YouTube.embeddable?(id)
    }

    {:noreply, save(socket, video)}
  end

  def handle_event("save_without_video", _params, socket) do
    no_video = %{"youtube_id" => nil, "youtube_title" => nil, "embeddable" => nil}
    {:noreply, save(socket, no_video)}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, socket |> assign(editing: false) |> clear_search()}
  end

  def handle_event("delete", _params, socket) do
    Party.delete_song(Party, socket.assigns.song.id)
    {:noreply, socket}
  end

  @impl true
  def handle_async(:youtube_search, {:ok, {:ok, results}}, socket) do
    {:noreply, socket |> assign(searching: false, search_results: results) |> put_mode()}
  end

  def handle_async(:youtube_search, {:ok, {:error, reason}}, socket) do
    {:noreply, search_failed(socket, reason)}
  end

  def handle_async(:youtube_search, {:exit, reason}, socket) do
    {:noreply, search_failed(socket, reason)}
  end

  # forget the failed search so the Search button is enabled to retry
  defp search_failed(socket, reason) do
    socket
    |> assign(searching: false, searched_for: nil, search_error: inspect(reason))
    |> put_mode()
  end

  # -- helpers

  defp put_fields(socket, fields) do
    socket = assign(socket, fields: fields)

    # results for a different title/artist are stale; drop them so the
    # search button is enabled again
    socket =
      if socket.assigns.searched_for && query_key(fields) != socket.assigns.searched_for do
        clear_search(socket)
      else
        socket
      end

    socket
    |> assign(form: to_form(fields, as: :edit))
    |> put_mode()
  end

  defp put_mode(socket) do
    %{song: song, fields: fields, searched_for: searched_for} = socket.assigns
    key = query_key(fields)

    mode =
      cond do
        key == query_key(song) -> :save
        key == searched_for -> :pick
        true -> :search
      end

    assign(socket, mode: mode)
  end

  defp search(socket) do
    changeset = Song.changeset(socket.assigns.song, socket.assigns.fields)

    if changeset.valid? do
      %{title: title, artist: artist} = Ecto.Changeset.apply_changes(changeset)
      query = [title, artist, "karaoke"] |> Enum.reject(&(&1 in [nil, ""])) |> Enum.join(" ")

      socket
      |> assign(
        searching: true,
        searched_for: query_key(socket.assigns.fields),
        search_results: [],
        search_error: nil
      )
      |> put_mode()
      |> start_async(:youtube_search, fn -> Karaoke.YouTube.search(query) end)
    else
      assign(socket, form: to_form(changeset, as: :edit, action: :validate))
    end
  end

  defp save(socket, video_attrs) do
    attrs = Map.merge(socket.assigns.fields, video_attrs)
    changeset = Song.changeset(socket.assigns.song, attrs)

    if changeset.valid? do
      Party.edit_song(Party, Ecto.Changeset.apply_changes(changeset))
      socket |> assign(editing: false) |> clear_search()
    else
      assign(socket, form: to_form(changeset, as: :edit, action: :validate))
    end
  end

  defp reset_search(socket) do
    socket
    |> assign_new(:searching, fn -> false end)
    |> assign_new(:searched_for, fn -> nil end)
    |> assign_new(:search_results, fn -> [] end)
    |> assign_new(:search_error, fn -> nil end)
  end

  defp clear_search(socket) do
    socket
    |> cancel_async(:youtube_search)
    |> assign(searching: false, searched_for: nil, search_results: [], search_error: nil)
  end

  # what identifies "the song" for deciding whether the video still fits:
  # title + artist, ignoring case and surrounding whitespace
  defp query_key(%Song{title: title, artist: artist}), do: {normalize(title), normalize(artist)}
  defp query_key(%{} = fields), do: {normalize(fields["title"]), normalize(fields["artist"])}

  defp normalize(nil), do: ""
  defp normalize(value), do: value |> String.trim() |> String.downcase()
end
