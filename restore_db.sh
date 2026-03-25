#!/bin/bash
set -e

# --- Arguments ---
DB_NAME="$1"     # e.g., odoo17
DB_USER="$2"     # e.g., odoo
SQL_FILE="$3"    # e.g., /tmp/odoo.sql

echo "Restoring PostgreSQL database..."
echo "DB_USER=$DB_USER, DB_NAME=$DB_NAME, SQL_FILE=$SQL_FILE"

# Check SQL file exists
if [ ! -f "$SQL_FILE" ]; then
    echo "Error: SQL file not found at $SQL_FILE"
    exit 1
fi

# Disconnect active connections
psql -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='$DB_NAME';"

# Drop database if exists
psql -d postgres -c "DROP DATABASE IF EXISTS $DB_NAME;"

# Create database with owner
psql -d postgres -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"

# Restore SQL file
psql -U "$DB_USER" -d "$DB_NAME" -f "$SQL_FILE"

echo "Database restore completed successfully!"
