# Architecture

Helm chart for **DevGuard** (software supply-chain security, vulnerability management, compliance). Deploys the API (`devguard`), web frontend (`devguard-web`), the Ory Kratos identity server, and a bundled PostgreSQL, plus optional observability (ServiceMonitor, Grafana dashboards, OTel tracing) and Kyverno policies.

The chart is also published as a **Rancher partner chart**, which shapes several design decisions (see [Rancher constraints](#rancher-constraints)).

## Single source of truth: `schema/schema.ts`

`values.yaml`, the Rancher `questions.yaml`, and `version`/`appVersion` in `Chart.yaml` are **generated** from [`schema/schema.ts`](schema/schema.ts).

- **Never hand-edit `values.yaml` or `questions.yaml`** — edit `schema.ts` and regenerate. Generated files start with `# DO NOT EDIT`.
- CI (`schema-check`) fails if generated files are out of sync.

```bash
cd schema
bun install          # deps are just `yaml`
bun run generate     # writes values.yaml, Chart.yaml (version/appVersion), questions.yaml
bun run check        # same as CI: exit 1 if any output is stale
```

### Generator model

- `schema.ts` is one nested tree; plain values render directly into `values.yaml`.
- `f(value, opts)` (from [`schema/builder.ts`](schema/builder.ts)) attaches metadata: `comment`, `inline`, `trailingComment`, `blankBefore`, and `question` (Rancher form metadata). `banner("Title")` renders a section header.
- `devguardVersion` is the **one version knob**: it sets the api/web/postgresql image tags and `Chart.yaml`'s `version` + `appVersion`. Bump it there only.
- Kratos, postgres-exporter, busybox, and CI-component versions live in the `dependencies` object at the top of `schema.ts`.
- In `Chart.yaml`, only `version`/`appVersion` are generated; the rest is hand-maintained.

### Outputs

| File             | Location                                                                 | Notes                                          |
| ---------------- | ------------------------------------------------------------------------ | ---------------------------------------------- |
| `values.yaml`    | chart root                                                               | fully generated                                |
| `Chart.yaml`     | chart root                                                               | only `version` + `appVersion` patched in place |
| `questions.yaml` | sibling `../rancher-partner-charts/packages/l3montree/devguard/overlay/` | fully generated                                |

The partner-charts repo is expected next to this one (override with `PARTNER_QUESTIONS=/path bun run generate`). If the sibling directory is absent (e.g. in CI), the partner output is skipped.

## Repo layout

```
schema/            # source of truth (TypeScript + bun) — edit here
templates/         # Helm templates (hand-written)
  _helpers.tpl     # devguard.image / devguard.labels / devguard.imagePullPolicy
  devguard/        # API: deployment, ingress, secrets, hpa, service, servicemonitor
  devguard-web/    # web frontend: deployment, ingress, hpa, service
  kratos/          # deployment, config, secret, service, cleanup cronjob
  postgresql/      # statefulset, service, configmap, initdb, pvc, dashboards
  otel-collector/  # tracing sidecar config
  *.yaml           # db-secret, kratos-db-secret, networkpolicy, kyverno-policy
values.yaml        # GENERATED
Chart.yaml         # metadata hand-maintained; version/appVersion GENERATED
CHANGELOG.md       # hand-maintained; keep an [Unreleased] section
tests/kyverno/     # kyverno CLI policy tests
rancher/           # local Rancher test harness (compose, Caddy, e2e) -> see ./rancher/README.md
.gitlab-ci.yml     # primary CI (validate → publish → release)
.github/workflows/ # helm-test, rancher-catalog-test, mirror-to-gitlab, helm-release
```

## Rancher constraints

The Rancher install form drives deliberate limitations — respect them:

- **Single ingress host.** `api.ingress.host` / `web.ingress.host` are scalars, not lists; each ingress serves one host at `/` (pathType `Prefix`). The old `hosts[]` shape fails the template with a migration hint — the Rancher form can't address list entries.
- **Boolean TLS.** `*.ingress.tls` is a boolean (matches Rancher's TLS toggle); the cert comes from `*.ingress.tlsSecretName` (defaults `devguard-{api,web}-tls`). The old list shape fails with a hint.
- Form-exposed fields carry `question` metadata in `schema.ts`; group order is controlled by `GROUP_ORDER`.

## Versioning

All DevGuard components (API, web, chart, CI) share the same **minor** version: any `vX.Y.*` is compatible with any other `vX.Y.*`; patches release independently. Bump `devguardVersion` in `schema.ts` and regenerate.

## Secrets & configuration behavior

- Secrets (`db-secret`, `kratos`, encryption key, pprof, intoto) are auto-generated via Helm `lookup` and preserved across upgrades. Each has a `useExisting*` / `generate` toggle to bring your own secret (needed where `lookup` is unavailable, e.g. ArgoCD).
- `additionalEnvs` (per component) injects extra env vars and is run through `tpl`, so values can reference other chart values.

## Working conventions

- After changing configurable values: `cd schema && bun run generate`, commit the regenerated files together with the `schema.ts` change.
- Verify template changes with `helm lint .` **and** `helm template dg . -f <test-values>` — render, don't just lint.
- Document breaking value changes in `CHANGELOG.md` under `[Unreleased]`, with a migration hint mirroring the template `fail` messages.
