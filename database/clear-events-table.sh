#!/usr/bin/env bash

set -e

clear

echo
echo "Clearing Events Table"
echo "= = ="
echo

if [ -z ${DATABASE_USER+x} ]; then
  echo "(DATABASE_USER is not set)"
  user=eventstream
else
  user=$DATABASE_USER
fi
echo "Database user is: $user"

if [ -z ${DATABASE_NAME+x} ]; then
  echo "(DATABASE_NAME is not set)"
  database=eventstream
else
  database=$DATABASE_NAME
fi
echo "Database name is: $database"

echo

function truncate-events-table {
  psql $database -f database/utilities/truncate-events-table.sql
}

truncate-events-table
