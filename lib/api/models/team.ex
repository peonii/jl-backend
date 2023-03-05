defmodule Api.Model.Team do
  use Ecto.Schema

  @derive {Jason.Encoder, only: [:name, :password, :balance, :last_veto, :double]}
  schema "teams" do
    field :name, :string
    field :password, :string
    field :balance, :integer
    field :last_veto, :utc_datetime
    field :double, :boolean
    has_many :quests, Api.Model.Quest
  end
end
