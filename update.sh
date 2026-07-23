#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT_DIR}"

if [[ -d .git ]]; then
  git pull --ff-only
fi

docker compose build api
docker compose up -d
docker compose exec -T api python -m compileall app

echo "Elinor CRM WEB updated."
