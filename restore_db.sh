#!/bin/bash
set -e

DB_NAME="$1"
DB_USER="$2"
SQL_FILE="$3"

echo "Restoring PostgreSQL database..."

# Check if SQL file exists
if [ ! -f "$SQL_FILE" ]; then
    echo "Error: SQL file not found at $SQL_FILE"
    exit 1
fi

# Create role if it doesn't exist
psql -d postgres -tc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1 || \
    psql -d postgres -c "CREATE ROLE $DB_USER WITH LOGIN SUPERUSER;"

# Disconnect active connections (ignore if DB doesn't exist yet)
psql -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='$DB_NAME';" || true

# Drop DB if exists
psql -d postgres -c "DROP DATABASE IF EXISTS $DB_NAME;"

# Create DB
psql -d postgres -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"

# Restore SQL
psql -U "$DB_USER" -d "$DB_NAME" -f "$SQL_FILE"

echo "Database restore completed successfully!"
