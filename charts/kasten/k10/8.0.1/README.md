# Veeam Kasten Helm Chart

The [Veeam Kasten](https://docs.kasten.io/) data management platform, purpose-built for Kubernetes, provides
enterprise operations teams an easy-to-use, scalable, and secure system for backup/restore, disaster recovery,
mobility, and ransomware protection of Kubernetes applications.

## Introduction

This chart installs Veeam Kasten on a supported [Kubernetes](http://kubernetes.io) cluster using
the [Helm](https://helm.sh) package manager. Each instance of Veeam Kasten protects and restores
data on the cluster to which it is deployed.

## Prerequisites

- See [docs.kasten.io](https://docs.kasten.io/latest/operating/support.html#supported-kubernetes-versions)
  for a current list of supported Kubernetes versions
- A CSI-based storage provisioner that includes VolumeSnapshot support is highly recommended

## Installing the Chart

To perform a basic install of Veeam Kasten's latest version:

```console
$ helm repo add kasten https://charts.kasten.io/
$ helm install kasten/k10 --name=k10 --namespace=kasten-io
```

See [docs.kasten.io](https://docs.kasten.io/latest/install/index.html) for additional details on
environment-specific configuration and post-install operation.

> **NOTE**: Veeam Kasten images are also available in Platform One's **Iron Bank** hardened container registry.
> To install Veeam Kasten from Iron Bank, follow the instructions
> [here](https://docs.kasten.io/latest/install/ironbank.html).

## Uninstalling the Chart

To uninstall Veeam Kasten (assuming `k10` release name and `kasten-io` namespace):

```console
$ helm uninstall k10 --namespace=kasten-io
```

## Configuration

The following table lists the configurable parameters of the
chart and their default values:

Parameter | Description | Default
--- | --- | ---
`eula.accept`| Whether to enable accept EULA before installation | `false`
`eula.company` | Company name. Required field if EULA is accepted | `None`
`eula.email` | Contact email. Required field if EULA is accepted | `None`
`license` | License string obtained from Kasten | `None`
`rbac.create` | Whether to enable RBAC with a specific cluster role and binding for K10 | `true`
`scc.create` | Whether to create a SecurityContextConstraints for K10 ServiceAccounts | `false`
`scc.priority` | Sets the SecurityContextConstraints priority | `15`
`services.dashboardbff.hostNetwork` | Whether the dashboardbff Pods may use the node network | `false`
`services.executor.hostNetwork` | Whether the executor Pods may use the node network | `false`
`services.aggregatedapis.hostNetwork` | Whether the aggregatedapis Pods may use the node network | `false`
`serviceAccount.create`| Specifies whether a ServiceAccount should be created | `true`
`serviceAccount.name` | The name of the ServiceAccount to use. If not set, a name is derived using the release and chart names. | `None`
`ingress.create` | Specifies whether the K10 dashboard should be exposed via ingress | `false`
`ingress.name` | Optional name of the Ingress object for the K10 dashboard. If not set, the name is formed using the release name. | `{Release.Name}-ingress`
`ingress.class` | Cluster ingress controller class: `nginx`, `GCE` | `None`
`ingress.host` | FQDN (e.g., `k10.example.com`) for name-based virtual host | `None`
`ingress.urlPath` | URL path for K10 Dashboard (e.g., `/k10`) | `Release.Name`
`ingress.pathType` | Specifies the path type for the ingress resource | `ImplementationSpecific`
`ingress.annotations` | Additional Ingress object annotations | `{}`
`ingress.tls.enabled` | Configures a TLS use for `ingress.host` | `false`
`ingress.tls.secretName` | Optional TLS secret name | `None`
`ingress.defaultBackend.service.enabled` | Configures the default backend backed by a service for the K10 dashboard Ingress (mutually exclusive setting with `ingress.defaultBackend.resource.enabled`). | `false`
`ingress.defaultBackend.service.name` | The name of a service referenced by the default backend (required if the service-backed default backend is used). | `None`
`ingress.defaultBackend.service.port.name` | The port name of a service referenced by the default backend (mutually exclusive setting with port `number`, required if the service-backed default backend is used). | `None`
`ingress.defaultBackend.service.port.number` | The port number of a service referenced by the default backend (mutually exclusive setting with port `name`, required if the service-backed default backend is used). | `None`
`ingress.defaultBackend.resource.enabled` | Configures the default backend backed by a resource for the K10 dashboard Ingress (mutually exclusive setting with `ingress.defaultBackend.service.enabled`). | `false`
`ingress.defaultBackend.resource.apiGroup` | Optional API group of a resource backing the default backend. | `''`
`ingress.defaultBackend.resource.kind` | The type of a resource being referenced by the default backend (required if the resource default backend is used). | `None`
`ingress.defaultBackend.resource.name` | The name of a resource being referenced by the default backend (required if the resource default backend is used). | `None`
`global.persistence.size` | Default global size of volumes for K10 persistent services | `20Gi`
`global.persistence.catalog.size` | Size of a volume for catalog service  | `global.persistence.size`
`global.persistence.jobs.size` | Size of a volume for jobs service  | `global.persistence.size`
`global.persistence.logging.size` | Size of a volume for logging service  | `global.persistence.size`
`global.persistence.metering.size` | Size of a volume for metering service  | `global.persistence.size`
`global.persistence.storageClass` | Specified StorageClassName will be used for PVCs | `None`
`global.podLabels` | Configures custom labels to be set to all Kasten Pods | `None`
`global.podAnnotations` | Configures custom annotations to be set to all Kasten Pods | `None`
`global.airgapped.repository` | Specify the helm repository for offline (airgapped) installation | `''`
`global.imagePullSecret` | Provide secret which contains docker config for private repository. Use `k10-ecr` when secrets.dockerConfigPath is used. | `''`
`global.prometheus.external.host` | Provide external prometheus host name | `''`
`global.prometheus.external.port` | Provide external prometheus port number | `''`
`global.prometheus.external.baseURL` | Provide Base URL of external prometheus | `''`
`global.network.enable_ipv6` | Enable `IPv6` support for K10 | `false`
`google.workloadIdentityFederation.enabled` | Enable Google Workload Identity Federation for K10 | `false`
`google.workloadIdentityFederation.idp.type` | Identity Provider type for Google Workload Identity Federation for K10 | `''`
`google.workloadIdentityFederation.idp.aud` | Audience for whom the ID Token from Identity Provider is intended | `''`
`secrets.awsAccessKeyId` | AWS access key ID (required for AWS deployment) | `None`
`secrets.awsSecretAccessKey` | AWS access key secret | `None`
`secrets.awsIamRole` | ARN of the AWS IAM role assumed by K10 to perform any AWS operation. | `None`
`secrets.awsClientSecretName` | The secret that contains AWS access key ID, AWS access key secret and AWS IAM role for AWS | `None`
`secrets.googleApiKey` | Non-default base64 encoded GCP Service Account key | `None`
`secrets.googleProjectId` | Sets Google Project ID other than the one used in the GCP Service Account | `None`
`secrets.azureTenantId` | Azure tenant ID (required for Azure deployment) | `None`
`secrets.azureClientId` | Azure Service App ID | `None`
`secrets.azureClientSecret` | Azure Service APP secret | `None`
`secrets.azureClientSecretName` | The secret that contains ClientID, ClientSecret and TenantID for Azure | `None`
`secrets.azureResourceGroup` | Resource Group name that was created for the Kubernetes cluster | `None`
`secrets.azureSubscriptionID` | Subscription ID in your Azure tenant | `None`
`secrets.azureResourceMgrEndpoint` | Resource management endpoint for the Azure Stack instance | `None`
`secrets.azureADEndpoint` | Azure Active Directory login endpoint | `None`
`secrets.azureADResourceID` | Azure Active Directory resource ID to obtain AD tokens | `None`
`secrets.microsoftEntraIDEndpoint` | Microsoft Entra ID login endpoint | `None`
`secrets.microsoftEntraIDResourceID` | Microsoft Entra ID resource ID to obtain AD tokens | `None`
`secrets.azureCloudEnvID` | Azure Cloud Environment ID | `None`
`secrets.vsphereEndpoint` | vSphere endpoint for login | `None`
`secrets.vsphereUsername` | vSphere username for login | `None`
`secrets.vspherePassword` | vSphere password for login | `None`
`secrets.vsphereClientSecretName` | The secret that contains vSphere username, vSphere password and vSphere endpoint | `None`
`secrets.dockerConfig` | Set base64 encoded docker config to use for image pull operations. Alternative to the ``secrets.dockerConfigPath`` | `None`
`secrets.dockerConfigPath` | Use ``--set-file secrets.dockerConfigPath=path_to_docker_config.yaml`` to specify docker config for image pull. Will be overwritten if ``secrets.dockerConfig`` is set | `None`
`cacertconfigmap.name` | Name of the ConfigMap that contains a certificate for a trusted root certificate authority | `None`
`clusterName` | Cluster name for better logs visibility | `None`
`metering.awsRegion` | Sets AWS_REGION for metering service | `None`
`metering.mode` | Control license reporting (set to `airgap` for private-network installs) | `None`
`metering.reportCollectionPeriod` | Sets metric report collection period (in seconds) | `1800`
`metering.reportPushPeriod` | Sets metric report push period (in seconds) | `3600`
`metering.promoID` | Sets K10 promotion ID from marketing campaigns | `None`
`metering.awsMarketplace` | Sets AWS cloud metering license mode | `false`
`metering.awsManagedLicense` | Sets AWS managed license mode | `false`
`metering.redhatMarketplacePayg` | Sets Red Hat cloud metering license mode | `false`
`metering.licenseConfigSecretName` | Sets AWS managed license config secret | `None`
`externalGateway.create` | Configures an external gateway for K10 API services | `false`
`externalGateway.annotations` | Standard annotations for the services | `None`
`externalGateway.fqdn.name` | Domain name for the K10 API services | `None`
`externalGateway.fqdn.type` | Supported gateway type: `route53-mapper` or `external-dns` | `None`
`externalGateway.awsSSLCertARN` | ARN for the AWS ACM SSL certificate used in the K10 API server | `None`
`auth.basicAuth.enabled` | Configures basic authentication for the K10 dashboard | `false`
`auth.basicAuth.htpasswd` | A username and password pair separated by a colon character | `None`
`auth.basicAuth.secretName` | Name of an existing Secret that contains a file generated with htpasswd | `None`
`auth.k10AdminGroups` | A list of groups whose members are granted admin level access to K10's dashboard | `None`
`auth.k10AdminUsers` | A list of users who are granted admin level access to K10's dashboard | `None`
`auth.tokenAuth.enabled` | Configures token based authentication for the K10 dashboard | `false`
`auth.oidcAuth.enabled` | Configures Open ID Connect based authentication for the K10 dashboard | `false`
`auth.oidcAuth.providerURL` | URL for the OIDC Provider | `None`
`auth.oidcAuth.redirectURL` | URL to the K10 gateway service | `None`
`auth.oidcAuth.scopes` | Space separated OIDC scopes required for userinfo. Example: "profile email" | `None`
`auth.oidcAuth.prompt` | The type of prompt to be used during authentication (none, consent, login or select_account) | `select_account`
`auth.oidcAuth.clientID` | Client ID given by the OIDC provider for K10 | `None`
`auth.oidcAuth.clientSecret` | Client secret given by the OIDC provider for K10 | `None`
`auth.oidcAuth.clientSecretName` | The secret that contains the Client ID and Client secret given by the OIDC provider for K10 | `None`
`auth.oidcAuth.usernameClaim` | The claim to be used as the username | `sub`
`auth.oidcAuth.usernamePrefix` | Prefix that has to be used with the username obtained from the username claim | `None`
`auth.oidcAuth.groupClaim` | Name of a custom OpenID Connect claim for specifying user groups | `None`
`auth.oidcAuth.groupPrefix` | All groups will be prefixed with this value to prevent conflicts | `None`
`auth.oidcAuth.sessionDuration` | Maximum OIDC session duration | `1h`
`auth.oidcAuth.refreshTokenSupport` | Enable OIDC Refresh Token support | `false`
`auth.openshift.enabled` | Enables access to the K10 dashboard by authenticating with the OpenShift OAuth server | `false`
`auth.openshift.serviceAccount` | Name of the service account that represents an OAuth client | `None`
`auth.openshift.clientSecret` | The token corresponding to the service account | `None`
`auth.openshift.clientSecretName` | The secret that contains the token corresponding to the service account | `None`
`auth.openshift.dashboardURL` | The URL used for accessing K10's dashboard | `None`
`auth.openshift.openshiftURL` | The URL for accessing OpenShift's API server | `None`
`auth.openshift.insecureCA` | To turn off SSL verification of connections to OpenShift | `false`
`auth.openshift.useServiceAccountCA` | Set this to true to use the CA certificate corresponding to the Service Account ``auth.openshift.serviceAccount`` usually found at ``/var/run/secrets/kubernetes.io/serviceaccount/ca.crt`` | `false`
`auth.openshift.caCertsAutoExtraction` | Set this to false to disable the OCP CA certificates automatic extraction to the K10 namespace | `true`
`auth.ldap.enabled` | Configures Active Directory/LDAP based authentication for the K10 dashboard | `false`
`auth.ldap.restartPod` | To force a restart of the authentication service Pod (useful when updating authentication config) | `false`
`auth.ldap.dashboardURL` | The URL used for accessing K10's dashboard | `None`
`auth.ldap.host` | Host and optional port of the AD/LDAP server in the form `host:port` | `None`
`auth.ldap.insecureNoSSL` | Required if the AD/LDAP host is not using TLS | `false`
`auth.ldap.insecureSkipVerifySSL` | To turn off SSL verification of connections to the AD/LDAP host | `false`
`auth.ldap.startTLS` | When set to true, ldap:// is used to connect to the server followed by creation of a TLS session. When set to false, ldaps:// is used. | `false`
`auth.ldap.bindDN` | The Distinguished Name(username) used for connecting to the AD/LDAP host | `None`
`auth.ldap.bindPW` | The password corresponding to the `bindDN` for connecting to the AD/LDAP host | `None`
`auth.ldap.bindPWSecretName` | The name of the secret that contains the password corresponding to the `bindDN` for connecting to the AD/LDAP host | `None`
`auth.ldap.userSearch.baseDN` | The base Distinguished Name to start the AD/LDAP search from | `None`
`auth.ldap.userSearch.filter` | Optional filter to apply when searching the directory | `None`
`auth.ldap.userSearch.username` | Attribute used for comparing user entries when searching the directory | `None`
`auth.ldap.userSearch.idAttr` | AD/LDAP attribute in a user's entry that should map to the user ID field in a token | `None`
`auth.ldap.userSearch.emailAttr` | AD/LDAP attribute in a user's entry that should map to the email field in a token | `None`
`auth.ldap.userSearch.nameAttr` | AD/LDAP attribute in a user's entry that should map to the name field in a token | `None`
`auth.ldap.userSearch.preferredUsernameAttr` | AD/LDAP attribute in a user's entry that should map to the preferred_username field in a token | `None`
`auth.ldap.groupSearch.baseDN` | The base Distinguished Name to start the AD/LDAP group search from | `None`
`auth.ldap.groupSearch.filter` | Optional filter to apply when searching the directory for groups | `None`
`auth.ldap.groupSearch.nameAttr` | The AD/LDAP attribute that represents a group's name in the directory | `None`
`auth.ldap.groupSearch.userMatchers` | List of field pairs that are used to match a user to a group. | `None`
`auth.ldap.groupSearch.userMatchers.userAttr` | Attribute in the user's entry that must match with the `groupAttr` while searching for groups | `None`
`auth.ldap.groupSearch.userMatchers.groupAttr` | Attribute in the group's entry that must match with the `userAttr` while searching for groups | `None`
`auth.groupAllowList` | A list of groups whose members are allowed access to K10's dashboard | `None`
`services.securityContext` | Custom [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) for K10 service containers | `{"runAsUser" : 1000, "fsGroup": 1000}`
`services.securityContext.runAsUser` | User ID K10 service containers run as| `1000`
`services.securityContext.runAsGroup` | Group ID K10 service containers run as| `1000`
`services.securityContext.fsGroup` | FSGroup that owns K10 service container volumes | `1000`
`siem.logging.cluster.enabled` | Whether to enable writing K10 audit event logs to stdout (standard output) | `true`
`siem.logging.cloud.path` | Directory path for saving audit logs in a cloud object store | `k10audit/`
`siem.logging.cloud.awsS3.enabled` | Whether to enable sending K10 audit event logs to AWS S3 | `true`
`injectGenericVolumeBackupSidecar.enabled` | Enables injection of sidecar container required to perform Generic Volume Backup into workload Pods | `false`
`injectGenericVolumeBackupSidecar.namespaceSelector.matchLabels` | Set of labels to select namespaces in which sidecar injection is enabled for workloads | `{}`
`injectGenericVolumeBackupSidecar.objectSelector.matchLabels` | Set of labels to filter workload objects in which the sidecar is injected | `{}`
`injectGenericVolumeBackupSidecar.webhookServer.port` | Port number on which the mutating webhook server accepts request | `8080`
`gateway.resources.[requests\|limits].[cpu\|memory]` | Resource requests and limits for gateway Pod | `{}`
`gateway.service.externalPort` | Specifies the gateway services external port | `80`
`genericVolumeSnapshot.resources.[requests\|limits].[cpu\|memory]` | Specifies resource requests and limits for generic backup sidecar and all temporary Kasten worker Pods. Superseded by ActionPodSpec | `{}`
`multicluster.enabled` | Choose whether to enable the multi-cluster system components and capabilities | `true`
`multicluster.primary.create` | Choose whether to setup cluster as a multi-cluster primary | `false`
`multicluster.primary.name` | Primary cluster name | `''`
`multicluster.primary.ingressURL` | Primary cluster dashboard URL | `''`
`prometheus.k10image.registry` | (optional) Set Prometheus image registry. | `gcr.io`
`prometheus.k10image.repository` | (optional) Set Prometheus image repository. | `kasten-images`
`prometheus.rbac.create` | (optional) Whether to create Prometheus RBAC configuration. Warning - this action will allow prometheus to scrape Pods in all k8s namespaces | `false`
`prometheus.alertmanager.enabled` | DEPRECATED: (optional) Enable Prometheus `alertmanager` service | `false`
`prometheus.alertmanager.serviceAccount.create` | DEPRECATED: (optional) Set true to create ServiceAccount for `alertmanager` | `false`
`prometheus.networkPolicy.enabled` | DEPRECATED: (optional) Enable Prometheus `networkPolicy` | `false`
`prometheus.prometheus-node-exporter.enabled` | DEPRECATED: (optional) Enable Prometheus `node-exporter` | `false`
`prometheus.prometheus-node-exporter.serviceAccount.create` | DEPRECATED: (optional) Set true to create ServiceAccount for `prometheus-node-exporter` | `false`
`prometheus.prometheus-pushgateway.enabled` | DEPRECATED: (optional) Enable Prometheus `pushgateway` | `false`
`prometheus.prometheus-pushgateway.serviceAccount.create` | DEPRECATED: (optional) Set true to create ServiceAccount for `prometheus-pushgateway` | `false`
`prometheus.scrapeCAdvisor` | DEPRECATED: (optional) Enable Prometheus ScrapeCAdvisor | `false`
`prometheus.server.enabled` | (optional) If false, K10's Prometheus server will not be created, reducing the dashboard's functionality. | `true`
`prometheus.server.securityContext.runAsUser` | (optional) Set security context `runAsUser` ID for Prometheus server Pod | `65534`
`prometheus.server.securityContext.runAsNonRoot` | (optional) Enable security context `runAsNonRoot` for Prometheus server Pod | `true`
`prometheus.server.securityContext.runAsGroup` | (optional) Set security context `runAsGroup` ID for Prometheus server Pod | `65534`
`prometheus.server.securityContext.fsGroup` | (optional) Set security context `fsGroup` ID for Prometheus server Pod | `65534`
`prometheus.server.retention` | (optional) K10 Prometheus data retention | `"30d"`
`prometheus.server.strategy.rollingUpdate.maxSurge` | DEPRECATED: (optional) The number of Prometheus server Pods that can be created above the desired amount of Pods during an update | `"100%"`
`prometheus.server.strategy.rollingUpdate.maxUnavailable` | DEPRECATED: (optional) The number of Prometheus server Pods that can be unavailable during the upgrade process | `"100%"`
`prometheus.server.strategy.type` | DEPRECATED: (optional) Change default deployment strategy for Prometheus server | `"RollingUpdate"`
`prometheus.server.persistentVolume.enabled` | DEPRECATED: (optional) If true, K10 Prometheus server will create a Persistent Volume Claim | `true`
`prometheus.server.persistentVolume.size` | (optional) K10 Prometheus server data Persistent Volume size | `8Gi`
`prometheus.server.persistentVolume.storageClass` | (optional) StorageClassName used to create Prometheus PVC. Setting this option overwrites global StorageClass value | `""`
`prometheus.server.configMapOverrideName` | DEPRECATED: (optional) Prometheus configmap name to override default generated name| `k10-prometheus-config`
`prometheus.server.fullnameOverride` | (optional) Prometheus deployment name to override default generated name| `prometheus-server`
`prometheus.server.baseURL` | (optional) K10 Prometheus external url path at which the server can be accessed | `/k10/prometheus/`
`prometheus.server.prefixURL` | (optional) K10 Prometheus prefix slug at which the server can be accessed | `/k10/prometheus/`
`prometheus.server.serviceAccounts.server.create` | DEPRECATED: (optional) Set true to create ServiceAccount for Prometheus server service | `true`
`resources.<deploymentName>.<containerName>.[requests\|limits].[cpu\|memory]` | Overwriting the default K10 [container resource requests and limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) | varies depending on the container
`route.enabled` | Specifies whether the K10 dashboard should be exposed via route | `false`
`route.host` | FQDN (e.g., `.k10.example.com`) for name-based virtual host | `""`
`route.path` | URL path for K10 Dashboard (e.g., `/k10`) | `/`
`route.annotations` | Additional Route object annotations | `{}`
`route.labels` | Additional Route object labels | `{}`
`route.tls.enabled` | Configures a TLS use for `route.host` | `false`
`route.tls.insecureEdgeTerminationPolicy` | Specifies behavior for insecure scheme traffic | `Redirect`
`route.tls.termination` | Specifies the TLS termination of the route | `edge`
`limiter.executorReplicas` | Specifies the number of executor-svc Pods used to process Kasten jobs | 3
`limiter.executorThreads` | Specifies the number of threads per executor-svc Pod used to process Kasten jobs | 8
`limiter.workloadSnapshotsPerAction` | Per action limit of concurrent manifest data snapshots, based on workload (ex. Namespace, Deployment, StatefulSet, VirtualMachine) | 5
`limiter.csiSnapshotsPerCluster` | Cluster-wide limit of concurrent CSI VolumeSnapshot creation requests | `10`
`limiter.directSnapshotsPerCluster` | Cluster-wide limit of concurrent non-CSI snapshot creation requests | `10`
`limiter.snapshotExportsPerAction` | Per action limit of concurrent volume export operations | `3`
`limiter.snapshotExportsPerCluster` | Cluster-wide limit of concurrent volume export operations | `10`
`limiter.genericVolumeBackupsPerCluster` | Cluster-wide limit of concurrent Generic Volume Backup operations | `10`
`limiter.imageCopiesPerCluster` | Cluster-wide limit of concurrent ImageStream container image backup (i.e. copy from) and restore (i.e. copy to) operations | `10`
`limiter.workloadRestoresPerAction` | Per action limit of concurrent manifest data restores, based on workload (ex. Namespace, Deployment, StatefulSet, VirtualMachine) | 3
`limiter.csiSnapshotRestoresPerAction` | Per action limit of concurrent CSI volume provisioning requests when restoring from VolumeSnapshots | 3
`limiter.volumeRestoresPerAction` | Per action limit of concurrent volume restore operations from an exported backup | 3
`limiter.volumeRestoresPerCluster` | Cluster-wide limit of concurrent volume restore operations from exported backups | `10`
`cluster.domainName` | Specifies the domain name of the cluster | `""`
`timeout.blueprintBackup` | Specifies the timeout (in minutes) for Blueprint backup actions | `45`
`timeout.blueprintRestore` | Specifies the timeout (in minutes) for Blueprint restore actions | `600`
`timeout.blueprintDelete` | Specifies the timeout (in minutes) for Blueprint delete actions | `45`
`timeout.blueprintHooks` | Specifies the timeout (in minutes) for Blueprint backupPrehook and backupPosthook actions | `20`
`timeout.checkRepoPodReady` | Specifies the timeout (in minutes) for temporary worker Pods used to validate backup repository existence | `20`
`timeout.statsPodReady` | Specifies the timeout (in minutes) for temporary worker Pods used to collect repository statistics | `20`
`timeout.efsRestorePodReady` | Specifies the timeout (in minutes) for temporary worker Pods used for shareable volume restore operations | `45`
`timeout.workerPodReady` | Specifies the timeout (in minutes) for all other temporary worker Pods used during Veeam Kasten operations | `15`
`timeout.jobWait` | Specifies the timeout (in minutes) for completing execution of any child job, after which the parent job will be canceled. If no value is set, a default of 10 hours will be used | `None`
`awsConfig.assumeRoleDuration` | Duration of a session token generated by AWS for an IAM role. The minimum value is 15 minutes and the maximum value is the maximum duration setting for that IAM role. For documentation about how to view and edit the maximum session duration for an IAM role see https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html#id_roles_use_view-role-max-session. The value accepts a number along with a single character ``m``(for minutes) or ``h`` (for hours)  Examples: 60m or 2h | `''`
`awsConfig.efsBackupVaultName` | Specifies the AWS EFS backup vault name | `k10vault`
`vmWare.taskTimeoutMin` | Specifies the timeout for VMWare operations | `60`
`encryption.primaryKey.awsCmkKeyId` | Specifies the AWS CMK key ID for encrypting K10 Primary Key | `None`
`garbagecollector.daemonPeriod` | Sets garbage collection period (in seconds) | `21600`
`garbagecollector.keepMaxActions` | Sets maximum actions to keep | `1000`
`garbagecollector.actions.enabled` | Enables action collectors | `false`
`kubeVirtVMs.snapshot.unfreezeTimeout` | Defines the time duration within which the VMs must be unfrozen while backing them up. To know more about format [go doc](https://pkg.go.dev/time#ParseDuration) can be followed | `5m`
`excludedApps` | Specifies a list of applications to be excluded from the dashboard & compliance considerations. Format should be a :ref:`YAML array<k10_compliance>` | `["kube-system", "kube-ingress", "kube-node-lease", "kube-public", "kube-rook-ceph"]`
`workerPodMetricSidecar.enabled` | Enables a sidecar container for temporary worker Pods used to push Pod performance metrics to Prometheus | `true`
`workerPodMetricSidecar.metricLifetime` | Specifies the period after which metrics for an individual worker Pod are removed from Prometheus | `2m`
`workerPodMetricSidecar.pushGatewayInterval` | Specifies the frequency for pushing metrics into Prometheus | `30s`
`workerPodMetricSidecar.resources.[requests\|limits].[cpu\|memory]` | Specifies resource requests and limits for the temporary worker Pod metric sidecar | `{}`
`forceRootInBlueprintActions` | Forces any Pod created by a Blueprint to run as root user | `true`
`defaultPriorityClassName` | Specifies the default [priority class](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/#priorityclass) name for all K10 deployments and ephemeral Pods | `None`
`priorityClassName.<deploymentName>` | Overrides the default [priority class](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/#priorityclass) name for the specified deployment | `{}`
`ephemeralPVCOverhead` | Set the percentage increase for the ephemeral Persistent Volume Claim's storage request, e.g. PVC size = (file raw size) * (1 + `ephemeralPVCOverhead`) | `0.1`
`datastore.parallelUploads` | Specifies how many files can be uploaded in parallel to the data store | `8`
`datastore.parallelDownloads` | Specifies how many files can be downloaded in parallel from the data store | `8`
`datastore.parallelBlockUploads` | Specifies how many blocks can be uploaded in parallel to the data store | `8`
`datastore.parallelBlockDownloads` | Specifies how many blocks can be downloaded in parallel from the data store | `8`
`kastenDisasterRecovery.quickMode.enabled` | Enables K10 Quick Disaster Recovery | `false`
`fips.enabled` | Specifies whether K10 should be run in the FIPS mode of operation | `false`
`workerPodCRDs.enabled` | Specifies whether K10 should use `ActionPodSpec` for granular resource control of worker Pods | `false`
`workerPodCRDs.resourcesRequests.maxCPU` | Max CPU which might be setup in `ActionPodSpec` | `''`
`workerPodCRDs.resourcesRequests.maxMemory` | Max memory which might be setup in `ActionPodSpec` | `''`
`workerPodCRDs.defaultActionPodSpec.name` | The name of `ActionPodSpec` that will be used by default for worker Pod resources. | `''`
`workerPodCRDs.defaultActionPodSpec.namespace` | The namespace of `ActionPodSpec` that will be used by default for worker Pod resources. | `''`
`vap.kastenPolicyPermissions.enabled` | Enable installation of the ValidatingAdmissionPolicy to evaluate non-admin user permissions while creating a Kasten policy. | `false`
