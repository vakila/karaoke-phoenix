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
      party = party_fixture([song_fixture()])
      assert length(party.queue) == 1
      list = Party.list_songs(party)
      # assert List.length(list) == 1
      song = List.pop_at(list, 0)
      assert song["title"] == "Closing Time"
    end

    # test "get_song!/1 returns the song with given id" do
    #   song = party_fixture()
    #   assert Party.get_song!(song.id) == song
    # end

    test "add_song/1 with valid data creates a song" do
      party = party_fixture()
      assert {:reply, song, party} = Party.add_song(party, @valid_attrs)
      # assert List.length(party.queue) == 1
      assert song.title == "some title"
      assert song.singer == "some singer"
    end

    test "add_song/1 with invalid data returns error changeset" do
      party = party_fixture()
      assert {:error, %Ecto.Changeset{}} = Party.add_song(party, @invalid_attrs)
    end

    test "edit_song/2 with valid data updates the song" do
      party = Karaoke.Party
      song = party.queue[0]
      update_attrs = %{title: "some updated title", singer: "some updated singer"}


      assert {:ok, %Song{} = song} = Party.edit_song(party, Enum.into(update_attrs, id: song.id))
      assert song.title == "some updated title"
      assert song.singer == "some updated singer"
    end

    test "edit_song/2 with invalid data returns error changeset" do
      song = song_fixture()
      party = party_fixture([song])

      assert {:error, %Ecto.Changeset{}} = Party.edit_song(party, Enum.into(@invalid_attrs, id: song.id))
      # assert [song] == Party.list_songs(party)
    end

    test "delete_song/1 deletes the song" do
      party = party_fixture()
      dbg(Party.add_song(party, @valid_attrs))
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
