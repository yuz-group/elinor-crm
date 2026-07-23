# Elinor CRM Desktop Application Migration Plan

## Current repository structure

The repository is currently an initialized project skeleton for Elinor CRM. It does not yet contain application source code or imported legacy desktop application files.

```text
.
├── AGENTS.md
├── README.md
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

### Directory intent

- `backend/`: Future backend services, API application code, business logic, persistence integration, authentication, and server-side migration utilities.
- `frontend/`: Future user interface code for the replacement CRM experience.
- `docker/`: Future container definitions, compose files, local development infrastructure, and deployment support files.
- `docs/`: Project documentation, architecture notes, migration plans, operational runbooks, and decision records.
- `legacy/`: Staging location for reviewed legacy source snapshots and extracted reference material when the import phase begins.
- `scripts/`: Project automation, repeatable migration helpers, setup scripts, and developer tooling.
- `tests/`: Cross-cutting automated tests, fixtures that are safe to commit, migration validation tests, and end-to-end coverage.

## Target architecture

The target architecture should convert the existing desktop CRM into a maintainable, testable, and deployable application with clear separation between presentation, business logic, and data access.

### Proposed high-level components

```text
frontend/              User-facing CRM application
backend/               API, domain services, persistence, auth, integrations
tests/                 Unit, integration, migration, and end-to-end tests
scripts/               Repeatable import, conversion, validation, and data tools
docker/                Local and deployable runtime infrastructure
docs/                  Architecture and migration documentation
legacy/                Read-only reference snapshots of approved legacy inputs
```

### Architectural principles

- Keep the legacy desktop application as reference material, not as the long-term runtime foundation.
- Preserve business behavior before redesigning workflows.
- Separate domain rules from UI framework and persistence details.
- Build repeatable migration scripts instead of one-off manual conversion steps.
- Add tests around legacy-equivalent behavior before refactoring critical workflows.
- Use environment-driven configuration for database connections, secrets, and deployment-specific settings.
- Maintain a clean repository boundary by excluding generated outputs, binaries, caches, local databases, backups, and bulky artifacts.

### Suggested target layers

- **Presentation layer**: CRM screens, forms, navigation, validation feedback, and user-facing state management in `frontend/`.
- **API layer**: HTTP or RPC endpoints, request validation, response contracts, authentication, authorization, and integration boundaries in `backend/`.
- **Domain layer**: Customer, contact, lead, opportunity, account, activity, task, reporting, and user-management rules in `backend/`.
- **Persistence layer**: Database schema, migrations, repositories, query services, and data import/export adapters in `backend/`.
- **Migration tooling**: Legacy parsers, transformation scripts, data mapping reports, and validation checks in `scripts/` and `tests/`.
- **Operations layer**: Local development services, container orchestration, and deployable runtime configuration in `docker/`.

## Legacy application import strategy

The legacy source should not be imported until it has been inventoried, filtered, and approved. The first import should be intentionally narrow and should avoid committing generated files or binary artifacts.

### Recommended import workflow

1. **Inventory the legacy application outside the repository**
   - Identify source directories, project files, database schemas, report definitions, configuration files, assets, third-party dependencies, generated outputs, local databases, installers, and build artifacts.
   - Record language, framework, runtime, database engine, reporting tools, and deployment assumptions.

2. **Classify files before copying**
   - Mark files as source, configuration template, database schema, documentation, tests, generated output, binary artifact, local environment file, secret-bearing file, or unknown.
   - Do not copy unknown or secret-bearing files into the repository until reviewed.

3. **Create a clean legacy snapshot under `legacy/` only after review**
   - Preserve the original directory structure where useful for traceability.
   - Add a manifest documenting source location, import date, excluded paths, checksums where appropriate, and known omissions.
   - Keep the snapshot read-only in practice: new development should happen in `backend/`, `frontend/`, `scripts/`, and `tests/`.

4. **Extract behavior and data contracts**
   - Document screens, workflows, data entities, validation rules, reports, permissions, integrations, scheduled jobs, and import/export formats.
   - Prioritize customer-critical workflows and data integrity rules.

5. **Build migration adapters incrementally**
   - Add scripts that can read legacy data formats without mutating source files.
   - Produce deterministic transformation outputs and validation reports.
   - Add automated checks for record counts, required fields, relationship integrity, and representative workflow behavior.

6. **Replace functionality phase by phase**
   - Rebuild the smallest complete vertical slice first.
   - Compare new behavior against legacy behavior with documented acceptance criteria.
   - Keep traceability between legacy modules and replacement modules until parity is confirmed.

## Files and folders to include

When the import phase begins, include only reviewed materials that are necessary for understanding, testing, or migrating the legacy system.

### Include from the legacy application

- Human-authored source code files.
- Project or solution files required to understand module boundaries.
- Database schema definitions, migration scripts, stored procedure definitions, and seed/reference data that are safe to commit.
- Report templates and query definitions if they are human-authored and required for CRM parity.
- UI layout definitions, form metadata, validation definitions, and workflow configuration.
- Documentation, user guides, deployment notes, and architecture notes.
- Test files and representative non-sensitive fixtures.
- Static assets that are source assets and required to reproduce the application experience, such as icons or images, if licensing permits.
- Dependency manifests and lockfiles when they are part of the legacy build process.
- Sanitized configuration examples, using placeholder values instead of real credentials or machine-specific paths.
- A legacy import manifest documenting what was imported and what was excluded.

### Include in the target application

- Backend source, database migrations, and API contract definitions in `backend/`.
- Frontend source, route definitions, reusable UI components, and client-side tests in `frontend/`.
- Container and local development configuration in `docker/`.
- Repeatable automation in `scripts/`.
- Automated tests, safe fixtures, and migration validation checks in `tests/`.
- Architecture decisions, migration notes, runbooks, and mapping documents in `docs/`.

## Files and folders to exclude

Do not commit files that are generated, machine-specific, secret-bearing, bulky, or unnecessary for source control.

### Exclude from legacy import

- Compiled binaries, installers, packaged applications, object files, and executable build outputs.
- Generated folders such as `bin/`, `obj/`, `dist/`, `build/`, `target/`, `.next/`, coverage outputs, and cache directories.
- Dependency folders such as `node_modules/`, `vendor/`, virtual environments, package caches, and restored binary dependencies.
- Local databases, production database dumps, customer data, backups, exported spreadsheets, and ad hoc data extracts unless sanitized and explicitly approved.
- Secrets, credentials, API keys, certificates, private keys, connection strings, and environment-specific configuration.
- User-specific IDE settings, local workspace files, temporary files, logs, and OS metadata.
- ZIP archives, compressed backups, disk images, and other binary archives.
- Generated code that can be recreated from committed source definitions, unless it is required and explicitly justified.
- Third-party proprietary libraries unless licensing and repository policy explicitly allow committing them.

### Exclude from target development

- Runtime logs, local environment files, local databases, coverage reports, and generated artifacts.
- Demo files or throwaway prototypes unless explicitly requested and reviewed.
- Large binary assets that should be stored in an artifact system instead of Git.

## Migration phases

### Phase 0: Repository preparation

- Confirm repository conventions, branching, commit policy, and documentation structure.
- Maintain the empty top-level directories with `.gitkeep` files until real source files are added.
- Add migration planning and architecture documentation.
- Define import review criteria and exclusion rules.

### Phase 1: Legacy discovery and inventory

- Inspect the legacy application outside this repository.
- Produce an inventory of modules, technologies, dependencies, data stores, integrations, reports, and deployment steps.
- Identify secrets and sensitive data that must not be imported.
- Decide which files are eligible for a controlled import into `legacy/`.

### Phase 2: Controlled legacy import

- Import only approved legacy source and documentation into `legacy/`.
- Add an import manifest with source provenance, import date, excluded paths, and review notes.
- Preserve enough structure for traceability while avoiding generated and binary artifacts.
- Verify the import with repository status checks and file-type scans.

### Phase 3: Domain and data mapping

- Map legacy entities to target CRM domain models.
- Document database tables, relationships, constraints, validation rules, and lookup/reference data.
- Identify data quality issues, duplicate handling needs, and required transformations.
- Define acceptance criteria for migrated records and critical workflows.

### Phase 4: Target foundation

- Select and scaffold the backend and frontend technology stacks.
- Add baseline application structure, test harnesses, linting, formatting, and local runtime configuration.
- Define API contracts, authentication approach, authorization model, and database migration strategy.
- Add initial CI-ready commands for validation.

### Phase 5: First vertical slice

- Implement a narrow CRM workflow end to end, such as customer/contact read-only listing and detail views.
- Add migration tooling for the data needed by that workflow.
- Validate behavior and data against legacy expectations.
- Capture differences as documented decisions or follow-up work.

### Phase 6: Incremental module migration

- Migrate modules by business priority and dependency order.
- For each module, add tests, data mapping, migration scripts, UI flows, API support, and documentation updates.
- Keep legacy-to-target traceability until parity is accepted.
- Retire legacy references only after replacement behavior is verified.

### Phase 7: Cutover preparation

- Run full migration rehearsals with sanitized or approved datasets.
- Validate performance, permissions, auditability, reporting, backup, restore, and operational procedures.
- Prepare user acceptance testing materials and rollback plans.
- Freeze legacy changes or define a delta migration process.

### Phase 8: Production cutover and stabilization

- Execute final data migration and validation.
- Switch users to the new application according to the approved cutover plan.
- Monitor errors, performance, and data integrity.
- Address stabilization issues and document operational lessons learned.

## Risks

- **Incomplete legacy inventory**: Missing modules, reports, scheduled jobs, or hidden workflows could cause parity gaps.
- **Data quality issues**: Duplicate records, invalid references, inconsistent formats, or implicit business rules may complicate migration.
- **Sensitive data exposure**: Legacy directories may contain credentials, customer data, database dumps, or private certificates that must not be committed.
- **Generated artifact pollution**: Build outputs and binary files can bloat the repository and obscure source history.
- **Undocumented business rules**: Critical behavior may exist only in desktop UI code, stored procedures, reports, or user habits.
- **Technology mismatch**: Legacy assumptions may not map cleanly to the target architecture or deployment model.
- **Scope creep**: Rebuilding and redesigning at the same time can delay parity and increase acceptance risk.
- **Integration uncertainty**: Email, calendar, telephony, accounting, document storage, or reporting integrations may require separate migration paths.
- **Testing gaps**: Lack of legacy tests may make behavior verification dependent on manual review.
- **Cutover risk**: Long migration windows, active legacy writes, and rollback complexity can affect business continuity.

## Next development steps

1. Confirm the target technology stack for `backend/`, `frontend/`, database, testing, and deployment.
2. Create a legacy inventory template in `docs/` to standardize discovery output.
3. Inspect the legacy application outside the repository and classify all files before import.
4. Draft `.gitignore` updates for known legacy and target build artifacts once technologies are confirmed.
5. Prepare a controlled import checklist for the future `legacy/` snapshot.
6. Define the first migration vertical slice and acceptance criteria.
7. Document the initial domain model and data mapping assumptions.
8. Add baseline test and validation commands after the target stack is selected.
9. Plan a sanitized data strategy for migration rehearsals and automated validation.
10. Review this plan with product, engineering, operations, and data owners before importing legacy source.
