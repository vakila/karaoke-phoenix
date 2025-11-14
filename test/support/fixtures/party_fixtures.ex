defmodule Karaoke.PartyFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Karaoke.Party` context.
  """
  alias Karaoke.Party.Song

  @doc """
  Generate a song.
  """
  def song_fixture(attrs \\ %{title: "Closing Time", singer: "Everyone", id: "Everyone-Closing Time"}) do
    %{"title" => title, "singer" => singer, "id" => id} = attrs
    %Song{title: title, singer: singer, id: id}
  end

  @doc """
  Generate a party with a list of songs.
  """
  def party_fixture(songs \\ [song_fixture()]) do
    %{queue: songs}
  end
end
