#!/bin/bash
set -e

# Create the users_test database if it doesn't exist
PGPASSWORD=${PGPASSWORD} psql -h ${PGHOST} -p ${PGPORT} -U ${DB_USER} -d ${DB_NAME} -c "CREATE DATABASE ${DB_NAME}_test;" || true
PGPASSWORD=${PGPASSWORD} psql -h ${PGHOST} -p ${PGPORT} -U ${DB_USER} -d ${DB_NAME} -c "GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME}_test TO ${DB_USER};" || true

echo "PostgreSQL initialization completed"