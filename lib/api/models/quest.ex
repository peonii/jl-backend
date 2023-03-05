defmodule Api.Model.Quest do
  use Ecto.Schema

  @derive {Jason.Encoder, only: [:id, :content, :type, :reward, :complete]}
  schema "quests" do
    field :content, :string
    field :type, :string
    field :reward, :integer
    field :complete, :boolean
    belongs_to :team, Api.Model.Team
  end
end
