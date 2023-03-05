defmodule Api.Route.Api do
  use Plug.Router

  plug(CORSPlug)
  plug(:match)
  plug(Plug.Parsers, parsers: [:urlencoded, :json], json_decoder: Jason)
  plug(:dispatch)

  forward "/quests", to: Api.Route.Quests
  forward "/team", to: Api.Route.Team
end
