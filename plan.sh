#!/usr/bin/env bash
set -e

if [ -z $2 ]; then echo "Usage: plan.sh <env_file_name> <comma_separated_schema_list>"; exit 1; fi

declare envFile=$1
declare schemas=$2

export $(cat $envFile | xargs)

rm -f output*

echo "Database: ${PGDATABASE}"

for s in $(echo $schemas | tr "," "\n");
do
    echo "Schema: ${s}"
    pgschema plan --file "${PGDATABASE}/${s}/${s}.sql" --schema $s --output-human "output_${s}.txt" --output-sql "output_${s}.sql" --output-json "output_${s}.json"
done
