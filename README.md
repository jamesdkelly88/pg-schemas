# pg-schemas

PostgreSQL database schemas, structured for compatibility with [pgschema](https://www.pgschema.com/)

```
├── database1
│   ├── schema1
|   |   ├── schema1.sql
│   │   └── tables
│   │       ├── first_table.sql
│   │       └── second_table.sql
│   └── schema2
|       ├── schema2.sql 
│       ├── views
│       │   └── view.sql
│       ├── default_privileges
│       │   └── tables.sql
│       └── privileges
│           └── view.sql
├── database2...
```

`pgschema` creates a `.sql` file for each database object. It also creates a `.sql` file for the schema listing the object files to include. 

These are processed in order and so this file can be edited to handle dependencies. The `\i` directives can be changed to include an entire folder (in alphabetical order) by adding a trailing `/`.

## Usage

### Environment variables

```sh
PGHOST=localhost
PGPORT=5432
PGDATABASE=example
PGUSER=postgres
PGPASSWORD=secret
PGSSLMODE=require

PGSCHEMA_PLAN_HOST=localhost
PGSCHEMA_PLAN_PORT=5432
PGSCHEMA_PLAN_DB=staging
PGSCHEMA_PLAN_USER=postgres
PGSCHEMA_PLAN_PASSWORD=secret
PGSCHEMA_PLAN_SSLMODE=require
```

Use `export $(cat project.env | xargs)` to load an `.env` file (`.env` and [a couple of others](https://www.pgschema.com/cli/dotenv) are loaded automatically by `pgschema`)

### Ignore file

```toml
[type]
patterns = ["exclude", "!include"]
```

#### Types

- tables
- views
- functions
- procedures
- aggregates
- types
- sequences
- indexes
- constraints
- triggers
- privileges
- default_privileges

The one in this repo excludes all permissions but includes everything else.

### Dump

```sh
pgschema dump --multi-file --schema schema --file database/schema/schema.sql --qualify-schema
```

### Plan

**Important** 

- If extensions or cross schema references are used, then an external database should be used, rather than the default embedded instance
- `pgschema` only works on a single schema at a time, so for multiple schemas, a looping process must be used
- The schema must exist in the target database

```sh
pgschema plan --schema schema --file database/schema/schema.sql                                                                               # outputs to console

pgschema plan --file database/schema/schema.sql --schema schema --output-sql output.sql --output-human output.txt --output-json output.json   # outputs to files
```

### Apply

**Important** 

- It is a schema management tool, so it will suggest dropping tables/columns
  - plans must be reviewed for data loss and migrations handled manually

#### Interactive (file)

1. Generates the plan
2. Prints it to the console
3. Asks for approval
4. Applies the changes

```sh
pgschema apply --file database/schema/schema.sql --schema schema 
```

### Interactive (planned)

1. Validates the plan for drift
2. Prints the changes to the console
3. Asks for approval
4. Applies the changes

```sh
pgschema apply --plan output_schema.json --schema schema
```

#### Automated

1. Validates the plan for drift
2. Applies the changes

```sh
pgschema apply --plan output_schema.json --schema schema --auto-approve
```