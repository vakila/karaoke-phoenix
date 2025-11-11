defmodule Karaoke.Songs.Song do
  use Ecto.Schema
  import Ecto.Changeset

  schema "songs" do
    field :title, :string
    field :singer, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(song, attrs) do
    song
    |> cast(attrs, [:title, :singer])
    |> validate_required([:title, :singer])
  end
end
