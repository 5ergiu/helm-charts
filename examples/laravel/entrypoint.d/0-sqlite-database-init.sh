#!/bin/sh

# ============================================================================
# SQLite Database Initialization
# ============================================================================
# Ensures the SQLite database file exists when DB_CONNECTION is set to "sqlite".
#
# Assumptions:
# - Laravel runs as www-data
# - DB_DATABASE contains the full SQLite database path
# - /tmp is provided by Kubernetes as tmpfs (emptyDir)
#
# This script is executed by the Docker entrypoint before starting PHP-FPM.
# ============================================================================

# ============================================================================
# CONFIGURATION
# ============================================================================

SQLITE_DB_PATH="/tmp/database.sqlite"

# ============================================================================
# VALIDATION
# ============================================================================

# Only run for sqlite connections
if [ "$DB_CONNECTION" != "sqlite" ]; then
    if [ "$LOG_OUTPUT_LEVEL" = "debug" ]; then
        echo "👉 $(basename "$0"): DB_CONNECTION is not 'sqlite'. Nothing to do."
    fi
    exit 0
fi

if [ -z "$DB_DATABASE" ]; then
    echo "❌ DB_DATABASE is not set but DB_CONNECTION=sqlite"
    exit 1
fi

# ============================================================================
# SQLITE INITIALIZATION
# ============================================================================

if [ ! -f "$DB_DATABASE" ]; then
    if [ "$LOG_OUTPUT_LEVEL" != "off" ]; then
        echo "📄 Creating SQLite database file: $DB_DATABASE"
    fi

    touch "$DB_DATABASE" || {
        echo "❌ Failed to create SQLite database file at $DB_DATABASE"
        exit 1
    }
else
    if [ "$LOG_OUTPUT_LEVEL" = "debug" ]; then
        echo "👉 $(basename "$0"): SQLite database already exists."
    fi
fi

# ============================================================================
# PERMISSIONS
# ============================================================================

chmod 664 "$DB_DATABASE" 2>/dev/null || true

if [ "$LOG_OUTPUT_LEVEL" = "debug" ]; then
    echo "👉 $(basename "$0"): SQLite database is writable by www-data"
fi
