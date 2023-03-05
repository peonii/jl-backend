defmodule Api.Repo.Migrations.CreateStructs do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
    end

    create table(:quests) do
      add :content, :string
      add :type, :string
      add :reward, :int
      add :team_id, references(:teams)
    end
  end
end
