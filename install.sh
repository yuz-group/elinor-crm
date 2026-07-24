#!/usr/bin/env bash
set -euo pipefail

APP_NAME="Elinor CRM WEB"
APP_VERSION="1.0.0"
INSTALL_DIR="${ELINOR_INSTALL_DIR:-/opt/elinor-crm-web}"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_KEYRING="/etc/apt/keyrings/docker.gpg"
DOCKER_LIST="/etc/apt/sources.list.d/docker.list"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

verify_ubuntu() {
  [[ -r /etc/os-release ]] || fail "Cannot determine operating system. Ubuntu is required."
  # shellcheck disable=SC1091
  source /etc/os-release
  [[ "${ID:-}" == "ubuntu" ]] || fail "Unsupported operating system '${PRETTY_NAME:-unknown}'. Ubuntu is required."
}

verify_privileges() {
  if [[ "${EUID}" -eq 0 ]]; then
    SUDO=()
  elif command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
    SUDO=(sudo)
  else
    fail "Root or passwordless sudo access is required."
  fi
}

apt_get_install() {
  "${SUDO[@]}" env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

apt_install_missing() {
  local packages=("$@") missing=()
  for package in "${packages[@]}"; do
    if ! dpkg-query -W -f='${Status}' "${package}" 2>/dev/null | grep -q "install ok installed"; then
      missing+=("${package}")
    fi
  done
  if [[ "${#missing[@]}" -gt 0 ]]; then
    "${SUDO[@]}" apt-get update
    apt_get_install "${missing[@]}"
  fi
}

install_docker_repository() {
  if [[ ! -f "${DOCKER_KEYRING}" || ! -f "${DOCKER_LIST}" ]]; then
    "${SUDO[@]}" install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | "${SUDO[@]}" gpg --dearmor -o "${DOCKER_KEYRING}"
    "${SUDO[@]}" chmod a+r "${DOCKER_KEYRING}"
    local codename arch
    # shellcheck disable=SC1091
    source /etc/os-release
    codename="${VERSION_CODENAME}"
    arch="$(dpkg --print-architecture)"
    echo "deb [arch=${arch} signed-by=${DOCKER_KEYRING}] https://download.docker.com/linux/ubuntu ${codename} stable" | "${SUDO[@]}" tee "${DOCKER_LIST}" >/dev/null
  fi
}

install_dependencies() {
  apt_install_missing ca-certificates curl git gnupg openssl rsync
  install_docker_repository
  apt_install_missing docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

create_env() {
  if [[ ! -f "${INSTALL_DIR}/.env" ]]; then
    local db_password secret_key
    db_password="$(openssl rand -base64 32 | tr -d '\n')"
    secret_key="$(openssl rand -hex 32)"
    "${SUDO[@]}" tee "${INSTALL_DIR}/.env" >/dev/null <<ENV
APP_NAME="${APP_NAME}"
APP_VERSION=${APP_VERSION}
ENVIRONMENT=production
LOG_LEVEL=INFO
API_PORT=8000
BACKUP_RETENTION_DAYS=30
POSTGRES_DB=elinor_crm
POSTGRES_USER=elinor
POSTGRES_PASSWORD=${db_password}
DATABASE_URL=postgresql+psycopg://elinor:${db_password}@db:5432/elinor_crm
DATABASE_HEALTH_TIMEOUT_SECONDS=2
SECRET_KEY=${secret_key}
ENV
    "${SUDO[@]}" chmod 600 "${INSTALL_DIR}/.env"
  fi
}

compose_services_healthy() {
  python3 -c '
import json
import sys

data = sys.stdin.read().strip()
if not data:
    sys.exit(1)

try:
    parsed = json.loads(data)
    rows = parsed if isinstance(parsed, list) else [parsed]
except json.JSONDecodeError:
    rows = [json.loads(line) for line in data.splitlines() if line.strip()]

healthy = rows and all(
    row.get("State") == "running"
    and row.get("Health", "healthy") in ("", "healthy")
    for row in rows
)
sys.exit(0 if healthy else 1)
'
}

wait_for_services() {
  local attempts=60 api_port
  api_port="$(grep -E '^API_PORT=' "${INSTALL_DIR}/.env" | tail -n1 | cut -d= -f2- | tr -d '"' || true)"
  api_port="${api_port:-8000}"
  cd "${INSTALL_DIR}"
  echo "Waiting for services to become healthy..."
  for _ in $(seq 1 "${attempts}"); do
    if "${SUDO[@]}" docker compose ps --format json 2>/dev/null | compose_services_healthy && curl -fsS "http://127.0.0.1:${api_port}/health" >/dev/null; then
      return 0
    fi
    sleep 2
  done
  "${SUDO[@]}" docker compose ps >&2 || true
  fail "Services did not become healthy. Check logs with: elinor logs"
}

check_health() {
  local api_port response
  api_port="$(grep -E '^API_PORT=' "${INSTALL_DIR}/.env" | tail -n1 | cut -d= -f2- | tr -d '"' || true)"
  api_port="${api_port:-8000}"
  response="$(curl -fsS "http://127.0.0.1:${api_port}/health")" || fail "Health check failed at http://127.0.0.1:${api_port}/health"
  echo "Health check succeeded: ${response}"
}

verify_ubuntu
verify_privileges
install_dependencies
"${SUDO[@]}" mkdir -p "${INSTALL_DIR}"
"${SUDO[@]}" rsync -a --delete --exclude '.git' --exclude '.venv' --exclude '__pycache__' --exclude '.env' --exclude 'backups/*.sql' --exclude 'backups/*.sql.gz' "${SOURCE_DIR}/" "${INSTALL_DIR}/"
"${SUDO[@]}" mkdir -p "${INSTALL_DIR}/backups"
create_env
"${SUDO[@]}" ln -sf "${INSTALL_DIR}/scripts/elinor" /usr/local/bin/elinor
"${SUDO[@]}" chmod +x "${INSTALL_DIR}/install.sh" "${INSTALL_DIR}/update.sh" "${INSTALL_DIR}/scripts/elinor" "${INSTALL_DIR}/scripts/backup.sh" "${INSTALL_DIR}/scripts/restore.sh"

cd "${INSTALL_DIR}"
"${SUDO[@]}" docker compose up -d --build
wait_for_services
check_health

echo "${APP_NAME} ${APP_VERSION} installed. Use: elinor status"
