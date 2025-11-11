defmodule Karaoke.SongsTest do
  use Karaoke.DataCase

  alias Karaoke.Songs

  describe "songs" do
    alias Karaoke.Songs.Song

    import Karaoke.SongsFixtures

    @invalid_attrs %{title: nil, singer: nil}

    test "list_songs/0 returns all songs" do
      song = song_fixture()
      assert Songs.list_songs() == [song]
    end

    test "get_song!/1 returns the song with given id" do
      song = song_fixture()
      assert Songs.get_song!(song.id) == song
    end

    test "create_song/1 with valid data creates a song" do
      valid_attrs = %{title: "some title", singer: "some singer"}

      assert {:ok, %Song{} = song} = Songs.create_song(valid_attrs)
      assert song.title == "some title"
      assert song.singer == "some singer"
    end

    test "create_song/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Songs.create_song(@invalid_attrs)
    end

    test "update_song/2 with valid data updates the song" do
      song = song_fixture()
      update_attrs = %{title: "some updated title", singer: "some updated singer"}

      assert {:ok, %Song{} = song} = Songs.update_song(song, update_attrs)
      assert song.title == "some updated title"
      assert song.singer == "some updated singer"
    end

    test "update_song/2 with invalid data returns error changeset" do
      song = song_fixture()
      assert {:error, %Ecto.Changeset{}} = Songs.update_song(song, @invalid_attrs)
      assert song == Songs.get_song!(song.id)
    end

    test "delete_song/1 deletes the song" do
      song = song_fixture()
      assert {:ok, %Song{}} = Songs.delete_song(song)
      assert_raise Ecto.NoResultsError, fn -> Songs.get_song!(song.id) end
    end

    test "change_song/1 returns a song changeset" do
      song = song_fixture()
      assert %Ecto.Changeset{} = Songs.change_song(song)
    end
  end
end
