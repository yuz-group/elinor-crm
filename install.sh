#!/usr/bin/env bash
set -euo pipefail

APP_NAME="Elinor CRM WEB"
APP_VERSION="1.0.0"
INSTALL_DIR="${ELINOR_INSTALL_DIR:-/opt/elinor-crm-web}"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

require_command() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }
}

require_command docker
if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose v2 is required." >&2
  exit 1
fi

sudo mkdir -p "${INSTALL_DIR}"
sudo rsync -a --delete --exclude '.git' --exclude '.venv' --exclude '__pycache__' "${SOURCE_DIR}/" "${INSTALL_DIR}/"
sudo mkdir -p "${INSTALL_DIR}/backups"

if [[ ! -f "${INSTALL_DIR}/.env" ]]; then
  db_password="$(openssl rand -base64 32 | tr -d '\n')"
  secret_key="$(openssl rand -hex 32)"
  sudo tee "${INSTALL_DIR}/.env" >/dev/null <<ENV
APP_NAME="${APP_NAME}"
APP_VERSION=${APP_VERSION}
ENVIRONMENT=production
LOG_LEVEL=INFO
POSTGRES_DB=elinor_crm
POSTGRES_USER=elinor
POSTGRES_PASSWORD=${db_password}
DATABASE_URL=postgresql+psycopg://elinor:${db_password}@db:5432/elinor_crm
DATABASE_HEALTH_TIMEOUT_SECONDS=2
SECRET_KEY=${secret_key}
ENV
  sudo chmod 600 "${INSTALL_DIR}/.env"
fi

sudo ln -sf "${INSTALL_DIR}/scripts/elinor" /usr/local/bin/elinor
sudo chmod +x "${INSTALL_DIR}/install.sh" "${INSTALL_DIR}/update.sh" "${INSTALL_DIR}/scripts/elinor" "${INSTALL_DIR}/scripts/backup.sh" "${INSTALL_DIR}/scripts/restore.sh"

cd "${INSTALL_DIR}"
sudo docker compose up -d --build

echo "${APP_NAME} ${APP_VERSION} installed. Use: elinor status"
