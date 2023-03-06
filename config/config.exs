import Config

config :api, Api.Repo, url: System.get_env("DATABASE_URL")

config :api, ecto_repos: [Api.Repo]
