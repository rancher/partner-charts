# Sextant

This chart is the base chart to install BTP Sextant. By default it
installs the development version of Sextant. It's intended use is as
a dependency of other charts which install particular editions of the
software.

## Configuration

| field | description | type | default |
|-|-|-|-|
| `imagePullSecrets.enabled` | true if imagePullSecrets are required | boolean | false |
| `imagePullSecrets.value` | a list of named secret references of the form   ```- name: secretName```| list | [] |
| `imagePullSecrets.createSecret.enabled` | true to create a image pull secret | boolean | false |
| `imagePullSecrets.createSecret.registryUrl` | the registry url | string | nil |
| `imagePullSecrets.createSecret.registryUser` | the username for the registry | string | nil |
| `imagePullSecrets.createSecret.registryPassword` | the password for the registry | string | nil |
| `replicaCount` | number of Sextant replicas to run | int | 1 |
| `logging` | default logging level | string | "1" |
| `ui.env` | environment variables to set in the UI container | map | nil |
| `ui.image` | UI image settings | map | N/A |
| `ui.image.repository` | UI image repository | string | "dev.catenasys.com:8083/blockchaintp/sextant" |
| `ui.image.tag` | UI image tag | string | "latest" |
| `ui.image.pullPolicy` | UI image pull policy | string | "IfNotPresent" |
| `ui.resources` | UI resources | map | nil |
| `api.env` | API environment settings | map | N/A |
| `api.image` | API image settings | map | N/A |
| `api.image.repository` | API image repository | string | "dev.catenasys.com:8083/blockchaintp/sextant-api" |
| `api.image.tag` | API image tag | string | "latest" |
| `api.image.pullPolicy` | API image pull policy | string | "IfNotPresent" |
| `api.resources` | UI resources | map | nil |
| `noxy.env` | Noxy environment variables | map | N/A |
| `noxy.image` | noxy image settings | map | N/A |
| `noxy.image.repository` | NOXY image repository | string | "dev.catenasys.com:8083/blockchaintp/noxy" |
| `noxy.image.tag` | noxy image tag | string | "latest" |
| `noxy.image.pullPolicy` | API image pull policy | string | "IfNotPresent" |
| `noxy.resources` | UI resources | map | nil |
| `serviceAccount.create` | if true create the service account | boolean | true |
| `serviceAccount.name` | name of the service account for sextant | string | nil |
| `postgres.enabled` | if true create an internal postgres instance | boolean | true |
| `postgres.env` | postgres environment variables | map | N/A |
| `postgres.image.repository` | postgres image repository | string | "postgres" |
| `postgres.image.tag` | postgres image tag | string | "11" |
| `postgres.user` | user for the postgres database | string | "postgres" |
| `postgres.host` | host for the postgres database | string | "localhost" |
| `postgres.database` | database for the postgres database | string | "postgres" |
| `postgres.port` | port for the postgres database | int | 5432 |
| `postgres.password` | password for the postgres database | string | "postgres" |
| `postgres.existingPasswordSecret` | name of a secret containing the postgres password | string | nil |
| `postgres.existingPasswordSecret` | name of the key in a secret containing the postgres password | string | password |
| `postgres.tls` | postgres TLS configuration | string | nil |
| `postgres.persistence` | postgres persistence settings | map | N/A |
| `postgres.persistence.enabled` | if true allocate a PVC for the postgres instance | boolean | false |
| `postgres.persistence.annotations` | any custom annotations to the postgres PVC's | map | {} |
| `postgres.persistence.accessModes` | postgres PVC access modes | list | [ "ReadWriteOnce" ] |
| `postgres.persistence.storageClass` | postgres PVC storageClass | string | nil |
| `postgres.persistence.size` | postgres PVC volume size | string | "40Gi" |
| `postgres.resources` | UI resources | map | nil |
| `service.type` | Sextant service type | string | ClusterIP |
| `service.port` | Sextant service port | int | 8000 |
| `ingress.apiVersion` | if necessary the apiVersion of the ingress may be overridden | "" |
| `ingress.enabled` | true to enable the ingress to the main service rest-api | false |
| `ingress.certManager` | true to enable the acme certmanager for this ingress | false |
| `ingress.hostname` | primary hostname for the ingress | false |
| `ingress.path` | path for the ingress's primary hostname | / |
| `ingress.pathType` | pathType for the ingress's primary hostname | nil |
| `ingress.annotations` | annotations for the ingress | {} |
| `ingress.tls` | true to enable tls on the ingress with a secrete at hostname-tls | false(truthy) |
| `ingress.extraHosts` | list of extra hosts to add to the ingress | [] |
| `ingress.extraPaths` | list of extra paths to add to the primary host of the ingress | [] |
| `ingress.extraTls` | list of extra tls entries | [] |
| `ingress.hosts` | a list of host and path lists to publish in the ingress (deprecated)| map | {} |
| `extraVolumes` | a list of additional volumes to add to all StatefulSets, Deployments, and DaemonSets | `[]` |
| `extraVolumeMounts` | a list of additional volume mounts to add to all StatefulSet, Deployment, and DaemonSet containers | `[]` |
