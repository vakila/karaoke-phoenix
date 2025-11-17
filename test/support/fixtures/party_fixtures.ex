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
  def party_fixture() do
    {:ok, pid} = Party.start_link([])
    {:reply, _queue, party} = GenServer.call(pid, {:list})
    IO.puts(party)
    party
  end

  def party_fixture(songs) do
    GenServer.start_link(Party, songs)

  end
end
