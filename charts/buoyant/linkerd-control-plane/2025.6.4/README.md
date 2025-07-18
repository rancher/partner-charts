# linkerd-control-plane

Linkerd gives you observability, reliability, and security
for your microservices — with no code change required.

![Version: 2025.6.4](https://img.shields.io/badge/Version-2025.6.4-informational?style=flat-square)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: edge-XX.X.X](https://img.shields.io/badge/AppVersion-edge--XX.X.X-informational?style=flat-square)

**Homepage:** <https://linkerd.io>

## Quickstart and documentation

You can run Linkerd on any Kubernetes cluster in a matter of seconds. See the
[Linkerd Getting Started Guide][getting-started] for how.

For more comprehensive documentation, start with the [Linkerd
docs][linkerd-docs].

## Prerequisite: linkerd-crds chart

Before installing this chart, please install the `linkerd-crds` chart, which
creates all the CRDs that the components from the current chart require.

## Prerequisite: identity certificates

The identity component of Linkerd requires setting up a trust anchor
certificate, and an issuer certificate with its key. These need to be provided
to Helm by the user (unlike when using the `linkerd install` CLI which can
generate these automatically). You can provide your own, or follow [these
instructions](https://linkerd.io/2/tasks/generate-certificates/) to generate new
ones.

Alternatively, both trust anchor and identity issuer certificates may be
derived from in-cluster resources. Existing CA (trust anchor) certificates
**must** live in a `ConfigMap` resource named `linkerd-identity-trust-roots`.
Issuer certificates **must** live in a `Secret` named
`linkerd-identity-issuer`. Both resources should exist in the control-plane's
install namespace. In order to use an existing CA, Linkerd needs to be
installed with `identity.externalCA=true`. To use an existing issuer
certificate, Linkerd should be installed with
`identity.issuer.scheme=kubernetes.io/tls`.

A more comprehensive description is in the [automatic certificate rotation
guide](https://linkerd.io/2.12/tasks/automatically-rotating-control-plane-tls-credentials/#a-note-on-third-party-cert-management-solutions).

Note that the provided certificates must be ECDSA certificates.

## Adding Linkerd's Helm repository

Included here for completeness-sake, but should have already been added when
`linkerd-base` was installed.

```bash
# To add the repo for Linkerd edge releases:
helm repo add linkerd https://helm.linkerd.io/edge
```

## Installing the chart

You must provide the certificates and keys described in the preceding section,
and the same expiration date you used to generate the Issuer certificate.

```bash
helm install linkerd-control-plane -n linkerd \
  --set-file identityTrustAnchorsPEM=ca.crt \
  --set-file identity.issuer.tls.crtPEM=issuer.crt \
  --set-file identity.issuer.tls.keyPEM=issuer.key \
  linkerd/linkerd-control-plane
```

Note that you require to install this chart in the same namespace you installed
the `linkerd-base` chart.

## Setting High-Availability

Besides the default `values.yaml` file, the chart provides a `values-ha.yaml`
file that overrides some default values as to set things up under a
high-availability scenario, analogous to the `--ha` option in `linkerd install`.
Values such as higher number of replicas, higher memory/cpu limits and
affinities are specified in that file.

You can get ahold of `values-ha.yaml` by fetching the chart files:

```bash
helm fetch --untar linkerd/linkerd-control-plane
```

Then use the `-f` flag to provide the override file, for example:

```bash
helm install linkerd-control-plane -n linkerd \
  --set-file identityTrustAnchorsPEM=ca.crt \
  --set-file identity.issuer.tls.crtPEM=issuer.crt \
  --set-file identity.issuer.tls.keyPEM=issuer.key \
  -f linkerd2/values-ha.yaml
  linkerd/linkerd-control-plane
```

## Get involved

* Check out Linkerd's source code at [GitHub][linkerd2].
* Join Linkerd's [user mailing list][linkerd-users], [developer mailing
  list][linkerd-dev], and [announcements mailing list][linkerd-announce].
* Follow [@linkerd][twitter] on Twitter.
* Join the [Linkerd Slack][slack].

[getting-started]: https://linkerd.io/2/getting-started/
[linkerd2]: https://github.com/linkerd/linkerd2
[linkerd-announce]: https://lists.cncf.io/g/cncf-linkerd-announce
[linkerd-dev]: https://lists.cncf.io/g/cncf-linkerd-dev
[linkerd-docs]: https://linkerd.io/2/overview/
[linkerd-users]: https://lists.cncf.io/g/cncf-linkerd-users
[slack]: http://slack.linkerd.io
[twitter]: https://twitter.com/linkerd

## Extensions for Linkerd

The current chart installs the core Linkerd components, which grant you
reliability and security features. Other functionality is available through
extensions. Check the corresponding docs for each one of the following
extensions:

* Observability:
  [Linkerd-viz](https://github.com/linkerd/linkerd2/blob/main/viz/charts/linkerd-viz/README.md)
* Multicluster:
  [Linkerd-multicluster](https://github.com/linkerd/linkerd2/blob/main/multicluster/charts/linkerd-multicluster/README.md)
* Tracing:
  [Linkerd-jaeger](https://github.com/linkerd/linkerd2/blob/main/jaeger/charts/linkerd-jaeger/README.md)

## Requirements

Kubernetes: `>=1.23.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../partials | partials | 0.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| clusterDomain | string | `"cluster.local"` | Kubernetes DNS Domain name to use |
| clusterNetworks | string | `"10.0.0.0/8,100.64.0.0/10,172.16.0.0/12,192.168.0.0/16,fd00::/8"` | The cluster networks for which service discovery is performed. This should include the pod and service networks, but need not include the node network.  By default, all IPv4 private networks and all accepted IPv6 ULAs are specified so that resolution works in typical Kubernetes environments. |
| cniEnabled | bool | `false` | enabling this omits the NET_ADMIN capability in the PSP and the proxy-init container when injecting the proxy; requires the linkerd-cni plugin to already be installed |
| commonLabels | object | `{}` | Labels to apply to all resources |
| configReaders | string | `nil` | List of additional service accounts with read access to the linkerd-config ConfigMap |
| controlPlaneTracing | bool | `false` | enables control plane tracing |
| controlPlaneTracingNamespace | string | `"linkerd-jaeger"` | namespace to send control plane traces to |
| controller.podDisruptionBudget | object | `{"maxUnavailable":1}` | sets pod disruption budget parameter for all deployments |
| controller.podDisruptionBudget.maxUnavailable | int | `1` | Maximum number of pods that can be unavailable during disruption |
| controllerGID | int | `-1` | Optional customisation of the group ID for the control plane components (the group ID will be omitted if lower than 0) |
| controllerImage | string | `"cr.l5d.io/linkerd/controller"` | Docker image for the destination and identity components |
| controllerImageVersion | string | `""` | Optionally allow a specific container image Tag (or SHA) to be specified for the controllerImage. |
| controllerLogFormat | string | `"plain"` | Log format for the control plane components |
| controllerLogLevel | string | `"info"` | Log level for the control plane components |
| controllerReplicas | int | `1` | Number of replicas for each control plane pod |
| controllerUID | int | `2103` | User ID for the control plane components |
| debugContainer.image.name | string | `"cr.l5d.io/linkerd/debug"` | Docker image for the debug container |
| debugContainer.image.pullPolicy | string | imagePullPolicy | Pull policy for the debug container image |
| debugContainer.image.version | string | linkerdVersion | Tag for the debug container image |
| deploymentStrategy | object | `{"rollingUpdate":{"maxSurge":"25%","maxUnavailable":"25%"}}` | default kubernetes deployment strategy |
| destinationController.livenessProbe.timeoutSeconds | int | `1` |  |
| destinationController.meshedHttp2ClientProtobuf.keep_alive.interval.seconds | int | `10` |  |
| destinationController.meshedHttp2ClientProtobuf.keep_alive.timeout.seconds | int | `3` |  |
| destinationController.meshedHttp2ClientProtobuf.keep_alive.while_idle | bool | `true` |  |
| destinationController.podAnnotations | object | `{}` | Additional annotations to add to destination pods |
| destinationController.readinessProbe.timeoutSeconds | int | `1` |  |
| disableHeartBeat | bool | `false` | Set to true to not start the heartbeat cronjob |
| disableIPv6 | bool | `true` | disables routing IPv6 traffic in addition to IPv4 traffic through the proxy (IPv6 routing only available as of proxy-init v2.3.0 and linkerd-cni v1.4.0) |
| egress.globalEgressNetworkNamespace | string | `"linkerd-egress"` | The namespace that is used to store egress configuration that affects all client workloads in the cluster |
| enableEndpointSlices | bool | `true` | enables the use of EndpointSlice informers for the destination service; enableEndpointSlices should be set to true only if EndpointSlice K8s feature gate is on |
| enableH2Upgrade | bool | `true` | Allow proxies to perform transparent HTTP/2 upgrading |
| enablePSP | bool | `false` | Add a PSP resource and bind it to the control plane ServiceAccounts. Note PSP has been deprecated since k8s v1.21 |
| enablePodAntiAffinity | bool | `false` | enables pod anti affinity creation on deployments for high availability |
| enablePodDisruptionBudget | bool | `false` | enables the creation of pod disruption budgets for control plane components |
| enablePprof | bool | `false` | enables the use of pprof endpoints on control plane component's admin servers |
| identity.externalCA | bool | `false` | If the linkerd-identity-trust-roots ConfigMap has already been created |
| identity.issuer.clockSkewAllowance | string | `"20s"` | Amount of time to allow for clock skew within a Linkerd cluster |
| identity.issuer.issuanceLifetime | string | `"24h0m0s"` | Amount of time for which the Identity issuer should certify identity |
| identity.issuer.scheme | string | `"linkerd.io/tls"` |  |
| identity.issuer.tls | object | `{"crtPEM":"","keyPEM":""}` | Which scheme is used for the identity issuer secret format |
| identity.issuer.tls.crtPEM | string | `""` | Issuer certificate (ECDSA). It must be provided during install. |
| identity.issuer.tls.keyPEM | string | `""` | Key for the issuer certificate (ECDSA). It must be provided during install |
| identity.kubeAPI.clientBurst | int | `200` | Burst value over clientQPS |
| identity.kubeAPI.clientQPS | int | `100` | Maximum QPS sent to the kube-apiserver before throttling. See [token bucket rate limiter implementation](https://github.com/kubernetes/client-go/blob/v12.0.0/util/flowcontrol/throttle.go) |
| identity.livenessProbe.timeoutSeconds | int | `1` |  |
| identity.podAnnotations | object | `{}` | Additional annotations to add to identity pods |
| identity.readinessProbe.timeoutSeconds | int | `1` |  |
| identity.serviceAccountTokenProjection | bool | `true` | Use [Service Account token Volume projection](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-token-volume-projection) for pod validation instead of the default token |
| identityTrustAnchorsPEM | string | `""` | Trust root certificate (ECDSA). It must be provided during install. |
| identityTrustDomain | string | clusterDomain | Trust domain used for identity |
| imagePullPolicy | string | `"IfNotPresent"` | Docker image pull policy |
| imagePullSecrets | list | `[]` | For Private docker registries, authentication is needed.  Registry secrets are applied to the respective service accounts |
| kubeAPI.clientBurst | int | `200` | Burst value over clientQPS |
| kubeAPI.clientQPS | int | `100` | Maximum QPS sent to the kube-apiserver before throttling. See [token bucket rate limiter implementation](https://github.com/kubernetes/client-go/blob/v12.0.0/util/flowcontrol/throttle.go) |
| linkerdVersion | string | `"linkerdVersionValue"` | control plane version. See Proxy section for proxy version |
| networkValidator.connectAddr | string | `""` | Address to which the network-validator will attempt to connect. This should be an IP that the cluster is expected to be able to reach but a port it should not, e.g., a public IP for public clusters and a private IP for air-gapped clusters with a port like 20001. If empty, defaults to 1.1.1.1:20001 and [fd00::1]:20001 for IPv4 and IPv6 respectively. |
| networkValidator.enableSecurityContext | bool | `true` | Include a securityContext in the network-validator pod spec |
| networkValidator.listenAddr | string | `""` | Address to which network-validator listens to requests from itself. If empty, defaults to 0.0.0.0:4140 and [::]:4140 for IPv4 and IPv6 respectively. |
| networkValidator.logFormat | string | plain | Log format (`plain` or `json`) for network-validator |
| networkValidator.logLevel | string | debug | Log level for the network-validator |
| networkValidator.timeout | string | `"10s"` | Timeout before network-validator fails to validate the pod's network connectivity |
| nodeSelector | object | `{"kubernetes.io/os":"linux"}` | NodeSelector section, See the [K8S documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector) for more information |
| podAnnotations | object | `{}` | Additional annotations to add to all pods |
| podLabels | object | `{}` | Additional labels to add to all pods |
| podMonitor.controller.enabled | bool | `true` | Enables the creation of PodMonitor for the control-plane |
| podMonitor.controller.namespaceSelector | string | `"matchNames:\n  - {{ .Release.Namespace }}\n  - linkerd-viz\n  - linkerd-jaeger\n"` | Selector to select which namespaces the Endpoints objects are discovered from |
| podMonitor.enabled | bool | `false` | Enables the creation of Prometheus Operator [PodMonitor](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1.PodMonitor) |
| podMonitor.labels | object | `{}` | Labels to apply to all pod Monitors |
| podMonitor.proxy.enabled | bool | `true` | Enables the creation of PodMonitor for the data-plane |
| podMonitor.scrapeInterval | string | `"10s"` | Interval at which metrics should be scraped |
| podMonitor.scrapeTimeout | string | `"10s"` | Iimeout after which the scrape is ended |
| podMonitor.serviceMirror.enabled | bool | `true` | Enables the creation of PodMonitor for the Service Mirror component |
| policyController.image.name | string | `"cr.l5d.io/linkerd/policy-controller"` | Docker image for the policy controller |
| policyController.image.pullPolicy | string | imagePullPolicy | Pull policy for the policy controller container image |
| policyController.image.version | string | linkerdVersion | Tag for the policy controller container image |
| policyController.livenessProbe.timeoutSeconds | int | `1` |  |
| policyController.logLevel | string | `"info"` | Log level for the policy controller |
| policyController.probeNetworks | list | `["0.0.0.0/0","::/0"]` | The networks from which probes are performed.  By default, all networks are allowed so that all probes are authorized. |
| policyController.readinessProbe.timeoutSeconds | int | `1` |  |
| policyController.resources | object | `{"cpu":{"limit":"","request":""},"ephemeral-storage":{"limit":"","request":""},"memory":{"limit":"","request":""}}` | policy controller resource requests & limits |
| policyController.resources.cpu.limit | string | `""` | Maximum amount of CPU units that the policy controller can use |
| policyController.resources.cpu.request | string | `""` | Amount of CPU units that the policy controller requests |
| policyController.resources.ephemeral-storage.limit | string | `""` | Maximum amount of ephemeral storage that the policy controller can use |
| policyController.resources.ephemeral-storage.request | string | `""` | Amount of ephemeral storage that the policy controller requests |
| policyController.resources.memory.limit | string | `""` | Maximum amount of memory that the policy controller can use |
| policyController.resources.memory.request | string | `""` | Maximum amount of memory that the policy controller requests |
| policyValidator.caBundle | string | `""` | Bundle of CA certificates for proxy injector. If not provided nor injected with cert-manager, then Helm will use the certificate generated for `policyValidator.crtPEM`. If `policyValidator.externalSecret` is set to true, this value, injectCaFrom, or injectCaFromSecret must be set, as no certificate will be generated. See the cert-manager [CA Injector Docs](https://cert-manager.io/docs/concepts/ca-injector) for more information. |
| policyValidator.crtPEM | string | `""` | Certificate for the policy validator. If not provided and not using an external secret then Helm will generate one. |
| policyValidator.externalSecret | bool | `false` | Do not create a secret resource for the policyValidator webhook. If this is set to `true`, the value `policyValidator.caBundle` must be set or the ca bundle must injected with cert-manager ca injector using `policyValidator.injectCaFrom` or `policyValidator.injectCaFromSecret` (see below). |
| policyValidator.injectCaFrom | string | `""` | Inject the CA bundle from a cert-manager Certificate. See the cert-manager [CA Injector Docs](https://cert-manager.io/docs/concepts/ca-injector/#injecting-ca-data-from-a-certificate-resource) for more information. |
| policyValidator.injectCaFromSecret | string | `""` | Inject the CA bundle from a Secret. If set, the `cert-manager.io/inject-ca-from-secret` annotation will be added to the webhook. The Secret must have the CA Bundle stored in the `ca.crt` key and have the `cert-manager.io/allow-direct-injection` annotation set to `true`. See the cert-manager [CA Injector Docs](https://cert-manager.io/docs/concepts/ca-injector/#injecting-ca-data-from-a-secret-resource) for more information. |
| policyValidator.keyPEM | string | `""` | Certificate key for the policy validator. If not provided and not using an external secret then Helm will generate one. |
| policyValidator.namespaceSelector | object | `{"matchExpressions":[{"key":"config.linkerd.io/admission-webhooks","operator":"NotIn","values":["disabled"]}]}` | Namespace selector used by admission webhook |
| priorityClassName | string | `""` | Kubernetes priorityClassName for the Linkerd Pods |
| profileValidator.caBundle | string | `""` | Bundle of CA certificates for proxy injector. If not provided nor injected with cert-manager, then Helm will use the certificate generated for `profileValidator.crtPEM`. If `profileValidator.externalSecret` is set to true, this value, injectCaFrom, or injectCaFromSecret must be set, as no certificate will be generated. See the cert-manager [CA Injector Docs](https://cert-manager.io/docs/concepts/ca-injector) for more information. |
| profileValidator.crtPEM | string | `""` | Certificate for the service profile validator. If not provided and not using an external secret then Helm will generate one. |
| profileValidator.externalSecret | bool | `false` | Do not create a secret resource for the profileValidator webhook. If this is set to `true`, the value `proxyInjector.caBundle` must be set or the ca bundle must injected with cert-manager ca injector using `proxyInjector.injectCaFrom` or `proxyInjector.injectCaFromSecret` (see below). |
| profileValidator.injectCaFrom | string | `""` | Inject the CA bundle from a cert-manager Certificate. See the cert-manager [CA Injector Docs](https://cert-manager.io/docs/concepts/ca-injector/#injecting-ca-data-from-a-certificate-resource) for more information. |
| profileValidator.injectCaFromSecret | string | `""` | Inject the CA bundle from a Secret. If set, the `cert-manager.io/inject-ca-from-secret` annotation will be added to the webhook. The Secret must have the CA Bundle stored in the `ca.crt` key and have the `cert-manager.io/allow-direct-injection` annotation set to `true`. See the cert-manager [CA Injector Docs](https://cert-manager.io/docs/concepts/ca-injector/#injecting-ca-data-from-a-secret-resource) for more information. |
| profileValidator.keyPEM | string | `""` | Certificate key for the service profile validator. If not provided and not using an external secret then Helm will generate one. |
| profileValidator.namespaceSelector | object | `{"matchExpressions":[{"key":"config.linkerd.io/admission-webhooks","operator":"NotIn","values":["disabled"]}]}` | Namespace selector used by admission webhook |
| prometheusUrl | string | `""` | url of external prometheus instance (used for the heartbeat) |
| proxy.await | bool | `true` | If set, the application container will not start until the proxy is ready |
| proxy.control.streams.idleTimeout | string | `"5m"` | The timeout between consecutive updates from the control plane. |
| proxy.control.streams.initialTimeout | string | `"3s"` | The timeout for the first update from the control plane. |
| proxy.control.streams.lifetime | string | `"1h"` | The maximum duration for a response stream (i.e. before it will be reinitialized). |
| proxy.cores | string | `nil` | Deprecated: use runtime.workers.minimum |
| proxy.defaultInboundPolicy | string | "all-unauthenticated" | The default allow policy to use when no `Server` selects a pod.  One of: "all-authenticated", "all-unauthenticated", "cluster-authenticated", "cluster-unauthenticated", "deny", "audit" |
| proxy.disableInboundProtocolDetectTimeout | bool | `false` | When set to true, disables the protocol detection timeout on the inbound side of the proxy by setting it to a very high value |
| proxy.disableOutboundProtocolDetectTimeout | bool | `false` | When set to true, disables the protocol detection timeout on the outbound side of the proxy by setting it to a very high value |
| proxy.enableExternalProfiles | bool | `false` | Enable service profiles for non-Kubernetes services |
| proxy.enableShutdownEndpoint | bool | `false` | Enables the proxy's /shutdown admin endpoint |
| proxy.gid | int | `-1` | Optional customisation of the group id under which the proxy runs (the group ID will be omitted if lower than 0) |
| proxy.image.name | string | `"cr.l5d.io/linkerd/proxy"` | Docker image for the proxy |
| proxy.image.pullPolicy | string | imagePullPolicy | Pull policy for the proxy container image |
| proxy.image.version | string | linkerdVersion | Tag for the proxy container image |
| proxy.inbound.server.http2.keepAliveInterval | string | `"10s"` | The interval at which PINGs are issued to remote HTTP/2 clients. |
| proxy.inbound.server.http2.keepAliveTimeout | string | `"3s"` | The timeout within which keep-alive PINGs must be acknowledged on inbound HTTP/2 connections. |
| proxy.inboundConnectTimeout | string | `"100ms"` | Maximum time allowed for the proxy to establish an inbound TCP connection |
| proxy.inboundDiscoveryCacheUnusedTimeout | string | `"90s"` | Maximum time allowed before an unused inbound discovery result is evicted from the cache |
| proxy.livenessProbe | object | `{"initialDelaySeconds":10,"timeoutSeconds":1}` | LivenessProbe timeout and delay configuration |
| proxy.logFormat | string | `"plain"` | Log format (`plain` or `json`) for the proxy |
| proxy.logHTTPHeaders | `off` or `insecure` | `"off"` | If set to `off`, will prevent the proxy from logging HTTP headers. If set to `insecure`, HTTP headers may be logged verbatim. Note that setting this to `insecure` is not alone sufficient to log HTTP headers; the proxy logLevel must also be set to debug. |
| proxy.logLevel | string | `"warn,linkerd=info,hickory=error"` | Log level for the proxy |
| proxy.metrics.hostnameLabels | bool | `false` | Whether or not to export hostname labels in outbound request metrics. |
| proxy.nativeSidecar | bool | `false` | Enable KEP-753 native sidecars This is an experimental feature. It requires Kubernetes >= 1.29. If enabled, .proxy.waitBeforeExitSeconds should not be used. |
| proxy.opaquePorts | string | `"25,587,3306,4444,5432,6379,9300,11211"` | Default set of opaque ports - SMTP (25,587) server-first - MYSQL (3306) server-first - Galera (4444) server-first - PostgreSQL (5432) server-first - Redis (6379) server-first - ElasticSearch (9300) server-first - Memcached (11211) clients do not issue any preamble, which breaks detection |
| proxy.outbound.server.http2.keepAliveInterval | string | `"10s"` | The interval at which PINGs are issued to local application HTTP/2 clients. |
| proxy.outbound.server.http2.keepAliveTimeout | string | `"3s"` | The timeout within which keep-alive PINGs must be acknowledged on outbound HTTP/2 connections. |
| proxy.outboundConnectTimeout | string | `"1000ms"` | Maximum time allowed for the proxy to establish an outbound TCP connection |
| proxy.outboundDiscoveryCacheUnusedTimeout | string | `"5s"` | Maximum time allowed before an unused outbound discovery result is evicted from the cache |
| proxy.outboundTransportMode | string | `"transport-header"` | Configures the outbound transport mode. Valid values are "transport-header" and "transparent" |
| proxy.ports.admin | int | `4191` | Admin port for the proxy container |
| proxy.ports.control | int | `4190` | Control port for the proxy container |
| proxy.ports.inbound | int | `4143` | Inbound port for the proxy container |
| proxy.ports.outbound | int | `4140` | Outbound port for the proxy container |
| proxy.readinessProbe | object | `{"initialDelaySeconds":2,"timeoutSeconds":1}` | ReadinessProbe timeout and delay configuration |
| proxy.requireIdentityOnInboundPorts | string | `""` |  |
| proxy.resources.cpu | object | `{"limit":"","request":""}` | CPU configuration, when specified globally in Helm values, should be kept in sync with the above runtime.workers.minimum configuration. The minimum should reflect _at least_ the CPU request. When a limit is set, the minimum should match the limit (and the maximumCPURatio should be unset). |
| proxy.resources.cpu.limit | string | `""` | Maximum amount of CPU units that the proxy can use |
| proxy.resources.cpu.request | string | `""` | Amount of CPU units that the proxy requests |
| proxy.resources.ephemeral-storage.limit | string | `""` | Maximum amount of ephemeral storage that the proxy can use |
| proxy.resources.ephemeral-storage.request | string | `""` | Amount of ephemeral storage that the proxy requests |
| proxy.resources.memory.limit | string | `""` | Maximum amount of memory that the proxy can use |
| proxy.resources.memory.request | string | `""` | Maximum amount of memory that the proxy requests |
| proxy.runtime.workers | object | `{"maximumCPURatio":null,"minimum":1}` | Worker threadpool configuration. The minimum will be automatically derived from workload proxy CPU requests, when they are configured by annotation. A cluster-level maximum may be configured here (and a workload-level annotation is supported as well). |
| proxy.runtime.workers.maximumCPURatio | string | `nil` | Maximum number of worker threads that the proxy can use, by ratio of the number of available CPUs. A value of 1.0 allocates a worker thread for all available CPUs. A value of 0.1 allocates a worker thread for 10% of the available CPUs. |
| proxy.runtime.workers.minimum | int | `1` | Configures a lower bound on the number of worker threads that the proxy can use. When maximumCPURatio is not set, this value is used. |
| proxy.shutdownGracePeriod | string | `""` | Grace period for graceful proxy shutdowns. If this timeout elapses before all open connections have completed, the proxy will terminate forcefully, closing any remaining connections. |
| proxy.startupProbe.failureThreshold | int | `120` |  |
| proxy.startupProbe.initialDelaySeconds | int | `0` |  |
| proxy.startupProbe.periodSeconds | int | `1` |  |
| proxy.tracing.collector.endpoint | string | `""` | The collector endpoint to send traces to. |
| proxy.tracing.collector.meshIdentity | object | `{"serviceAccountName":""}` | The identity of the collector in the linkerd mesh. If the collector is unmeshed, this should remain unset. |
| proxy.tracing.enable | bool | `false` | Enables trace collection and export in the proxy |
| proxy.tracing.traceServiceName | string | `"linkerd-proxy"` |  |
| proxy.uid | int | `2102` | User id under which the proxy runs |
| proxy.waitBeforeExitSeconds | int | `0` | If set the injected proxy sidecars in the data plane will stay alive for at least the given period before receiving the SIGTERM signal from Kubernetes but no longer than the pod's `terminationGracePeriodSeconds`. See [Lifecycle hooks](https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks) for more info on container lifecycle hooks. |
| proxyInit.closeWaitTimeoutSecs | int | `0` | Changes the default value for the nf_conntrack_tcp_timeout_close_wait kernel parameter. If used, runAsRoot needs to be true. |
| proxyInit.ignoreInboundPorts | string | `"4567,4568"` | Default set of inbound ports to skip via iptables - Galera (4567,4568) |
| proxyInit.ignoreOutboundPorts | string | `"4567,4568"` | Default set of outbound ports to skip via iptables - Galera (4567,4568) |
| proxyInit.image.name | string | `"cr.l5d.io/linkerd/proxy-init"` | Docker image for the proxy-init container |
| proxyInit.image.pullPolicy | string | imagePullPolicy | Pull policy for the proxy-init container image |
| proxyInit.image.version | string | `"v2.4.2"` | Tag for the proxy-init container image |
| proxyInit.iptablesMode | string | `"legacy"` | Variant of iptables that will be used to configure routing. Currently, proxy-init can be run either in 'nft' or in 'legacy' mode. The mode will control which utility binary will be called. The host must support whichever mode will be used |
| proxyInit.kubeAPIServerPorts | string | `"443,6443"` | Default set of ports to skip via iptables for control plane components so they can communicate with the Kubernetes API Server |
| proxyInit.logFormat | string | plain | Log format (`plain` or `json`) for the proxy-init |
| proxyInit.logLevel | string | info | Log level for the proxy-init |
| proxyInit.privileged | bool | false | Privileged mode allows the container processes to inherit all security capabilities and bypass any security limitations enforced by the kubelet. When used with 'runAsRoot: true', the container will behave exactly as if it was running as root on the host. May escape cgroup limits and see other processes and devices on the host. |
| proxyInit.runAsGroup | int | `65534` | This value is used only if runAsRoot is false; otherwise runAsGroup will be 0 |
| proxyInit.runAsRoot | bool | `false` | Allow overriding the runAsNonRoot behaviour (<https://github.com/linkerd/linkerd2/issues/7308>) |
| proxyInit.runAsUser | int | `65534` | This value is used only if runAsRoot is false; otherwise runAsUser will be 0 |
| proxyInit.skipSubnets | string | `""` | Comma-separated list of subnets in valid CIDR format that should be skipped by the proxy |
| proxyInit.xtMountPath.mountPath | string | `"/run"` |  |
| proxyInit.xtMountPath.name | string | `"linkerd-proxy-init-xtables-lock"` |  |
| proxyInjector.caBundle | string | `""` | Bundle of CA certificates for proxy injector. If not provided nor injected with cert-manager, then Helm will use the certificate generated for `proxyInjector.crtPEM`. If `proxyInjector.externalSecret` is set to true, this value, injectCaFrom, or injectCaFromSecret must be set, as no certificate will be generated. See the cert-manager [CA Injector Docs](https://cert-manager.io/docs/concepts/ca-injector) for more information. |
| proxyInjector.crtPEM | string | `""` | Certificate for the proxy injector. If not provided and not using an external secret then Helm will generate one. |
| proxyInjector.externalSecret | bool | `false` | Do not create a secret resource for the proxyInjector webhook. If this is set to `true`, the value `proxyInjector.caBundle` must be set or the ca bundle must injected with cert-manager ca injector using `proxyInjector.injectCaFrom` or `proxyInjector.injectCaFromSecret` (see below). |
| proxyInjector.injectCaFrom | string | `""` | Inject the CA bundle from a cert-manager Certificate. See the cert-manager [CA Injector Docs](https://cert-manager.io/docs/concepts/ca-injector/#injecting-ca-data-from-a-certificate-resource) for more information. |
| proxyInjector.injectCaFromSecret | string | `""` | Inject the CA bundle from a Secret. If set, the `cert-manager.io/inject-ca-from-secret` annotation will be added to the webhook. The Secret must have the CA Bundle stored in the `ca.crt` key and have the `cert-manager.io/allow-direct-injection` annotation set to `true`. See the cert-manager [CA Injector Docs](https://cert-manager.io/docs/concepts/ca-injector/#injecting-ca-data-from-a-secret-resource) for more information. |
| proxyInjector.keyPEM | string | `""` | Certificate key for the proxy injector. If not provided and not using an external secret then Helm will generate one. |
| proxyInjector.livenessProbe.timeoutSeconds | int | `1` |  |
| proxyInjector.namespaceSelector | object | `{"matchExpressions":[{"key":"config.linkerd.io/admission-webhooks","operator":"NotIn","values":["disabled"]},{"key":"kubernetes.io/metadata.name","operator":"NotIn","values":["kube-system","cert-manager"]}]}` | Namespace selector used by admission webhook. |
| proxyInjector.objectSelector | object | `{"matchExpressions":[{"key":"linkerd.io/control-plane-component","operator":"DoesNotExist"},{"key":"linkerd.io/cni-resource","operator":"DoesNotExist"}]}` | Object selector used by admission webhook. |
| proxyInjector.podAnnotations | object | `{}` | Additional annotations to add to proxy-injector pods |
| proxyInjector.readinessProbe.timeoutSeconds | int | `1` |  |
| proxyInjector.timeoutSeconds | int | `10` | Timeout in seconds before the API Server cancels a request to the proxy injector. If timeout is exceeded, the webhookfailurePolicy is used. |
| revisionHistoryLimit | int | `10` | Specifies the number of old ReplicaSets to retain to allow rollback. |
| runtimeClassName | string | `""` | Runtime Class Name for all the pods |
| spValidator | object | `{"livenessProbe":{"timeoutSeconds":1},"readinessProbe":{"timeoutSeconds":1}}` | SP validator configuration |
| webhookFailurePolicy | string | `"Ignore"` | Failure policy for the proxy injector |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
