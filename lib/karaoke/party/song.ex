defmodule Karaoke.Party.Song do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :title, :string
    field :singer, :string
    field :position, :integer

    timestamps(type: :utc_datetime)
  end

  def to_changeset(attrs) do
    changeset(%{}, attrs)
  end

  def changeset(song, attrs) do
    song
    |> cast(attrs, [:title, :singer])
    |> validate_required([:title, :singer])
  end
end
