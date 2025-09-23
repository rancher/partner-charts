# reports-server

![Version: 0.2.3](https://img.shields.io/badge/Version-0.2.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.2.2](https://img.shields.io/badge/AppVersion-v0.2.2-informational?style=flat-square)

TODO

## Installing the Chart

Add `reports-server` Helm repository:

```shell
helm repo add reports-server https://kyverno.github.io/reports-server/
```

Install `reports-server` Helm chart:

```shell
helm install reports-server --namespace reports-server --create-namespace reports-server/reports-server
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| fipsEnabled | bool | `false` |  |
| nameOverride | string | `""` | Name override |
| fullnameOverride | string | `""` | Full name override |
| replicaCount | int | `1` | Number of pod replicas |
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
| metrics.enabled | bool | `true` | Enable prometheus metrics |
| metrics.serviceMonitor.enabled | bool | `false` | Enable service monitor for scraping prometheus metrics |
| metrics.serviceMonitor.additionalLabels | object | `{}` | Service monitor additional labels |
| metrics.serviceMonitor.interval | string | `""` | Service monitor scrape interval |
| metrics.serviceMonitor.metricRelabelings | list | `[]` | Service monitor metric relabelings |
| metrics.serviceMonitor.relabelings | list | `[]` | Service monitor relabelings |
| metrics.serviceMonitor.scrapeTimeout | string | `""` | Service monitor scrape timeout |
| resources.limits | object | `{"memory":"128Mi"}` | Container resource limits |
| resources.requests | object | `{"cpu":"100m","memory":"64Mi"}` | Container resource requests |
| autoscaling.enabled | bool | `false` | Enable autoscaling |
| autoscaling.minReplicas | int | `1` | Min number of replicas |
| autoscaling.maxReplicas | int | `100` | Max number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilisation |
| autoscaling.targetMemoryUtilizationPercentage | string | `nil` | Target Memory utilisation |
| pdb | object | `{"enabled":true,"maxUnavailable":"50%","minAvailable":null}` | Using a PDB is highly recommended for highly available deployments. Defaults to enabled. The default configuration doesn't prevent disruption when using a single replica |
| pdb.enabled | bool | `true` | Enable PodDisruptionBudget |
| pdb.minAvailable | string | `nil` | minAvailable pods for PDB, cannot be used together with maxUnavailable |
| pdb.maxUnavailable | string | `"50%"` | maxUnavailable pods for PDB, will take precedence over minAvailable if both are defined |
| nodeSelector | object | `{}` | Node selector |
| tolerations | list | `[]` | Tolerations |
| affinity | object | `{}` | Affinity |
| service.type | string | `"ClusterIP"` | Service type |
| service.port | int | `443` | Service port |
| config.etcd.image.registry | string | `"ghcr.io"` | Image registry |
| config.etcd.image.repository | string | `"nirmata/etcd"` | Image repository |
| config.etcd.image.tag | string | `"v3.5.18-cve-free"` | Image tag |
| config.etcd.imagePullSecrets | list | `[]` | Image pull secrets |
| config.etcd.enabled | bool | `true` |  |
| config.etcd.endpoints | string | `nil` |  |
| config.etcd.insecure | bool | `true` |  |
| config.etcd.storage | string | `"2Gi"` |  |
| config.etcd.quotaBackendBytes | int | `1932735283` |  |
| config.etcd.autoCompaction.enabled | bool | `true` | Enable auto-compaction for etcd |
| config.etcd.autoCompaction.mode | string | `"periodic"` | Auto-compaction mode (periodic or revision) |
| config.etcd.autoCompaction.retention | string | `"30m"` | Auto-compaction retention (e.g., 30m for 30 minutes, 1h for 1 hour) |
| config.etcd.nodeSelector | object | `{}` |  |
| config.etcd.tolerations | list | `[]` |  |
| config.db.secretCreation | bool | `false` | If set, a secret will be created with the database connection information. If this is set to true, secretName must be set. |
| config.db.secretName | string | `""` | If set, database connection information will be read from the Secret with this name. Overrides `db.host`, `db.name`, `db.user`, `db.password` and `db.readReplicaHosts`. |
| config.db.host | string | `"reports-server-cluster-rw.reports-server"` | Database host |
| config.db.hostSecretKeyName | string | `"host"` | The database host will be read from this `key` in the specified Secret, when `db.secretName` is set. |
| config.db.readReplicaHosts | string | `""` | Database read replica hosts |
| config.db.readReplicaHostsSecretKeyName | string | `"readReplicaHosts"` | The database read replica hosts will be read from this `key` in the specified Secret, when `db.secretName` is set. |
| config.db.port | string | `nil` | Database port |
| config.db.portSecretKeyName | string | `"port"` | The database port will be read from this `key` in the specified Secret, when `db.secretName` is set. |
| config.db.name | string | `"reportsdb"` | Database name |
| config.db.dbNameSecretKeyName | string | `"dbname"` | The database name will be read from this `key` in the specified Secret, when `db.secretName` is set. |
| config.db.user | string | `"app"` | Database user |
| config.db.userSecretKeyName | string | `"username"` | The database username will be read from this `key` in the specified Secret, when `db.secretName` is set. |
| config.db.password | string | `"password"` | Database password |
| config.db.passwordSecretKeyName | string | `"password"` | The database password will be read from this `key` in the specified Secret, when `db.secretName` is set. |
| config.db.sslmode | string | `"disable"` | Database SSL |
| config.db.sslrootcert | string | `""` | Database SSL root cert |
| config.db.sslkey | string | `""` | Database SSL key |
| config.db.sslcert | string | `""` | Database SSL cert |
| config.db.sslrds | object | `{"mountPath":"/etc/ssl/rds","secretName":""}` | Volume configuration for RDS certificate |
| apiServicesManagement.installApiServices | object | `{"enabled":true,"installEphemeralReportsService":true}` | Install api services in manifest |
| apiServicesManagement.installApiServices.enabled | bool | `true` | Store reports in reports-server |
| apiServicesManagement.installApiServices.installEphemeralReportsService | bool | `true` | Store ephemeral reports in reports-server |
| apiServicesManagement.migrateReportsServer.enabled | bool | `false` | Create api services only when reports-server is ready and migration is guaranteed |
| jobConfigurations.image.registry | string | `"ghcr.io"` | Image registry |
| jobConfigurations.image.repository | string | `"nirmata/kubectl"` | Image repository |
| jobConfigurations.image.tag | string | `"1.30.2"` | Image tag Defaults to `latest` if omitted |
| jobConfigurations.image.pullPolicy | string | `nil` | Image pull policy Defaults to image.pullPolicy if omitted |
| jobConfigurations.imagePullSecrets | list | `[]` | Image pull secrets |
| jobConfigurations.podSecurityContext | object | `{}` | Security context for the pod |
| jobConfigurations.nodeSelector | object | `{}` | Node labels for pod assignment |
| jobConfigurations.tolerations | list | `[]` | List of node taints to tolerate |
| jobConfigurations.podAntiAffinity | object | `{}` | Pod anti affinity constraints. |
| jobConfigurations.podAffinity | object | `{}` | Pod affinity constraints. |
| jobConfigurations.podLabels | object | `{}` | Pod labels. |
| jobConfigurations.podAnnotations | object | `{}` | Pod annotations. |
| jobConfigurations.nodeAffinity | object | `{}` | Node affinity constraints. |
| jobConfigurations.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"privileged":false,"readOnlyRootFilesystem":true,"runAsGroup":65534,"runAsNonRoot":true,"runAsUser":65534,"seccompProfile":{"type":"RuntimeDefault"}}` | Security context for the hook containers |

## Source Code

* <https://github.com/nirmata/reports-server>

## Requirements

Kubernetes: `>=1.16.0-0`

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Nirmata | <cncf-kyverno-maintainers@lists.cncf.io> | <https://kyverno.io/> |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
