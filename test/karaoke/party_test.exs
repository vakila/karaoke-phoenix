defmodule Karaoke.PartyTest do
  # use Karaoke.DataCase
  use ExUnit.Case

  alias Karaoke.Party

  describe "party" do
    alias Karaoke.Party.Song

    import Karaoke.PartyFixtures

    @invalid_attrs %{title: nil, singer: nil}

    @valid_attrs %{title: "Closing Time", singer: "Everyone"}

    test "list_songs/0 returns all songs" do
      dbg(party_fixture([song_fixture()]))
      party = party_fixture([song_fixture()])
      assert length(party.queue) == 1
      assert Party.list_songs(party) == [song_fixture()]
    end

    # test "get_song!/1 returns the song with given id" do
    #   song = party_fixture()
    #   assert Party.get_song!(song.id) == song
    # end

    test "add_song/1 with valid data creates a song" do
      party = party_fixture()
      assert {:ok, %Song{} = song, party} = Party.add_song(party, @valid_attrs)
      assert length(party.queue) == 1
      assert song.title == "some title"
      assert song.singer == "some singer"
    end

    test "add_song/1 with invalid data returns error changeset" do
      party = party_fixture()
      assert {:error, %Ecto.Changeset{}} = Party.add_song(party, @invalid_attrs)
    end

    test "update_song/2 with valid data updates the song" do
      party = party_fixture()
      [song] = party.queue
      update_attrs = %{title: "some updated title", singer: "some updated singer"}

      assert {:ok, %Song{} = song} = Party.update_song(party, song, update_attrs)
      assert song.title == "some updated title"
      assert song.singer == "some updated singer"
    end

    test "update_song/2 with invalid data returns error changeset" do
      party = party_fixture()
      [song] = Party.list_songs(party)

      assert {:error, %Ecto.Changeset{}} = Party.update_song(party, song, @invalid_attrs)
      assert [song] == Party.list_songs(party)
    end

    test "delete_song/1 deletes the song" do
      party = party_fixture()
      {:reply, song, party} = Party.add_song(party, @valid_attrs)
      assert {:ok, %Song{}} = Party.delete_song(party, song)
      # assert_raise Ecto.NoResultsError, fn -> Party.get_song!(song.id) end
      assert [] == party.queue
    end

    test "Song.to_changeset/1 returns a song changeset" do
      assert %Ecto.Changeset{} = Song.to_changeset(@valid_attrs)
    end
  end
end
