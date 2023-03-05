defmodule Api.Route.Team do
  use Plug.Router
  alias Api.{Repo, Model.Team, Model.Quest}

  plug(CORSPlug)
  plug(:match)
  plug(Plug.Parsers, parsers: [:urlencoded, :json], json_decoder: Jason)
  plug(:dispatch)

  get "/" do
    auth = get_req_header(conn, "authorization")

    team = Team
      |> Repo.get_by(password: Enum.at(auth, 0))
      |> Repo.preload(:quests)

    conn |> send_resp(200, Jason.encode!(team))
  end

  get "/status" do
    auth = get_req_header(conn, "authorization")

    team = Team
      |> Repo.get_by(password: Enum.at(auth, 0))
      |> Repo.preload(:quests)

    conn |> send_resp(200, Jason.encode!(%{ status: team != nil }))
  end

  post "/balance" do
    auth = get_req_header(conn, "authorization")

    subtract = conn.body_params["subtract"]

    team = Team
      |> Repo.get_by(password: Enum.at(auth, 0))

    if team.balance - subtract >= 0 do
      changeset = Ecto.Changeset.change(team, %{balance: team.balance - subtract})

      {:ok, team} = Repo.update(changeset)

      conn |> send_resp(200, Jason.encode!(team))
    else
      conn |> send_resp(400, Jason.encode!(%{error: "Invalid balance after operation!"}))
    end
  end

  post "/double" do
    auth = get_req_header(conn, "authorization")

    team = Team
      |> Repo.get_by(password: Enum.at(auth, 0))

    changeset = Ecto.Changeset.change(team, %{double: true})

    {:ok, team} = Repo.update(changeset)

    conn |> send_resp(200, Jason.encode!(team))
  end
end
