---
name: qa-hue
description: Plan and verify testing of a Qubership Hue change when the repository has no automated tests — deploy-based verification of the Hue web UI, PostgreSQL creation and migration, OIDC/LDAP/Kerberos authentication, Hive and Trino editor connectivity, embedded Trino, gateway/ingress and read-only filesystem behaviour. Triggers when the user asks how to test a Hue chart or image change, or why Hue will not start or users cannot log in. Do NOT run automatically.
---

## Read this first

**This repository has no tests.** No unit tests, no integration tests, no Helm test hooks.
The only executable quality gate is a Python lint job (`pythonlint.yml`) over the single file
`hue_docker/createdb.py` — black, flake8, mypy, pylint. It runs **only when that file changes**.

So: lint tells you `createdb.py` is well-formed. It says nothing about whether Hue works.
Every behavioural claim needs a deployment.

---

## The component

`chart/helm/hue` deploys Hue (`gethue/hue:20261105-140101`, `appVersion 1.16.0`) and,
optionally, an **embedded Trino** (`trino.enabled`, default `false`) for databases Hue cannot
reach directly.

Service names are literal: Hue on `8888` (Service `hue`), embedded Trino on `8080`
(Service `trino`).

Pre-install hooks: Secret `huepreinstallhooksecret` (weight `-5`) and Job
`<chart>-create-postgres-db` (weight `-4`, `activeDeadlineSeconds: 320`, `backoffLimit: 6`)
running `/bin/createdb.py`.

---

## The database path is the first thing to verify

`createdb.py` reads credentials from **files**, not env:
`/var/run/secrets/hue/POSTGRES_PASSWORD`, `POSTGRES_ADMIN_USER`, `POSTGRES_ADMIN_PASSWORD`.
It exits 1 when the admin password is empty.

It does **not** run migrations. Migrations happen only in `hue_docker/get_hive_conf.sh`, and
that script runs only when `hue.args` is set to `["/bin/get_hive_conf.sh"]`. Even then it
**exits 0 silently** if any of `AMBARI_USER`, `AMBARI_PASSWORD`, `AMBARI_URL`, `AMBARI_PORT`,
`CLUSTER_NAME` is unset — leaving the schema un-migrated with a green job.

Consequences for any test plan:

- Verify the database and its schema directly in PostgreSQL, not by job status.
- Any change touching `hue.args`, entrypoint or `createdb.py` must be tested with an
  **existing** database as well as a fresh one, because migrations are the risk.

---

## Authentication variants

Each is a distinct deployment, not a toggle to skip.

| Variant | Keys | Specific failure mode |
| --- | --- | --- |
| Local admin | `hue.ini [desktop] [[auth]]` | default credentials left enabled |
| LDAP | `hue.ini [[ldap]]`, `ldap.enabled`, `bind_password_script` | bind password mount missing |
| OIDC / Keycloak | `oidc_rp_client_id`, `oidc_rp_client_secret`, four `oidc_op_*` endpoints, `login_redirect_url=<ingress>/oidc/callback/` | login succeeds but groups do not appear — **Hue does not create groups**; `superuser_group` only marks admins |
| OIDC with TLS IdP | `env: REQUESTS_CA_BUNDLE` + mounted IdP cert | silent TLS failure without the bundle |
| Kerberos | `kerberos.enabled`, `keytab`, `config` | psycopg2 tries GSSAPI to PostgreSQL and fails — needs `options='{"sslmode":"verify-ca","gssencmode":"disable"}'` |

**CSRF 403 behind a custom domain** is a real, frequently misreported defect: the fix is
`[desktop] > [[session]] trusted_origins=<domain>`. Check this before filing a UI bug.

---

## Data-source variants

| Variant | Keys | Notes |
| --- | --- | --- |
| Hive editor | `hive.site` → Secret `<chart>-hive-config` (`hive-site.xml`) | requires a reachable metastore |
| Embedded Trino | `trino.enabled: true` | Service `trino:8080`; interpreters point at `trino://trino:8080/<catalog>` |
| External Trino | `hue.interpreters` | **database properties must exist on that Trino** — Hue cannot supply them |
| Databases common configs | `databasescommon.enabled`, `configs.*` | mongodb / cassandra / redis / tpch properties |

Hue embeds a **specific** Trino image (`release-images.yaml` → `qubership-trino:1.4.0`) and the
release workflow requires a separate `trino_release` input. An upgrade of the embedded Trino is a
coordination scenario — test Hue with the exact Trino version that will ship, not `:main`.

---

## Platform constraints that break startup

- **Read-only root FS.** Requires volumes `tmp→/tmp`, `hadoop-conf→/etc/hadoop/conf`,
  `gunicorn-log-volume→/usr/share/hue/desktop/conf/gunicorn_log.conf`, and
  `HUE_RUN_DIR=/tmp`. Missing any of these looks like a crash loop with unrelated errors.
- **Probe scheme is inferred from ini content** — readiness/liveness use HTTPS only if
  `hue.ini` contains the literal string `ssl_private_key`. A TLS change that forgets this makes
  probes fail against an HTTPS port, or succeed misleadingly when TLS was removed.
- **Secrets shadow ConfigMaps.** `configmap-hive.yaml` becomes `secret-hive.yaml`, and
  `configmap-hue-extra.yaml` / `configmap-hue.yaml` become `secret-hue.yaml`. Editing the
  ConfigMap has no effect — this is a common "my config change did nothing" report.
- **Gateway/ingress auto-derivation** — `ingress.create` and `gateway.enabled` are `null` and
  derived from `GATEWAY_SYSTEM_TYPE`. Test the actual gateway type in the target environment.
- **OpenShift** — `GUNICORN_USE_OS_USER=true` is only set when `PAAS_PLATFORM != KUBERNETES`.

---

## What a deployment test must include

1. `helm template` renders for the changed values.
2. Fresh install: postgres DB job **and** schema tables created (inspect PostgreSQL).
3. Upgrade over an existing Hue DB: existing queries/history preserved, no migration error.
4. Login works for the deployment's auth backend; for OIDC also verify logout redirect and that
   an admin user sees admin UI.
5. Query executed end-to-end in the Hive editor **and** in Trino (embedded or external).
6. Either `metrics`/health endpoints respond or probes are green **and** you explain why.
7. For TLS: browser reaches Hue over HTTPS and probes agree.

Name which of these were skipped and why.

---

## Known documentation drift

`installation.md` lists `databasescommon.enabled` and `trino.enabled` as default `true`; the
chart defaults them to `false`. `certManagerInegration.secretName` is documented as `hue-tls`
but is `hue-tls-cm`. **`values.yaml` and `values.schema.json` are the ground truth**, not the
docs table.

---

## Reviewing a change

- Does it touch auth, the database/migration path, or the read-only volume set? Those are the
  three highest-risk areas and each has a documented trap above.
- Does it change an image tag or the embedded Trino version? Then the test must run the exact
  shipped versions.
- If a config change was reported as "not applied", check whether a Secret shadows the ConfigMap
  before treating it as a defect.
- Propose the cheapest durable check: this repo has none, so a `values.schema.json` constraint
  or a health assertion is worth more than a manual pass.
