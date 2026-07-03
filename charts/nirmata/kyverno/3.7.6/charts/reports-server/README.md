# reports-server

![Version: 0.3.0-rc2](https://img.shields.io/badge/Version-0.3.0--rc2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.3.0-rc4](https://img.shields.io/badge/AppVersion-v0.3.0--rc4-informational?style=flat-square)

TODO

## Installing the Chart

Install `reports-server` Helm repository:

```shell
helm repo add nirmata https://nirmata.github.io/kyverno-charts/
helm install reports-server nirmata/reports-server --namespace reports-server --create-namespace
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fipsEnabled | bool | `false` |  |
| postgresql.image.registry | string | `"docker.io"` |  |
| postgresql.image.repository | string | `"bitnamilegacy/postgresql"` |  |
| postgresql.image.tag | string | `"16.1.0-debian-11-r22"` |  |
| postgresql.image.digest | string | `""` |  |
| postgresql.enabled | bool | `false` | Deploy postgresql dependency chart |
| postgresql.auth.postgresPassword | string | `"reports"` |  |
| postgresql.auth.database | string | `"reportsdb"` |  |
| nameOverride | string | `""` | Name override |
| fullnameOverride | string | `""` | Full name override |
| replicaCount | int | `1` | Number of pod replicas |
| clusterName | string | `""` | Optional cluster name, used to easily identify database records when querying the database directly |
| image.registry | string | `"reg.nirmata.io"` | Image registry |
| image.repository | string | `"nirmata/reports-server"` | Image repository |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.tag | string | `nil` | Image tag (will default to app version if not set) |
| imagePullSecrets | list | `[]` | Image pull secrets |
| priorityClassName | string | `"system-cluster-critical"` | Priority class name |
| serviceAccount.create | bool | `true` | Create service account |
| serviceAccount.annotations | object | `{}` | Service account annotations |
| serviceAccount.name | string | `""` | Service account name (required if `serviceAccount.create` is `false`) |
| podAnnotations | object | `{}` | Pod annotations |
| commonLabels | object | `{}` | Labels to add to resources managed by the chart |
| podSecurityContext | object | `{"fsGroup":2000}` | Pod security context |
| podEnv | object | `{}` | Provide additional environment variables to the pods. Map with the same format as kubernetes deployment spec's env. |
| securityContext | object | See [values.yaml](values.yaml) | Container security context |
| livenessProbe | object | `{"failureThreshold":10,"httpGet":{"path":"/livez","port":"https","scheme":"HTTPS"},"initialDelaySeconds":20,"periodSeconds":10}` | Liveness probe |
| readinessProbe | object | `{"failureThreshold":10,"httpGet":{"path":"/readyz","port":"https","scheme":"HTTPS"},"initialDelaySeconds":30,"periodSeconds":10}` | Readiness probe |
| compliance.enabled | bool | `false` | Enable all compliance monitoring features at once When enabled, this automatically enables: - metrics.serviceMonitor.enabled - metrics.prometheusRules.enabled - metrics.grafanaDashboard.enabled |
| metrics.enabled | bool | `true` | Enable prometheus metrics |
| metrics.serviceMonitor.enabled | bool | `false` | Enable service monitor for scraping prometheus metrics |
| metrics.serviceMonitor.additionalLabels | object | `{}` | Service monitor additional labels |
| metrics.serviceMonitor.interval | string | `""` | Service monitor scrape interval |
| metrics.serviceMonitor.metricRelabelings | list | `[]` | Service monitor metric relabelings |
| metrics.serviceMonitor.relabelings | list | `[]` | Service monitor relabelings |
| metrics.serviceMonitor.scrapeTimeout | string | `""` | Service monitor scrape timeout |
| metrics.prometheusRules.enabled | bool | `false` | Enable prometheus recording rules for policy compliance metrics |
| metrics.prometheusRules.additionalLabels | object | `{}` | PrometheusRule additional labels |
| metrics.grafanaDashboard.enabled | bool | `false` | Enable Grafana dashboard ConfigMap creation |
| metrics.grafanaDashboard.namespace | string | `""` | Namespace to create the ConfigMap in (defaults to release namespace) |
| metrics.grafanaDashboard.labels | object | See values.yaml | Labels to add to the ConfigMap (for Grafana sidecar discovery) |
| metrics.grafanaDashboard.annotations | object | `{}` | Annotations to add to the ConfigMap |
| resources.limits | string | `nil` | Container resource limits |
| resources.requests | string | `nil` | Container resource requests |
| autoscaling.enabled | bool | `false` | Enable autoscaling |
| autoscaling.minReplicas | int | `1` | Min number of replicas |
| autoscaling.maxReplicas | int | `100` | Max number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilisation percentage |
| autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Target memory utilization percentage |
| autoscaling.metrics | list | `[]` | Configures custom HPA metrics Ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/ |
| autoscaling.behavior | object | `{}` | Configures the scaling behavior of the target in both Up and Down directions. |
| pdb | object | `{"enabled":true,"maxUnavailable":"50%","minAvailable":null}` | Using a PDB is highly recommended for highly available deployments. Defaults to enabled. The default configuration doesn't prevent disruption when using a single replica |
| pdb.enabled | bool | `true` | Enable PodDisruptionBudget |
| pdb.minAvailable | string | `nil` | minAvailable pods for PDB, cannot be used together with maxUnavailable |
| pdb.maxUnavailable | string | `"50%"` | maxUnavailable pods for PDB, will take precedence over minAvailable if both are defined |
| nodeSelector | object | `{}` | Node selector |
| tolerations | list | `[]` | Tolerations |
| affinity | object | `{}` | Affinity |
| service.type | string | `"ClusterIP"` | Service type |
| service.port | int | `443` | Service port |
| config.skipMigration | bool | `false` | Skip database migration on startup |
| config.etcd.image.registry | string | `"ghcr.io"` | Image registry |
| config.etcd.image.repository | string | `"nirmata/etcd"` | Image repository |
| config.etcd.image.tag | string | `"3.6.9-hardened"` | Image tag |
| config.etcd.imagePullSecrets | list | `[]` | Image pull secrets for the etcd container image |
| config.etcd.enabled | bool | `true` |  |
| config.etcd.endpoints | string | `nil` |  |
| config.etcd.insecure | bool | `true` |  |
| config.etcd.storage | string | `"2Gi"` |  |
| config.etcd.quotaBackendBytes | int | `1932735283` |  |
| config.etcd.storageClassName | string | `""` | Storage class name for etcd PVC. Leave empty to use the cluster's default storage class. Set to a specific storage class name (e.g., "fast", "standard", "aws-ebs") to pin the PV. |
| config.etcd.nodeSelector | object | `{}` |  |
| config.etcd.tolerations | list | `[]` |  |
| config.etcd.autoCompaction.enabled | bool | `true` | Enable auto-compaction for etcd |
| config.etcd.autoCompaction.mode | string | `"periodic"` | Auto-compaction mode (periodic or revision) |
| config.etcd.autoCompaction.retention | string | `"30m"` | Auto-compaction retention (e.g., 30m for 30 minutes, 1h for 1 hour) |
| config.db.secretCreation | bool | `false` | If set, a secret will be created with the database connection information. If this is set to true, secretName must be set. |
| config.db.secretName | string | `""` | If set, database connection information will be read from the Secret with this name. Overrides `db.host`, `db.name`, `db.user`, `db.password`, and `db.readReplicaHosts`. |
| config.db.host | string | `""` | Database host |
| config.db.hostSecretKeyName | string | `"host"` | The database host will be read from this `key` in the specified Secret, when `db.secretName` is set. |
| config.db.readReplicaHosts | string | `""` | Database read replica hosts. Comma-separated list of hostnames; reads are routed to a random replica with fallback to the primary. |
| config.db.readReplicaHostsSecretKeyName | string | `"readReplicaHosts"` | The database read replica hosts will be read from this `key` in the specified Secret, when `db.secretName` is set. |
| config.db.port | int | `5432` | Database port |
| config.db.portSecretKeyName | string | `"port"` | The database port will be read from this `key` in the specified Secret, when `db.secretName` is set. |
| config.db.name | string | `"reportsdb"` | Database name |
| config.db.dbNameSecretKeyName | string | `"dbname"` | The database name will be read from this `key` in the specified Secret, when `db.secretName` is set. |
| config.db.user | string | `"postgres"` | Database user |
| config.db.userSecretKeyName | string | `"username"` | The database username will be read from this `key` in the specified Secret, when `db.secretName` is set. |
| config.db.password | string | `"reports"` | Database password |
| config.db.passwordSecretKeyName | string | `"password"` | The database password will be read from this `key` in the specified Secret, when `db.secretName` is set. |
| config.db.sslmode | string | `"disable"` | Database SSL |
| config.db.sslrootcert | string | `""` | Database SSL root cert |
| config.db.sslkey | string | `""` | Database SSL key |
| config.db.sslcert | string | `""` | Database SSL cert |
| config.db.sslrds | object | `{"mountPath":"/etc/ssl/rds","secretName":""}` | Volume configuration for an RDS (or other managed Postgres) CA bundle. When `secretName` is set, the chart mounts the named Secret at `mountPath` inside the reports-server pod. Pair with `sslrootcert` pointing at a file under that mountPath to enable TLS verification. |
| config.db.connectionPool | object | `{"connMaxIdleTimeSeconds":120,"connMaxLifetimeSeconds":300,"maxIdleConns":5,"maxOpenConns":25}` | Database connection pool configuration (per reports-server pod). These control how many concurrent PostgreSQL connections each pod opens. Defaults match the storage layer's built-in defaults. |
| config.db.connectionPool.maxOpenConns | int | `25` | Maximum number of open connections per pod (sql.DB.SetMaxOpenConns) |
| config.db.connectionPool.maxIdleConns | int | `5` | Maximum number of idle connections per pod (sql.DB.SetMaxIdleConns) |
| config.db.connectionPool.connMaxLifetimeSeconds | int | `300` | Maximum lifetime of a connection in seconds (0 = use storage default of 300s / 5m) |
| config.db.connectionPool.connMaxIdleTimeSeconds | int | `120` | Maximum idle time of a connection in seconds (0 = use storage default of 120s / 2m) |
| apiServicesManagement.enabled | bool | `true` | Manage APIService objects for the reports-server. APIServices are anchored to the chart's ClusterRole via OwnerReferences and garbage-collected on uninstall. |
| apiServicesManagement.installApiServices | object | `{"enabled":true,"installEphemeralReportsService":true,"installOpenreportsService":true}` | Install api services in manifest |
| apiServicesManagement.installApiServices.enabled | bool | `true` | Store reports in reports-server |
| apiServicesManagement.installApiServices.installEphemeralReportsService | bool | `true` | Store ephemeral reports in reports-server |
| apiServicesManagement.installApiServices.installOpenreportsService | bool | `true` | Store open reports in reports-server |
| apiServicesManagement.image.registry | string | `"ghcr.io"` | Image registry |
| apiServicesManagement.image.repository | string | `"nirmata/kubectl"` | Image repository |
| apiServicesManagement.image.tag | string | `"1.35-alpine3.23-dev"` | Image tag Defaults to `latest` if omitted |
| apiServicesManagement.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy Defaults to image.pullPolicy if omitted |
| apiServicesManagement.imagePullSecrets | list | `[]` | Image pull secrets |
| apiServicesManagement.podSecurityContext | object | `{}` | Security context for the pod |
| apiServicesManagement.nodeSelector | object | `{}` | Node labels for pod assignment |
| apiServicesManagement.tolerations | list | `[]` | List of node taints to tolerate |
| apiServicesManagement.podAntiAffinity | object | `{}` | Pod anti affinity constraints. |
| apiServicesManagement.podAffinity | object | `{}` | Pod affinity constraints. |
| apiServicesManagement.podLabels | object | `{}` | Pod labels. |
| apiServicesManagement.podAnnotations | object | `{}` | Pod annotations. |
| apiServicesManagement.nodeAffinity | object | `{}` | Node affinity constraints. |
| apiServicesManagement.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":65534,"runAsNonRoot":true,"runAsUser":65534,"seccompProfile":{"type":"RuntimeDefault"}}` | Security context for the hook containers |
| extraObjects | list | `[]` |  |
| openreports.enabled | bool | `false` | Deploy openreports-api CRDs |

## Source Code

* <https://github.com/nirmata/reports-server>

## Requirements

Kubernetes: `>=1.16.0-0`

| Repository | Name | Version |
|------------|------|---------|
| oci://ghcr.io/openreports/charts | openreports | 0.2.1 |
| oci://registry-1.docker.io/bitnamicharts | postgresql | 13.4.1 |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Nirmata | <support@nirmata.com> | <https://nirmata.com/> |

## License

This software is proprietary to Nirmata Inc. and are made available under the terms of the [Nirmata Enterprise Software License Agreement](https://nirmata.com/eula/). By downloading, installing, or using this software, you acknowledge that you have read and understood, and agree to be bound by, all terms and conditions of that Agreement. If you do not agree, do not download, install, or use this software.

Unauthorized use, reproduction, modification, or distribution of this software, in whole or in part, is strictly prohibited and may result in civil and criminal penalties.

© 2026 Nirmata Inc. All rights reserved.

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
