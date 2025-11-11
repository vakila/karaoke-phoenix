defmodule KaraokeWeb.SongLiveTest do
  use KaraokeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Karaoke.SongsFixtures

  @create_attrs %{title: "some title", singer: "some singer"}
  @update_attrs %{title: "some updated title", singer: "some updated singer"}
  @invalid_attrs %{title: nil, singer: nil}
  defp create_song(_) do
    song = song_fixture()

    %{song: song}
  end

  describe "Index" do
    setup [:create_song]

    test "lists all songs", %{conn: conn, song: song} do
      {:ok, _index_live, html} = live(conn, ~p"/songs")

      assert html =~ "Listing Songs"
      assert html =~ song.title
    end

    test "saves new song", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/songs")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Song")
               |> render_click()
               |> follow_redirect(conn, ~p"/songs/new")

      assert render(form_live) =~ "New Song"

      assert form_live
             |> form("#song-form", song: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#song-form", song: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/songs")

      html = render(index_live)
      assert html =~ "Song created successfully"
      assert html =~ "some title"
    end

    test "updates song in listing", %{conn: conn, song: song} do
      {:ok, index_live, _html} = live(conn, ~p"/songs")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#songs-#{song.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/songs/#{song}/edit")

      assert render(form_live) =~ "Edit Song"

      assert form_live
             |> form("#song-form", song: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#song-form", song: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/songs")

      html = render(index_live)
      assert html =~ "Song updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes song in listing", %{conn: conn, song: song} do
      {:ok, index_live, _html} = live(conn, ~p"/songs")

      assert index_live |> element("#songs-#{song.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#songs-#{song.id}")
    end
  end

  describe "Show" do
    setup [:create_song]

    test "displays song", %{conn: conn, song: song} do
      {:ok, _show_live, html} = live(conn, ~p"/songs/#{song}")

      assert html =~ "Show Song"
      assert html =~ song.title
    end

    test "updates song and returns to show", %{conn: conn, song: song} do
      {:ok, show_live, _html} = live(conn, ~p"/songs/#{song}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/songs/#{song}/edit?return_to=show")

      assert render(form_live) =~ "Edit Song"

      assert form_live
             |> form("#song-form", song: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#song-form", song: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/songs/#{song}")

      html = render(show_live)
      assert html =~ "Song updated successfully"
      assert html =~ "some updated title"
    end
  end
end
