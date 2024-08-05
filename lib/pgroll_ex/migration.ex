defmodule PgRollEx.Migration do
  @moduledoc """
  Module responsible for handling migrations and generating pgroll-compatible files.
  """

  def create(log_content, path) do
    pgroll_migrations = parse_migrations(log_content)

    Enum.each(pgroll_migrations, fn {name, content} ->
      unless Enum.empty?(content["migration"]["operations"]) do
        migration_file = Path.join(path, "#{name}.json")
        File.write!(migration_file, Jason.encode!(content))
        update_ledger(path, name)
      end
    end)

    IO.puts("PgRoll migrations generated successfully.")
    :ok
  end

  def run(repo, path) do
    Mix.Task.run("ecto.migrate", ["-r", inspect(repo), "--log-migrations-sql"])

    log_path = Path.join([File.cwd!(), "priv/repo/logs"])
    File.mkdir_p!(log_path)
    log_file = Path.join(log_path, "migrations.log")

    {:ok, log_content} = File.read(log_file)

    create(log_content, path)
  end

  defp parse_migrations(log_content) do
    log_content
    |> String.split("\n")
    |> Enum.chunk_while([], &parse_chunk/2, &final_chunk/1)
    |> Enum.flat_map(&build_migration/1)
  end

  defp parse_chunk(line, acc) when line == "", do: {:cont, acc, []}
  defp parse_chunk(line, acc), do: {:cont, [line | acc]}
  defp final_chunk(acc), do: {:cont, acc, []}

  defp build_migration(lines) do
    up_lines =
      Enum.filter(lines, fn line ->
        String.contains?(line, "CREATE TABLE") or String.contains?(line, "CREATE INDEX") or
          String.contains?(line, "CREATE UNIQUE INDEX")
      end)

    down_lines =
      Enum.filter(lines, fn line ->
        String.contains?(line, "DROP TABLE") or String.contains?(line, "DROP INDEX") or
          String.contains?(line, "DROP UNIQUE INDEX")
      end)

    Enum.map(up_lines, fn up_sql -> build_single_migration(up_sql, down_lines) end)
    |> Enum.reject(&is_nil/1)
  end

  defp build_single_migration(up_sql, down_lines) do
    down_sql = Enum.find(down_lines, fn line -> String.contains?(line, clean_sql(up_sql)) end)

    hash = :crypto.hash(:md5, up_sql) |> Base.encode16() |> String.downcase()
    name = "mig_#{hash}"

    {
      name,
      %{
        "done" => true,
        "migration" => %{
          "name" => name,
          "operations" => [
            %{
              "sql" => %{
                "up" => clean_sql(up_sql),
                "down" => if(down_sql, do: clean_sql(down_sql), else: "")
              }
            }
          ]
        },
        "migrationType" => "pgroll",
        "name" => name,
        "schema" => "public",
        "startedAt" => DateTime.utc_now() |> DateTime.to_iso8601()
      }
    }
  end

  defp clean_sql(line) do
    line
    |> String.replace(~r/\"([^\"]+)\"/, "\\1")
    |> String.trim()
  end

  defp update_ledger(path, name) do
    ledger_file = Path.join(path, ".ledger")
    File.write!(ledger_file, "#{name}\n", [:append])
  end
end
