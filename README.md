# PgRollEx

PgRollEx is an Elixir tool for generating pgroll-compatible migrations from Ecto migrations output, offering an easy way to extract and deploy zero-downtime, reversible and concurrently available postgres schemas.

This package provides a custom task that runs regular Ecto migrations and generates the necessary JSON files for pgroll migrations, saving them in a directory configured by the user. It also generates the .ledger file to keep track of all migration files in the correct order.

The package requires postgres 14.0 and above.

More on pgroll can be found in the [command line tool github page](https://github.com/xataio/pgroll/tree/main).

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
mig_48eca6c9994d7f1b5bab8b3fc9b38278.json
{
  "done": true,
  "migration": {
    "name": "mig_48eca6c9994d7f1b5bab8b3fc9b38278",
    "operations": [
      {
        "sql": {
          "down": "",
          "up": "CREATE UNIQUE INDEX merchants_tax_id_index ON merchants (tax_id) []"
        }
      }
    ]
  },
  "migrationType": "pgroll",
  "name": "mig_48eca6c9994d7f1b5bab8b3fc9b38278",
  "schema": "public",
  "startedAt": "2024-08-04T16:28:40.567277Z"
}
```

A `.ledger` file will also be created in the specified directory, containing the names of the generated migrations ordered by creation date.

## Contributing

Please feel free to open issues or submit pull requests for any bugs or feature requests.

## Licence
This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
