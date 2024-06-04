# Chronicle on Hyperledger Sawtooth

| field | description | default |
|-|-|-|
| `affinity`| custom affinity rules for the chronicle pod | {} |
| `auth.required` | if true require authentication, rejecting 'anonymous' requests | false |
| `auth.id.claims` | Chronicle provides default values ["iss", "sub"] | nil |
| `backtraceLevel` | backtrace level for Chronicle  | nil |
| `devIdProvider.image` | the image to use for the id-provider container | blockchaintp/id-provider |
| `devIdProvider.image.pullPolicy` | the image pull policy | IfNotPresent |
| `devIdProvider.image.repository` | the image repository | blockchaintp/id-provider |
| `devIdProvider.image.tag` | the image tag | latest |
| `extraVolumes` | a list of additional volumes to add to chronicle | [] |
| `extraVolumeMounts` | a list of additional volume mounts to add to chronicle | [] |
| `image.repository` | the repository of the image | blockchaintp/chronicle |
| `image.tag`| the tag of the image to use | latest |
| `image.pullPolicy` | the image pull policy to use | IfNotPresent |
| `imagePullSecrets.enabled`| if true use the list of named imagePullSecrets | false |
| `imagePullSecrets.value`| a list if named secret references of the form `- name: secretName`| [] |
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
| `logLevel` | log level for Chronicle | info |
| `opa.enabled` | if true set up a full OPA enabled setup | true |
| `opa.init.image` | the image to use for the chronicle-init container | blockchaintp/chronicle-opa-init |
| `image.pullPolicy` | the image pull policy to use | IfNotPresent |
| `image.repository` | the repository of the image | blockchaintp/chronicle |
| `image.tag`| the tag of the image to use | latest |
| `image.repository` | the repository of the image | blockchaintp/chronicle |
| `image.tag`| the tag of the image to use | latest |
| `image.pullPolicy` | the image pull policy to use | IfNotPresent |
| `opa.tp.resources` | resources | map | nil |
| `opa.tp.extraVolumes` | extra volumes declarations for the opa-tp deployment | list | nil
| `opa.tp.extraVolumeMounts` | extra volume mounts for opa-tp deployment | list | nil
| `port` | the port on which the chronicle service listens | 9982 |
| `replicas` | number of Chronicle replicas to run | 1 |
| `serviceAccount.create` | true to create a service account | false |
| `serviceAccount.name` | name of the service account | nil (defaults to based on release name) |
| `test.api` | test the chronicle GraphQL server API |
| `test.api.enabled` | true to enable api-test Jobs and Services | true |
| `test.api.image` | the image to use for the api-test container | blockchaintp/chronicle-helm-api-test |
| `test.api.image.pullPolicy` | the image pull policy | IfNotPresent |
| `test.api.image.repository` | the image repository | blockchaintp/chronicle-helm-api-test |
| `test.api.image.tag` | the image tag | latest |
| `test.auth` | test the chronicle auth server API |
| `test.auth.enabled` | true to enable auth-related testing | true |
| `test.auth.token` | provide a token for auth-related testing | nil |
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
| `sawset.image.pullPolicy` | the image pull policy | IfNotPresent |
| `sawset.image.repository` | the image repository | blockchaintp/sawtooth-validator |
| `sawset.image.tag` | the image tag | latest |
| `tp.args` | a string of arguments to pass to the tp container| nil |
| `tp.image.pullPolicy` | the image pull policy | IfNotPresent |
| `tp.image.repository` | the image repository | blockchaintp/chronicle-tp |
| `tp.image.tag` | the image tag | latest |
| `tp.extraVolumes` | extra volumes declarations for the chronicle-tp deployment | list | nil
| `tp.extraVolumeMounts` | extra volume mounts for chronicle-tp deployment | list | nil
| `tp.resources` | resources | map | nil |
| `tp.maxUnavailable` | maximum unavailable nodes during a rolling upgrade |
| `tp.minReadySeconds` | minimum time before node becomes available |
| `sawtooth` | sawtooth options may be configured | see [Sawtooth](../sawtooth/README.md) |
| `livenessProbe.enabled` | if true, enables the liveness probe | false |
| `livenessProbe.initialDelaySeconds` | delay before liveness probe is initiated | 30 |
| `livenessProbe.periodSeconds` | how often to perform the probe | 10 |
| `livenessProbe.timeoutSeconds` | when the probe times out | 1 |
| `livenessProbe.failureThreshold` | how many times to retry the probe before giving up | 3 |
| `livenessProbe.successThreshold` | how many times the probe must report success to be considered successful after having failed | 1 |
| `livenessProbe.namespaceName` | the namespace name for the liveness probe | "default" |
| `livenessProbe.namespaceUuid` | the namespace UUID for the liveness probe | "fd717fd6-70f1-44c1-81de-287d5e101089" |
| `startupProbe.enabled` | if true, enables the startup probe | false |
| `startupProbe.initialDelaySeconds` | delay before startup probe is initiated | 10 |
| `startupProbe.periodSeconds` | how often to perform the probe | 10 |
| `startupProbe.timeoutSeconds` | when the probe times out | 1 |
| `startupProbe.failureThreshold` | how many times to retry the probe before giving up | 3 |
| `startupProbe.successThreshold` | how many times the probe must report success to be considered successful after having failed | 1 |
| `startupProbe.namespaceName` | the namespace name for the startup probe | "default" |
| `startupProbe.namespaceUuid` | the namespace UUID for the startup probe | "fd717fd6-70f1-44c1-81de-287d5e101089" |
