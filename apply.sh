#!/usr/bin/env bash
set -e

if [ -z $2 ]; then echo "Usage: dump.sh <env_file_name> <comma_separated_schema_list>"; exit 1; fi

declare envFile=$1
declare schemas=$2

export $(cat $envFile | xargs)

echo "Database: ${PGDATABASE}"

for s in $(echo $schemas | tr "," "\n");
do
    echo "Schema: ${s}"
    pgschema apply --plan "output_${s}.json" --schema $s --auto-approve
done