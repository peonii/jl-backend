import Config

config :api, Api.Repo,
  database: "jetlag",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :api, ecto_repos: [Api.Repo]
