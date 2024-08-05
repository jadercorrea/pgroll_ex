import Config

config :pgroll_ex, PgRollEx.Repo,
  username: "postgres",
  password: "postgres",
  database: "pgroll_ex_dev",
  hostname: "localhost",
  pool_size: 10

config :pgroll_ex, ecto_repos: [PgRollEx.Repo]
