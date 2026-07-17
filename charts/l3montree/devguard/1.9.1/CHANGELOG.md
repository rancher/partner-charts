# Changelog

All notable changes to the DevGuard Helm chart are documented here.

For API and web frontend changes see the [main DevGuard CHANGELOG](https://github.com/l3montree-dev/devguard/blob/main/CHANGELOG.md).

## [v1.9.1] — 2026-07-17

### Added

- `api.ingress.tls` / `web.ingress.tls` now also accept a **boolean**. Set it to `true` to serve the ingress over TLS for the single configured host; the certificate is read from `api.ingress.tlsSecretName` / `web.ingress.tlsSecretName` (new values, defaulting to `devguard-api-tls` / `devguard-web-tls` when empty). The old list shape (`tls: [{hosts, secretName}]`) is still fully supported as a fallback.
- `api.ingress.host` / `web.ingress.host` — single-host **scalars** the Rancher install form can populate (the form cannot write list entries like `hosts[0].host`). Each serves one host at path `/` (pathType `Prefix`). The old `api.ingress.hosts` / `web.ingress.hosts` list is still fully supported as a fallback for multi-host / custom-path setups.

### Changed

- The single-host `host` scalar and boolean `tls` are now the documented default in `values.yaml`. **These changes are backwards compatible:** existing values files using the `hosts` and `tls` list shapes continue to render unchanged — no migration required.

### Deprecated

- The list shapes `api.ingress.hosts` / `web.ingress.hosts` (`[{host, paths}]`) and `api.ingress.tls` / `web.ingress.tls` (`[{hosts, secretName}]`) are **deprecated and will be removed in the next major version.** Helm prints a deprecation warning on install/upgrade when they are detected. Migrate to the single-host `host` scalar and the boolean `tls` + `tlsSecretName`. If you rely on multiple hosts or a custom path prefix, please open a ticket: https://github.com/l3montree-dev/devguard-helm-chart/issues

---

## [v1.9.0] — 2026-07-14

### Added

- Support for specifying additional environment variables for all services (DevGuard, DevGuard web, Kratos, PostgreSQL) (thanks to [@skuethe](https://github.com/skuethe))
- Support for using existing secrets without relying on the Helm `lookup` function, for the DB, Kratos DB, Kratos, encryption, and pprof secrets (thanks to [@skuethe](https://github.com/skuethe))

### Changed

- Bumped default Kratos image version to v26.2.0
- Extended access control documentation for database secrets (thanks to [@skuethe](https://github.com/skuethe))

### Fixed

- Corrected YAML indentation on secret templates (thanks to [@skuethe](https://github.com/skuethe))

---

## [v1.8.0] — 2026-07-06

First release under the shared [versioning policy](https://github.com/l3montree-dev/devguard/blob/main/versioning.md): major/minor versions are now synchronized across devguard, devguard-web, the Helm chart, and CI components.

### Added

- Chart metadata: maintainers, keywords, icon, and source links (`Chart.yaml`)
- Configurable Grafana dashboard sidecar label (`observability.grafanaDashboard.labelName` / `labelValue`)

### Changed

- Improved GitHub Actions release workflow to use the job token for release creation
- Minor GitLab CI pipeline cleanup

---

## [v1.7.0] — 2026-06-19

### Added

- Configurable instance admin public key via `instanceAdmin.publicKey` value

### Changed

- Bumped default DevGuard image versions to v1.7.0
- Added GitLab mirror workflow

---

## [v1.6.2] — 2026-06-17

### Changed

- Added `PROFILE` environment variable to the API deployment

---

## [v1.6.1] — 2026-06-16

### Changed

- Bumped default DevGuard image versions to v1.6.1

---

## [v1.6.0] — 2026-06-16

### Added

- App-side encryption `initContainer` and automatic secret generation for the encryption key

### Changed

- Bumped default DevGuard image versions to v1.6.0

---

## [v1.5.1] — 2026-05-29

### Changed

- Bumped default DevGuard image versions to v1.5.1

---

## [v1.5.0] — 2026-05-28

### Changed

- Bumped default DevGuard image versions to v1.5.0

---

## [v1.4.0] — 2026-05-21

### Changed

- Bumped default DevGuard image versions to v1.4.2

---

## [v1.3.5] — 2026-05-08

### Added

- Resource requests/limits are now fully configurable per component
- Kratos session cleanup CronJob
- `chown` init container for root-mounted PostgreSQL volumes

### Changed

- PostgreSQL security contexts exposed as configurable values
- Default CPA behaviour applied to the PostgreSQL init container

---

## [v1.3.4] — 2026-04-28

### Changed

- Bumped default DevGuard image versions to v1.3.1

---

## [v1.3.3] — 2026-04-28

### Fixed

- Removed default case for `registrationEnabled` that caused unexpected behaviour

---

## [v1.3.2] — 2026-04-28

### Fixed

- PostgreSQL `run` directory now uses `emptyDir` instead of a host path

---

## [v1.3.1] — 2026-04-28

### Changed

- Bumped default image tags

---

## [v1.3.0] — 2026-04-28

### Changed

- Bumped default DevGuard image versions to v1.3.0

---

## [v1.2.3] — 2026-04-23

### Added

- Web environment variables for script integrity (`SCRIPT_INTEGRITY` / `NEXT_PUBLIC_*`)

### Changed

- Bumped default DevGuard image versions to v1.2.3

---

## [v1.2.2] — 2026-04-22

### Changed

- Bumped default DevGuard image versions to v1.2.2

---

## [v1.2.1] — 2026-04-14

### Changed

- Updated default values; bumped API version to v1.2.1

---

## [v1.2.0] — 2026-04-14

### Added

- Support for pinning images by digest (`image.digest`)
- Configurable `DEVGUARD_API_URL` in the deployment and values

### Changed

- Bumped default DevGuard image versions to v1.2.0

---

## [v1.1.6] — 2026-03-20

### Added

- Compliance folder (`.compliance/`)
- PostgreSQL config mounted at `/etc`
- Grafana dashboard included in chart
- ServiceMonitor labels so Prometheus auto-discovers services

### Changed

- Kratos jsonnet mapper falls back to GitHub login

---

## [v1.1.5] — 2026-03-17

### Fixed

- Removed `hook-delete-policy` that prevented clean upgrades

---

## [v1.1.4] — 2026-03-17

### Added

- Helm hook-based OPA/Kyverno policy enforcement

---

## [v1.1.3] — 2026-03-17

### Fixed

- Kyverno policy: only verify signing attestations, not build provenance for PostgreSQL image

---

## [v1.1.2] — 2026-03-17

### Added

- `mutateDigest` option (conditional)

---

## [v1.1.1] — 2026-03-17

### Changed

- Kyverno policies disabled by default

---

## [v1.1.0] — 2026-03-17

### Added

- Kyverno policy verifying build provenance for OCI images
- Connector endpoint added to ServiceMonitor
- OpenTelemetry tracing support (basic auth, span metrics sidecar)
- Prometheus `ServiceMonitor` resource

### Changed

- Bumped default DevGuard image versions to v1.1.0

---

## [v1.0.1] — 2026-03-02

### Changed

- Bumped default DevGuard image versions to v1.0.1

---

## [v1.0.0] — 2026-02-20

Initial stable release of the DevGuard Helm chart.

### Added

- Deployments for `devguard` (API), `devguard-web` (frontend), `devguard-scanner`, and bundled PostgreSQL
- Configurable ingress, TLS, resource limits, and replica counts
- Kratos identity server integration with configurable jsonnet mappers
- Secret management for database credentials and integration tokens
