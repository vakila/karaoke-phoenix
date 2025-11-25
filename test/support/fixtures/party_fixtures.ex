defmodule Karaoke.PartyFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Karaoke.Party` context.
  """
  alias Karaoke.Party
  alias Karaoke.Party.Song

  @doc """
  Generate a song.
  """
  def song_fixture() do
    %Song{title: "Closing Time", singer: "Everyone", id: "Everyone-Closing Time"}
  end

  @doc """
  Generate a party with a list of songs.
  """
  def party_fixture(songs \\ []) do
    Party.subscribe(Party)
    party = Party.list_songs(Party)
    dbg(party)
    for(song <- songs) do
      Party.add_song(party, song)
    end
    Party.list_songs(Party)
  end

end
