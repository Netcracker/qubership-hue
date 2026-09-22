# Documentation Index

Navigable index of the Qubership Hue documentation.

## Navigation

### docs/public/

- [architecture.md](/docs/public/architecture.md) — Deployment schema overview, supported deployment scheme (Non-HA), Hue/Trino components, and example database connections.
- [installation.md](/docs/public/installation.md) — Prerequisites, the full Helm chart parameter reference, TLS/Kerberos/LDAP/Keycloak setup, HTTPRoute (Gateway API) support, installation/upgrade/rollback steps.
- [configuration-guide.md](/docs/public/configuration-guide.md) — Hue Hadoop-side setup, Hive configuration, connecting to Trino-supported databases (Cassandra, MongoDB, Redis), PostgreSQL/Greenplum, and OOB-supported connections.
- [security.md](/docs/public/security.md) — Exposed ports, secure protocols, user management, credential rotation, security events, and session management.

### docs/internal/

- [readme.md](/docs/internal/readme.md) — Repository structure, how to start developing, upgrade strategy, and useful upstream links.
- [dev.md](/docs/internal/dev.md) — Deploying Hue with non-Kerberized, non-HA Hadoop for local testing.

### docs/sources/

- `qubership-hue.drawio` — Source diagram for the deployment schema images used in `architecture.md`/the root `README.md`.

## Project Layout

```
docs/
├── internal/
│   ├── dev.md            # Non-Kerberized, non-HA Hadoop testing setup
│   ├── images/
│   │   └── qubership-hue-non-ha-scheme.png
│   └── readme.md         # Repo structure, dev workflow, upgrade strategy
├── public/
│   ├── architecture.md       # Deployment schema and components
│   ├── configuration-guide.md # Hadoop/Hive/Trino/database connection setup
│   ├── installation.md       # Prerequisites, parameters, install/upgrade/rollback
│   ├── security.md           # Ports, protocols, user/session/credential management
│   └── images/
│       ├── keycloak_client.png
│       ├── keycloak_client_scopes.png
│       ├── keycloak_group_mapper.png
│       ├── keycloak_mapper.png
│       └── qubership-hue-non-ha-scheme.png
└── sources/
    └── qubership-hue.drawio  # Source diagram for deployment schema images
```
