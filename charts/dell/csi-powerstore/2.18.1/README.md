# CSI Driver for Dell PowerStore

## Overview

A Helm chart for deploying the Dell CSI Driver for PowerStore on Kubernetes. Enables dynamic volume provisioning, snapshots, and metrics-based Prometheus alerting.

## Prerequisites

- Kubernetes 1.29+
- Helm 3.x
- Dell PowerStore array with API access
- (Optional for alerts) Prometheus Operator CRDs (`monitoring.coreos.com/v1`) installed in the cluster

## Installation

```bash
helm install my-powerstore ./csi-powerstore -f values.yaml
```

## PrometheusRule Alert Rules

### Overview

When `metrics.enabled: true` AND `metrics.prometheusRule.enabled: true`, the chart creates a `PrometheusRule` custom resource (API version: `monitoring.coreos.com/v1`) containing **18 alert rules** for the PowerStore CSI driver.

Rules cover the following categories:

- **Volume operation failures** — CreateVolume, DeleteVolume, Publish/Unpublish, Stage/Unstage
- **Driver health** — pod availability, crash looping, high memory usage, high CPU usage
- **API connectivity** — error rate thresholds and connectivity loss
- **Authentication** — auth failure detection
- **Appliance capacity** — warning and critical utilization thresholds
- **Thin provisioning over-commitment** — logical capacity exceeding physical capacity

> **Default:** `metrics.prometheusRule.enabled` is `true` — PrometheusRule creation is active by default when `metrics.enabled` is `true`. Set to `false` to disable bundled alerts.

### Prerequisites

- Prometheus Operator CRDs (`monitoring.coreos.com/v1`) must be installed in the cluster before enabling this feature.
- Prometheus scraping must be configured via a ServiceMonitor (controller) and/or PodMonitor (node pods).
- `metrics.enabled: true` must be set — the PrometheusRule resource is skipped entirely when metrics are disabled.

### Threshold Format

All numeric threshold parameters use a **whole-number percent** format in the range 0–100, where `80` means "80%". The chart internally normalizes comparisons to each metric's native scale:

- **Percent-scale metrics** (e.g., CPU utilization, appliance utilization after conversion) are compared directly against the threshold value.
- **Ratio-scale metrics** are converted before comparison.

The `memoryWarningThreshold` parameter is an exception — it is expressed in **bytes** rather than percent (e.g., `2147483648` = 2 GiB).

### Configuration Parameters

| Parameter | Type | Default | Human-readable | Alert(s) Affected | Description |
|---|---|---|---|---|---|
| `metrics.prometheusRule.enabled` | bool | `true` | — | All | Enable/disable PrometheusRule creation |
| `metrics.prometheusRule.applianceWarningThreshold` | integer | `80` | = 80% | PST-16 | Appliance utilization warning level |
| `metrics.prometheusRule.applianceCriticalThreshold` | integer | `90` | = 90% | PST-17 | Appliance utilization critical level |
| `metrics.prometheusRule.apiErrorRateThreshold` | integer | `10` | = 10% | PST-13 | API error rate warning level |
| `metrics.prometheusRule.apiErrorRateWindow` | string | `"5m"` | — | PST-13 | Prometheus `rate()` window for API errors |
| `metrics.prometheusRule.cpuWarningThreshold` | integer | `80` | = 80% | PST-12 | Driver pod CPU warning level |
| `metrics.prometheusRule.memoryWarningThreshold` | integer | `2147483648` | = 2 GiB | PST-11 | Driver pod memory warning level (bytes) |
| `metrics.prometheusRule.driverCrashLoopRestartThreshold` | integer | `3` | — | PST-10 | Restart count to trigger crash loop alert |
| `metrics.prometheusRule.driverCrashLoopWindow` | string | `"15m"` | — | PST-10 | Window for crash loop restart counting |

### Alert Inventory

| Alert ID | Alert Name | Severity | Category | Trigger Condition | Configurable Threshold? |
|---|---|---|---|---|---|
| PST-01 | PowerStoreCreateVolumeFailure | warning | Volume Operations | CreateVolume failures > 0 in 5m | No |
| PST-02 | PowerStoreDeleteVolumeFailure | warning | Volume Operations | DeleteVolume failures > 0 in 5m | No |
| PST-03 | PowerStoreControllerPublishVolumeFailure | warning | Volume Operations | ControllerPublishVolume failures > 0 in 5m | No |
| PST-04 | PowerStoreControllerUnpublishVolumeFailure | warning | Volume Operations | ControllerUnpublishVolume failures > 0 in 5m | No |
| PST-05 | PowerStoreNodeStageVolumeFailure | warning | Volume Operations | NodeStageVolume failures > 0 in 5m | No |
| PST-06 | PowerStoreNodeUnstageVolumeFailure | warning | Volume Operations | NodeUnstageVolume failures > 0 in 5m | No |
| PST-07 | PowerStoreNodePublishVolumeFailure | warning | Volume Operations | NodePublishVolume failures > 0 in 5m | No |
| PST-08 | PowerStoreNodeUnpublishVolumeFailure | warning | Volume Operations | NodeUnpublishVolume failures > 0 in 5m | No |
| PST-09 | PowerStoreDriverPodUnavailable | critical | Driver Health | Controller or node driver metrics absent for 5m | No |
| PST-10 | PowerStoreDriverCrashLooping | warning | Driver Health | Restart count > `driverCrashLoopRestartThreshold` in window | Yes |
| PST-11 | PowerStoreDriverHighMemoryUsage | warning | Driver Health | Memory > `memoryWarningThreshold` for 5m | Yes |
| PST-12 | PowerStoreDriverHighCPUUsage | warning | Driver Health | CPU% > `cpuWarningThreshold` for 5m | Yes |
| PST-13 | PowerStoreHighAPIErrorRate | warning | Driver Health | API error rate% > `apiErrorRateThreshold` for 5m | Yes |
| PST-14 | PowerStoreMetricsStale | warning | Connectivity | Metrics stale flag set for 5m | No |
| PST-15 | PowerStoreAuthenticationFailure | critical | Authentication | `auth_failure` errors > 0 in 5m | No |
| PST-16 | PowerStoreApplianceCapacityWarning | warning | Capacity | Appliance utilization% > `applianceWarningThreshold` for 10m | Yes |
| PST-17 | PowerStoreApplianceCapacityCritical | critical | Capacity | Appliance utilization% > `applianceCriticalThreshold` for 10m | Yes |
| PST-18 | PowerStoreThinProvisioningOvercommitment | warning | Capacity | `compression_ratio × utilization_ratio > 1.0` for 10m | No |

> **Note — PST-18:** This alert fires when logical provisioned capacity exceeds physical capacity. It is not configurable via threshold parameters — the condition is binary (`product > 1.0`).

### Enabling PrometheusRule

Add the following to your `values.yaml` to enable the PrometheusRule with custom thresholds:

```yaml
metrics:
  enabled: true
  prometheusRule:
    enabled: true
    applianceWarningThreshold: 75
    applianceCriticalThreshold: 90
    apiErrorRateThreshold: 10
    apiErrorRateWindow: "5m"
    cpuWarningThreshold: 80
    memoryWarningThreshold: 2147483648
    driverCrashLoopRestartThreshold: 3
    driverCrashLoopWindow: "15m"
```

### Alertmanager Routing

For recommended Alertmanager routing configuration using the `platform: powerstore` and `component: csi-driver` labels, see the runbook at:

```
src/docs/v1.18.0/runbooks/alertmanager-routing-powerstore.md
```

## Metrics

When `metrics.enabled: true`, metrics are scraped via:

- **ServiceMonitor** — targets the controller pod
- **PodMonitor** — targets node driver pods across the cluster

## Values Reference

See [`values.yaml`](./values.yaml) for the full parameter reference with inline comments.
