defmodule Karaoke.SongsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Karaoke.Songs` context.
  """

  @doc """
  Generate a song.
  """
  def song_fixture(attrs \\ %{}) do
    {:ok, song} =
      attrs
      |> Enum.into(%{
        singer: "some singer",
        title: "some title"
      })
      |> Karaoke.Songs.create_song()

    song
  end
end
