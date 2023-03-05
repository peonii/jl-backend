defmodule Api.Router do
  use Plug.Router

  plug(CORSPlug)
  plug(:match)
  plug(Plug.Parsers, parsers: [:urlencoded, :json], json_decoder: Jason)
  plug(:dispatch)

  forward "/api", to: Api.Route.Api
end
