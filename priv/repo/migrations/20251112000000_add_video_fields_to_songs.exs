defmodule Karaoke.Repo.Migrations.AddVideoFieldsToSongs do
  use Ecto.Migration

  def change do
    alter table(:songs) do
      add :artist, :string
      add :youtube_id, :string
      add :youtube_title, :string
      add :embeddable, :boolean
    end
  end
end