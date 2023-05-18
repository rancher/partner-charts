# Changelog
All notable changes are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## v1.2.0 - 2023-05-12

### ⛓️ Dependencies
- Updated newrelic/newrelic-prometheus-configurator to v1.4.0 - [Changelog 🔗](https://github.com/newrelic/newrelic-prometheus-configurator/releases/tag/1.4.0)

## v1.1.1 - 2023-03-20

### ⛓️ Dependencies
- Updated common-library to v1.1.1 - [Changelog 🔗](https://github.com/newrelic/helm-charts/releases/tag/common-library-1.1.1)

## v1.1.0 - 2023-01-30

### 🚀 Enhancements
- Set `NR_PROM_CHART_VERSION` env var in the configurator statefulset init container.

### ⛓️ Dependencies
- Upgraded github.com/prometheus/prometheus from 0.37.3 to 0.37.5 - [Changelog 🔗](https://github.com/prometheus/prometheus/releases/tag/0.37.5)

## v1.0.1 - 2022-11-30

### 🐞 Bug fixes
- whenever `config.kubernetes.integrations_filter.enabled: false` we should pass the list of `labels` and `app_values` to the configurator config.

## v1.0.0 - 2022-11-29

### First stable release
- From now on the configuration is considered stable.

### 🚀 Enhancements
- added `k8s-app` label in `integration_filters`.
- added `kube-dns` label value in `integration_filters` to cover `coreDNS` use-case.
- configurator version bumped to `1.0.0`

### 🐞 Bug fixes
- chart readme was outdated with respect the new default behaviour of integrations_filters.

### ⛓️ Dependencies
- Upgraded github.com/prometheus/prometheus from 0.37.2 to 0.37.3 [Changelog](https://github.com/prometheus/prometheus/releases/tag/0.37.3)

## v0.3.1 - 2022-11-08

### 🚀 Enhancements
- the chart is now applying by default a series of relabel configs to fix metric types for Cockroach db service.
- the chart is now scraping by default Cockroach db service as well.

### 🐞 Bug fixes
- updated appVersion of `quay.io/prometheus/prometheus` from v2.37.1 to v2.37.2

## v0.2.1 - 2022-11-03

### 🐞 Bug fixes
- `imagePullPolicy` is now correctly applied to the init container as well.

## v0.2.0 - 2022-11-03

### Note, defaults of the chart changed
Now, the chart has two jobs configured and integration filters turned on by default:
- `default` scrapes all targets having `prometheus.io/scrape: true`. By default, `integrations_filter.enabled=true`, unless changed, only targets selected by the integration filters will be scraped.
- `newrelic` scrapes all targets having `newrelic.io/scrape: true`. This is useful to extend the `default` job allowlisting by adding the required annotation on each extra service.

### 🚀 Enhancements
- `integration filters` option, is now supported and enabled by default.

## v0.1.1 - 2022-10-20

### ⛓️ Dependencies
- Updated newrelic/newrelic-prometheus-configurator to v0.1.0

## v0.1.0 - 2022-10-17

### 🚀 Enhancements
- The chart is now published leveraging the release toolkit.
- The chart release notes from now on will be available in the chart package and in the GitHub release notes.

## [0.0.6] - 2022-10-11
### Changed
- Changed the default value for `extra_scrape_configs` and improved the documentation

## [0.0.5] - 2022-10-06
### Changed
- `newrelic-prometheus-configurator` image bumped `0.0.1` -> `0.0.2`.

## [0.0.4] - 2022-09-30
### Changed
- Rename chart `newrelic-prometheus` -> `newrelic-prometheus-agent`.

## [0.0.3] - 2022-09-30
### Changed
- Improve docs on readme and values.yaml.

## [0.0.2] - 2022-09-21
### Changed
- Update docs on readme.

## [0.0.1] - 2022-09-20
### Added
- First Version of this Chart.

