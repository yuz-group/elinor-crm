# Legacy Elinor CRM Import Plan

## Current Repository Structure

The repository is currently an empty scaffold for the Elinor CRM project. No legacy application code has been imported yet.

```text
.
├── README.md
├── AGENTS.md
├── .gitignore
├── backend/
│   └── .gitkeep
├── docker/
│   └── .gitkeep
├── docs/
│   └── .gitkeep
├── frontend/
│   └── .gitkeep
├── legacy/
│   └── .gitkeep
├── scripts/
│   └── .gitkeep
└── tests/
    └── .gitkeep
```

## Legacy Source Files to Import Later

When the legacy Elinor CRM application is imported, include only human-authored source, configuration templates, documentation, and tests needed to rebuild or run the application from source.

Import these categories from the legacy source package:

- Python application modules and packages, including files ending in `.py`.
- Dependency and environment definition files such as `requirements.txt`, `pyproject.toml`, `setup.cfg`, `setup.py`, `Pipfile`, `Pipfile.lock`, `poetry.lock`, or equivalent files used by the legacy application.
- Application configuration templates or examples that do not contain secrets, such as `.env.example`, sample YAML/TOML/INI files, or framework settings templates.
- Migration source files that are text-based and required to recreate the database schema, such as Alembic or Django migration scripts.
- Static source assets that are part of the application and are not generated build outputs.
- HTML, Jinja, Django, or other template source files used by the Python application.
- Test source files and test fixtures that are small, text-based, deterministic, and do not contain production data.
- Project documentation, developer notes, and operational runbooks that are relevant to understanding or running the legacy CRM.

## Files and Artifacts to Exclude

Do not import artifacts that are generated, environment-specific, sensitive, binary, or derived from runtime execution.

Exclude these categories from the import:

- Database files, including SQLite, DuckDB, Access, MySQL/PostgreSQL dumps, and files ending in `.db`, `.sqlite`, `.sqlite3`, `.dump`, or `.sql` unless a specific schema-only SQL file is approved for import.
- Production data exports, customer data, CRM records, personally identifiable information, or any files containing secrets.
- Backup files and archives, including `.bak`, `.backup`, `.old`, `.orig`, `.zip`, `.tar`, `.tar.gz`, `.tgz`, `.7z`, and `.rar` files.
- Processed files, import/export results, uploaded documents, generated reports, or runtime data directories.
- Log files and runtime traces, including `.log` files.
- Cache files and interpreter artifacts, including `__pycache__/`, `.pytest_cache/`, `.mypy_cache/`, `.ruff_cache/`, `.tox/`, `.nox/`, and files ending in `.pyc`, `.pyo`, or `.pyd`.
- Virtual environments and local dependency installs, including `venv/`, `.venv/`, `env/`, and site-package directories.
- Generated frontend or documentation builds, including `dist/`, `build/`, `.next/`, `coverage/`, `htmlcov/`, and generated API documentation.
- Local editor, operating system, and temporary files, including `.DS_Store`, `Thumbs.db`, swap files, and temporary working files.
- Binary artifacts unless explicitly reviewed and approved as required source assets.

## Target Placement for the Current Python Application

Place the legacy Python application under `backend/` when it is imported.

Recommended placement:

```text
backend/
├── app/                  # Legacy Python application package or modules
├── migrations/           # Text-based schema migration source, if present
├── requirements.txt      # Or pyproject.toml / other dependency file used by the app
├── README.md             # Backend-specific setup notes, if available
└── .gitkeep              # Remove only after real tracked files exist in backend/
```

If the legacy package already has a clear Python package name, preserve that package name below `backend/` rather than flattening module paths. Keep import paths stable where practical, and document any required path or entrypoint changes before modifying application code.

Use `legacy/` only for import staging documentation, inventories, or other non-application reference material. Do not place runnable application code in `legacy/` unless a later migration step explicitly requires preserving an untouched source snapshot.

## Handling Runtime and Generated Data

The repository should contain source and reproducible configuration only. Runtime state and generated artifacts must stay outside version control.

- **Databases:** Do not commit database files or production data dumps. Store local development databases outside the repository or in an ignored runtime directory. Recreate schemas from migrations or documented setup steps.
- **Backups:** Do not commit backups. Keep backups in external storage with appropriate access controls and retention policies.
- **Processed files:** Do not commit processed import results, transformed customer files, uploaded documents, generated reports, or other workflow output. Store them in external object storage or an ignored runtime data path.
- **ZIP and archive files:** Do not commit ZIP files or archives. Extract and review them outside the repository, then import only approved source files.
- **Logs:** Do not commit logs. Configure the application to write logs to stdout/stderr in containerized environments or to an ignored runtime log directory for local development.
- **Cache files:** Do not commit caches from Python, test tools, linters, type checkers, package managers, editors, or operating systems. Regenerate caches locally as needed.
- **Generated files:** Do not commit generated build outputs, reports, coverage artifacts, compiled files, or generated documentation unless a future decision explicitly identifies a generated artifact as required source material.

## Import Procedure for a Future Change

1. Inventory the legacy source package outside the repository.
2. Classify each file as source, configuration template, documentation, test material, generated artifact, runtime data, backup, cache, log, archive, or sensitive material.
3. Copy only approved source-controlled files into the target project structure, primarily under `backend/`.
4. Preserve empty scaffold directories with `.gitkeep` files until they contain other tracked files.
5. Review `git status` before committing to confirm no excluded artifacts were added.
6. Run available tests or at least syntax/import checks after the application is imported.
7. Document any deviations from this plan in the import pull request.
