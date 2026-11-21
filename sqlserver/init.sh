#!/bin/bash
set -euo pipefail

SQLSERVR=/opt/mssql/bin/sqlservr
SQLCMD=/opt/mssql-tools18/bin/sqlcmd

if [ ! -x "$SQLCMD" ]; then
    SQLCMD=/opt/mssql-tools/bin/sqlcmd
fi

"$SQLSERVR" &
SQLSERVR_PID=$!

cleanup() {
    kill "$SQLSERVR_PID" 2>/dev/null || true
    wait "$SQLSERVR_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

echo "Attesa avvio SQL Server..."
for attempt in {1..60}; do
    if "$SQLCMD" -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "SELECT 1" -b -l 5 >/dev/null 2>&1; then
        break
    fi
    if [ "$attempt" -eq 60 ]; then
        echo "SQL Server non ha risposto entro 60 tentativi." >&2
        exit 1
    fi
    sleep 2
done

DB_EXISTS=$(
    "$SQLCMD" -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C \
        -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM sys.databases WHERE name = 'ScuolaDb'" \
        -h -1 -W 2>/dev/null
)

TABLE_COUNT=$(
    "$SQLCMD" -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C \
        -d ScuolaDb -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'" \
        -h -1 -W 2>/dev/null || echo 0
)
TABLE_COUNT="${TABLE_COUNT//[[:space:]]/}"

if [ "${DB_EXISTS//[[:space:]]/}" = "0" ] || [ "${TABLE_COUNT:-0}" -lt 12 ]; then
    if [ "${DB_EXISTS//[[:space:]]/}" = "1" ]; then
        echo "Database incompleto rilevato: ricreazione..."
        "$SQLCMD" -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C \
            -Q "ALTER DATABASE [ScuolaDb] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [ScuolaDb]"
    fi

    echo "Creazione database ScuolaDb..."
    "$SQLCMD" -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C \
        -I -i /opt/scuoladb/ScuolaDb.sql

    echo "Inserimento dati iniziali..."
    "$SQLCMD" -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C \
        -I -d ScuolaDb -i /opt/scuoladb/SeedData.sql
else
    echo "Database ScuolaDb gia presente: inizializzazione saltata."
fi

wait "$SQLSERVR_PID"
