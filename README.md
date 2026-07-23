# Elinor CRM WEB

Elinor CRM WEB v1.0.0 provides the deployment foundation for the web application. It includes a FastAPI service, PostgreSQL, Docker Compose orchestration, an Ubuntu installer, a global `elinor` management CLI, persistent database storage, and backup/restore operations.

No CRM domain models are included yet.

## Requirements

- Ubuntu with root or passwordless `sudo` access
- Network access to Ubuntu and Docker package repositories

The installer installs missing runtime packages automatically: Docker Engine, Docker Compose v2 plugin, `curl`, `git`, `rsync`, and `openssl`.

## Ubuntu installation

Clone the repository onto the server, then run:

```bash
sudo ./install.sh
```

The installer verifies Ubuntu and privilege access, adds the official Docker Ubuntu repository when needed, installs missing packages only, copies the project to `/opt/elinor-crm-web` by default, waits for services to become healthy, and calls `GET /health`. Override the location with:

```bash
sudo env ELINOR_INSTALL_DIR=/opt/custom-elinor ./install.sh
```

On first install, `.env` is generated with secure random database and secret values, stored with `600` permissions, and not committed to git. Existing `.env`, database data, and backups are preserved on repeated installs.

## Services

`docker-compose.yml` starts:

- `api`: FastAPI application exposed on port `8000`
- `db`: PostgreSQL 16 with persistent Docker volume storage

Backups are written to the host `backups/` directory. The public API host port is configured with `API_PORT` in `.env`, defaulting to `8000`.

## Management CLI

The installer links the global `elinor` command to `/usr/local/bin/elinor`.

Run `elinor` with no arguments to open the interactive menu:

```text
Elinor CRM WEB v1.0.0

1. Install
2. Start
3. Stop
4. Restart
5. Status
6. Update
7. Backup
8. Restore
9. View Logs
10. Database Migration
11. Application Information
0. Exit
```

Non-interactive commands are also supported:

```bash
elinor install    # Install on Ubuntu
elinor start      # Start services
elinor stop       # Stop services
elinor restart    # Restart services
elinor status     # Show service status
elinor update     # Pull, rebuild, and restart
elinor logs       # Follow logs
elinor backup     # Create a PostgreSQL backup
elinor restore backups/file.sql.gz
elinor migrate    # Run migrations when configured
elinor info       # Show product and deployment information
elinor help       # Show CLI help
```

## Backup and restore

Create a compressed PostgreSQL backup. After a new backup succeeds, expired Elinor backup files matching `elinor-crm-web-*.sql.gz` are removed according to `BACKUP_RETENTION_DAYS` in `.env`, defaulting to `30`:

```bash
elinor backup
```

Restore a backup:

```bash
elinor restore backups/elinor-crm-web-YYYYMMDDTHHMMSSZ.sql.gz
```

## Updates

Run:

```bash
elinor update
```

This pulls fast-forward git updates when installed from a git checkout, rebuilds the API image, restarts services, and runs a Python compile check inside the API container.

## Health check

Check application and database health:

```bash
curl http://127.0.0.1:8000/health
```

Example response:

```json
{
  "application": "ok",
  "name": "Elinor CRM WEB",
  "version": "1.0.0",
  "database": "ok"
}
```

If PostgreSQL cannot be reached, the endpoint returns HTTP 200 with `database` set to `unavailable`.

## Local development

```bash
python3.12 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Optionally edit API_PORT and BACKUP_RETENTION_DAYS in .env
uvicorn app.main:app --reload
```

Run tests:

```bash
pytest
```
