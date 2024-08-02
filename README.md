# PgRollEx

PgRollEx is an Elixir tool for generating pgroll-compatible migrations from Ecto migrations. This package provides a custom task that runs Ecto migrations and generates the necessary JSON files for pgroll, saving them in a specified directory.

## Installation

Add pgroll_ex to your list of dependencies in mix.exs:

```
def deps do
  [
    {:pgroll_ex, "~> 0.1.0"}
  ]
end
```

## Configuration

Update your config/config.exs with the following configuration options:

```
config :pgroll_ex,
  migration_directory: "path/to/your/migrations_directory"
```

## Usage

To run migrations and generate pgroll-compatible migration files, use the custom migrate task provided by PgRollEx:

```
mix pgroll_ex.migrate
```

## Example

After running the task, you will find the generated migration files in the specified directory. Each migration file will follow the naming convention mig_<hash>.json and contain the necessary up and down SQL statements.

Example migration file:

```
mig_cqhskp8ihk4ub131mmpg.json
{
  "done": true,
  "migration": {
    "name": "mig_cqhskp8ihk4ub131mmpg",
    "operations": [
      {
        "sql": {
          "up": "CREATE SCHEMA \"bb_00000000000000000000000000_000000\";"
        }
      }
    ]
  },
  "migrationType": "pgroll",
  "name": "mig_cqhskp8ihk4ub131mmpg",
  "schema": "public",
  "startedAt": "2024-07-26T16:10:13.298728Z"
}
```

A `.ledger` file will also be created in the specified directory, containing the names of the generated migrations.

## Contributing

Please feel free to open issues or submit pull requests for any bugs or feature requests.

## Licence
This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
