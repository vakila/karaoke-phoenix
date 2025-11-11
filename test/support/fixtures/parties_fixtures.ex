defmodule Karaoke.PartiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Karaoke.Parties` context.
  """

  @doc """
  Generate a party.
  """
  def party_fixture(attrs \\ %{}) do
    {:ok, party} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Karaoke.Parties.create_party()

    party
  end
end
