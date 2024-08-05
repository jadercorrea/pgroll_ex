defmodule PgRollEx.MigrationTest do
  use ExUnit.Case
  alias PgRollEx.Migration
  alias PgRollEx.Repo

  setup_all do
    {:ok, _} = Application.ensure_all_started(:postgrex)
    {:ok, _} = Application.ensure_all_started(:ecto_sql)

    Mix.Task.run("ecto.create", ["-r", "PgRollEx.Repo", "--quiet"])
    Mix.Task.run("ecto.migrate", ["-r", "PgRollEx.Repo", "--quiet"])

    :ok
  end

  setup do
    path = "test/support/migrations"
    File.rm_rf!(path)
    File.mkdir_p!(path)

    log_path = Path.join(["priv/repo/logs", "migrations.log"])
    File.rm_rf!(Path.dirname(log_path))
    File.mkdir_p!(Path.dirname(log_path))

    {:ok, path: path, log_path: log_path}
  end

  test "parses and creates pgroll migrations", %{path: path, log_path: log_path} do
    sample_log = """
    09:59:52.338 [info] == Running 20240731123328 Platform.Repo.Migrations.CreateMerchants.change/0 forward
    09:59:52.339 [info] create table merchants
    09:59:52.351 [debug] QUERY OK db=10.1ms
    CREATE TABLE merchants (id uuid, legal_name varchar(255), social_name varchar(255), address varchar(255), tax_id varchar(255), state_registration varchar(255), inserted_at timestamp(0) NOT NULL, updated_at timestamp(0) NOT NULL, PRIMARY KEY (id)) []
    09:59:52.351 [info] create index merchants_tax_id_index
    09:59:52.353 [debug] QUERY OK db=1.3ms
    CREATE UNIQUE INDEX merchants_tax_id_index ON merchants (tax_id) []
    09:59:52.353 [info] == Migrated 20240731123328 in 0.0s
    """

    File.write!(log_path, sample_log)

    Migration.create(sample_log, path)

    files = File.ls!(path)
    assert length(files) == 3

    ledger_path = Path.join(path, ".ledger")
    assert File.exists?(ledger_path)

    Enum.each(files, fn file ->
      if Path.extname(file) == ".json" do
        file_path = Path.join(path, file)
        content = File.read!(file_path)

        json = Jason.decode!(content)
        migration_data = Map.update!(json, "migration", &Map.delete(&1, "startedAt"))

        expected_migration = %{
          "done" => true,
          "migration" => %{
            "name" => migration_data["migration"]["name"],
            "operations" => migration_data["migration"]["operations"]
          },
          "migrationType" => "pgroll",
          "name" => migration_data["name"],
          "schema" => "public"
        }

        assert Map.delete(json, "startedAt") == expected_migration
      end
    end)
  end
end
