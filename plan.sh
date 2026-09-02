#!/usr/bin/env bash
set -e

if [ -z $2 ]; then echo "Usage: plan.sh <env_file_name> <comma_separated_schema_list>"; exit 1; fi

declare envFile=$1
declare schemas=$2

export $(cat $envFile | xargs)

rm -f output*

echo "Database: ${PGDATABASE}"

if [ -f "${PGDATABASE}/extensions.sql" ]; then
    echo "Adding extensions"
    psql -f "${PGDATABASE}/extensions.sql"

    if [ -n "${PGSCHEMA_PLAN_DB}" ]; then
        PGPASSTEMP=$PGPASSWORD
        PGPASSWORD=$PGSCHEMA_PLAN_PASSWORD
        psql -h $PGSCHEMA_PLAN_HOST -p $PGSCHEMA_PLAN_PORT -U $PGSCHEMA_PLAN_USER -d $PGSCHEMA_PLAN_DB -f "${PGDATABASE}/extensions.sql"
        PGPASSWORD=$PGPASSTEMP
    fi

fi

for s in $(echo $schemas | tr "," "\n");
do
    echo "Schema: ${s}"
    psql -c "CREATE SCHEMA IF NOT EXISTS ${s} AUTHORIZATION ${PGDATABASE}_owner;"

    if [ -n "${PGSCHEMA_PLAN_DB}" ]; then
        PGPASSTEMP=$PGPASSWORD
        PGPASSWORD=$PGSCHEMA_PLAN_PASSWORD
        psql -h $PGSCHEMA_PLAN_HOST -p $PGSCHEMA_PLAN_PORT -U $PGSCHEMA_PLAN_USER -d $PGSCHEMA_PLAN_DB -c "CREATE SCHEMA IF NOT EXISTS ${s} AUTHORIZATION ${PGSCHEMA_PLAN_DB}_owner;"
        PGPASSWORD=$PGPASSTEMP
    fi

    pgschema plan --file "${PGDATABASE}/${s}/${s}.sql" --schema $s --output-human "output_${s}.txt" --output-sql "output_${s}.sql" --output-json "output_${s}.json"
done
