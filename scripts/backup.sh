#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${ROOT_DIR}/backups"
mkdir -p "${BACKUP_DIR}"

cd "${ROOT_DIR}"
if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

POSTGRES_DB="${POSTGRES_DB:-elinor_crm}"
POSTGRES_USER="${POSTGRES_USER:-elinor}"
BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
BACKUP_FILE="${BACKUP_DIR}/elinor-crm-web-${TIMESTAMP}.sql.gz"

docker compose exec -T db pg_dump -U "${POSTGRES_USER}" "${POSTGRES_DB}" | gzip > "${BACKUP_FILE}"
echo "Created backup: ${BACKUP_FILE}"

if [[ "${BACKUP_RETENTION_DAYS}" =~ ^[0-9]+$ ]]; then
  find "${BACKUP_DIR}" -maxdepth 1 -type f -name 'elinor-crm-web-*.sql.gz' -mtime +"${BACKUP_RETENTION_DAYS}" -delete
else
  echo "Skipping backup retention cleanup: BACKUP_RETENTION_DAYS must be an integer." >&2
fi
