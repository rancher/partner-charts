## Changelog

### 2.0.26

* Add option to define Kubernetes env vars in the agent.pod.env property of the agent CR. This notation replaces the previous string map notation in agent.env, but both notations keep working. This feature allows to map Kubernetes secrets or other properties to env vars exposed to the agent pod and can be used by sensors.

### 2.0.25

* Add migration script to convert agent configuration from configmap to custom-values.yaml prior an helm upgrade from v1 to v2
* Bump operator to v2.1.27: Update go version to v1.24.4

### 2.0.24

* Add config options for controllerManager deployment resources

### 2.0.23

* Fix rendering logic for agent.pod.nodeSelector

### 2.0.22

* Bump operator to v2.1.26: Adjust RBAC permissions of instana-agent-controller-manager to control PodDisruptionBudgets of the k8sensor deployment

### 2.0.21

* Remove duplicated label `app.kubernetes.io/name: instana-agent-operator` on the instana-agent-controller-manager deployment
* Bump operator to v2.1.25: Add prerequisites to allow selective monitoring on namespace level in the operator

### 2.0.20

* Bump operator to v2.1.24: Update depencencies in the operator and golang to v1.24.3

### 2.0.19

* Bump operator to v2.1.23: Fix problem in the k8sensor deployment when existing additional backends were changed

### 2.0.18

* Bump operator to v2.1.22

### 2.0.17

* Avoid rending of `proxyPort:` in the agent CR, if agent.proxyPort is not defined in values

### 2.0.16

* Remove outdated tech-preview files, as the k8sensor is general available now
* Refactor CI pipeline to use IBM Cloud
* Update operator to v.2.1.21: Add `nodes/proxy` to ClusterRoles to fetch kubelet information

### 2.0.15

* Fix label and matchLabel rendering on controller-manager deployment during upgrades

### 2.0.14

* Update operator to v2.1.20: Fix http proxy handling for k8sensor if no credentials are required
* Make controllerManager.image configurable
* Support deploying to non-default namespaces

### 2.0.13

* Fix rendering of agent.proxyPort in agent custom resource

### 2.0.12

* Update operator to v2.1.19: Deploy operator as a single instance to reduce resource consumption

### 2.0.11

* Update operator to v2.1.18: Adjust logic when to render configuration-opentelemetry.yaml and increase default k8sensor pollrate to 10s

### 2.0.10

* Update operator to v2.1.16: Add ClusterRole/ClusterRoleBinding to instana-agent service account to enable prometheus sensor in Kubernetes
* Update operator to v2.1.15: Change deployment `controller-manager`, and RBAC `manager-role` and `manager-rolebinding` to instana-specifc names `instana-agent-controller-manager`, `instana-agent-clusterrole` and `instana-agent-clusterrolebinding`

### 2.0.9

* Fix rendering of the agent zones

### 2.0.8

* Add option to define custom volumes and volumeMounts for the agent pod

### 2.0.7

* Fix handling of opentelemetry settings, if `spec.opentelemetry.grpc.enabled` or `spec.opentelemetry.http.enabled` are set to false
* Update operator to v2.1.13

### 2.0.6

* Rename flags for the agent repository mirror configuration

### 2.0.5

* Add flags for the agent repository mirror configuration

### 2.0.4

* Update to operator v2.1.10: Add roles for node metrics and stats for k8sensor

### 2.0.3

* Fix k8sensor deployment rendering

### 2.0.2

* Hardening for endpointPort and configuration parsing

### 2.0.1

* Fix rendering of the `spec.agent.env`, `spec.configuration_yaml`, `spec.agent.image.pullSecrets`

### 2.0.0

* Deploy the instana-agent operator instead of managing agent artifacts directly
* Always use the k8sensor, the deprecated kubernetes sensor is no longer supported (this is an internal change, Kubernetes clusters will still report into the Instana backend)
* BREAKING CHANGE: Due to limitations of helm to manage Custom Resource Definition (CRD) updates, the upgrade requires to apply the CRD from the helm chart crds folder manually. Find more details in the [upgrade](#upgrade) section.

### 1.2.74

* Enable OTLP by default

### 1.2.73

* Fix label for `io.instana/zone` to reflect the real agent mode
* Change the charts flag from ENABLE_AGENT_SOCKET to serviceMesh.enabled
* Add type: DirectoryOrCreate to DaemonSet definitions to ensure required directories exist

### 1.2.72

* Add minReadySeconds field to agent daemonset yaml

### 1.2.71

* Fix usage of digest for pulling images

### 1.2.70

* Allow the configuration of `minReadySeconds` for the agent daemonset and deployment

### 1.2.69

* Add possibility to set annotations for the serviceAccount.

### 1.2.68

* Add leader elector configuration back to allow for proper deprecation

### 1.2.67

* Fix variable name in the K8s deployment

### 1.2.66

* Allign the default Memory requests to 768Mi for the Agent container.

### 1.2.65

* Ensure we have appropriate SCC when running with new K8s sensor.

### 1.2.64

* Remove RBAC not required by agent when kubernetes-sensor is disabed.
* Add settings override for k8s-sensor affinity
* Add optional pod disruption budget for k8s-sensor

### 1.2.63

* Add RBAC required to allow access to /metrics end-points.

### 1.2.62

* Include k8s-sensor resources in the default static YAML definitions

### 1.2.61

* Increase timeout and initialDelay for the Agent container
* Add OTLP ports to headless service

### 1.2.60

* Enable the k8s_sensor by default

### 1.2.59

* Introduce unique selectorLabels and commonLabels for k8s-sensor deployment

### 1.2.58

* Default to `internalTrafficPolicy` instead of `topologyKeys` for rendering of static YAMLs

### 1.2.57

* Fix vulnerability in the leader-elector image

### 1.2.49

* Add zone name to label `io.instana/zone` in daemonset

### 1.2.48

* Set env var INSTANA_KUBERNETES_REDACT_SECRETS true if agent.redactKubernetesSecrets is enabled.
* Use feature PSP flag in k8sensor ClusterRole only when podsecuritypolicy.enable is true.

### 1.2.47

* Roll back the changes from version 1.2.46 to be compatible with the Agent Operator installation

### 1.2.46

* Use K8sensor by default.
* kubernetes.deployment.enabled setting overrides k8s_sensor.deployment.enabled setting.
* Use feature PSP flag in k8sensor ClusterRole only when podsecuritypolicy.enable is true.
* Throw failure if customer specifies proxy with k8sensor.
* Set env var INSTANA_KUBERNETES_REDACT_SECRETS true if agent.redactKubernetesSecrets is enabled.

### 1.2.45

* Use agent key secret in k8sensor deployment.

### 1.2.44

* Add support for enabling the hot-reload of `configuration.yaml` when the default `instana-agent` ConfigMap changes
* Enablement is done via the flag `--set agent.configuration.hotreloadEnabled=true`

### 1.2.43

* Bump leader-elector image to v0.5.16 (Update dependencies)

### 1.2.42

* Add support for creating multiple zones within the same cluster using affinity and tolerations.

### 1.2.41

* Add additional permissions (HPA, ResourceQuotas, etc) to k8sensor clusterrole.

### 1.2.40

* Mount all system mounts mountPropagation: HostToContainer.

### 1.2.39

* Add NO_PROXY to k8sensor deployment to prevent api-server requests from being routed to the proxy.

### 1.2.38

* Fix issue related to EKS version format when enabling OTel service.

### 1.2.37

* Fix issue where cluster_zone is used as cluster_name when `k8s_sensor.deployment.enabled=true`.
* Set `HTTPS_PROXY` in k8s deployment when proxy information is set.

### 1.2.36

* Remove Service `topologyKeys`, which was removed in Kubernetes v1.22. Replaced by `internalTrafficPolicy` which is available with Kubernetes v1.21+.

### 1.2.35

* Fix invalid backend port for new Kubernetes sensor (k8sensor)

### 1.2.34

* Add support for new Kubernetes sensor (k8sensor)
  * New Kubernetes sensor can be used via the flag `--set k8s_sensor.deployment.enabled=true`

### 1.2.33

* Bump leader-elector image to v0.5.15 (Update dependencies)

### 1.2.32

* Add support for containerd montoring on TKGI  

### 1.2.31

* Bump leader-elector image to v0.5.14 (Update dependencies)

### 1.2.30

* Pull agent image from IBM Cloud Container Registry (icr.io/instana/agent). No code changes have been made.
* Bump leader-elector image to v0.5.13 and pull from IBM Cloud Container Registry (icr.io/instana/leader-elector). No code changes have been made.

### 1.2.29

* Add an additional port to the Instana Agent `Service` definition, for the OpenTelemetry registered IANA port 4317.

### 1.2.28

* Fix deployment when `cluster.name` is not specified. Should be allowed according to docs but previously broke the Pod
    when starting up.

### 1.2.27

* Update leader elector image to `0.5.10` to tone down logging and make it configurable

### 1.2.26

* Add TLS support. An existing secret can be used of type `kubernetes.io/tls`. Or provide a certificate and a private key, which creates a new secret.
* Update leader elector image version to 0.5.9 to support PPCle

### 1.2.25

* Add `agent.pod.labels` to add custom labels to the Instana Agent pods

### 1.2.24

* Bump leader-elector image to v0.5.8 which includes a health-check endpoint. Update the `livenessProbe`
    correspondingly.

### 1.2.23

* Bump leader-elector image to v0.5.7 to fix a potential Golang bug in the elector

### 1.2.22

* Fix templating scope when defining multiple backends

### 1.2.21

* Internal updates

### 1.2.20

* upgrade leader-elector image to v0.5.6 to enable usage on s390x and arm64

### 1.2.18 / 1.2.19

* Internal change on generated DaemonSet YAML from the Helm charts

### 1.2.17

* Update Pod Security Policies as the `readOnly: true` appears not to be working for the mount points and
  actually causes the Agent deployment to fail when these policies are enforced in the cluster.

### 1.2.16

* Add configuration option for `INSTANA_MVN_REPOSITORY_URL` setting on the Agent container.

### 1.2.15

* Internal pipeline changes. No significant changes to the Helm charts

### v1.2.14

* Update Agent container mounts. Make some read-only as we don't need all mounts with read-write permissions.
    Additionally add the mount for `/var/data` which is needed in certain environments for the Agent to function
    properly.

### v1.2.13

* Update memory settings specifically for the Kubernetes sensor (Technical Preview)

### v1.2.11

* Simplify setup for using OpenTelemetry and the Prometheus `remote_write` endpoint using the `opentelemetry.enabled` and `prometheus.remoteWrite.enabled` settings, respectively.

### v1.2.9

* **Technical Preview:** Introduce a new mode of running to the Kubernetes sensor using a dedicated deployment.
  See the [Kubernetes Sensor Deployment](#kubernetes-sensor-deployment) section for more information.

### v1.2.7

* Fix: Make service opt-in, as it uses functionality (`topologyKeys`) that is available only in K8S 1.17+.

### v1.2.6

* Fix bug that might cause some OpenShift-specific resources to be created in other flavours of Kubernetes.

### v1.2.5

* Introduce the `instana-agent:instana-agent` Kubernetes service that allows you to talk to the Instana agent on the same node.

### v1.2.3

* Bug fix: Extend the built-in Pod Security Policy to cover the Docker socket mount for Tanzu Kubernetes Grid systems.

### v1.2.1

* Support OpenShift 4.x: just add --set openshift=true to the usual settings, and off you go :-)
* Restructure documentation for consistency and readability
* Deprecation: Helm 2 is no longer supported; the minimum Helm API version is now v2, which will make Helm 2 refuse to process the chart.

### v1.1.10

* Some linting of the whitespaces in the generated YAML

### v1.1.9

* Update the README to replace all references of `stable/instana-agent` with specifically setting the repo flag to `https://agents.instana.io/helm`.
* Add support for TKGI and PKS systems, providing a workaround for the [unexpected Docker socket location](https://github.com/cloudfoundry-incubator/kubo-release/issues/329).

### v1.1.7

* Store the cluster name in a new `cluster-name` entry of the `instana-agent` ConfigMap rather than directly as the value of the `INSTANA_KUBERNETES_CLUSTER_NAME`, so that you can edit the cluster name in the ConfigMap in deployments like VMware Tanzu Kubernetes Grid in which, when installing the Instana agent over the [Instana tile](https://www.instana.com/docs/setup_and_manage/host_agent/on/vmware_tanzu), you do not have directly control to the configuration of the cluster name.
If you edit the ConfigMap, you will need to delete the `instana-agent` pods for its new value to take effect.

### v1.1.6

* Allow to use user-specified memony measurement units in `agent.pod.requests.memory` and `agent.pod.limits.memory`.
  If the value set is numerical, the Chart will assume it to be expressed in `Mi` for backwards compatibility.
* Exposed `agent.updateStrategy.type` and `agent.updateStrategy.rollingUpdate.maxUnavailable` settings.

### v1.1.5

Restore compatibility with Helm 2 that was broken in v1.1.4 by the usage of the `lookup` function, a function actually introduced only with Helm 3.1.
Coincidentally, this has been an _excellent_ opportunity to introduce `helm lint` to our validation pipeline and end-to-end tests with Helm 2 ;-)

### v1.1.4

* Bring-your-own secret for agent keys: using the new `agent.keysSecret` setting, you can specify the name of the secret that contains the agent key and, optionally, the download key; refer to [Bring your own Keys secret](#bring-your-own-keys-secret) for more details.
* Add support for affinities for the instana agent pod via the `agent.pod.affinity` setting.
* Put some love into the ArtifactHub.io metadata; likely to add some more improvements related to this over time.

### v1.1.3

* No new features, just ironing some wrinkles out of our release automation.

### v1.1.2

* Improvement: Seamless support for Instana static agent images: When using an `agent.image.name` starting with `containers.instana.io`, automatically create a secret called `containers-instana-io` containing the `.dockerconfigjson` for `containers.instana.io`, using `_` as username and `agent.downloadKey` or, if missing, `agent.key` as password. If you want to control the creation of the image pull secret, or disable it, you can use `agent.image.pullSecrets`, passing to it the YAML to use for the `imagePullSecrets` field of the Daemonset spec, including an empty array `[]` to mount no pull secrets, no matter what.

### v1.1.1

* Fix: Recreate the `instana-agent` pods when there is a change in one of the following configuration, which are mapped to the chart-managed ConfigMap:

* `agent.configuration_yaml`
* `agent.additional_backends`

The pod recreation is achieved by annotating the `instana-agent` Pod with a new `instana-configuration-hash` annotation that has, as value, the SHA-1 hash of the configurations used to populate the ConfigMap.
This way, when the configuration changes, the respective change in the `instana-configuration-hash` annotation will cause the agent pods to be recreated.
This technique has been described at [1] (or, at least, that is were we learned about it) and it is pretty cool :-)

### v1.1.0

* Improvement: The `instana-agent` Helm chart has a new home at `https://agents.instana.io/helm` and `https://github.com/instana/helm-charts/instana-agent`!
This release is functionally equivalent to `1.0.34`, but we bumped the major to denote the new location ;-)
