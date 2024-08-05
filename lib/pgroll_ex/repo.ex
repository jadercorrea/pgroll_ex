defmodule PgRollEx.Repo do
  use Ecto.Repo,
    otp_app: :pgroll_ex,
    adapter: Ecto.Adapters.Postgres
end
