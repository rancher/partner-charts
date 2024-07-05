# Shipa Helm Chart Parameters

## Parameters

### Common parameters

| Name                            | Description                                                                                                                                                                                                                                                                                                                                                               | Value                     |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| `nameOverride`                  | If provided, overrides the release name, for example, in the app.kubernetes.io/name label                                                                                                                                                                                                                                                                                 | `""`                      |
| `fullnameOverride`              | If provided, overrides the release name, for example, in the naming of resources (pods, deployments, etc.)                                                                                                                                                                                                                                                                | `""`                      |
| `imagePullSecrets`              | If provided, these will be configured as imagePullSecrets for pulling images directly included in this chart (the MongoDB(&reg;) sub-chart has its own imagePullSecrets configuration). The array is a list of Kubernetes secrets, likely of type `kubernetes.io/dockerconfigjson`. Example:<br/><code>imagePullSecrets:<br/>&nbsp;&nbsp;- name: image-pull-secret</code> | `[]`                      |
| `images.shipaRepositoryDirname` | The base directory for Shipa Corp images. For Shipa Corp images this value has repositoryBasename and tag appended to it to determine the location to pull images from. This does not affect non-Shipa Corp images, such as k8s.gcr.io/ingress-nginx/controller, docker.io/postgres, k8s.gcr.io/mongodb-install, docker.io/mongo, and docker.io/busybox                   | `docker.io/shipasoftware` |
| `rbac.enabled`                  | If enabled, a Shipa specific ServiceAccount will be used by resources, otherwise `"default"` is used                                                                                                                                                                                                                                                                      | `true`                    |


### Initial Admin account credentials

| Name                 | Description                             | Value |
| -------------------- | --------------------------------------- | ----- |
| `auth.adminUser`     | is the login name for the initial admin | `""`  |
| `auth.adminPassword` | is the password for the initial admin   | `""`  |


### Shipa API configuration

| Name                                      | Description                                                                                                                                                                                                                                                                                                                                                                                                    | Value                                      |
| ----------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| `shipaApi.port`                           | Port to expose for HTTP traffic to the Shipa API pod                                                                                                                                                                                                                                                                                                                                                           | `8080`                                     |
| `shipaApi.securePort`                     | Port to expose for HTTPS traffic to the Shipa API pod                                                                                                                                                                                                                                                                                                                                                          | `8081`                                     |
| `shipaApi.servicePorts`                   | Ports to expose for HTTP traffic to the Shipa API Service                                                                                                                                                                                                                                                                                                                                                      | `["80"]`                                   |
| `shipaApi.serviceSecurePorts`             | Ports to expose for HTTPS traffic to the Shipa API Service                                                                                                                                                                                                                                                                                                                                                     | `["443"]`                                  |
| `shipaApi.repositoryBasename`             | The repository name to use for pulling the Shipa API image                                                                                                                                                                                                                                                                                                                                                     | `api`                                      |
| `shipaApi.tag`                            | The tag to use for pulling the Shipa API image                                                                                                                                                                                                                                                                                                                                                                 | `6e4a1bc373b4afffa1e5851813271cf61be6dd9a` |
| `shipaApi.pullPolicy`                     | Image pull policy to use for pulling the Shipa API image                                                                                                                                                                                                                                                                                                                                                       | `Always`                                   |
| `shipaApi.debug`                          | Enables debug log level for the Shipa API                                                                                                                                                                                                                                                                                                                                                                      | `false`                                    |
| `shipaApi.resources`                      | Can be used to put resource limits on the Shipa API pod. Example:<br/><code>shipaApi:<br/>&nbsp;&nbsp;resources:<br/>&nbsp;&nbsp;&nbsp;&nbsp;requests:<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;memory: 16Mi<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cpu: 50m<br/>&nbsp;&nbsp;&nbsp;&nbsp;limits:<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;memory: 64Mi<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;cpu: 250m</code> | `{}`                                       |
| `shipaApi.cnames`                         | If there are any DNS names that will be used they need to be specified here for appropriate ingress and cert provisioning. Example:<br/><code>shipaApi:<br/>&nbsp;&nbsp;cnames:<br/>&nbsp;&nbsp;&nbsp;&nbsp;- target.myshipa.lan<br/>&nbsp;&nbsp;&nbsp;&nbsp;- other-target.myshipa.lan</code>                                                                                                                 | `[]`                                       |
| `shipaApi.allowRestartIngressControllers` | If set to false, disables the ability for a cluster update to restart the ingress controllers                                                                                                                                                                                                                                                                                                                  | `true`                                     |
| `shipaApi.isCAEndpointDisabled`           | If set to true, the ca/certificates endpoint of the Shipa API will be disabled, which disallows the Shipa CLI from trusting invalid TLS certificates when connecting to this Shipa API                                                                                                                                                                                                                         | `false`                                    |
| `shipaApi.secureIngressOnly`              | If set to true, all HTTP traffic to the Shipa API ingress will be redirected to HTTPS                                                                                                                                                                                                                                                                                                                          | `false`                                    |
| `shipaApi.useInternalHost`                | If true (recommended), the main shipa cluster will communicate with the Shipa API using the internal Kubernetes host name, rather than an external CNAME                                                                                                                                                                                                                                                       | `true`                                     |
| `shipaApi.customSecretName`               | If provided, this secret will be used as the TLS secret for the API ingress controller. Use this if you have a trusted certificate that you wish to use instead of the default, self-signed certificate                                                                                                                                                                                                        | `""`                                       |
| `shipaApi.customIngressAnnotations`       | If provided, these annotations will be added to the Shipa API Ingress resources. Example:<br/><code>shipaApi<br/>&nbsp;&nbsp;customIngressAnnotations:<br/>&nbsp;&nbsp;&nbsp;&nbsp;custom-keys/first-key: "bbb"<br/>&nbsp;&nbsp;&nbsp;&nbsp;custom-keys/second-key: "ddd"</code>                                                                                                                               | `{}`                                       |


### Shipa cluster access configuration

| Name                                        | Description                                                                                                                                                                                                                                                                                                                                                                        | Value                                        |
| ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| `shipaCluster.clusterDomain`                | The domain that your cluster uses internally, through coredns, kube-dns, etc.                                                                                                                                                                                                                                                                                                      | `cluster.local`                              |
| `shipaCluster.ingress.type`                 | ingress controller type. Supported values: (nginx, istio, traefik)                                                                                                                                                                                                                                                                                                                 | `nginx`                                      |
| `shipaCluster.ingress.image`                | NGINX ingress controller image. If the ingress controller type is nginx and no ingress controller ip address is provided, an ingress controller will be deployed using this image                                                                                                                                                                                                  | `k8s.gcr.io/ingress-nginx/controller:v1.1.0` |
| `shipaCluster.ingress.serviceType`          | ingress controller serviceType. When using shipa managed nginx, we reconcile looking for the right Host of LoadBalancer or ClusterIP based on what is provided here. When using non user managed ingress controller we use this just to store it in DB                                                                                                                             | `LoadBalancer`                               |
| `shipaCluster.ingress.ip`                   | Ingress controller ip address. If provided, we assume user provided ingress controller should be used and create api resources for it                                                                                                                                                                                                                                              | `""`                                         |
| `shipaCluster.ingress.className`            | Ingress controller class name. If undefined, in most places we set default: nginx, traefik, istio. If we detect that it's shipa managed nginx, we default to shipa-nginx-ingress                                                                                                                                                                                                   | `""`                                         |
| `shipaCluster.ingress.apiAccessOnIngressIp` | If enabled, we will create ingress controller resources to allow api to be accessible on root ip of ingress controller.<br/>NOTE: all ingresses require Host targeting instead of Path targeting for TLS. Also if you use nginxinc/kubernetes-ingress, using Ingress without host is not allowed until this is resolved: https://github.com/nginxinc/kubernetes-ingress/issues/209 | `true`                                       |


### Shipa managed Nginx configs

| Name                                                 | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | Value |
| ---------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| `shipaCluster.ingress.clusterIp`                     | Ingress controller ClusterIp address. If provided, it will be used for shipa managed nginx ingress controller                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | `""`  |
| `shipaCluster.ingress.loadBalancerIp`                | Ingress controller LoadBalancerIp address. If provided, it will be used for shipa managed nginx ingress controller                                                                                                                                                                                                                                                                                                                                                                                                                                                               | `""`  |
| `shipaCluster.ingress.nodePort`                      | If provided, it will be used as node port for shipa managed nginx ingress controller                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | `""`  |
| `shipaCluster.ingress.customNginxServiceAnnotations` | If provided, these annotations will be appended to the Shipa managed Nginx ingress controller Service resource. Example for configuring internet facing NLB in AWS:<br/>                                                                                                                                                                                                                                                                                                                                                                                                         | `{}`  |
| `shipaCluster.ingress.config`                        | Configuration overrides for the Shipa managed Nginx ingress controller. Example (these are the defaults if you leave this empty):<br/><code>shipaCluster:<br/>&nbsp;&nbsp;ingress:<br/>&nbsp;&nbsp;&nbsp;&nbsp;config:<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;proxy-body-size: "512M"<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;proxy-read-timeout: "300"<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;proxy-connect-timeout: "300"<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;proxy-send-timeout: "300"<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;upstream-keepalive-timeout: "300"</code> | `{}`  |


### PostgreSQL configuration for use by Clair

| Name                                | Description                                                                                                                                                | Value                   |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| `postgres.source.host`              | Host to connect to for Clair database. Leave blank to default to {{ template "shipa.fullname" . }}-postgres.{{ .Release.Namespace }}                       | `""`                    |
| `postgres.source.port`              | Port to connect to for Clair database                                                                                                                      | `5432`                  |
| `postgres.source.user`              | User to connect to for Clair database                                                                                                                      | `postgres`              |
| `postgres.source.password`          | Password to connect to for Clair database. Leave blank to generate a random value                                                                          | `""`                    |
| `postgres.source.sslmode`           | The SSL mode to run PostgreSQL in. Options: "require", "verify-full", "verify-ca", or "disable                                                             | `disable`               |
| `postgres.create`                   | Set to false to avoid creating a PostgreSQL instance, for example, if you are using an external PostgreSQL instance                                        | `true`                  |
| `postgres.image`                    | If postgres.create is set to true, this is the image that will be used                                                                                     | `docker.io/postgres:13` |
| `postgres.persistence.storageClass` | The storageClassName to use. Undefined or null will use the default provisioner, or "-" will to set storageClassName to "", disabling dynamic provisioning | `""`                    |
| `postgres.persistence.accessMode`   | The PVC access mode to use. Options: ReadWriteOnce, ReadOnlyMany or ReadWriteMany                                                                          | `ReadWriteOnce`         |
| `postgres.persistence.size`         | The amount of storage to provision for the Clair database                                                                                                  | `10Gi`                  |


### cert-manager configuration

| Name                     | Description                                                                                                                                                            | Value                                                                                 |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `certManager.installUrl` | When Shipa is installed, if cert-manager is not yet installed (existence of cert-manager ClusterIssuer CRD) it will be installed via the resources at the provided URL | `https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.yaml` |


### Shipa Dashboard configuration

| Name                           | Description                                                | Value                                      |
| ------------------------------ | ---------------------------------------------------------- | ------------------------------------------ |
| `dashboard.enabled`            | If set to false, the Shipa Dashboard will not be deployed  | `true`                                     |
| `dashboard.repositoryBasename` | The repository name to use for pulling the dashboard image | `dashboard`                                |
| `dashboard.tag`                | The tag to use for pulling the dashboard image             | `c18b7d0031047c48d8c3b4666d489a498ca58653` |


### Shipa CLI configuration

| Name                     | Description                                                | Value                                      |
| ------------------------ | ---------------------------------------------------------- | ------------------------------------------ |
| `cli.repositoryBasename` | The repository name to use for pulling the Shipa CLI image | `cli`                                      |
| `cli.tag`                | The tag to use for pulling the Shipa CLI image             | `eb516ebb0bb625748cd6baaa5312e8330469ae34` |
| `cli.pullPolicy`         | Image pull policy to use for pulling the Shipa CLI image   | `Always`                                   |


### Metrics configuration

| Name                                   | Description                                                                                                                                                                                                                                                                                                                                                                                                          | Value                              |
| -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| `metrics.repositoryBasename`           | The repository name to use for pulling the metrics image                                                                                                                                                                                                                                                                                                                                                             | `metrics`                          |
| `metrics.tag`                          | The tag to use for pulling the metrics image                                                                                                                                                                                                                                                                                                                                                                         | `v0.0.7`                           |
| `metrics.pullPolicy`                   | Image pull policy to use for pulling the metrics image                                                                                                                                                                                                                                                                                                                                                               | `Always`                           |
| `metrics.password`                     | Password to setup for connecting to the Shipa metrics. If left blank, a random value will be generated and used                                                                                                                                                                                                                                                                                                      | `""`                               |
| `metrics.prometheusArgs`               | Arguments to pass to Prometheus on starting the Shipa metrics                                                                                                                                                                                                                                                                                                                                                        | `--storage.tsdb.retention.time=1d` |
| `metrics.extraPrometheusConfiguration` | Extra configuration to add to `prometheus.yaml`. Example for configuring remote reads and writes:<br/><code>metrics:<br/>&nbsp;&nbsp;extraPrometheusConfiguration: \|<br/>&nbsp;&nbsp;&nbsp;&nbsp;remote_read:<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- url: http://localhost:9268/read<br/>&nbsp;&nbsp;&nbsp;&nbsp;remote_write:<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- url: http://localhost:9268/write</code> | `""`                               |


### busybody configuration

| Name                          | Description                                               | Value                                      |
| ----------------------------- | --------------------------------------------------------- | ------------------------------------------ |
| `busybody.repositoryBasename` | The repository name to use for pulling the busybody image | `bb`                                       |
| `busybody.tag`                | The tag to use for pulling the busybody image             | `ead64d61a7dab4dca50bd90e18b908e6f44bb9f9` |


### Shipa controller configuration

| Name                                           | Description                                                           | Value                                      |
| ---------------------------------------------- | --------------------------------------------------------------------- | ------------------------------------------ |
| `shipaController.repositoryBasename`           | The repository name to use for pulling the Shipa controller image     | `shipa-controller`                         |
| `shipaController.tag`                          | The tag to use for pulling the Shipa controller image                 | `5e7f221a1adce3bd40b5c352418d9da8de94ada2` |
| `shipaController.enableEventUpdater`           | Shipa creates and shows more shipa events for discovered applications | `true`                                     |
| `shipaController.enableNetworkPolicyViolation` | Enables network policy violations                                     | `true`                                     |


### prometheus-metrics-exporter configuration

| Name                                           | Description                                                          | Value                                      |
| ---------------------------------------------- | -------------------------------------------------------------------- | ------------------------------------------ |
| `prometheusMetricsExporter.repositoryBasename` | The repository name to use for pulling the Prometheus exporter image | `prometheus-metrics-exporter`              |
| `prometheusMetricsExporter.tag`                | The tag to use for pulling the Prometheus exporter image             | `b123eb79bdbe56f83812b5ad3cfb8bbb568b2e3d` |


### Clair configuration

| Name                       | Description                                            | Value    |
| -------------------------- | ------------------------------------------------------ | -------- |
| `clair.repositoryBasename` | The repository name to use for pulling the Clair image | `clair`  |
| `clair.tag`                | The tag to use for pulling the Clair image             | `v2.1.7` |


### Ketch controller configuration

| Name                       | Description                                                                     | Value                                      |
| -------------------------- | ------------------------------------------------------------------------------- | ------------------------------------------ |
| `ketch.repositoryBasename` | The repository name to use for pulling the Ketch controller image               | `ketch`                                    |
| `ketch.tag`                | The tag to use for pulling the Ketch controller image                           | `4105c20ee2ca27c2ce4811764901565aa5035393` |
| `ketch.metricsAddress`     | Address of where metrics will be sent. Leave empty to disable metrics for Ketch | `127.0.0.1:8080`                           |


### Shipa agent configuration

| Name                       | Description                                                  | Value                                      |
| -------------------------- | ------------------------------------------------------------ | ------------------------------------------ |
| `agent.repositoryBasename` | The repository name to use for pulling the Shipa agent image | `shipa-cluster-agent`                      |
| `agent.tag`                | The tag to use for pulling the Shipa agent image             | `d130d858d71522bbbffbfaaba6097dceaba4c0d8` |


### External MongoDB(&reg;) configuration

| Name                            | Description                                                          | Value  |
| ------------------------------- | -------------------------------------------------------------------- | ------ |
| `externalMongodb.url`           | Connection URL for external MongoDB instance.                        | `""`   |
| `externalMongodb.auth.username` | Username for authenticating to an external MongoDB instance          | `""`   |
| `externalMongodb.auth.password` | Password for authenticating to an external MongoDB instance          | `""`   |
| `externalMongodb.tls.enable`    | Set to false to disable TLS when connecting to external DB instance. | `true` |


### Dependent chart tags

| Name                         | Description                                                                                                                                                                                                  | Value   |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------- |
| `tags.defaultDB`             | Set defaultDB (and legacyMongoReplicaset) to `false` when using external DB to not install default DB. It will also prevent creating Persistent Volumes. This cannot be used with tags.legacyMongoReplicaset | `true`  |
| `tags.legacyMongoReplicaset` | (Deprecated) Set legacyMongoReplicaset to 'true' in order to use the deprecated https://charts.helm.sh/stable/mongodb-replicaset chart as an internal MongoDB. This cannot be used with tags.defaultDB       | `false` |


### MongoDB(&reg;) dependent chart parameters

| Name                                                     | Description                                                                                                                                             | Value                       |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `mongodb.global.imageRegistry`                           | Global Docker image registry for MongoDB(&reg;) dependent chart                                                                                         | `""`                        |
| `mongodb.global.imagePullSecrets`                        | Global Docker registry secret names as an array                                                                                                         | `[]`                        |
| `mongodb.image.registry`                                 | MongoDB(&reg;) image registry for MongoDB(&reg;) dependent chart                                                                                        | `docker.io`                 |
| `mongodb.image.repository`                               | MongoDB(&reg;) image registry for MongoDB(&reg;) dependent chart                                                                                        | `bitnami/mongodb`           |
| `mongodb.image.tag`                                      | MongoDB(&reg;) image tag (immutable tags are recommended) for MongoDB(&reg;) dependent chart                                                            | `5.0.6-debian-10-r29`       |
| `mongodb.image.pullPolicy`                               | MongoDB(&reg;) image pull policy for MongoDB(&reg;) dependent chart                                                                                     | `IfNotPresent`              |
| `mongodb.image.pullSecrets`                              | Specify docker-registry secret names as an array for MongoDB(&reg;) dependent chart                                                                     | `[]`                        |
| `mongodb.persistence.existingClaim`                      | Provide an existing `PersistentVolumeClaim` (only when `architecture=standalone`) for MongoDB(&reg;) dependent chart                                    | `""`                        |
| `mongodb.persistence.size`                               | PVC Storage Request for MongoDB(&reg;) data volume for MongoDB(&reg;) dependent chart                                                                   | `10Gi`                      |
| `mongodb.architecture`                                   | MongoDB(&reg;) architecture (`standalone` or `replicaset`) for MongoDB(&reg;) dependent chart                                                           | `standalone`                |
| `mongodb.useStatefulSet`                                 | Set to true to use a StatefulSet instead of a Deployment (only when `architecture=standalone`) for MongoDB(&reg;) dependent chart                       | `true`                      |
| `mongodb.replicaSetName`                                 | Name of the replica set (only when `architecture=replicaset`) for MongoDB(&reg;) dependent chart                                                        | `rs0`                       |
| `mongodb.service.port`                                   | MongoDB(&reg;) service port for MongoDB(&reg;) dependent chart                                                                                          | `27017`                     |
| `mongodb.nodeSelector`                                   | MongoDB(&reg;) Node labels for pod assignment for MongoDB(&reg;) dependent chart                                                                        | `{}`                        |
| `mongodb.arbiter.podSecurityContext.enabled`             | Enable Arbiter pod(s)' Security Context for MongoDB(&reg;) dependent chart                                                                              | `true`                      |
| `mongodb.arbiter.podSecurityContext.fsGroup`             | Group ID for the volumes of the Arbiter pod(s) for MongoDB(&reg;) dependent chart                                                                       | `999`                       |
| `mongodb.arbiter.containerSecurityContext.enabled`       | Enable Arbiter container(s)' Security Context for MongoDB(&reg;) dependent chart                                                                        | `true`                      |
| `mongodb.arbiter.containerSecurityContext.runAsUser`     | User ID for the Arbiter container for MongoDB(&reg;) dependent chart                                                                                    | `999`                       |
| `mongodb.arbiter.nodeSelector`                           | Arbiter Node labels for pod assignment for MongoDB(&reg;) dependent chart                                                                               | `{}`                        |
| `mongodb.auth.enabled`                                   | Enable authentication for MongoDB(&reg;) dependent chart                                                                                                | `false`                     |
| `mongodb.tls.enabled`                                    | Enable MongoDB(&reg;) TLS support between nodes in the cluster as well as between mongo clients and nodes for MongoDB(&reg;) dependent chart            | `false`                     |
| `mongodb.tls.image.registry`                             | Init container TLS certs setup image registry for MongoDB(&reg;) dependent chart                                                                        | `docker.io`                 |
| `mongodb.tls.image.repository`                           | Init container TLS certs setup image repository for MongoDB(&reg;) dependent chart                                                                      | `bitnami/nginx`             |
| `mongodb.tls.image.tag`                                  | Init container TLS certs setup image tag (immutable tags are recommended) for MongoDB(&reg;) dependent chart                                            | `1.21.6-debian-10-r30`      |
| `mongodb.tls.image.pullPolicy`                           | Init container TLS certs setup image pull policy for MongoDB(&reg;) dependent chart                                                                     | `IfNotPresent`              |
| `mongodb.tls.image.pullSecrets`                          | Init container TLS certs specify docker-registry secret names as an array for MongoDB(&reg;) dependent chart                                            | `[]`                        |
| `mongodb.externalAccess.enabled`                         | Enable Kubernetes external cluster access to MongoDB(&reg;) nodes (only for replicaset architecture) for MongoDB(&reg;) dependent chart                 | `false`                     |
| `mongodb.externalAccess.autoDiscovery.enabled`           | Enable using an init container to auto-detect external IPs by querying the K8s API for MongoDB(&reg;) dependent chart                                   | `false`                     |
| `mongodb.externalAccess.autoDiscovery.image.registry`    | Init container auto-discovery image registry for MongoDB(&reg;) dependent chart                                                                         | `docker.io`                 |
| `mongodb.externalAccess.autoDiscovery.image.repository`  | Init container auto-discovery image repository for MongoDB(&reg;) dependent chart                                                                       | `bitnami/kubectl`           |
| `mongodb.externalAccess.autoDiscovery.image.tag`         | Init container auto-discovery image tag (immutable tags are recommended) for MongoDB(&reg;) dependent chart                                             | `1.23.4-debian-10-r7`       |
| `mongodb.externalAccess.autoDiscovery.image.pullPolicy`  | Init container auto-discovery image pull policy for MongoDB(&reg;) dependent chart                                                                      | `IfNotPresent`              |
| `mongodb.externalAccess.autoDiscovery.image.pullSecrets` | Init container auto-discovery image pull secrets for MongoDB(&reg;) dependent chart                                                                     | `[]`                        |
| `mongodb.volumePermissions.enabled`                      | Enable init container that changes the owner and group of the persistent volume(s) mountpoint to `runAsUser:fsGroup` for MongoDB(&reg;) dependent chart | `false`                     |
| `mongodb.volumePermissions.image.registry`               | Init container volume-permissions image registry for MongoDB(&reg;) dependent chart                                                                     | `docker.io`                 |
| `mongodb.volumePermissions.image.repository`             | Init container volume-permissions image repository for MongoDB(&reg;) dependent chart                                                                   | `bitnami/bitnami-shell`     |
| `mongodb.volumePermissions.image.tag`                    | Init container volume-permissions image tag (immutable tags are recommended) for MongoDB(&reg;) dependent chart                                         | `10-debian-10-r350`         |
| `mongodb.volumePermissions.image.pullPolicy`             | Init container volume-permissions image pull policy for MongoDB(&reg;) dependent chart                                                                  | `IfNotPresent`              |
| `mongodb.volumePermissions.image.pullSecrets`            | Specify docker-registry secret names as an array for MongoDB(&reg;) dependent chart                                                                     | `[]`                        |
| `mongodb.metrics.enabled`                                | Enable using a sidecar Prometheus exporter for MongoDB(&reg;) dependent chart                                                                           | `false`                     |
| `mongodb.metrics.image.registry`                         | MongoDB(&reg;) Prometheus exporter image registry for MongoDB(&reg;) dependent chart                                                                    | `docker.io`                 |
| `mongodb.metrics.image.repository`                       | MongoDB(&reg;) Prometheus exporter image repository for MongoDB(&reg;) dependent chart                                                                  | `bitnami/mongodb-exporter`  |
| `mongodb.metrics.image.tag`                              | MongoDB(&reg;) Prometheus exporter image tag (immutable tags are recommended) for MongoDB(&reg;) dependent chart                                        | `0.30.0-debian-10-r83`      |
| `mongodb.metrics.image.pullPolicy`                       | MongoDB(&reg;) Prometheus exporter image pull policy for MongoDB(&reg;) dependent chart                                                                 | `IfNotPresent`              |
| `mongodb.metrics.image.pullSecrets`                      | Specify docker-registry secret names as an array for MongoDB(&reg;) dependent chart                                                                     | `[]`                        |
| `mongodb.extraFlags`                                     | MongoDB(&reg;) additional command line flags for MongoDB(&reg;) dependent chart                                                                         | `--dbpath=/bitnami/mongodb` |
| `mongodb.containerSecurityContext.enabled`               | Enable MongoDB(&reg;) container(s)' Security Context for MongoDB(&reg;) dependent chart                                                                 | `true`                      |
| `mongodb.containerSecurityContext.runAsUser`             | User ID for the MongoDB(&reg;) container for MongoDB(&reg;) dependent chart                                                                             | `999`                       |
| `mongodb.containerSecurityContext.runAsNonRoot`          | Set MongoDB(&reg;) container's Security Context runAsNonRoot for MongoDB(&reg;) dependent chart                                                         | `true`                      |
| `mongodb.podSecurityContext.enabled`                     | Enable MongoDB(&reg;) pod(s)' Security Context for MongoDB(&reg;) dependent chart                                                                       | `true`                      |
| `mongodb.podSecurityContext.fsGroup`                     | Group ID for the volumes of the MongoDB(&reg;) pod(s) for MongoDB(&reg;) dependent chart                                                                | `999`                       |


