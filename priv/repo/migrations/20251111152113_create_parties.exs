defmodule Karaoke.Repo.Migrations.CreateParties do
  use Ecto.Migration

  def change do
    create table(:parties) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
