defmodule PgRollEx.TestMigration do
  use Ecto.Migration

  def change do
    create table(:test_table) do
      add :name, :string
      timestamps()
    end
  end
end
