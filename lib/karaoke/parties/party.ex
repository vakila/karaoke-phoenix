defmodule Karaoke.Parties.Party do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parties" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(party, attrs) do
    party
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
