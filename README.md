# Elinor CRM

Elinor CRM is in Phase 1: Core Foundation. This phase provides a FastAPI backend shell with environment-based configuration, structured logging setup, SQLAlchemy 2 database connectivity, and a health endpoint.

## Requirements

- Python 3.12
- PostgreSQL

## Local setup

1. Create and activate a virtual environment:

   ```bash
   python3.12 -m venv .venv
   source .venv/bin/activate
   ```

2. Install dependencies:

   ```bash
   pip install -r requirements.txt
   ```

3. Create local environment configuration:

   ```bash
   cp .env.example .env
   ```

4. Update `DATABASE_URL` in `.env` for your local PostgreSQL database.

## Run the API

Start the development server:

```bash
uvicorn app.main:app --reload
```

The API will be available at `http://127.0.0.1:8000`.

## Health check

Check application and database status:

```bash
curl http://127.0.0.1:8000/health
```

Example response:

```json
{
  "application": "ok",
  "database": "ok"
}
```

If the database cannot be reached, the endpoint still returns HTTP 200 with `database` set to `unavailable`.

## Run tests

```bash
pytest
```
