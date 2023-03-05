defmodule Api.Route.Quests do
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

    quests = team.quests

    conn |> send_resp(200, Jason.encode!(quests))
  end

  get "/side" do
    auth = get_req_header(conn, "authorization")

    has_side_quest = Team
      |> Repo.get_by(password: Enum.at(auth, 0))
      |> Repo.preload(:quests)
      |> Map.get(:quests)
      |> Enum.any?(fn quest -> quest.type == "SIDE" && !quest.complete end)

    conn |> send_resp(200, Jason.encode!(%{status: !has_side_quest}))
  end

  post "/side" do
    auth = get_req_header(conn, "authorization")

    team = Team
      |> Repo.get_by(password: Enum.at(auth, 0))
      |> Repo.preload(:quests)

    is_vetoed = DateTime.compare(team.last_veto, DateTime.utc_now()) == :gt

    if !is_vetoed do
      has_side_quest = team
        |> Map.get(:quests)
        |> Enum.any?(fn quest -> quest.type == "SIDE" && !quest.complete end)

      if !has_side_quest do
        possible_quests = [
          %{content: "free", reward: 300}
        ]

        {:ok, quest} = Team
          |> Repo.get_by(password: Enum.at(auth, 0))
          |> Ecto.build_assoc(:quests)
          |> Ecto.Changeset.cast(
            Map.merge(Enum.random(possible_quests), %{complete: false, type: "SIDE"}), [:content, :complete, :type, :reward]
          )
          |> Repo.insert()

        conn |> send_resp(200, Jason.encode!(quest))
      else
        conn |> send_resp(401, Jason.encode!(%{ error: "You already have a side quest!" }))
      end
    else
      conn |> send_resp(401, Jason.encode!(%{ error: "You're vetoing a quest right now!" }))
    end
  end

  get "/veto" do
    auth = get_req_header(conn, "authorization")

    team = Team
      |> Repo.get_by(password: Enum.at(auth, 0))
      |> Repo.preload(:quests)

    is_vetoed = DateTime.compare(team.last_veto, DateTime.utc_now()) == :gt

    conn |> send_resp(200, Jason.encode!(%{ veto: team.last_veto, now: DateTime.utc_now(), status: is_vetoed }))
  end

  post "/veto" do
    auth = get_req_header(conn, "authorization")

    team = Team
      |> Repo.get_by(password: Enum.at(auth, 0))
      |> Repo.preload(:quests)

    if team.last_veto != nil && DateTime.compare(team.last_veto, DateTime.utc_now()) != :gt do
      quest = team
        |> Map.get(:quests)
        |> Enum.find(fn quest -> quest.type == "SIDE" && !quest.complete end)

      if quest != nil do
        changeset = Ecto.Changeset.change(quest, %{complete: true})
        Repo.update(changeset)

        last_veto = DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.add(20, :minute)

        changeset = Ecto.Changeset.change(team, %{last_veto: last_veto})
        {:ok, team} = Repo.update(changeset)

        conn |> send_resp(200, Jason.encode!(team))
      else
        conn |> send_resp(404, Jason.encode!(%{ error: "No quest to veto!" }))
      end
    else
      conn |> send_resp(401, Jason.encode!(%{ error: "You're already vetoing a quest!" }))
    end
  end

  post "/complete/:id" do
    auth = get_req_header(conn, "authorization")
    {id, _} = conn.params["id"] |> Integer.parse

    quest =
      Quest
      |> Repo.get(id)

    changeset = Ecto.Changeset.change(quest, %{complete: true})

    {:ok, quest} = Repo.update(changeset)

    if quest.complete == false do
      team = Team
        |> Repo.get_by(password: Enum.at(auth, 0))


      if team.double && quest.type == "SIDE" do
        changeset = Ecto.Changeset.change(team, %{balance: team.balance + (2 * quest.reward), double: false})

        Repo.update(changeset)
      else
        changeset = Ecto.Changeset.change(team, %{balance: team.balance + quest.reward})

        Repo.update(changeset)
      end

      conn |> send_resp(200, Jason.encode!(%{ status: true }))
    else
      conn |> send_resp(400, Jason.encode!(%{ status: false }))
    end
  end
end
