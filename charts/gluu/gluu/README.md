# gluu

![Version: 5.0.17](https://img.shields.io/badge/Version-5.0.17-informational?style=flat-square) ![AppVersion: 5.0.0](https://img.shields.io/badge/AppVersion-5.0.0-informational?style=flat-square)

Gluu Access and Identity Management

**Homepage:** <https://www.gluu.org>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| moabu | <support@gluu.org> |  |

## Source Code

* <https://gluu.org/docs/gluu-server>
* <https://github.com/GluuFederation/flex/flex-cn-setup>

## Requirements

Kubernetes: `>=v1.21.0-0`

| Repository | Name | Version |
|------------|------|---------|
|  | admin-ui | 5.0.17 |
|  | auth-server | 5.0.17 |
|  | auth-server-key-rotation | 5.0.17 |
|  | casa | 5.0.17 |
|  | cn-istio-ingress | 5.0.17 |
|  | config | 5.0.17 |
|  | config-api | 5.0.17 |
|  | fido2 | 5.0.17 |
|  | nginx-ingress | 5.0.17 |
|  | opendj | 5.0.17 |
|  | oxpassport | 5.0.17 |
|  | oxshibboleth | 5.0.17 |
|  | persistence | 5.0.17 |
|  | scim | 5.0.17 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| admin-ui | object | `{"additionalAnnotations":{},"additionalLabels":{},"dnsConfig":{},"dnsPolicy":"","hpa":{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50},"image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"ghcr.io/gluufederation/flex/admin-ui","tag":"1.0.13_dev"},"lifecycle":{},"livenessProbe":{"failureThreshold":20,"initialDelaySeconds":60,"periodSeconds":25,"tcpSocket":{"port":8080},"timeoutSeconds":5},"pdb":{"enabled":true,"maxUnavailable":"90%"},"readinessProbe":{"failureThreshold":20,"initialDelaySeconds":60,"periodSeconds":25,"tcpSocket":{"port":8080},"timeoutSeconds":5},"replicas":1,"resources":{"limits":{"cpu":"2000m","memory":"2000Mi"},"requests":{"cpu":"2000m","memory":"2000Mi"}},"topologySpreadConstraints":{},"usrEnvs":{"normal":{},"secret":{}},"volumeMounts":[],"volumes":[]}` | Admin GUI for configuration of the auth-server |
| admin-ui.additionalAnnotations | object | `{}` | Additional annotations that will be added across the gateway in the format of {cert-manager.io/issuer: "letsencrypt-prod"} |
| admin-ui.additionalLabels | object | `{}` | Additional labels that will be added across the gateway in the format of {mylabel: "myapp"} |
| admin-ui.dnsConfig | object | `{}` | Add custom dns config |
| admin-ui.dnsPolicy | string | `""` | Add custom dns policy |
| admin-ui.hpa | object | `{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50}` | Configure the HorizontalPodAutoscaler |
| admin-ui.hpa.behavior | object | `{}` | Scaling Policies |
| admin-ui.hpa.metrics | list | `[]` | metrics if targetCPUUtilizationPercentage is not set |
| admin-ui.image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy to use for deploying. |
| admin-ui.image.pullSecrets | list | `[]` | Image Pull Secrets |
| admin-ui.image.repository | string | `"ghcr.io/gluufederation/flex/admin-ui"` | Image  to use for deploying. |
| admin-ui.image.tag | string | `"1.0.13_dev"` | Image  tag to use for deploying. |
| admin-ui.livenessProbe | object | `{"failureThreshold":20,"initialDelaySeconds":60,"periodSeconds":25,"tcpSocket":{"port":8080},"timeoutSeconds":5}` | Configure the liveness healthcheck for the admin ui if needed. |
| admin-ui.pdb | object | `{"enabled":true,"maxUnavailable":"90%"}` | Configure the PodDisruptionBudget |
| admin-ui.readinessProbe | object | `{"failureThreshold":20,"initialDelaySeconds":60,"periodSeconds":25,"tcpSocket":{"port":8080},"timeoutSeconds":5}` | Configure the readiness healthcheck for the admin ui if needed. |
| admin-ui.replicas | int | `1` | Service replica number. |
| admin-ui.resources | object | `{"limits":{"cpu":"2000m","memory":"2000Mi"},"requests":{"cpu":"2000m","memory":"2000Mi"}}` | Resource specs. |
| admin-ui.resources.limits.cpu | string | `"2000m"` | CPU limit. |
| admin-ui.resources.limits.memory | string | `"2000Mi"` | Memory limit. |
| admin-ui.resources.requests.cpu | string | `"2000m"` | CPU request. |
| admin-ui.resources.requests.memory | string | `"2000Mi"` | Memory request. |
| admin-ui.topologySpreadConstraints | object | `{}` | Configure the topology spread constraints. Notice this is a map NOT a list as in the upstream API https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/ |
| admin-ui.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service |
| admin-ui.usrEnvs.normal | object | `{}` | Add custom normal envs to the service variable1: value1 |
| admin-ui.usrEnvs.secret | object | `{}` | Add custom secret envs to the service variable1: value1 |
| admin-ui.volumeMounts | list | `[]` | Configure any additional volumesMounts that need to be attached to the containers |
| admin-ui.volumes | list | `[]` | Configure any additional volumes that need to be attached to the pod |
| auth-server | object | `{"additionalAnnotations":{},"additionalLabels":{},"dnsConfig":{},"dnsPolicy":"","hpa":{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50},"image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"ghcr.io/janssenproject/jans/auth-server","tag":"1.0.13_dev"},"lifecycle":{},"livenessProbe":{"exec":{"command":["python3","/app/scripts/healthcheck.py"]},"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5},"pdb":{"enabled":true,"maxUnavailable":"90%"},"readinessProbe":{"exec":{"command":["python3","/app/scripts/healthcheck.py"]},"initialDelaySeconds":25,"periodSeconds":25,"timeoutSeconds":5},"replicas":1,"resources":{"limits":{"cpu":"2500m","memory":"2500Mi"},"requests":{"cpu":"2500m","memory":"2500Mi"}},"topologySpreadConstraints":{},"usrEnvs":{"normal":{},"secret":{}},"volumeMounts":[],"volumes":[]}` | OAuth Authorization Server, the OpenID Connect Provider, the UMA Authorization Server--this is the main Internet facing component of Gluu. It's the service that returns tokens, JWT's and identity assertions. This service must be Internet facing. |
| auth-server-key-rotation | object | `{"additionalAnnotations":{},"additionalLabels":{},"dnsConfig":{},"dnsPolicy":"","image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"ghcr.io/janssenproject/jans/certmanager","tag":"1.0.13_dev"},"keysLife":48,"lifecycle":{},"resources":{"limits":{"cpu":"300m","memory":"300Mi"},"requests":{"cpu":"300m","memory":"300Mi"}},"usrEnvs":{"normal":{},"secret":{}},"volumeMounts":[],"volumes":[]}` | Responsible for regenerating auth-keys per x hours |
| auth-server-key-rotation.additionalAnnotations | object | `{}` | Additional annotations that will be added across the gateway in the format of {cert-manager.io/issuer: "letsencrypt-prod"} |
| auth-server-key-rotation.additionalLabels | object | `{}` | Additional labels that will be added across the gateway in the format of {mylabel: "myapp"} |
| auth-server-key-rotation.dnsConfig | object | `{}` | Add custom dns config |
| auth-server-key-rotation.dnsPolicy | string | `""` | Add custom dns policy |
| auth-server-key-rotation.image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy to use for deploying. |
| auth-server-key-rotation.image.pullSecrets | list | `[]` | Image Pull Secrets |
| auth-server-key-rotation.image.repository | string | `"ghcr.io/janssenproject/jans/certmanager"` | Image  to use for deploying. |
| auth-server-key-rotation.image.tag | string | `"1.0.13_dev"` | Image  tag to use for deploying. |
| auth-server-key-rotation.keysLife | int | `48` | Auth server key rotation keys life in hours |
| auth-server-key-rotation.resources | object | `{"limits":{"cpu":"300m","memory":"300Mi"},"requests":{"cpu":"300m","memory":"300Mi"}}` | Resource specs. |
| auth-server-key-rotation.resources.limits.cpu | string | `"300m"` | CPU limit. |
| auth-server-key-rotation.resources.limits.memory | string | `"300Mi"` | Memory limit. |
| auth-server-key-rotation.resources.requests.cpu | string | `"300m"` | CPU request. |
| auth-server-key-rotation.resources.requests.memory | string | `"300Mi"` | Memory request. |
| auth-server-key-rotation.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service |
| auth-server-key-rotation.usrEnvs.normal | object | `{}` | Add custom normal envs to the service variable1: value1 |
| auth-server-key-rotation.usrEnvs.secret | object | `{}` | Add custom secret envs to the service variable1: value1 |
| auth-server-key-rotation.volumeMounts | list | `[]` | Configure any additional volumesMounts that need to be attached to the containers |
| auth-server-key-rotation.volumes | list | `[]` | Configure any additional volumes that need to be attached to the pod |
| auth-server.additionalAnnotations | object | `{}` | Additional annotations that will be added across the gateway in the format of {cert-manager.io/issuer: "letsencrypt-prod"} |
| auth-server.additionalLabels | object | `{}` | Additional labels that will be added across the gateway in the format of {mylabel: "myapp"} |
| auth-server.dnsConfig | object | `{}` | Add custom dns config |
| auth-server.dnsPolicy | string | `""` | Add custom dns policy |
| auth-server.hpa | object | `{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50}` | Configure the HorizontalPodAutoscaler |
| auth-server.hpa.behavior | object | `{}` | Scaling Policies |
| auth-server.hpa.metrics | list | `[]` | metrics if targetCPUUtilizationPercentage is not set |
| auth-server.image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy to use for deploying. |
| auth-server.image.pullSecrets | list | `[]` | Image Pull Secrets |
| auth-server.image.repository | string | `"ghcr.io/janssenproject/jans/auth-server"` | Image  to use for deploying. |
| auth-server.image.tag | string | `"1.0.13_dev"` | Image  tag to use for deploying. |
| auth-server.livenessProbe | object | `{"exec":{"command":["python3","/app/scripts/healthcheck.py"]},"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5}` | Configure the liveness healthcheck for the auth server if needed. |
| auth-server.livenessProbe.exec | object | `{"command":["python3","/app/scripts/healthcheck.py"]}` | Executes the python3 healthcheck. https://github.com/JanssenProject/docker-jans-auth-server/blob/master/scripts/healthcheck.py |
| auth-server.pdb | object | `{"enabled":true,"maxUnavailable":"90%"}` | Configure the PodDisruptionBudget |
| auth-server.readinessProbe | object | `{"exec":{"command":["python3","/app/scripts/healthcheck.py"]},"initialDelaySeconds":25,"periodSeconds":25,"timeoutSeconds":5}` | Configure the readiness healthcheck for the auth server if needed. https://github.com/JanssenProject/docker-jans-auth-server/blob/master/scripts/healthcheck.py |
| auth-server.replicas | int | `1` | Service replica number. |
| auth-server.resources | object | `{"limits":{"cpu":"2500m","memory":"2500Mi"},"requests":{"cpu":"2500m","memory":"2500Mi"}}` | Resource specs. |
| auth-server.resources.limits.cpu | string | `"2500m"` | CPU limit. |
| auth-server.resources.limits.memory | string | `"2500Mi"` | Memory limit. |
| auth-server.resources.requests.cpu | string | `"2500m"` | CPU request. |
| auth-server.resources.requests.memory | string | `"2500Mi"` | Memory request. |
| auth-server.topologySpreadConstraints | object | `{}` | Configure the topology spread constraints. Notice this is a map NOT a list as in the upstream API https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/ |
| auth-server.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service |
| auth-server.usrEnvs.normal | object | `{}` | Add custom normal envs to the service variable1: value1 |
| auth-server.usrEnvs.secret | object | `{}` | Add custom secret envs to the service variable1: value1 |
| auth-server.volumeMounts | list | `[]` | Configure any additional volumesMounts that need to be attached to the containers |
| auth-server.volumes | list | `[]` | Configure any additional volumes that need to be attached to the pod |
| casa | object | `{"additionalAnnotations":{},"additionalLabels":{},"dnsConfig":{},"dnsPolicy":"","hpa":{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50},"image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"ghcr.io/gluufederation/flex/casa","tag":"5.0.0_dev"},"lifecycle":{},"livenessProbe":{"httpGet":{"path":"/casa/health-check","port":"http-casa"},"initialDelaySeconds":25,"periodSeconds":25,"timeoutSeconds":5},"pdb":{"enabled":true,"maxUnavailable":"90%"},"readinessProbe":{"httpGet":{"path":"/casa/health-check","port":"http-casa"},"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5},"replicas":1,"resources":{"limits":{"cpu":"500m","memory":"500Mi"},"requests":{"cpu":"500m","memory":"500Mi"}},"topologySpreadConstraints":{},"usrEnvs":{"normal":{},"secret":{}},"volumeMounts":[],"volumes":[]}` | Gluu Casa ("Casa") is a self-service web portal for end-users to manage authentication and authorization preferences for their account in a Gluu Server. |
| casa.additionalAnnotations | object | `{}` | Additional annotations that will be added across the gateway in the format of {cert-manager.io/issuer: "letsencrypt-prod"} |
| casa.additionalLabels | object | `{}` | Additional labels that will be added across the gateway in the format of {mylabel: "myapp"} |
| casa.dnsConfig | object | `{}` | Add custom dns config |
| casa.dnsPolicy | string | `""` | Add custom dns policy |
| casa.hpa | object | `{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50}` | Configure the HorizontalPodAutoscaler |
| casa.hpa.behavior | object | `{}` | Scaling Policies |
| casa.hpa.metrics | list | `[]` | metrics if targetCPUUtilizationPercentage is not set |
| casa.image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy to use for deploying. |
| casa.image.pullSecrets | list | `[]` | Image Pull Secrets |
| casa.image.repository | string | `"ghcr.io/gluufederation/flex/casa"` | Image  to use for deploying. |
| casa.image.tag | string | `"5.0.0_dev"` | Image  tag to use for deploying. |
| casa.livenessProbe | object | `{"httpGet":{"path":"/casa/health-check","port":"http-casa"},"initialDelaySeconds":25,"periodSeconds":25,"timeoutSeconds":5}` | Configure the liveness healthcheck for casa if needed. |
| casa.livenessProbe.httpGet.path | string | `"/casa/health-check"` | http liveness probe endpoint |
| casa.pdb | object | `{"enabled":true,"maxUnavailable":"90%"}` | Configure the PodDisruptionBudget |
| casa.readinessProbe | object | `{"httpGet":{"path":"/casa/health-check","port":"http-casa"},"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5}` | Configure the readiness healthcheck for the casa if needed. |
| casa.readinessProbe.httpGet.path | string | `"/casa/health-check"` | http readiness probe endpoint |
| casa.replicas | int | `1` | Service replica number. |
| casa.resources | object | `{"limits":{"cpu":"500m","memory":"500Mi"},"requests":{"cpu":"500m","memory":"500Mi"}}` | Resource specs. |
| casa.resources.limits.cpu | string | `"500m"` | CPU limit. |
| casa.resources.limits.memory | string | `"500Mi"` | Memory limit. |
| casa.resources.requests.cpu | string | `"500m"` | CPU request. |
| casa.resources.requests.memory | string | `"500Mi"` | Memory request. |
| casa.topologySpreadConstraints | object | `{}` | Configure the topology spread constraints. Notice this is a map NOT a list as in the upstream API https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/ |
| casa.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service |
| casa.usrEnvs.normal | object | `{}` | Add custom normal envs to the service variable1: value1 |
| casa.usrEnvs.secret | object | `{}` | Add custom secret envs to the service variable1: value1 |
| casa.volumeMounts | list | `[]` | Configure any additional volumesMounts that need to be attached to the containers |
| casa.volumes | list | `[]` | Configure any additional volumes that need to be attached to the pod |
| config | object | `{"additionalAnnotations":{},"additionalLabels":{},"adminPassword":"Test1234#","city":"Austin","configmap":{"cnAwsAccessKeyId":"","cnAwsDefaultRegion":"us-west-1","cnAwsProfile":"gluu","cnAwsSecretAccessKey":"","cnAwsSecretsEndpointUrl":"","cnAwsSecretsNamePrefix":"gluu","cnAwsSecretsReplicaRegions":[],"cnCacheType":"NATIVE_PERSISTENCE","cnConfigKubernetesConfigMap":"cn","cnCouchbaseBucketPrefix":"jans","cnCouchbaseCrt":"SWFtTm90YVNlcnZpY2VBY2NvdW50Q2hhbmdlTWV0b09uZQo=","cnCouchbaseIndexNumReplica":0,"cnCouchbasePassword":"P@ssw0rd","cnCouchbaseSuperUser":"admin","cnCouchbaseSuperUserPassword":"Test1234#","cnCouchbaseUrl":"cbgluu.default.svc.cluster.local","cnCouchbaseUser":"gluu","cnGoogleProjectId":"google-project-to-save-config-and-secrets-to","cnGoogleSecretManagerServiceAccount":"SWFtTm90YVNlcnZpY2VBY2NvdW50Q2hhbmdlTWV0b09uZQo=","cnGoogleSecretNamePrefix":"gluu","cnGoogleSecretVersionId":"latest","cnGoogleSpannerDatabaseId":"","cnGoogleSpannerInstanceId":"","cnJettyRequestHeaderSize":8192,"cnLdapUrl":"opendj:1636","cnMaxRamPercent":"75.0","cnPersistenceHybridMapping":"{}","cnRedisSentinelGroup":"","cnRedisSslTruststore":"","cnRedisType":"STANDALONE","cnRedisUrl":"redis.redis.svc.cluster.local:6379","cnRedisUseSsl":false,"cnScimProtectionMode":"OAUTH","cnSecretKubernetesSecret":"cn","cnSqlDbDialect":"mysql","cnSqlDbHost":"my-release-mysql.default.svc.cluster.local","cnSqlDbName":"gluu","cnSqlDbPort":3306,"cnSqlDbSchema":"","cnSqlDbTimezone":"UTC","cnSqlDbUser":"gluu","cnSqldbUserPassword":"Test1234#","lbAddr":""},"countryCode":"US","dnsConfig":{},"dnsPolicy":"","email":"support@gluu.org","image":{"pullSecrets":[],"repository":"ghcr.io/janssenproject/jans/configurator","tag":"1.0.13_dev"},"ldapPassword":"P@ssw0rds","lifecycle":{},"migration":{"enabled":false,"migrationDataFormat":"ldif","migrationDir":"/ce-migration"},"orgName":"Gluu","redisPassword":"P@assw0rd","resources":{"limits":{"cpu":"300m","memory":"300Mi"},"requests":{"cpu":"300m","memory":"300Mi"}},"state":"TX","usrEnvs":{"normal":{},"secret":{}},"volumeMounts":[],"volumes":[]}` | Configuration parameters for setup and initial configuration secret and config layers used by Gluu services. |
| config-api | object | `{"additionalAnnotations":{},"additionalLabels":{},"dnsConfig":{},"dnsPolicy":"","hpa":{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50},"image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"ghcr.io/janssenproject/jans/config-api","tag":"1.0.13_dev"},"lifecycle":{},"livenessProbe":{"httpGet":{"path":"/jans-config-api/api/v1/health/live","port":8074},"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5},"pdb":{"enabled":true,"maxUnavailable":"90%"},"readinessProbe":{"httpGet":{"path":"jans-config-api/api/v1/health/ready","port":8074},"initialDelaySeconds":25,"periodSeconds":25,"timeoutSeconds":5},"replicas":1,"resources":{"limits":{"cpu":"1000m","memory":"1000Mi"},"requests":{"cpu":"1000m","memory":"1000Mi"}},"topologySpreadConstraints":{},"usrEnvs":{"normal":{},"secret":{}},"volumeMounts":[],"volumes":[]}` | Config Api endpoints can be used to configure the auth-server, which is an open-source OpenID Connect Provider (OP) and UMA Authorization Server (AS). |
| config-api.additionalAnnotations | object | `{}` | Additional annotations that will be added across the gateway in the format of {cert-manager.io/issuer: "letsencrypt-prod"} |
| config-api.additionalLabels | object | `{}` | Additional labels that will be added across the gateway in the format of {mylabel: "myapp"} |
| config-api.dnsConfig | object | `{}` | Add custom dns config |
| config-api.dnsPolicy | string | `""` | Add custom dns policy |
| config-api.hpa | object | `{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50}` | Configure the HorizontalPodAutoscaler |
| config-api.hpa.behavior | object | `{}` | Scaling Policies |
| config-api.hpa.metrics | list | `[]` | metrics if targetCPUUtilizationPercentage is not set |
| config-api.image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy to use for deploying. |
| config-api.image.pullSecrets | list | `[]` | Image Pull Secrets |
| config-api.image.repository | string | `"ghcr.io/janssenproject/jans/config-api"` | Image  to use for deploying. |
| config-api.image.tag | string | `"1.0.13_dev"` | Image  tag to use for deploying. |
| config-api.livenessProbe | object | `{"httpGet":{"path":"/jans-config-api/api/v1/health/live","port":8074},"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5}` | Configure the liveness healthcheck for the auth server if needed. |
| config-api.livenessProbe.httpGet | object | `{"path":"/jans-config-api/api/v1/health/live","port":8074}` | http liveness probe endpoint |
| config-api.pdb | object | `{"enabled":true,"maxUnavailable":"90%"}` | Configure the PodDisruptionBudget |
| config-api.readinessProbe.httpGet | object | `{"path":"jans-config-api/api/v1/health/ready","port":8074}` | http readiness probe endpoint |
| config-api.replicas | int | `1` | Service replica number. |
| config-api.resources | object | `{"limits":{"cpu":"1000m","memory":"1000Mi"},"requests":{"cpu":"1000m","memory":"1000Mi"}}` | Resource specs. |
| config-api.resources.limits.cpu | string | `"1000m"` | CPU limit. |
| config-api.resources.limits.memory | string | `"1000Mi"` | Memory limit. |
| config-api.resources.requests.cpu | string | `"1000m"` | CPU request. |
| config-api.resources.requests.memory | string | `"1000Mi"` | Memory request. |
| config-api.topologySpreadConstraints | object | `{}` | Configure the topology spread constraints. Notice this is a map NOT a list as in the upstream API https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/ |
| config-api.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service |
| config-api.usrEnvs.normal | object | `{}` | Add custom normal envs to the service variable1: value1 |
| config-api.usrEnvs.secret | object | `{}` | Add custom secret envs to the service variable1: value1 |
| config-api.volumeMounts | list | `[]` | Configure any additional volumesMounts that need to be attached to the containers |
| config-api.volumes | list | `[]` | Configure any additional volumes that need to be attached to the pod |
| config.additionalAnnotations | object | `{}` | Additional annotations that will be added across the gateway in the format of {cert-manager.io/issuer: "letsencrypt-prod"} |
| config.additionalLabels | object | `{}` | Additional labels that will be added across the gateway in the format of {mylabel: "myapp"} |
| config.adminPassword | string | `"Test1234#"` | Admin password to log in to the UI. |
| config.city | string | `"Austin"` | City. Used for certificate creation. |
| config.configmap.cnCacheType | string | `"NATIVE_PERSISTENCE"` | Cache type. `NATIVE_PERSISTENCE`, `REDIS`. or `IN_MEMORY`. Defaults to `NATIVE_PERSISTENCE` . |
| config.configmap.cnConfigKubernetesConfigMap | string | `"cn"` | The name of the Kubernetes ConfigMap that will hold the configuration layer |
| config.configmap.cnCouchbaseBucketPrefix | string | `"jans"` | The prefix of couchbase buckets. This helps with separation in between different environments and allows for the same couchbase cluster to be used by different setups of Gluu. |
| config.configmap.cnCouchbaseCrt | string | `"SWFtTm90YVNlcnZpY2VBY2NvdW50Q2hhbmdlTWV0b09uZQo="` | Couchbase certificate authority string. This must be encoded using base64. This can also be found in your couchbase UI Security > Root Certificate. In mTLS setups this is not required. |
| config.configmap.cnCouchbaseIndexNumReplica | int | `0` | The number of replicas per index created. Please note that the number of index nodes must be one greater than the number of index replicas. That means if your couchbase cluster only has 2 index nodes you cannot place the number of replicas to be higher than 1. |
| config.configmap.cnCouchbasePassword | string | `"P@ssw0rd"` | Couchbase password for the restricted user config.configmap.cnCouchbaseUser  that is often used inside the services. The password must contain one digit, one uppercase letter, one lower case letter and one symbol . |
| config.configmap.cnCouchbaseSuperUser | string | `"admin"` | The Couchbase super user (admin) username. This user is used during initialization only. |
| config.configmap.cnCouchbaseSuperUserPassword | string | `"Test1234#"` | Couchbase password for the superuser config.configmap.cnCouchbaseSuperUser  that is used during the initialization process. The password must contain one digit, one uppercase letter, one lower case letter and one symbol |
| config.configmap.cnCouchbaseUrl | string | `"cbgluu.default.svc.cluster.local"` | Couchbase URL. Used only when global.cnPersistenceType is hybrid or couchbase. This should be in FQDN format for either remote or local Couchbase clusters. The address can be an internal address inside the kubernetes cluster |
| config.configmap.cnCouchbaseUser | string | `"gluu"` | Couchbase restricted user. Used only when global.cnPersistenceType is hybrid or couchbase. |
| config.configmap.cnGoogleProjectId | string | `"google-project-to-save-config-and-secrets-to"` | Project id of the Google project the secret manager belongs to. Used only when global.configAdapterName and global.configSecretAdapter is set to google. |
| config.configmap.cnGoogleSecretManagerServiceAccount | string | `"SWFtTm90YVNlcnZpY2VBY2NvdW50Q2hhbmdlTWV0b09uZQo="` | Service account with roles roles/secretmanager.admin base64 encoded string. This is used often inside the services to reach the configuration layer. Used only when global.configAdapterName and global.configSecretAdapter is set to google. |
| config.configmap.cnGoogleSecretNamePrefix | string | `"gluu"` | Prefix for Gluu secret in Google Secret Manager. Defaults to gluu. If left gluu-secret secret will be created. Used only when global.configAdapterName and global.configSecretAdapter is set to google. |
| config.configmap.cnGoogleSecretVersionId | string | `"latest"` | Secret version to be used for secret configuration. Defaults to latest and should normally always stay that way. Used only when global.configAdapterName and global.configSecretAdapter is set to google. |
| config.configmap.cnGoogleSpannerDatabaseId | string | `""` | Google Spanner Database ID. Used only when global.cnPersistenceType is spanner. |
| config.configmap.cnGoogleSpannerInstanceId | string | `""` | Google Spanner ID. Used only when global.cnPersistenceType is spanner. |
| config.configmap.cnJettyRequestHeaderSize | int | `8192` | Jetty header size in bytes in the auth server |
| config.configmap.cnLdapUrl | string | `"opendj:1636"` | OpenDJ internal address. Leave as default. Used when `global.cnPersistenceType` is set to `ldap`. |
| config.configmap.cnMaxRamPercent | string | `"75.0"` | Value passed to Java option -XX:MaxRAMPercentage |
| config.configmap.cnPersistenceHybridMapping | string | `"{}"` | Specify data that should be saved in LDAP (one of default, user, cache, site, token, or session; default to default). Note this environment only takes effect when `global.cnPersistenceType`  is set to `hybrid`. {  "default": "<couchbase|ldap|spanner|sql>",  "user": "<couchbase|ldap|spanner|sql>",  "site": "<couchbase|ldap|spanner|sql>",  "cache": "<couchbase|ldap|spanner|sql>",  "token": "<couchbase|ldap|spanner|sql>",  "session": "<couchbase|ldap|spanner|sql>", } |
| config.configmap.cnRedisSentinelGroup | string | `""` | Redis Sentinel Group. Often set when `config.configmap.cnRedisType` is set to `SENTINEL`. Can be used when  `config.configmap.cnCacheType` is set to `REDIS`. |
| config.configmap.cnRedisSslTruststore | string | `""` | Redis SSL truststore. Optional. Can be used when  `config.configmap.cnCacheType` is set to `REDIS`. |
| config.configmap.cnRedisType | string | `"STANDALONE"` | Redis service type. `STANDALONE` or `CLUSTER`. Can be used when  `config.configmap.cnCacheType` is set to `REDIS`. |
| config.configmap.cnRedisUrl | string | `"redis.redis.svc.cluster.local:6379"` | Redis URL and port number <url>:<port>. Can be used when  `config.configmap.cnCacheType` is set to `REDIS`. |
| config.configmap.cnRedisUseSsl | bool | `false` | Boolean to use SSL in Redis. Can be used when  `config.configmap.cnCacheType` is set to `REDIS`. |
| config.configmap.cnScimProtectionMode | string | `"OAUTH"` | SCIM protection mode OAUTH|TEST|UMA |
| config.configmap.cnSecretKubernetesSecret | string | `"cn"` | Kubernetes secret name holding configuration keys. Used when global.configSecretAdapter is set to kubernetes which is the default. |
| config.configmap.cnSqlDbDialect | string | `"mysql"` | SQL database dialect. `mysql` or `pgsql` |
| config.configmap.cnSqlDbHost | string | `"my-release-mysql.default.svc.cluster.local"` | SQL database host uri. |
| config.configmap.cnSqlDbName | string | `"gluu"` | SQL database name. |
| config.configmap.cnSqlDbPort | int | `3306` | SQL database port. |
| config.configmap.cnSqlDbSchema | string | `""` | Schema name used by SQL database (default to empty-string; if using MySQL, the schema name will be resolved as the database name, whereas in PostgreSQL the schema name will be resolved as `"public"`). |
| config.configmap.cnSqlDbTimezone | string | `"UTC"` | SQL database timezone. |
| config.configmap.cnSqlDbUser | string | `"gluu"` | SQL database username. |
| config.configmap.cnSqldbUserPassword | string | `"Test1234#"` | SQL password  injected the secrets . |
| config.configmap.lbAddr | string | `""` | Load balancer address for AWS if the FQDN is not registered. |
| config.countryCode | string | `"US"` | Country code. Used for certificate creation. |
| config.dnsConfig | object | `{}` | Add custom dns config |
| config.dnsPolicy | string | `""` | Add custom dns policy |
| config.email | string | `"support@gluu.org"` | Email address of the administrator usually. Used for certificate creation. |
| config.image.pullSecrets | list | `[]` | Image Pull Secrets |
| config.image.repository | string | `"ghcr.io/janssenproject/jans/configurator"` | Image  to use for deploying. |
| config.image.tag | string | `"1.0.13_dev"` | Image  tag to use for deploying. |
| config.ldapPassword | string | `"P@ssw0rds"` | LDAP admin password if OpenDJ is used for persistence. |
| config.migration | object | `{"enabled":false,"migrationDataFormat":"ldif","migrationDir":"/ce-migration"}` | CE to CN Migration section |
| config.migration.enabled | bool | `false` | Boolean flag to enable migration from CE |
| config.migration.migrationDataFormat | string | `"ldif"` | migration data-format depending on persistence backend. Supported data formats are ldif, couchbase+json, spanner+avro, postgresql+json, and mysql+json. |
| config.migration.migrationDir | string | `"/ce-migration"` | Directory holding all migration files |
| config.orgName | string | `"Gluu"` | Organization name. Used for certificate creation. |
| config.redisPassword | string | `"P@assw0rd"` | Redis admin password if `config.configmap.cnCacheType` is set to `REDIS`. |
| config.resources | object | `{"limits":{"cpu":"300m","memory":"300Mi"},"requests":{"cpu":"300m","memory":"300Mi"}}` | Resource specs. |
| config.resources.limits.cpu | string | `"300m"` | CPU limit. |
| config.resources.limits.memory | string | `"300Mi"` | Memory limit. |
| config.resources.requests.cpu | string | `"300m"` | CPU request. |
| config.resources.requests.memory | string | `"300Mi"` | Memory request. |
| config.state | string | `"TX"` | State code. Used for certificate creation. |
| config.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service. |
| config.usrEnvs.normal | object | `{}` | Add custom normal envs to the service. variable1: value1 |
| config.usrEnvs.secret | object | `{}` | Add custom secret envs to the service. variable1: value1 |
| config.volumeMounts | list | `[]` | Configure any additional volumesMounts that need to be attached to the containers |
| config.volumes | list | `[]` | Configure any additional volumes that need to be attached to the pod |
| fido2 | object | `{"additionalAnnotations":{},"additionalLabels":{},"dnsConfig":{},"dnsPolicy":"","hpa":{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50},"image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"ghcr.io/janssenproject/jans/fido2","tag":"1.0.13_dev"},"lifecycle":{},"livenessProbe":{"httpGet":{"path":"/jans-fido2/sys/health-check","port":"http-fido2"},"initialDelaySeconds":25,"periodSeconds":25,"timeoutSeconds":5},"pdb":{"enabled":true,"maxUnavailable":"90%"},"readinessProbe":{"httpGet":{"path":"/jans-fido2/sys/health-check","port":"http-fido2"},"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5},"replicas":1,"resources":{"limits":{"cpu":"500m","memory":"500Mi"},"requests":{"cpu":"500m","memory":"500Mi"}},"service":{"name":"http-fido2","port":8080},"topologySpreadConstraints":{},"usrEnvs":{"normal":{},"secret":{}},"volumeMounts":[],"volumes":[]}` | FIDO 2.0 (FIDO2) is an open authentication standard that enables leveraging common devices to authenticate to online services in both mobile and desktop environments. |
| fido2.additionalAnnotations | object | `{}` | Additional annotations that will be added across the gateway in the format of {cert-manager.io/issuer: "letsencrypt-prod"} |
| fido2.additionalLabels | object | `{}` | Additional labels that will be added across the gateway in the format of {mylabel: "myapp"} |
| fido2.dnsConfig | object | `{}` | Add custom dns config |
| fido2.dnsPolicy | string | `""` | Add custom dns policy |
| fido2.hpa | object | `{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50}` | Configure the HorizontalPodAutoscaler |
| fido2.hpa.behavior | object | `{}` | Scaling Policies |
| fido2.hpa.metrics | list | `[]` | metrics if targetCPUUtilizationPercentage is not set |
| fido2.image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy to use for deploying. |
| fido2.image.pullSecrets | list | `[]` | Image Pull Secrets |
| fido2.image.repository | string | `"ghcr.io/janssenproject/jans/fido2"` | Image  to use for deploying. |
| fido2.image.tag | string | `"1.0.13_dev"` | Image  tag to use for deploying. |
| fido2.livenessProbe | object | `{"httpGet":{"path":"/jans-fido2/sys/health-check","port":"http-fido2"},"initialDelaySeconds":25,"periodSeconds":25,"timeoutSeconds":5}` | Configure the liveness healthcheck for the fido2 if needed. |
| fido2.livenessProbe.httpGet | object | `{"path":"/jans-fido2/sys/health-check","port":"http-fido2"}` | http liveness probe endpoint |
| fido2.pdb | object | `{"enabled":true,"maxUnavailable":"90%"}` | Configure the PodDisruptionBudget |
| fido2.readinessProbe | object | `{"httpGet":{"path":"/jans-fido2/sys/health-check","port":"http-fido2"},"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5}` | Configure the readiness healthcheck for the fido2 if needed. |
| fido2.replicas | int | `1` | Service replica number. |
| fido2.resources | object | `{"limits":{"cpu":"500m","memory":"500Mi"},"requests":{"cpu":"500m","memory":"500Mi"}}` | Resource specs. |
| fido2.resources.limits.cpu | string | `"500m"` | CPU limit. |
| fido2.resources.limits.memory | string | `"500Mi"` | Memory limit. |
| fido2.resources.requests.cpu | string | `"500m"` | CPU request. |
| fido2.resources.requests.memory | string | `"500Mi"` | Memory request. |
| fido2.service.name | string | `"http-fido2"` | The name of the fido2 port within the fido2 service. Please keep it as default. |
| fido2.service.port | int | `8080` | Port of the fido2 service. Please keep it as default. |
| fido2.topologySpreadConstraints | object | `{}` | Configure the topology spread constraints. Notice this is a map NOT a list as in the upstream API https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/ |
| fido2.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service |
| fido2.usrEnvs.normal | object | `{}` | Add custom normal envs to the service variable1: value1 |
| fido2.usrEnvs.secret | object | `{}` | Add custom secret envs to the service variable1: value1 |
| fido2.volumeMounts | list | `[]` | Configure any additional volumesMounts that need to be attached to the containers |
| fido2.volumes | list | `[]` | Configure any additional volumes that need to be attached to the pod |
| global | object | `{"admin-ui":{"adminUiServiceName":"admin-ui","enabled":true,"ingress":{"adminUiEnabled":false}},"alb":{"ingress":false},"auth-server":{"appLoggers":{"auditStatsLogLevel":"INFO","auditStatsLogTarget":"FILE","authLogLevel":"INFO","authLogTarget":"STDOUT","enableStdoutLogPrefix":"true","httpLogLevel":"INFO","httpLogTarget":"FILE","ldapStatsLogLevel":"INFO","ldapStatsLogTarget":"FILE","persistenceDurationLogLevel":"INFO","persistenceDurationLogTarget":"FILE","persistenceLogLevel":"INFO","persistenceLogTarget":"FILE","scriptLogLevel":"INFO","scriptLogTarget":"FILE"},"authEncKeys":"RSA1_5 RSA-OAEP","authServerServiceName":"auth-server","authSigKeys":"RS256 RS384 RS512 ES256 ES384 ES512 PS256 PS384 PS512","enabled":true,"ingress":{"authServerEnabled":true,"authServerProtectedRegister":false,"authServerProtectedToken":false,"deviceCodeEnabled":true,"firebaseMessagingEnabled":true,"openidConfigEnabled":true,"u2fConfigEnabled":true,"uma2ConfigEnabled":true,"webdiscoveryEnabled":true,"webfingerEnabled":true}},"auth-server-key-rotation":{"enabled":false},"awsStorageType":"io1","azureStorageAccountType":"Standard_LRS","azureStorageKind":"Managed","casa":{"appLoggers":{"casaLogLevel":"INFO","casaLogTarget":"STDOUT","enableStdoutLogPrefix":"true","timerLogLevel":"INFO","timerLogTarget":"FILE"},"casaServiceName":"casa","enabled":true,"ingress":{"casaEnabled":false}},"cloud":{"testEnviroment":false},"cnAwsConfigFile":"/etc/jans/conf/aws_config_file","cnAwsSecretsReplicaRegionsFile":"/etc/jans/conf/aws_secrets_replica_regions","cnAwsSharedCredentialsFile":"/etc/jans/conf/aws_shared_credential_file","cnDocumentStoreType":"LOCAL","cnGoogleApplicationCredentials":"/etc/jans/conf/google-credentials.json","cnObExtSigningAlias":"","cnObExtSigningJwksCrt":"","cnObExtSigningJwksKey":"","cnObExtSigningJwksKeyPassPhrase":"","cnObExtSigningJwksUri":"","cnObStaticSigningKeyKid":"","cnObTransportAlias":"","cnObTransportCrt":"","cnObTransportKey":"","cnObTransportKeyPassPhrase":"","cnObTransportTrustStore":"","cnPersistenceType":"sql","cnPrometheusPort":"","config":{"enabled":true},"config-api":{"adminUiAppLoggers":{"adminUiAuditLogLevel":"INFO","adminUiAuditLogTarget":"FILE","adminUiLogLevel":"INFO","adminUiLogTarget":"FILE","enableStdoutLogPrefix":"true"},"appLoggers":{"configApiLogLevel":"INFO","configApiLogTarget":"STDOUT","enableStdoutLogPrefix":"true","ldapStatsLogLevel":"INFO","ldapStatsLogTarget":"FILE","persistenceDurationLogLevel":"INFO","persistenceDurationLogTarget":"FILE","persistenceLogLevel":"INFO","persistenceLogTarget":"FILE","scriptLogLevel":"INFO","scriptLogTarget":"FILE"},"configApiServerServiceName":"config-api","enabled":true,"ingress":{"configApiEnabled":true}},"configAdapterName":"kubernetes","configSecretAdapter":"kubernetes","distribution":"default","fido2":{"appLoggers":{"enableStdoutLogPrefix":"true","fido2LogLevel":"INFO","fido2LogTarget":"STDOUT","persistenceDurationLogLevel":"INFO","persistenceDurationLogTarget":"FILE","persistenceLogLevel":"INFO","persistenceLogTarget":"FILE","scriptLogLevel":"INFO","scriptLogTarget":"FILE"},"enabled":true,"fido2ServiceName":"fido2","ingress":{"fido2ConfigEnabled":false}},"fqdn":"demoexample.gluu.org","gcePdStorageType":"pd-standard","isFqdnRegistered":false,"istio":{"additionalAnnotations":{},"additionalLabels":{},"enabled":false,"gateways":[],"ingress":false,"namespace":"istio-system"},"jobTtlSecondsAfterFinished":300,"lbIp":"22.22.22.22","licenseSsa":"","nginx-ingress":{"enabled":true},"opendj":{"enabled":false,"ldapServiceName":"opendj"},"oxpassport":{"enabled":false,"oxPassportServiceName":"oxpassport"},"oxshibboleth":{"appLoggers":{"auditStatsLogLevel":"INFO","auditStatsLogTarget":"FILE","consentAuditLogLevel":"INFO","consentAuditLogTarget":"FILE","containerLogLevel":"","encryptionLogLevel":"","httpclientLogLevel":"","idpLogLevel":"INFO","idpLogTarget":"STDOUT","ldapLogLevel":"","messagesLogLevel":"","opensamlLogLevel":"","propsLogLevel":"","scriptLogLevel":"INFO","scriptLogTarget":"FILE","springLogLevel":"","xmlsecLogLevel":""},"enabled":false,"oxShibbolethServiceName":"oxshibboleth"},"persistence":{"enabled":true},"scim":{"appLoggers":{"enableStdoutLogPrefix":"true","ldapStatsLogLevel":"INFO","ldapStatsLogTarget":"FILE","persistenceDurationLogLevel":"INFO","persistenceDurationLogTarget":"FILE","persistenceLogLevel":"INFO","persistenceLogTarget":"FILE","scimLogLevel":"INFO","scimLogTarget":"STDOUT","scriptLogLevel":"INFO","scriptLogTarget":"FILE"},"enabled":true,"ingress":{"scimConfigEnabled":false,"scimEnabled":false},"scimServiceName":"scim"},"storageClass":{"allowVolumeExpansion":true,"allowedTopologies":[],"mountOptions":["debug"],"parameters":{},"provisioner":"microk8s.io/hostpath","reclaimPolicy":"Retain","volumeBindingMode":"WaitForFirstConsumer"},"usrEnvs":{"normal":{},"secret":{}}}` | Parameters used globally across all services helm charts. |
| global.admin-ui.adminUiServiceName | string | `"admin-ui"` | Name of the admin-ui service. Please keep it as default. |
| global.admin-ui.enabled | bool | `true` | Boolean flag to enable/disable the admin-ui chart and admin ui config api plugin. |
| global.admin-ui.ingress.adminUiEnabled | bool | `false` | Enable Admin UI endpoints in either istio or nginx ingress depending on users choice |
| global.alb.ingress | bool | `false` | Activates ALB ingress |
| global.auth-server-key-rotation.enabled | bool | `false` | Boolean flag to enable/disable the auth-server-key rotation cronjob chart. |
| global.auth-server.appLoggers | object | `{"auditStatsLogLevel":"INFO","auditStatsLogTarget":"FILE","authLogLevel":"INFO","authLogTarget":"STDOUT","enableStdoutLogPrefix":"true","httpLogLevel":"INFO","httpLogTarget":"FILE","ldapStatsLogLevel":"INFO","ldapStatsLogTarget":"FILE","persistenceDurationLogLevel":"INFO","persistenceDurationLogTarget":"FILE","persistenceLogLevel":"INFO","persistenceLogTarget":"FILE","scriptLogLevel":"INFO","scriptLogTarget":"FILE"}` | App loggers can be configured to define where the logs will be redirected to and the level of each in which it should be displayed. |
| global.auth-server.appLoggers.auditStatsLogLevel | string | `"INFO"` | jans-auth_audit.log level |
| global.auth-server.appLoggers.auditStatsLogTarget | string | `"FILE"` | jans-auth_script.log target |
| global.auth-server.appLoggers.authLogLevel | string | `"INFO"` | jans-auth.log level |
| global.auth-server.appLoggers.authLogTarget | string | `"STDOUT"` | jans-auth.log target |
| global.auth-server.appLoggers.enableStdoutLogPrefix | string | `"true"` | Enable log prefixing which enables prepending the STDOUT logs with the file name. i.e auth-server-script ===> 2022-12-20 17:49:55,744 INFO |
| global.auth-server.appLoggers.httpLogLevel | string | `"INFO"` | http_request_response.log level |
| global.auth-server.appLoggers.httpLogTarget | string | `"FILE"` | http_request_response.log target |
| global.auth-server.appLoggers.ldapStatsLogLevel | string | `"INFO"` | jans-auth_persistence_ldap_statistics.log level |
| global.auth-server.appLoggers.ldapStatsLogTarget | string | `"FILE"` | jans-auth_persistence_ldap_statistics.log target |
| global.auth-server.appLoggers.persistenceDurationLogLevel | string | `"INFO"` | jans-auth_persistence_duration.log level |
| global.auth-server.appLoggers.persistenceDurationLogTarget | string | `"FILE"` | jans-auth_persistence_duration.log target |
| global.auth-server.appLoggers.persistenceLogLevel | string | `"INFO"` | jans-auth_persistence.log level |
| global.auth-server.appLoggers.persistenceLogTarget | string | `"FILE"` | jans-auth_persistence.log target |
| global.auth-server.appLoggers.scriptLogLevel | string | `"INFO"` | jans-auth_script.log level |
| global.auth-server.appLoggers.scriptLogTarget | string | `"FILE"` | jans-auth_script.log target |
| global.auth-server.authEncKeys | string | `"RSA1_5 RSA-OAEP"` | space-separated key algorithm for encryption (default to `RSA1_5 RSA-OAEP`) |
| global.auth-server.authServerServiceName | string | `"auth-server"` | Name of the auth-server service. Please keep it as default. |
| global.auth-server.authSigKeys | string | `"RS256 RS384 RS512 ES256 ES384 ES512 PS256 PS384 PS512"` | space-separated key algorithm for signing (default to `RS256 RS384 RS512 ES256 ES384 ES512 PS256 PS384 PS512`) |
| global.auth-server.enabled | bool | `true` | Boolean flag to enable/disable auth-server chart. You should never set this to false. |
| global.auth-server.ingress | object | `{"authServerEnabled":true,"authServerProtectedRegister":false,"authServerProtectedToken":false,"deviceCodeEnabled":true,"firebaseMessagingEnabled":true,"openidConfigEnabled":true,"u2fConfigEnabled":true,"uma2ConfigEnabled":true,"webdiscoveryEnabled":true,"webfingerEnabled":true}` | Enable endpoints in either istio or nginx ingress depending on users choice |
| global.auth-server.ingress.authServerEnabled | bool | `true` | Enable Auth server endpoints /jans-auth |
| global.auth-server.ingress.authServerProtectedRegister | bool | `false` | Enable mTLS onn Auth server endpoint /jans-auth/restv1/register. Currently not working in Istio. |
| global.auth-server.ingress.authServerProtectedToken | bool | `false` | Enable mTLS on Auth server endpoint /jans-auth/restv1/token. Currently not working in Istio. |
| global.auth-server.ingress.deviceCodeEnabled | bool | `true` | Enable endpoint /device-code |
| global.auth-server.ingress.firebaseMessagingEnabled | bool | `true` | Enable endpoint /firebase-messaging-sw.js |
| global.auth-server.ingress.openidConfigEnabled | bool | `true` | Enable endpoint /.well-known/openid-configuration |
| global.auth-server.ingress.u2fConfigEnabled | bool | `true` | Enable endpoint /.well-known/fido-configuration |
| global.auth-server.ingress.uma2ConfigEnabled | bool | `true` | Enable endpoint /.well-known/uma2-configuration |
| global.auth-server.ingress.webdiscoveryEnabled | bool | `true` | Enable endpoint /.well-known/simple-web-discovery |
| global.auth-server.ingress.webfingerEnabled | bool | `true` | Enable endpoint /.well-known/webfinger |
| global.awsStorageType | string | `"io1"` | Volume storage type if using AWS volumes. |
| global.azureStorageAccountType | string | `"Standard_LRS"` | Volume storage type if using Azure disks. |
| global.azureStorageKind | string | `"Managed"` | Azure storage kind if using Azure disks |
| global.casa.appLoggers | object | `{"casaLogLevel":"INFO","casaLogTarget":"STDOUT","enableStdoutLogPrefix":"true","timerLogLevel":"INFO","timerLogTarget":"FILE"}` | App loggers can be configured to define where the logs will be redirected to and the level of each in which it should be displayed. |
| global.casa.appLoggers.casaLogLevel | string | `"INFO"` | casa.log level |
| global.casa.appLoggers.casaLogTarget | string | `"STDOUT"` | casa.log target |
| global.casa.appLoggers.enableStdoutLogPrefix | string | `"true"` | Enable log prefixing which enables prepending the STDOUT logs with the file name. i.e casa ===> 2022-12-20 17:49:55,744 INFO |
| global.casa.appLoggers.timerLogLevel | string | `"INFO"` | casa timer log level |
| global.casa.appLoggers.timerLogTarget | string | `"FILE"` | casa timer log target |
| global.casa.casaServiceName | string | `"casa"` | Name of the casa service. Please keep it as default. |
| global.casa.enabled | bool | `true` | Boolean flag to enable/disable the casa chart. |
| global.casa.ingress | object | `{"casaEnabled":false}` | Enable endpoints in either istio or nginx ingress depending on users choice |
| global.casa.ingress.casaEnabled | bool | `false` | Enable casa endpoints /casa |
| global.cloud.testEnviroment | bool | `false` | Boolean flag if enabled will strip resources requests and limits from all services. |
| global.cnDocumentStoreType | string | `"LOCAL"` | Document store type to use for shibboleth files LOCAL. |
| global.cnGoogleApplicationCredentials | string | `"/etc/jans/conf/google-credentials.json"` | Base64 encoded service account. The sa must have roles/secretmanager.admin to use Google secrets and roles/spanner.databaseUser to use Spanner. Leave as this is a sensible default. |
| global.cnObExtSigningAlias | string | `""` | Open banking external signing AS Alias. This is a kid value.Used in SSA Validation, kid used while encoding a JWT sent to token URL i.e. XkwIzWy44xWSlcWnMiEc8iq9s2G |
| global.cnObExtSigningJwksCrt | string | `""` | Open banking external signing jwks AS certificate authority string. Used in SSA Validation. This must be encoded using base64.. Used when `.global.cnObExtSigningJwksUri` is set. |
| global.cnObExtSigningJwksKey | string | `""` | Open banking external signing jwks AS key string. Used in SSA Validation. This must be encoded using base64. Used when `.global.cnObExtSigningJwksUri` is set. |
| global.cnObExtSigningJwksKeyPassPhrase | string | `""` | Open banking external signing jwks AS key passphrase to unlock provided key. This must be encoded using base64. Used when `.global.cnObExtSigningJwksUri` is set. |
| global.cnObExtSigningJwksUri | string | `""` | Open banking external signing jwks uri. Used in SSA Validation. |
| global.cnObStaticSigningKeyKid | string | `""` | Open banking  signing AS kid to force the AS to use a specific signing key. i.e. Wy44xWSlcWnMiEc8iq9s2G |
| global.cnObTransportAlias | string | `""` | Open banking transport Alias used inside the JVM. |
| global.cnObTransportCrt | string | `""` | Open banking AS transport crt. Used in SSA Validation. This must be encoded using base64. |
| global.cnObTransportKey | string | `""` | Open banking AS transport key. Used in SSA Validation. This must be encoded using base64. |
| global.cnObTransportKeyPassPhrase | string | `""` | Open banking AS transport key passphrase to unlock AS transport key. This must be encoded using base64. |
| global.cnObTransportTrustStore | string | `""` | Open banking AS transport truststore crt. This is normally generated from the OB issuing CA, OB Root CA and Signing CA. Used when .global.cnObExtSigningJwksUri is set. Used in SSA Validation. This must be encoded using base64. |
| global.cnPersistenceType | string | `"sql"` | Persistence backend to run Gluu with ldap|couchbase|hybrid|sql|spanner. |
| global.cnPrometheusPort | string | `""` | Port used by Prometheus JMX agent (default to empty string). To enable Prometheus JMX agent, set the value to a number. |
| global.config-api.adminUiAppLoggers.adminUiAuditLogLevel | string | `"INFO"` | config-api admin-ui plugin audit log level |
| global.config-api.adminUiAppLoggers.adminUiAuditLogTarget | string | `"FILE"` | config-api admin-ui plugin audit log target |
| global.config-api.adminUiAppLoggers.adminUiLogLevel | string | `"INFO"` | config-api admin-ui plugin log target |
| global.config-api.adminUiAppLoggers.adminUiLogTarget | string | `"FILE"` | config-api admin-ui plugin log level |
| global.config-api.adminUiAppLoggers.enableStdoutLogPrefix | string | `"true"` | Enable log prefixing which enables prepending the STDOUT logs with the file name. i.e config-api_persistence ===> 2022-12-20 17:49:55,744 INFO |
| global.config-api.appLoggers | object | `{"configApiLogLevel":"INFO","configApiLogTarget":"STDOUT","enableStdoutLogPrefix":"true","ldapStatsLogLevel":"INFO","ldapStatsLogTarget":"FILE","persistenceDurationLogLevel":"INFO","persistenceDurationLogTarget":"FILE","persistenceLogLevel":"INFO","persistenceLogTarget":"FILE","scriptLogLevel":"INFO","scriptLogTarget":"FILE"}` | App loggers can be configured to define where the logs will be redirected to and the level of each in which it should be displayed. |
| global.config-api.appLoggers.configApiLogLevel | string | `"INFO"` | configapi.log level |
| global.config-api.appLoggers.configApiLogTarget | string | `"STDOUT"` | configapi.log target |
| global.config-api.appLoggers.enableStdoutLogPrefix | string | `"true"` | Enable log prefixing which enables prepending the STDOUT logs with the file name. i.e config-api_persistence ===> 2022-12-20 17:49:55,744 INFO |
| global.config-api.appLoggers.ldapStatsLogLevel | string | `"INFO"` | config-api_persistence_ldap_statistics.log level |
| global.config-api.appLoggers.ldapStatsLogTarget | string | `"FILE"` | config-api_persistence_ldap_statistics.log target |
| global.config-api.appLoggers.persistenceDurationLogLevel | string | `"INFO"` | config-api_persistence_duration.log level |
| global.config-api.appLoggers.persistenceDurationLogTarget | string | `"FILE"` | config-api_persistence_duration.log target |
| global.config-api.appLoggers.persistenceLogLevel | string | `"INFO"` | config-api_persistence.log level |
| global.config-api.appLoggers.persistenceLogTarget | string | `"FILE"` | config-api_persistence.log target |
| global.config-api.appLoggers.scriptLogLevel | string | `"INFO"` | config-api_script.log level |
| global.config-api.appLoggers.scriptLogTarget | string | `"FILE"` | config-api_script.log target |
| global.config-api.configApiServerServiceName | string | `"config-api"` | Name of the config-api service. Please keep it as default. |
| global.config-api.enabled | bool | `true` | Boolean flag to enable/disable the config-api chart. |
| global.config-api.ingress | object | `{"configApiEnabled":true}` | Enable endpoints in either istio or nginx ingress depending on users choice |
| global.config.enabled | bool | `true` | Boolean flag to enable/disable the configuration chart. This normally should never be false |
| global.configAdapterName | string | `"kubernetes"` | The config backend adapter that will hold Gluu configuration layer. aws|google|kubernetes |
| global.configSecretAdapter | string | `"kubernetes"` | The config backend adapter that will hold Gluu secret layer. aws|google|kubernetes |
| global.distribution | string | `"default"` | Gluu distributions supported are: default|openbanking. |
| global.fido2.appLoggers | object | `{"enableStdoutLogPrefix":"true","fido2LogLevel":"INFO","fido2LogTarget":"STDOUT","persistenceDurationLogLevel":"INFO","persistenceDurationLogTarget":"FILE","persistenceLogLevel":"INFO","persistenceLogTarget":"FILE","scriptLogLevel":"INFO","scriptLogTarget":"FILE"}` | App loggers can be configured to define where the logs will be redirected to and the level of each in which it should be displayed. |
| global.fido2.appLoggers.enableStdoutLogPrefix | string | `"true"` | Enable log prefixing which enables prepending the STDOUT logs with the file name. i.e fido2 ===> 2022-12-20 17:49:55,744 INFO |
| global.fido2.appLoggers.fido2LogLevel | string | `"INFO"` | fido2.log level |
| global.fido2.appLoggers.fido2LogTarget | string | `"STDOUT"` | fido2.log target |
| global.fido2.appLoggers.persistenceDurationLogLevel | string | `"INFO"` | fido2_persistence_duration.log level |
| global.fido2.appLoggers.persistenceDurationLogTarget | string | `"FILE"` | fido2_persistence_duration.log target |
| global.fido2.appLoggers.persistenceLogLevel | string | `"INFO"` | fido2_persistence.log level |
| global.fido2.appLoggers.persistenceLogTarget | string | `"FILE"` | fido2_persistence.log target |
| global.fido2.appLoggers.scriptLogLevel | string | `"INFO"` | fido2_script.log level |
| global.fido2.appLoggers.scriptLogTarget | string | `"FILE"` | fido2_script.log target |
| global.fido2.enabled | bool | `true` | Boolean flag to enable/disable the fido2 chart. |
| global.fido2.fido2ServiceName | string | `"fido2"` | Name of the fido2 service. Please keep it as default. |
| global.fido2.ingress | object | `{"fido2ConfigEnabled":false}` | Enable endpoints in either istio or nginx ingress depending on users choice |
| global.fido2.ingress.fido2ConfigEnabled | bool | `false` | Enable endpoint /.well-known/fido2-configuration |
| global.fqdn | string | `"demoexample.gluu.org"` | Fully qualified domain name to be used for Gluu installation. This address will be used to reach Gluu services. |
| global.gcePdStorageType | string | `"pd-standard"` | GCE storage kind if using Google disks |
| global.isFqdnRegistered | bool | `false` | Boolean flag to enable mapping global.lbIp  to global.fqdn inside pods on clouds that provide static ip for load balancers. On cloud that provide only addresses to the LB this flag will enable a script to actively scan config.configmap.lbAddr and update the hosts file inside the pods automatically. |
| global.istio.additionalAnnotations | object | `{}` | Additional annotations that will be added across the gateway in the format of {cert-manager.io/issuer: "letsencrypt-prod"} |
| global.istio.additionalLabels | object | `{}` | Additional labels that will be added across the gateway in the format of {mylabel: "myapp"} |
| global.istio.enabled | bool | `false` | Boolean flag that enables using istio side-cars with Gluu services. |
| global.istio.gateways | list | `[]` | Override the gateway that can be created by default. This is used when istio ingress has already been setup and the gateway exists. |
| global.istio.ingress | bool | `false` | Boolean flag that enables using istio gateway for Gluu. This assumes istio ingress is installed and hence the LB is available. |
| global.istio.namespace | string | `"istio-system"` | The namespace istio is deployed in. The is normally istio-system. |
| global.jobTtlSecondsAfterFinished | int | `300` | https://kubernetes.io/docs/concepts/workloads/controllers/ttlafterfinished/ |
| global.lbIp | string | `"22.22.22.22"` | The Loadbalancer IP created by nginx or istio on clouds that provide static IPs. This is not needed if `global.fqdn` is globally resolvable. |
| global.licenseSsa | string | `""` | Your organization needs to register with Gluu to trial Flex, after which you are issued a JWT placed here in which you can use to install. This must be base64 encoded. |
| global.nginx-ingress.enabled | bool | `true` | Boolean flag to enable/disable the nginx-ingress definitions chart. |
| global.opendj.enabled | bool | `false` | Boolean flag to enable/disable the OpenDJ  chart. |
| global.opendj.ldapServiceName | string | `"opendj"` | Name of the OpenDJ service. Please keep it as default. |
| global.oxpassport.enabled | bool | `false` | Boolean flag to enable/disable passport chart |
| global.oxpassport.oxPassportServiceName | string | `"oxpassport"` | Name of the oxPassport service. Please keep it as default. |
| global.oxshibboleth.appLoggers | object | `{"auditStatsLogLevel":"INFO","auditStatsLogTarget":"FILE","consentAuditLogLevel":"INFO","consentAuditLogTarget":"FILE","containerLogLevel":"","encryptionLogLevel":"","httpclientLogLevel":"","idpLogLevel":"INFO","idpLogTarget":"STDOUT","ldapLogLevel":"","messagesLogLevel":"","opensamlLogLevel":"","propsLogLevel":"","scriptLogLevel":"INFO","scriptLogTarget":"FILE","springLogLevel":"","xmlsecLogLevel":""}` | App loggers can be configured to define where the logs will be redirected to and the level of each in which it should be displayed. log levels are "OFF", "FATAL", "ERROR", "WARN", "INFO", "DEBUG", "TRACE" Targets are "STDOUT" and "FILE" |
| global.oxshibboleth.appLoggers.auditStatsLogLevel | string | `"INFO"` | idp-audit.log level |
| global.oxshibboleth.appLoggers.auditStatsLogTarget | string | `"FILE"` | idp-audit.log target |
| global.oxshibboleth.appLoggers.consentAuditLogLevel | string | `"INFO"` | idp-consent-audit.log level |
| global.oxshibboleth.appLoggers.consentAuditLogTarget | string | `"FILE"` | idp-consent-audit.log target |
| global.oxshibboleth.appLoggers.idpLogLevel | string | `"INFO"` | idp-process.log level |
| global.oxshibboleth.appLoggers.idpLogTarget | string | `"STDOUT"` | idp-process.log target |
| global.oxshibboleth.appLoggers.ldapLogLevel | string | `""` | https://github.com/GluuFederation/docker-oxshibboleth#additional-logger-configuration The below are very noisy logs and are better left untouched |
| global.oxshibboleth.appLoggers.scriptLogLevel | string | `"INFO"` | idp-script.log level |
| global.oxshibboleth.appLoggers.scriptLogTarget | string | `"FILE"` | idp-script.log target |
| global.oxshibboleth.enabled | bool | `false` | Boolean flag to enable/disable the oxShibbboleth chart. |
| global.oxshibboleth.oxShibbolethServiceName | string | `"oxshibboleth"` | Name of the oxShibboleth service. Please keep it as default. |
| global.persistence.enabled | bool | `true` | Boolean flag to enable/disable the persistence chart. |
| global.scim.appLoggers | object | `{"enableStdoutLogPrefix":"true","ldapStatsLogLevel":"INFO","ldapStatsLogTarget":"FILE","persistenceDurationLogLevel":"INFO","persistenceDurationLogTarget":"FILE","persistenceLogLevel":"INFO","persistenceLogTarget":"FILE","scimLogLevel":"INFO","scimLogTarget":"STDOUT","scriptLogLevel":"INFO","scriptLogTarget":"FILE"}` | App loggers can be configured to define where the logs will be redirected to and the level of each in which it should be displayed. |
| global.scim.appLoggers.enableStdoutLogPrefix | string | `"true"` | Enable log prefixing which enables prepending the STDOUT logs with the file name. i.e jans-scim ===> 2022-12-20 17:49:55,744 INFO |
| global.scim.appLoggers.ldapStatsLogLevel | string | `"INFO"` | jans-scim_persistence_ldap_statistics.log level |
| global.scim.appLoggers.ldapStatsLogTarget | string | `"FILE"` | jans-scim_persistence_ldap_statistics.log target |
| global.scim.appLoggers.persistenceDurationLogLevel | string | `"INFO"` | jans-scim_persistence_duration.log level |
| global.scim.appLoggers.persistenceDurationLogTarget | string | `"FILE"` | jans-scim_persistence_duration.log target |
| global.scim.appLoggers.persistenceLogLevel | string | `"INFO"` | jans-scim_persistence.log level |
| global.scim.appLoggers.persistenceLogTarget | string | `"FILE"` | jans-scim_persistence.log target |
| global.scim.appLoggers.scimLogLevel | string | `"INFO"` | jans-scim.log level |
| global.scim.appLoggers.scimLogTarget | string | `"STDOUT"` | jans-scim.log target |
| global.scim.appLoggers.scriptLogLevel | string | `"INFO"` | jans-scim_script.log level |
| global.scim.appLoggers.scriptLogTarget | string | `"FILE"` | jans-scim_script.log target |
| global.scim.enabled | bool | `true` | Boolean flag to enable/disable the SCIM chart. |
| global.scim.ingress | object | `{"scimConfigEnabled":false,"scimEnabled":false}` | Enable endpoints in either istio or nginx ingress depending on users choice |
| global.scim.ingress.scimConfigEnabled | bool | `false` | Enable endpoint /.well-known/scim-configuration |
| global.scim.ingress.scimEnabled | bool | `false` | Enable SCIM endpoints /jans-scim |
| global.scim.scimServiceName | string | `"scim"` | Name of the scim service. Please keep it as default. |
| global.storageClass | object | `{"allowVolumeExpansion":true,"allowedTopologies":[],"mountOptions":["debug"],"parameters":{},"provisioner":"microk8s.io/hostpath","reclaimPolicy":"Retain","volumeBindingMode":"WaitForFirstConsumer"}` | StorageClass section for OpenDJ charts. This is not currently used by the openbanking distribution. You may specify custom parameters as needed. |
| global.storageClass.parameters | object | `{}` | parameters: fsType: "" kind: "" pool: "" storageAccountType: "" type: "" |
| global.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service. Envs defined in global.userEnvs will be globally available to all services |
| global.usrEnvs.normal | object | `{}` | Add custom normal envs to the service. variable1: value1 |
| global.usrEnvs.secret | object | `{}` | Add custom secret envs to the service. variable1: value1 |
| installer-settings | object | `{"acceptLicense":"","aws":{"arn":{"arnAcmCert":"","enabled":""},"lbType":"","vpcCidr":"0.0.0.0/0"},"confirmSettings":false,"couchbase":{"backup":{"fullSchedule":"","incrementalSchedule":"","retentionTime":"","storageSize":""},"clusterName":"","commonName":"","customFileOverride":"","install":"","lowResourceInstall":"","namespace":"","subjectAlternativeName":"","totalNumberOfExpectedTransactionsPerSec":"","totalNumberOfExpectedUsers":"","volumeType":""},"currentVersion":"","google":{"useSecretManager":""},"images":{"edit":""},"ldap":{"backup":{"fullSchedule":""}},"namespace":"","nginxIngress":{"namespace":"","releaseName":""},"nodes":{"ips":"","names":"","zones":""},"openbanking":{"cnObTransportTrustStoreP12password":"","hasCnObTransportTrustStore":false},"postgres":{"install":"","namespace":""},"redis":{"install":"","namespace":""},"releaseName":"","sql":{"install":"","namespace":""},"volumeProvisionStrategy":""}` | Only used by the installer. These settings do not affect nor are used by the chart |
| nginx-ingress | object | `{"certManager":{"certificate":{"enabled":false,"issuerGroup":"cert-manager.io","issuerKind":"ClusterIssuer","issuerName":""}},"ingress":{"additionalAnnotations":{},"additionalLabels":{},"adminUiAdditionalAnnotations":{},"adminUiLabels":{},"authServerAdditionalAnnotations":{},"authServerLabels":{},"authServerProtectedRegisterAdditionalAnnotations":{},"authServerProtectedRegisterLabels":{},"authServerProtectedTokenAdditionalAnnotations":{},"authServerProtectedTokenLabels":{},"casaAdditionalAnnotations":{},"casaLabels":{},"configApiAdditionalAnnotations":{},"configApiLabels":{},"deviceCodeAdditionalAnnotations":{},"deviceCodeLabels":{},"fido2ConfigAdditionalAnnotations":{},"fido2ConfigLabels":{},"firebaseMessagingAdditionalAnnotations":{},"firebaseMessagingLabels":{},"hosts":["demoexample.gluu.org"],"openidAdditionalAnnotations":{},"openidConfigLabels":{},"path":"/","scimAdditionalAnnotations":{},"scimConfigAdditionalAnnotations":{},"scimConfigLabels":{},"scimLabels":{},"tls":[{"hosts":["demoexample.gluu.org"],"secretName":"tls-certificate"}],"u2fAdditionalAnnotations":{},"u2fConfigLabels":{},"uma2AdditionalAnnotations":{},"uma2ConfigLabels":{},"webdiscoveryAdditionalAnnotations":{},"webdiscoveryLabels":{},"webfingerAdditionalAnnotations":{},"webfingerLabels":{}}}` | Nginx ingress definitions chart |
| nginx-ingress.ingress.additionalAnnotations | object | `{}` | Additional annotations that will be added across all ingress definitions in the format of {cert-manager.io/issuer: "letsencrypt-prod"} Enable client certificate authentication nginx.ingress.kubernetes.io/auth-tls-verify-client: "optional" Create the secret containing the trusted ca certificates nginx.ingress.kubernetes.io/auth-tls-secret: "gluu/tls-certificate" Specify the verification depth in the client certificates chain nginx.ingress.kubernetes.io/auth-tls-verify-depth: "1" Specify if certificates are passed to upstream server nginx.ingress.kubernetes.io/auth-tls-pass-certificate-to-upstream: "true" |
| nginx-ingress.ingress.additionalLabels | object | `{}` | Additional labels that will be added across all ingress definitions in the format of {mylabel: "myapp"} |
| nginx-ingress.ingress.adminUiAdditionalAnnotations | object | `{}` | openid-configuration ingress resource additional annotations. |
| nginx-ingress.ingress.adminUiLabels | object | `{}` | Admin UI ingress resource labels. key app is taken. |
| nginx-ingress.ingress.authServerAdditionalAnnotations | object | `{}` | Auth server ingress resource additional annotations. |
| nginx-ingress.ingress.authServerLabels | object | `{}` | Auth server ingress resource labels. key app is taken |
| nginx-ingress.ingress.authServerProtectedRegisterAdditionalAnnotations | object | `{}` | Auth server protected register ingress resource additional annotations. |
| nginx-ingress.ingress.authServerProtectedRegisterLabels | object | `{}` | Auth server protected token ingress resource labels. key app is taken |
| nginx-ingress.ingress.authServerProtectedTokenAdditionalAnnotations | object | `{}` | Auth server protected token ingress resource additional annotations. |
| nginx-ingress.ingress.authServerProtectedTokenLabels | object | `{}` | Auth server protected token ingress resource labels. key app is taken |
| nginx-ingress.ingress.casaAdditionalAnnotations | object | `{}` | Casa ingress resource additional annotations. |
| nginx-ingress.ingress.casaLabels | object | `{}` | Casa ingress resource labels. key app is taken |
| nginx-ingress.ingress.configApiAdditionalAnnotations | object | `{}` | ConfigAPI ingress resource additional annotations. |
| nginx-ingress.ingress.configApiLabels | object | `{}` | configAPI ingress resource labels. key app is taken |
| nginx-ingress.ingress.deviceCodeAdditionalAnnotations | object | `{}` | device-code ingress resource additional annotations. |
| nginx-ingress.ingress.deviceCodeLabels | object | `{}` | device-code ingress resource labels. key app is taken |
| nginx-ingress.ingress.fido2ConfigAdditionalAnnotations | object | `{}` | fido2 config ingress resource additional annotations. |
| nginx-ingress.ingress.fido2ConfigLabels | object | `{}` | fido2 config ingress resource labels. key app is taken |
| nginx-ingress.ingress.firebaseMessagingAdditionalAnnotations | object | `{}` | Firebase Messaging ingress resource additional annotations. |
| nginx-ingress.ingress.firebaseMessagingLabels | object | `{}` | Firebase Messaging ingress resource labels. key app is taken |
| nginx-ingress.ingress.openidAdditionalAnnotations | object | `{}` | openid-configuration ingress resource additional annotations. |
| nginx-ingress.ingress.openidConfigLabels | object | `{}` | openid-configuration ingress resource labels. key app is taken |
| nginx-ingress.ingress.scimAdditionalAnnotations | object | `{}` | SCIM ingress resource additional annotations. |
| nginx-ingress.ingress.scimConfigAdditionalAnnotations | object | `{}` | SCIM config ingress resource additional annotations. |
| nginx-ingress.ingress.scimConfigLabels | object | `{}` | SCIM config ingress resource labels. key app is taken |
| nginx-ingress.ingress.scimLabels | object | `{}` | SCIM config ingress resource labels. key app is taken |
| nginx-ingress.ingress.tls | list | `[{"hosts":["demoexample.gluu.org"],"secretName":"tls-certificate"}]` | Secrets holding HTTPS CA cert and key. |
| nginx-ingress.ingress.u2fAdditionalAnnotations | object | `{}` | u2f config ingress resource additional annotations. |
| nginx-ingress.ingress.u2fConfigLabels | object | `{}` | u2f config ingress resource labels. key app is taken |
| nginx-ingress.ingress.uma2AdditionalAnnotations | object | `{}` | uma2 config ingress resource additional annotations. |
| nginx-ingress.ingress.uma2ConfigLabels | object | `{}` | uma2 config ingress resource labels. key app is taken |
| nginx-ingress.ingress.webdiscoveryAdditionalAnnotations | object | `{}` | webdiscovery ingress resource additional annotations. |
| nginx-ingress.ingress.webdiscoveryLabels | object | `{}` | webdiscovery ingress resource labels. key app is taken |
| nginx-ingress.ingress.webfingerAdditionalAnnotations | object | `{}` | webfinger ingress resource additional annotations. |
| nginx-ingress.ingress.webfingerLabels | object | `{}` | webfinger ingress resource labels. key app is taken |
| opendj | object | `{"additionalAnnotations":{},"additionalLabels":{},"backup":{"cronJobSchedule":"*/59 * * * *","enabled":true},"dnsConfig":{},"dnsPolicy":"","hpa":{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50},"image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"gluufederation/opendj","tag":"5.0.0-12"},"lifecycle":{"preStop":{"exec":{"command":["/bin/sh","-c","python3 /app/scripts/deregister_peer.py 1>&/proc/1/fd/1"]}}},"livenessProbe":{"exec":{"command":["python3","/app/scripts/healthcheck.py"]},"failureThreshold":20,"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5},"pdb":{"enabled":true,"maxUnavailable":1},"persistence":{"size":"5Gi"},"ports":{"tcp-admin":{"nodePort":"","port":4444,"protocol":"TCP","targetPort":4444},"tcp-ldap":{"nodePort":"","port":1389,"protocol":"TCP","targetPort":1389},"tcp-ldaps":{"nodePort":"","port":1636,"protocol":"TCP","targetPort":1636},"tcp-repl":{"nodePort":"","port":8989,"protocol":"TCP","targetPort":8989},"tcp-serf":{"nodePort":"","port":7946,"protocol":"TCP","targetPort":7946},"udp-serf":{"nodePort":"","port":7946,"protocol":"UDP","targetPort":7946}},"readinessProbe":{"failureThreshold":20,"initialDelaySeconds":60,"periodSeconds":25,"tcpSocket":{"port":1636},"timeoutSeconds":5},"replicas":1,"resources":{"limits":{"cpu":"1500m","memory":"2000Mi"},"requests":{"cpu":"1500m","memory":"2000Mi"}},"topologySpreadConstraints":{},"usrEnvs":{"normal":{},"secret":{}},"volumeMounts":[],"volumes":[]}` | OpenDJ is a directory server which implements a wide range of Lightweight Directory Access Protocol and related standards, including full compliance with LDAPv3 but also support for Directory Service Markup Language (DSMLv2).Written in Java, OpenDJ offers multi-master replication, access control, and many extensions. |
| opendj.additionalAnnotations | object | `{}` | Additional annotations that will be added across the gateway in the format of {cert-manager.io/issuer: "letsencrypt-prod"} |
| opendj.additionalLabels | object | `{}` | Additional labels that will be added across the gateway in the format of {mylabel: "myapp"} |
| opendj.backup | object | `{"cronJobSchedule":"*/59 * * * *","enabled":true}` | Configure ldap backup cronjob |
| opendj.dnsConfig | object | `{}` | Add custom dns config |
| opendj.dnsPolicy | string | `""` | Add custom dns policy |
| opendj.hpa | object | `{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50}` | Configure the HorizontalPodAutoscaler |
| opendj.hpa.behavior | object | `{}` | Scaling Policies |
| opendj.hpa.metrics | list | `[]` | metrics if targetCPUUtilizationPercentage is not set |
| opendj.image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy to use for deploying. |
| opendj.image.pullSecrets | list | `[]` | Image Pull Secrets |
| opendj.image.repository | string | `"gluufederation/opendj"` | Image  to use for deploying. |
| opendj.image.tag | string | `"5.0.0-12"` | Image  tag to use for deploying. |
| opendj.livenessProbe | object | `{"exec":{"command":["python3","/app/scripts/healthcheck.py"]},"failureThreshold":20,"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5}` | Configure the liveness healthcheck for OpenDJ if needed. https://github.com/GluuFederation/docker-opendj/blob/master/scripts/healthcheck.py |
| opendj.livenessProbe.exec | object | `{"command":["python3","/app/scripts/healthcheck.py"]}` | Executes the python3 healthcheck. |
| opendj.pdb | object | `{"enabled":true,"maxUnavailable":1}` | Configure the PodDisruptionBudget |
| opendj.persistence.size | string | `"5Gi"` | OpenDJ volume size |
| opendj.readinessProbe | object | `{"failureThreshold":20,"initialDelaySeconds":60,"periodSeconds":25,"tcpSocket":{"port":1636},"timeoutSeconds":5}` | Configure the readiness healthcheck for OpenDJ if needed. https://github.com/GluuFederation/docker-opendj/blob/master/scripts/healthcheck.py |
| opendj.replicas | int | `1` | Service replica number. |
| opendj.resources | object | `{"limits":{"cpu":"1500m","memory":"2000Mi"},"requests":{"cpu":"1500m","memory":"2000Mi"}}` | Resource specs. |
| opendj.resources.limits.cpu | string | `"1500m"` | CPU limit. |
| opendj.resources.limits.memory | string | `"2000Mi"` | Memory limit. |
| opendj.resources.requests.cpu | string | `"1500m"` | CPU request. |
| opendj.resources.requests.memory | string | `"2000Mi"` | Memory request. |
| opendj.topologySpreadConstraints | object | `{}` | Configure the topology spread constraints. Notice this is a map NOT a list as in the upstream API https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/ |
| opendj.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service |
| opendj.usrEnvs.normal | object | `{}` | Add custom normal envs to the service variable1: value1 |
| opendj.usrEnvs.secret | object | `{}` | Add custom secret envs to the service variable1: value1 |
| opendj.volumeMounts | list | `[]` | Configure any additional volumesMounts that need to be attached to the containers |
| opendj.volumes | list | `[]` | Configure any additional volumes that need to be attached to the pod |
| oxpassport | object | `{"additionalAnnotations":{},"additionalLabels":{},"dnsConfig":{},"dnsPolicy":"","hpa":{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50},"image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"gluufederation/oxpassport","tag":"5.0.0-12"},"lifecycle":{},"livenessProbe":{"failureThreshold":20,"httpGet":{"path":"/passport/health-check","port":"http-passport"},"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5},"pdb":{"enabled":true,"maxUnavailable":"90%"},"readinessProbe":{"failureThreshold":20,"httpGet":{"path":"/passport/health-check","port":"http-passport"},"initialDelaySeconds":25,"periodSeconds":25,"timeoutSeconds":5},"replicas":1,"resources":{"limits":{"cpu":"700m","memory":"900Mi"},"requests":{"cpu":"700m","memory":"900Mi"}},"topologySpreadConstraints":{},"usrEnvs":{"normal":{},"secret":{}},"volumeMounts":[],"volumes":[]}` | Gluu interface to Passport.js to support social login and inbound identity. |
| oxpassport.additionalAnnotations | object | `{}` | Additional annotations that will be added across the gateway in the format of {cert-manager.io/issuer: "letsencrypt-prod"} |
| oxpassport.additionalLabels | object | `{}` | Additional labels that will be added across the gateway in the format of {mylabel: "myapp"} |
| oxpassport.dnsConfig | object | `{}` | Add custom dns config |
| oxpassport.dnsPolicy | string | `""` | Add custom dns policy |
| oxpassport.hpa | object | `{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50}` | Configure the HorizontalPodAutoscaler |
| oxpassport.hpa.behavior | object | `{}` | Scaling Policies |
| oxpassport.hpa.metrics | list | `[]` | metrics if targetCPUUtilizationPercentage is not set |
| oxpassport.image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy to use for deploying. |
| oxpassport.image.pullSecrets | list | `[]` | Image Pull Secrets |
| oxpassport.image.repository | string | `"gluufederation/oxpassport"` | Image  to use for deploying. |
| oxpassport.image.tag | string | `"5.0.0-12"` | Image  tag to use for deploying. |
| oxpassport.livenessProbe | object | `{"failureThreshold":20,"httpGet":{"path":"/passport/health-check","port":"http-passport"},"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5}` | Configure the liveness healthcheck for oxPassport if needed. |
| oxpassport.livenessProbe.httpGet.path | string | `"/passport/health-check"` | http liveness probe endpoint |
| oxpassport.pdb | object | `{"enabled":true,"maxUnavailable":"90%"}` | Configure the PodDisruptionBudget |
| oxpassport.readinessProbe | object | `{"failureThreshold":20,"httpGet":{"path":"/passport/health-check","port":"http-passport"},"initialDelaySeconds":25,"periodSeconds":25,"timeoutSeconds":5}` | Configure the readiness healthcheck for the oxPassport if needed. |
| oxpassport.readinessProbe.httpGet.path | string | `"/passport/health-check"` | http readiness probe endpoint |
| oxpassport.replicas | int | `1` | Service replica number |
| oxpassport.resources | object | `{"limits":{"cpu":"700m","memory":"900Mi"},"requests":{"cpu":"700m","memory":"900Mi"}}` | Resource specs. |
| oxpassport.resources.limits.cpu | string | `"700m"` | CPU limit. |
| oxpassport.resources.limits.memory | string | `"900Mi"` | Memory limit. |
| oxpassport.resources.requests.cpu | string | `"700m"` | CPU request. |
| oxpassport.resources.requests.memory | string | `"900Mi"` | Memory request. |
| oxpassport.topologySpreadConstraints | object | `{}` | Configure the topology spread constraints. Notice this is a map NOT a list as in the upstream API https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/ |
| oxpassport.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service |
| oxpassport.usrEnvs.normal | object | `{}` | Add custom normal envs to the service variable1: value1 |
| oxpassport.usrEnvs.secret | object | `{}` | Add custom secret envs to the service variable1: value1 |
| oxpassport.volumeMounts | list | `[]` | Configure any additional volumesMounts that need to be attached to the containers |
| oxpassport.volumes | list | `[]` | Configure any additional volumes that need to be attached to the pod |
| oxshibboleth | object | `{"additionalAnnotations":{},"additionalLabels":{},"dnsConfig":{},"dnsPolicy":"","hpa":{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50},"image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"gluufederation/oxshibboleth","tag":"5.0.0-12"},"lifecycle":{},"livenessProbe":{"exec":{"command":["python3","/app/scripts/healthcheck.py"]},"failureThreshold":20,"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5},"pdb":{"enabled":true,"maxUnavailable":1},"readinessProbe":{"exec":{"command":["python3","/app/scripts/healthcheck.py"]},"failureThreshold":20,"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5},"replicas":1,"resources":{"limits":{"cpu":"1000m","memory":"1000Mi"},"requests":{"cpu":"1000m","memory":"1000Mi"}},"topologySpreadConstraints":{},"usrEnvs":{"normal":{},"secret":{}},"volumeMounts":[],"volumes":[]}` | Shibboleth project for the Gluu Server's SAML IDP functionality. |
| oxshibboleth.additionalAnnotations | object | `{}` | Additional annotations that will be added across the gateway in the format of {cert-manager.io/issuer: "letsencrypt-prod"} |
| oxshibboleth.additionalLabels | object | `{}` | Additional labels that will be added across the gateway in the format of {mylabel: "myapp"} |
| oxshibboleth.dnsConfig | object | `{}` | Add custom dns config |
| oxshibboleth.dnsPolicy | string | `""` | Add custom dns policy |
| oxshibboleth.hpa | object | `{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50}` | Configure the HorizontalPodAutoscaler |
| oxshibboleth.hpa.behavior | object | `{}` | Scaling Policies |
| oxshibboleth.hpa.metrics | list | `[]` | metrics if targetCPUUtilizationPercentage is not set |
| oxshibboleth.image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy to use for deploying. |
| oxshibboleth.image.pullSecrets | list | `[]` | Image Pull Secrets |
| oxshibboleth.image.repository | string | `"gluufederation/oxshibboleth"` | Image  to use for deploying. |
| oxshibboleth.image.tag | string | `"5.0.0-12"` | Image  tag to use for deploying. |
| oxshibboleth.livenessProbe | object | `{"exec":{"command":["python3","/app/scripts/healthcheck.py"]},"failureThreshold":20,"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5}` | Configure the liveness healthcheck for oxshibboleth if needed. https://github.com/GluuFederation/docker-oxshibboleth/blob/master/scripts/healthcheck.py |
| oxshibboleth.livenessProbe.exec | object | `{"command":["python3","/app/scripts/healthcheck.py"]}` | Executes the python3 healthcheck. |
| oxshibboleth.pdb | object | `{"enabled":true,"maxUnavailable":1}` | Configure the PodDisruptionBudget |
| oxshibboleth.readinessProbe | object | `{"exec":{"command":["python3","/app/scripts/healthcheck.py"]},"failureThreshold":20,"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5}` | Configure the readiness healthcheck for the casa if needed. |
| oxshibboleth.readinessProbe.exec | object | `{"command":["python3","/app/scripts/healthcheck.py"]}` | Executes the python3 healthcheck. |
| oxshibboleth.replicas | int | `1` | Service replica number. |
| oxshibboleth.resources | object | `{"limits":{"cpu":"1000m","memory":"1000Mi"},"requests":{"cpu":"1000m","memory":"1000Mi"}}` | Resource specs. |
| oxshibboleth.resources.limits.cpu | string | `"1000m"` | CPU limit. |
| oxshibboleth.resources.limits.memory | string | `"1000Mi"` | Memory limit. |
| oxshibboleth.resources.requests.cpu | string | `"1000m"` | CPU request. |
| oxshibboleth.resources.requests.memory | string | `"1000Mi"` | Memory request. |
| oxshibboleth.topologySpreadConstraints | object | `{}` | Configure the topology spread constraints. Notice this is a map NOT a list as in the upstream API https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/ |
| oxshibboleth.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service |
| oxshibboleth.usrEnvs.normal | object | `{}` | Add custom normal envs to the service variable1: value1 |
| oxshibboleth.usrEnvs.secret | object | `{}` | Add custom secret envs to the service variable1: value1 |
| oxshibboleth.volumeMounts | list | `[]` | Configure any additional volumesMounts that need to be attached to the containers |
| oxshibboleth.volumes | list | `[]` | Configure any additional volumes that need to be attached to the pod |
| persistence | object | `{"additionalAnnotations":{},"additionalLabels":{},"dnsConfig":{},"dnsPolicy":"","image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"ghcr.io/janssenproject/jans/persistence-loader","tag":"1.0.13_dev"},"lifecycle":{},"resources":{"limits":{"cpu":"300m","memory":"300Mi"},"requests":{"cpu":"300m","memory":"300Mi"}},"usrEnvs":{"normal":{},"secret":{}},"volumeMounts":[],"volumes":[]}` | Job to generate data and initial config for Gluu Server persistence layer. |
| persistence.additionalAnnotations | object | `{}` | Additional annotations that will be added across the gateway in the format of {cert-manager.io/issuer: "letsencrypt-prod"} |
| persistence.additionalLabels | object | `{}` | Additional labels that will be added across the gateway in the format of {mylabel: "myapp"} |
| persistence.dnsConfig | object | `{}` | Add custom dns config |
| persistence.dnsPolicy | string | `""` | Add custom dns policy |
| persistence.image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy to use for deploying. |
| persistence.image.pullSecrets | list | `[]` | Image Pull Secrets |
| persistence.image.repository | string | `"ghcr.io/janssenproject/jans/persistence-loader"` | Image  to use for deploying. |
| persistence.image.tag | string | `"1.0.13_dev"` | Image  tag to use for deploying. |
| persistence.resources | object | `{"limits":{"cpu":"300m","memory":"300Mi"},"requests":{"cpu":"300m","memory":"300Mi"}}` | Resource specs. |
| persistence.resources.limits.cpu | string | `"300m"` | CPU limit |
| persistence.resources.limits.memory | string | `"300Mi"` | Memory limit. |
| persistence.resources.requests.cpu | string | `"300m"` | CPU request. |
| persistence.resources.requests.memory | string | `"300Mi"` | Memory request. |
| persistence.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service |
| persistence.usrEnvs.normal | object | `{}` | Add custom normal envs to the service variable1: value1 |
| persistence.usrEnvs.secret | object | `{}` | Add custom secret envs to the service variable1: value1 |
| persistence.volumeMounts | list | `[]` | Configure any additional volumesMounts that need to be attached to the containers |
| persistence.volumes | list | `[]` | Configure any additional volumes that need to be attached to the pod |
| scim | object | `{"additionalAnnotations":{},"additionalLabels":{},"dnsConfig":{},"dnsPolicy":"","hpa":{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50},"image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"ghcr.io/janssenproject/jans/scim","tag":"1.0.13_dev"},"lifecycle":{},"livenessProbe":{"httpGet":{"path":"/jans-scim/sys/health-check","port":8080},"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5},"pdb":{"enabled":true,"maxUnavailable":"90%"},"readinessProbe":{"httpGet":{"path":"/jans-scim/sys/health-check","port":8080},"initialDelaySeconds":25,"periodSeconds":25,"timeoutSeconds":5},"replicas":1,"resources":{"limits":{"cpu":"1000m","memory":"1000Mi"},"requests":{"cpu":"1000m","memory":"1000Mi"}},"service":{"name":"http-scim","port":8080},"topologySpreadConstraints":{},"usrEnvs":{"normal":{},"secret":{}},"volumeMounts":[],"volumes":[]}` | System for Cross-domain Identity Management (SCIM) version 2.0 |
| scim.additionalAnnotations | object | `{}` | Additional annotations that will be added across the gateway in the format of {cert-manager.io/issuer: "letsencrypt-prod"} |
| scim.additionalLabels | object | `{}` | Additional labels that will be added across the gateway in the format of {mylabel: "myapp"} |
| scim.dnsConfig | object | `{}` | Add custom dns config |
| scim.dnsPolicy | string | `""` | Add custom dns policy |
| scim.hpa | object | `{"behavior":{},"enabled":true,"maxReplicas":10,"metrics":[],"minReplicas":1,"targetCPUUtilizationPercentage":50}` | Configure the HorizontalPodAutoscaler |
| scim.hpa.behavior | object | `{}` | Scaling Policies |
| scim.hpa.metrics | list | `[]` | metrics if targetCPUUtilizationPercentage is not set |
| scim.image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy to use for deploying. |
| scim.image.pullSecrets | list | `[]` | Image Pull Secrets |
| scim.image.repository | string | `"ghcr.io/janssenproject/jans/scim"` | Image  to use for deploying. |
| scim.image.tag | string | `"1.0.13_dev"` | Image  tag to use for deploying. |
| scim.livenessProbe | object | `{"httpGet":{"path":"/jans-scim/sys/health-check","port":8080},"initialDelaySeconds":30,"periodSeconds":30,"timeoutSeconds":5}` | Configure the liveness healthcheck for SCIM if needed. |
| scim.livenessProbe.httpGet.path | string | `"/jans-scim/sys/health-check"` | http liveness probe endpoint |
| scim.pdb | object | `{"enabled":true,"maxUnavailable":"90%"}` | Configure the PodDisruptionBudget |
| scim.readinessProbe | object | `{"httpGet":{"path":"/jans-scim/sys/health-check","port":8080},"initialDelaySeconds":25,"periodSeconds":25,"timeoutSeconds":5}` | Configure the readiness healthcheck for the SCIM if needed. |
| scim.readinessProbe.httpGet.path | string | `"/jans-scim/sys/health-check"` | http readiness probe endpoint |
| scim.replicas | int | `1` | Service replica number. |
| scim.resources.limits.cpu | string | `"1000m"` | CPU limit. |
| scim.resources.limits.memory | string | `"1000Mi"` | Memory limit. |
| scim.resources.requests.cpu | string | `"1000m"` | CPU request. |
| scim.resources.requests.memory | string | `"1000Mi"` | Memory request. |
| scim.service.name | string | `"http-scim"` | The name of the scim port within the scim service. Please keep it as default. |
| scim.service.port | int | `8080` | Port of the scim service. Please keep it as default. |
| scim.topologySpreadConstraints | object | `{}` | Configure the topology spread constraints. Notice this is a map NOT a list as in the upstream API https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/ |
| scim.usrEnvs | object | `{"normal":{},"secret":{}}` | Add custom normal and secret envs to the service |
| scim.usrEnvs.normal | object | `{}` | Add custom normal envs to the service variable1: value1 |
| scim.usrEnvs.secret | object | `{}` | Add custom secret envs to the service variable1: value1 |
| scim.volumeMounts | list | `[]` | Configure any additional volumesMounts that need to be attached to the containers |
| scim.volumes | list | `[]` | Configure any additional volumes that need to be attached to the pod |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
