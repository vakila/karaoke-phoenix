defmodule Karaoke.PartyTest do
  # use Karaoke.DataCase
  use ExUnit.Case

  alias Karaoke.Party

  describe "party" do
    alias Karaoke.Party.Song

    import Karaoke.PartyFixtures

    @invalid_attrs %{title: nil, singer: nil}

    test "list_songs/0 returns all songs" do
      songs = [song_fixture()]
      party = party_fixture(songs)
      assert Party.list_songs(party) == songs
    end

    # test "get_song!/1 returns the song with given id" do
    #   song = party_fixture()
    #   assert Party.get_song!(song.id) == song
    # end

    test "create_song/1 with valid data creates a song" do
      valid_attrs = %{title: "some title", singer: "some singer"}

      assert {:ok, %Song{} = song} = Party.add_song(valid_attrs)
      assert song.title == "some title"
      assert song.singer == "some singer"
    end

    test "create_song/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Party.add_song(@invalid_attrs)
    end

    test "update_song/2 with valid data updates the song" do
      song = party_fixture()
      update_attrs = %{title: "some updated title", singer: "some updated singer"}

      assert {:ok, %Song{} = song} = Party.update_song(song, update_attrs)
      assert song.title == "some updated title"
      assert song.singer == "some updated singer"
    end

    test "update_song/2 with invalid data returns error changeset" do
      song = party_fixture()
      assert {:error, %Ecto.Changeset{}} = Party.update_song(song, @invalid_attrs)
      assert song == Party.get_song!(song.id)
    end

    test "delete_song/1 deletes the song" do
      song = party_fixture()
      assert {:ok, %Song{}} = Party.delete_song(song)
      assert_raise Ecto.NoResultsError, fn -> Party.get_song!(song.id) end
    end

    test "change_song/1 returns a song changeset" do
      song = party_fixture()
      assert %Ecto.Changeset{} = Party.get_changeset(song)
    end
  end
end
