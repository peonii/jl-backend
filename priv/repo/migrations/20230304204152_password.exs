defmodule Api.Repo.Migrations.Password do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :password, :string
    end
  end
end
