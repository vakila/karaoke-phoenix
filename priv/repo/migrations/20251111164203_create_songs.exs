defmodule Karaoke.Repo.Migrations.CreateSongs do
  use Ecto.Migration

  def change do
    create table(:songs) do
      add :title, :string
      add :singer, :string

      timestamps(type: :utc_datetime)
    end
  end
end
