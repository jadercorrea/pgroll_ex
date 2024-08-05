defmodule Mix.Tasks.PgrollEx.Migrate do
  use Mix.Task

  @shortdoc "Runs Ecto migrations and generates pgroll-compatible migration files"

  alias PgRollEx.Migration

  @impl true
  def run(_args) do
    Application.ensure_all_started(:pgroll_ex)

    repo = Application.fetch_env!(:pgroll_ex, :repo)
    path = Application.get_env(:pgroll_ex, :migrations_path, "priv/repo/pgroll/migrations")

    Migration.run(repo, path)
  end
end
