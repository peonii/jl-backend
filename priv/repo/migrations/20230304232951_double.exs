defmodule Api.Repo.Migrations.Double do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :double, :boolean, default: false
    end
  end
end
