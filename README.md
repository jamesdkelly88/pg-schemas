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


## Ownership

Best practice is to have a `database_owner` role own the database and objects (unless a `schema_owner` role is required for segregation). 

In order to satisfy this with `pgschema`, perform the following setup (TODO: needs thorough testing on different providers):

```sql

-- ==========================================
-- 1. RUN AS SUPERUSER (Connected to 'postgres' database)
-- ==========================================

-- CREATE DB OWNER ROLE
CREATE ROLE dbname_owner WITH NOLOGIN;

-- CREATE DB
CREATE DATABASE dbname WITH OWNER = dbname_owner;

-- CREATE HUMAN ADMIN USER
CREATE USER human WITH ENCRYPTED PASSWORD 'password';
GRANT dbname_owner TO human WITH INHERIT TRUE, SET TRUE;

-- CREATE PGSCHEMA USER THAT AUTOMATICALLY ASSUMES OWNER ROLE
CREATE USER bot WITH ENCRYPTED PASSWORD 'password';
GRANT dbname_owner TO bot WITH SET TRUE;
ALTER ROLE bot IN DATABASE dbname SET role TO dbname_owner;

-- CREATE APP ROLE
CREATE ROLE dbname_app WITH NOLOGIN;

-- CREATE APP USER
CREATE USER app WITH ENCRYPTED PASSWORD 'password';
GRANT dbname_app TO app;

-- SECURE DATABASE
REVOKE CONNECT ON DATABASE dbname FROM PUBLIC;
GRANT CONNECT ON DATABASE dbname TO dbname_owner;
GRANT CONNECT ON DATABASE dbname TO dbname_app;
GRANT CONNECT ON DATABASE dbname TO bot;

-- ==========================================
-- 2. RUN CONNECTED TO TARGET DATABASE (\c dbname)
-- ==========================================

-- GRANT SPECIFIC PERMISSIONS TO APP ROLE
GRANT USAGE ON SCHEMA schemaname TO dbname_app;
GRANT SELECT ON ALL TABLES IN SCHEMA schemaname TO dbname_app;
ALTER DEFAULT PRIVILEGES FOR ROLE dbname_owner IN SCHEMA schemaname GRANT SELECT ON TABLES TO dbname_app;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA schemaname TO dbname_app;
ALTER DEFAULT PRIVILEGES FOR ROLE dbname_owner IN SCHEMA schemaname GRANT USAGE, SELECT ON SEQUENCES TO dbname_app;

-- CHECK FOR ASSUMED ROLE
SELECT 
  session_user AS authenticated_role,
  current_user AS effective_role,
  current_role AS active_role;  

-- LEAVE ASSUMED ROLE
SET ROLE NONE;
```
