defmodule PgRollEx.Application do
  use Application

  def start(_type, _args) do
    children = [
      PgRollEx.Repo
    ]

    opts = [strategy: :one_for_one, name: PgRollEx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
