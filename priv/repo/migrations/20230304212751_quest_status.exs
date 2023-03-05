defmodule Api.Repo.Migrations.QuestStatus do
  use Ecto.Migration

  def change do
    alter table(:quests) do
      add :complete, :boolean
    end
  end
end
