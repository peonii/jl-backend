defmodule Api.Repo.Migrations.Balance do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :balance, :int, default: 0
    end
  end
end
