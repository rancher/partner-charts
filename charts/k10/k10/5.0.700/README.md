# Kasten's K10 Helm chart.

[Kasten's k10](https://docs.kasten.io/) is a data lifecycle management system for all your persistence.enabled container-based applications.

## TL;DR;

```console
$ helm install kasten/k10 --name=k10 --namespace=kasten-io
```

## Introduction

This chart bootstraps Kasten's K10 platform on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites
  - Kubernetes 1.7+ with Beta APIs enabled

## Installing the Chart

To install the chart on a [GKE](https://cloud.google.com/container-engine/) cluster

```console
$ helm install kasten/k10 --name=k10 --namespace=kasten-io
```

To install the chart on an [AWS](https://aws.amazon.com/) [kops](https://github.com/kubernetes/kops)-created cluster

```console
$ helm install kasten/k10 --name=k10 --namespace=kasten-io --set secrets.awsAccessKeyId="${AWS_ACCESS_KEY_ID}" \
                                                           --set secrets.awsSecretAccessKey="${AWS_SECRET_ACCESS_KEY}"
```

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `k10` application:

```console
$ helm delete k10 --purge
```

## Configuration

The following table lists the configurable parameters of the K10
chart and their default values.

Parameter | Description | Default
--- | --- | ---
`eula.accept`| Whether to enable accept EULA before installation | `false`
`eula.company` | Company name. Required field if EULA is accepted | `None`
`eula.email` | Contact email. Required field if EULA is accepted | `None`
`license` | License string obtained from Kasten | `None`
`rbac.create` | Whether to enable RBAC with a specific cluster role and binding for K10  | `true`
`scc.create` | Whether to create a SecurityContextConstraints for K10 ServiceAccounts  | `false`
`services.dashboardbff.hostNetwork` | Whether the dashboardbff pods may use the node network | `false`
`services.executor.hostNetwork` | Whether the executor pods may use the node network | `false`
`services.aggregatedapis.hostNetwork` | Whether the aggregatedapis pods may use the node network | `false`
`serviceAccount.create`| Specifies whether a ServiceAccount should be created | `true`
`serviceAccount.name` | The name of the ServiceAccount to use. If not set, a name is derived using the release and chart names. | `None`
`ingress.create` | Specifies whether the K10 dashboard should be exposed via ingress | `false`
`ingress.class` | Cluster ingress controller class: `nginx`, `GCE` | `None`
`ingress.host` | FQDN (e.g., `k10.example.com`) for name-based virtual host | `None`
`ingress.urlPath` | URL path for K10 Dashboard (e.g., `/k10`) | `Release.Name`
`ingress.annotations` | Additional Ingress object annotations | `{}`
`ingress.tls.enabled` | Configures a TLS use for `ingress.host` | `false`
`ingress.tls.secretName` | Specifies a name of TLS secret | `None`
`ingress.pathType` | Specifies the path type for the ingress resource | `ImplementationSpecific`
`global.persistence.enabled` | Use PVS to persist data | `true`
`global.persistence.size` | Default global size of volumes for K10 persistent services  | `20Gi`
`global.persistence.catalog.size` | Size of a volume for catalog service  | `global.persistence.size`
`global.persistence.jobs.size` | Size of a volume for jobs service  | `global.persistence.size`
`global.persistence.logging.size` | Size of a volume for logging service  | `global.persistence.size`
`global.persistence.metering.size` | Size of a volume for metering service  | `global.persistence.size`
`global.persistence.storageClass` | Specified StorageClassName will be used for PVCs | `None`
`global.airgapped.repository` | Specify the helm repository for offline (airgapped) installation | `''`
`global.imagePullSecret` | Provide secret which contains docker config for private repository. Use `k10-ecr` when secrets.dockerConfigPath is used. | `''`
`global.prometheus.external.host` | Provide external prometheus host name | `''`
`global.prometheus.external.port` | Provide external prometheus port number | `''`
`global.prometheus.external.baseURL` | Provide Base URL of external prometheus | `''`
`global.network.enable_ipv6` | Enable `IPv6` support for K10 | `false`
`secrets.awsAccessKeyId` | AWS access key ID (required for AWS deployment) | `None`
`secrets.awsSecretAccessKey` | AWS access key secret | `None`
`secrets.awsIamRole` | ARN of the AWS IAM role assumed by K10 to perform any AWS operation. | `None`
`secrets.googleApiKey` | Non-default base64 encoded GCP Service Account key file | `None`
`secrets.azureTenantId` | Azure tenant ID (required for Azure deployment) | `None`
`secrets.azureClientId` | Azure Service App ID | `None`
`secrets.azureClientSecret` | Azure Service APP secret | `None`
`secrets.azureResourceGroup` | Resource Group name that was created for the Kubernetes cluster | `None`
`secrets.azureSubscriptionID` | Subscription ID in your Azure tenant | `None`
`secrets.azureResourceMgrEndpoint` | Resource management endpoint for the Azure Stack instance | `None`
`secrets.azureADEndpoint` | Azure Active Directory login endpoint | `None`
`secrets.azureADResourceID` | Azure Active Directory resource ID to obtain AD tokens | `None`
`secrets.azureCloudEnvID` | Azure Cloud Environment ID | `None`
`secrets.vsphereEndpoint` | vSphere endpoint for login | `None`
`secrets.vsphereUsername` | vSphere username for login | `None`
`secrets.vspherePassword` | vSphere password for login | `None`
`secrets.dockerConfigPath` | Use --set-file secrets.dockerConfigPath=path_to_docker_config.yaml to specify docker config for image pull | `None`
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
`auth.oidcAuth.usernameClaim` | The claim to be used as the username | `sub`
`auth.oidcAuth.usernamePrefix` | Prefix that has to be used with the username obtained from the username claim | `None`
`auth.oidcAuth.groupClaim` | Name of a custom OpenID Connect claim for specifying user groups | `None`
`auth.oidcAuth.groupPrefix` | All groups will be prefixed with this value to prevent conflicts | `None`
`auth.openshift.enabled` | Enables access to the K10 dashboard by authenticating with the OpenShift OAuth server | `false`
`auth.openshift.serviceAccount` | Name of the service account that represents an OAuth client | `None`
`auth.openshift.clientSecret` | The token corresponding to the service account | `None`
`auth.openshift.dashboardURL` | The URL used for accessing K10's dashboard | `None`
`auth.openshift.openshiftURL` | The URL for accessing OpenShift's API server | `None`
`auth.openshift.insecureCA` | To turn off SSL verification of connections to OpenShift | `false`
`auth.openshift.useServiceAccountCA` | Set this to true to use the CA certificate corresponding to the Service Account ``auth.openshift.serviceAccount`` usually found at ``/var/run/secrets/kubernetes.io/serviceaccount/ca.crt`` | `false`
`auth.ldap.enabled` | Configures Active Directory/LDAP based authentication for the K10 dashboard | `false`
`auth.ldap.restartPod` | To force a restart of the authentication service pod (useful when updating authentication config) | `false`
`auth.ldap.dashboardURL` | The URL used for accessing K10's dashboard | `None`
`auth.ldap.host` | Host and optional port of the AD/LDAP server in the form `host:port` | `None`
`auth.ldap.insecureNoSSL` | Required if the AD/LDAP host is not using TLS | `false`
`auth.ldap.insecureSkipVerifySSL` | To turn off SSL verification of connections to the AD/LDAP host | `false`
`auth.ldap.startTLS` | When set to true, ldap:// is used to connect to the server followed by creation of a TLS session. When set to false, ldaps:// is used.  | `false`
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
`injectKanisterSidecar.enabled` | Enable Kanister sidecar injection for workload pods | `false`
`injectKanisterSidecar.namespaceSelector.matchLabels` | Set of labels to select namespaces in which sidecar injection is enabled for workloads | `{}`
`injectKanisterSidecar.objectSelector.matchLabels` | Set of labels to filter workload objects in which the sidecar is injected | `{}`
`injectKanisterSidecar.webhookServer.port` | Port number on which the mutating webhook server accepts request | `8080`
`gateway.insecureDisableSSLVerify` | Specifies whether to disable SSL verification for gateway pods | `false`
`gateway.exposeAdminPort` | Specifies whether to expose Admin port for gateway service | `true`
`genericVolumeSnapshot.resources.[requests\|limits].[cpu\|memory]` | Resource requests and limits for Generic Volume Snapshot restore pods | `{}`
`prometheus.server.enabled` | If false, K10's Prometheus server will not be created, reducing the dashboard's functionality. | `true`
`prometheus.server.persistentVolume.enabled` | If true, K10 Prometheus server will create a Persistent Volume Claim | `true`
`prometheus.server.persistentVolume.size` | K10 Prometheus server data Persistent Volume size | `30Gi`
`prometheus.server.persistentVolume.storageClass` | StorageClassName used to create Prometheus PVC. Setting this option overwrites global StorageClass value | `""`
`prometheus.server.retention` | (optional) K10 Prometheus data retention | `"30d"`
`prometheus.server.baseURL` | (optional) K10 Prometheus external url path at which the server can be accessed | `/k10/prometheus/`
`prometheus.server.prefixURL` | (optional) K10 Prometheus prefix slug at which the server can be accessed | `/k10/prometheus/`
`grafana.enabled` | (optional) If false Grafana will not be available | `true`
`grafana.prometheusPrefixURL` | (optional) URL for Prometheus datasource in Grafana (must match `prometheus.server.prefixURL`) | `/k10/prometheus/`
`resources.<podName>.<containerName>.[requests\|limits].[cpu\|memory]` | Overwrite default K10 [container resource requests and limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) | varies by container
`route.enabled` | Specifies whether the K10 dashboard should be exposed via route | `false`
`route.host` | FQDN (e.g., `.k10.example.com`) for name-based virtual host | `""`
`route.path` | URL path for K10 Dashboard (e.g., `/k10`) | `/`
`route.annotations` | Additional Route object annotations | `{}`
`route.labels` | Additional Route object labels | `{}`
`route.tls.enabled` | Configures a TLS use for `route.host` | `false`
`route.tls.insecureEdgeTerminationPolicy` | Specifies behavior for insecure scheme traffic | `Redirect`
`route.tls.termination` | Specifies the TLS termination of the route | `edge`
`apigateway.serviceResolver` | Specifies the resolver used for service discovery in the API gateway (`dns` or `endpoint`) | `dns`
`limiter.genericVolumeSnapshots` | Limit of concurrent generic volume snapshot create operations | `10`
`limiter.genericVolumeCopies` | Limit of concurrent generic volume snapshot copy operations | `10`
`limiter.genericVolumeRestores` | Limit of concurrent generic volume snapshot restore operations | `10`
`limiter.csiSnapshots` | Limit of concurrent CSI snapshot create operations | `10`
`limiter.providerSnapshots` | Limit of concurrent cloud provider create operations | `10`
`cluster.domainName` | Specifies the domain name of the cluster | `cluster.local`
`kanister.backupTimeout` | Specifies timeout to set on Kanister backup operations | `45`
`kanister.restoreTimeout` | Specifies timeout to set on Kanister restore operations | `600`
`kanister.deleteTimeout` | Specifies timeout to set on Kanister delete operations | `45`
`kanister.hookTimeout` | Specifies timeout to set on Kanister pre-hook and post-hook operations | `20`
`kanister.checkRepoTimeout` | Specifies timeout to set on Kanister checkRepo operations | `20`
`kanister.statsTimeout` | Specifies timeout to set on Kanister stats operations | `20`
`kanister.efsPostRestoreTimeout` | Specifies timeout to set on Kanister efsPostRestore operations | `45`
`awsConfig.assumeRoleDuration` | Duration of a session token generated by AWS for an IAM role. The minimum value is 15 minutes and the maximum value is the maximum duration setting for that IAM role. For documentation about how to view and edit the maximum session duration for an IAM role see https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html#id_roles_use_view-role-max-session. The value accepts a number along with a single character ``m``(for minutes) or ``h`` (for hours)  Examples: 60m or 2h | `''`
`awsConfig.efsBackupVaultName` | Specifies the AWS EFS backup vault name | `k10vault`
`vmWare.taskTimeoutMin` | Specifies the timeout for VMWare operations | `60`
`encryption.primaryKey.awsCmkKeyId` | Specifies the AWS CMK key ID for encrypting K10 Primary Key | `None`
## Helm tips and tricks

There is a way of setting values via a yaml file instead of using `--set`.
You can copy/paste values into a file (e.g., my_values.yaml):

```yaml
secrets:
  awsAccessKeyId: ${AWS_ACCESS_KEY_ID}
  awsSecretAccessKey: ${AWS_SECRET_ACCESS_KEY}
```
and then run:
```bash
  envsubst < my_values.yaml > my_values_out.yaml && helm install helm/k10 -f my_values_out.yaml
```

To use non-default GCP ServiceAccount (SA) credentials, the credentials JSON file needs to be encoded into a base64 string.


```bash
  sa_key=$(base64 -w0 sa-key.json)
  helm install kasten/k10 --name=k10 --namespace=kasten-io --set secrets.googleApiKey=$sa_key
```
