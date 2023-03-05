defmodule Api.Repo.Migrations.LastVeto do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :last_veto, :utc_datetime
    end
  end
end
