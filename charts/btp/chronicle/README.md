# Chronicle

| field | description | default |
|-|-|-|
| `imagePullSecrets.enabled`| if true use the list of named imagePullSecrets | false |
| `imagePullSecrets.value`| a list if named secret references of the form `- name: secretName`| [] |
| `image.repository` | the repository of the image | blockchaintp/chronicle |
| `image.tag`| the tag of the image to use | latest |
| `image.pullPolicy` | the image pull policy to use | IfNotPresent |
| `logLevel` | log level for chronicle | info |
| `webUi` | If true serve the graphql playground interface | false |
| `replicas` | number of Chronicle replicas to run | 1 |
| `affinity`| custom affinity rules for the chronicle pod | {} |
| `extraVolumes` | a list of additional volumes to add to chronicle | [] |
| `extraVolumeMounts` | a list of additional volume mounts to add to chronicle | [] |
| `port` | the port on which the chronicle service listens | 9982 |
| `serviceAccount.create` | true to create a service account | false |
| `serviceAccount.name` | name of the service account | nil (defaults to based on release name) |
| `ingress.apiVersion` | if necessary the apiVersion of the ingress may be overridden | "" |
| `ingress.enabled` | true to enable the ingress to the main service rest-api | false |
| `ingress.certManager` | true to enable the acme certmanager for this ingress | false |
| `ingress.hostname` | primary hostname for the ingress | false |
| `ingress.path` | path for the ingress's primary hostname | / |
| `ingress.pathType` | pathType for the ingress's primary hostname | nil |
| `ingress.annotations` | annotations for the ingress | {} |
| `ingress.tls` | true to enable tls on the ingress with a secrete at hostname-tls | false |
| `ingress.extraHosts` | list of extra hosts to add to the ingress | [] |
| `ingress.extraPaths` | list of extra paths to add to the primary host of the ingress | [] |
| `ingress.extraTls` | list of extra tls entries | [] |
| `ingress.hosts`| list of ingress host and path declarations for the chronicle ingress| [] |
| `sawtooth` | sawtooth options may be configured | see [Sawtooth](../sawtooth/README.md) |
| `tp.args` | a string of arguments to pass to the tp container| nil |
| `tp.image.pullPolicy` | the image pull policy | IfNotPresent |
| `tp.image.repository` | the image repository | blockchaintp/chronicle-tp |
| `tp.image.tag` | the image tag | BTP2.1.0 |
| `tp.extraVolumes` | extra volumes declarations for the chronicle-tp deployment | list | nil
| `tp.extraVolumeMounts` | extra volume mounts for chronicle-tp deployment | list | nil
| `tp.resources` | resources | map | nil |
| `tp.maxUnavailable` | maximum unavailable nodes during a rolling upgrade |
| `tp.minReadySeconds` | minimum time before node becomes available |
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
| `postgres.existingPasswordSecret` | name of the key in a secret containing the postgres password | string | nil |
| `postgres.tls` | postgres TLS configuration | string | nil |
| `postgres.persistence` | postgres persistence settings | map | N/A |
| `postgres.persistence.enabled` | if true allocate a PVC for the postgres instance | boolean | false |
| `postgres.persistence.annotations` | any custom annotations to the postgres PVC's | map | {} |
| `postgres.persistence.accessModes` | postgres PVC access modes | list | [ "ReadWriteOnce" ] |
| `postgres.persistence.storageClass` | postgres PVC storageClass | string | nil |
| `postgres.persistence.size` | postgres PVC volume size | string | "40Gi" |
| `postgres.resources` | resources | map | nil |
| `resources` | resources | map | nil |
