defmodule KaraokeWeb.QueuedSongEditTest do
  # the queue lives in the app-wide Karaoke.Party, so these can't run async
  use KaraokeWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias Karaoke.Party
  alias Karaoke.Party.Song

  @video_id "fJ9rUzIMcZQ"

  setup do
    id = "test-" <> Integer.to_string(System.unique_integer([:positive]))

    song = %Song{
      id: id,
      singer: "Anna",
      title: "Bohemian Rhapsody",
      artist: "Queen",
      youtube_id: @video_id,
      youtube_title: "Queen - Bohemian Rhapsody (Karaoke)",
      embeddable: true
    }

    Party.add_song(Party, song)
    on_exit(fn -> Party.delete_song(Party, id) end)

    %{song: song}
  end

  defp queued(id), do: Enum.find(Party.list_songs(Party), &(&1.id == id))

  defp start_editing(conn, song) do
    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("#view-queued-#{song.id} button", "Edit") |> render_click()
    view
  end

  defp change(view, song, fields) do
    view |> form("#edit-queued-#{song.id}", edit: fields) |> render_change()
  end

  defp submit_button(song, mode_title) do
    "#edit-submit-#{song.id}[title^='#{mode_title}']"
  end

  test "the current video shows while editing, not in the queue", %{conn: conn, song: song} do
    {:ok, view, _html} = live(conn, ~p"/")

    refute view
           |> element("#view-queued-#{song.id}")
           |> render() =~ "Queen - Bohemian Rhapsody (Karaoke)"

    view |> element("#view-queued-#{song.id} button", "Edit") |> render_click()

    assert view
           |> element("#editing-queued-#{song.id}")
           |> render() =~ "Queen - Bohemian Rhapsody (Karaoke)"

    # and its thumbnail opens the video on YouTube
    assert has_element?(
             view,
             "#editing-queued-#{song.id} a[href='https://www.youtube.com/watch?v=#{@video_id}'][target='_blank']"
           )
  end

  test "changing only the singer saves and keeps the video", %{conn: conn, song: song} do
    view = start_editing(conn, song)
    change(view, song, %{singer: "Anna K", title: "Bohemian Rhapsody", artist: "Queen"})
    assert has_element?(view, submit_button(song, "Save"))

    view |> form("#edit-queued-#{song.id}") |> render_submit()

    assert %Song{singer: "Anna K", youtube_id: @video_id} = queued(song.id)
    refute has_element?(view, "#edit-queued-#{song.id}")
  end

  test "case/whitespace-only title fixes still count as the same song", %{conn: conn, song: song} do
    view = start_editing(conn, song)
    change(view, song, %{singer: "Anna", title: "  bohemian rhapsody ", artist: "QUEEN"})
    assert has_element?(view, submit_button(song, "Save"))
  end

  test "changing the title turns Save into Search", %{conn: conn, song: song} do
    view = start_editing(conn, song)
    change(view, song, %{singer: "Anna", title: "Africa", artist: "Toto"})
    assert has_element?(view, submit_button(song, "Song changed"))

    # changing it back to the original song goes back to Save
    change(view, song, %{singer: "Anna", title: "Bohemian Rhapsody", artist: "Queen"})
    assert has_element?(view, submit_button(song, "Save"))
  end

  test "save without video clears the old video", %{conn: conn, song: song} do
    view = start_editing(conn, song)
    change(view, song, %{singer: "Anna", title: "Africa", artist: "Toto"})

    view |> with_target("##{song.id}") |> render_click("save_without_video", %{})

    assert %Song{title: "Africa", artist: "Toto", youtube_id: nil} = queued(song.id)
  end

  test "cancel doesn't save", %{conn: conn, song: song} do
    view = start_editing(conn, song)
    change(view, song, %{singer: "Someone else", title: "Bohemian Rhapsody", artist: "Queen"})

    view |> element("#edit-cancel-#{song.id}") |> render_click()

    assert %Song{singer: "Anna"} = queued(song.id)
    refute has_element?(view, "#edit-queued-#{song.id}")
  end

  test "edit form stays open when someone else changes the queue", %{conn: conn, song: song} do
    view = start_editing(conn, song)
    change(view, song, %{singer: "Anna", title: "Africa", artist: "Toto"})

    other = %Song{id: song.id <> "-other", singer: "Bo", title: "Closing Time"}
    Party.add_song(Party, other)
    on_exit(fn -> Party.delete_song(Party, other.id) end)

    assert has_element?(view, "#view-queued-#{other.id}")
    assert has_element?(view, "#edit-queued-#{song.id}")
    assert has_element?(view, submit_button(song, "Song changed"))
  end

  test "editing a song that already left the queue doesn't crash the party", %{song: song} do
    pid = Process.whereis(Party)
    Party.delete_song(Party, song.id)

    Party.edit_song(Party, %{song | title: "Africa"})

    assert Process.whereis(Party) == pid
    refute queued(song.id)
  end
end
