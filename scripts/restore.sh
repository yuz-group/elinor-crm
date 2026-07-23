#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <backup.sql.gz|backup.sql>" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_FILE="$1"
if [[ "${BACKUP_FILE}" != /* ]]; then
  BACKUP_FILE="${ROOT_DIR}/${BACKUP_FILE}"
fi
if [[ ! -f "${BACKUP_FILE}" ]]; then
  echo "Backup not found: ${BACKUP_FILE}" >&2
  exit 1
fi

cd "${ROOT_DIR}"
if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

POSTGRES_DB="${POSTGRES_DB:-elinor_crm}"
POSTGRES_USER="${POSTGRES_USER:-elinor}"

if [[ "${BACKUP_FILE}" == *.gz ]]; then
  gzip -dc "${BACKUP_FILE}" | docker compose exec -T db psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"
else
  docker compose exec -T db psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" < "${BACKUP_FILE}"
fi

echo "Restored backup: ${BACKUP_FILE}"
