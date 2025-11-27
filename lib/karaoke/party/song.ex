defmodule Karaoke.Party.Song do
  use Ecto.Schema
  import Ecto.Changeset

  schema "song" do
    field :title, :string
    field :singer, :string
    field :position, :integer

    timestamps(type: :utc_datetime)
  end

  def to_changeset(attrs) do
    changeset(%Karaoke.Party.Song{}, attrs)
  end

  def changeset(song, attrs) do
    song
    |> cast(attrs, [:title, :singer])
    |> validate_required([:title, :singer])
  end


  def validate(songData) do
    changeset = to_changeset(songData)
    if (!changeset.valid?) do
      {:error, changeset}
    end
    {:ok, changeset}
  end

end
