#!/bin/bash
set -euo pipefail

: "${MSSQL_SA_PASSWORD:?MSSQL_SA_PASSWORD non impostata}"

BACKUP_DIR=/var/opt/mssql/backups
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/ScuolaDb-$TIMESTAMP.bak"
mkdir -p "$BACKUP_DIR"

/opt/mssql-tools18/bin/sqlcmd \
    -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C \
    -Q "BACKUP DATABASE [ScuolaDb] TO DISK = N'$BACKUP_FILE' WITH INIT, COMPRESSION, CHECKSUM"

echo "Backup creato: $BACKUP_FILE"
