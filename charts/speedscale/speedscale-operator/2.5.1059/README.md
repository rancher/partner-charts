![GitHub Tag](https://img.shields.io/github/v/tag/speedscale/operator-helm)


# Speedscale Operator

The [Speedscale](https://www.speedscale.com) Operator is a [Kubernetes operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
that watches for deployments to be applied to the cluster and takes action based on annotations. The operator
can inject a proxy to capture traffic into or out of applications, or setup an isolation test environment around
a deployment for testing. The operator itself is a deployment that will be always present on the cluster once
the helm chart is installed.

## Prerequisites

- Kubernetes 1.20+
- Helm 3+
- Appropriate [network and firewall configuration](https://docs.speedscale.com/reference/networking) for Speedscale cloud and webhook traffic

## Get Repo Info

```bash
helm repo add speedscale https://speedscale.github.io/operator-helm/
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

An API key is required. Sign up for a [free Speedscale trial](https://speedscale.com/free-trial/) if you do not have one.

```bash
helm install speedscale-operator speedscale/speedscale-operator \
	-n speedscale \
	--create-namespace \
	--set apiKey=<YOUR-SPEEDSCALE-API-KEY> \
	--set clusterName=<YOUR-CLUSTER-NAME>
```

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

### Custom Redis and Java images

Set image.registry to mirror Speedscale images in your registry. To select Redis or Java independently, supply full image references in a values file:

```yaml
replayComponents:
  redis:
    image: registry.example.com/cache/redis:7.4
jks:
  image: registry.example.com/java/amazoncorretto:23
image:
  pullSecrets:
    - name: registry-credentials
```

Pass the file with helm install -f values.yaml or helm upgrade -f values.yaml. Image references may include tags or digests. Empty overrides retain the existing registry and tag defaults, including imageTags.redis.

The Redis image must provide redis-server on PATH and accept the standard Redis 7.4 command-line options. The operator starts it directly with persistence disabled; image entrypoint scripts are bypassed.

The Java image must provide a Java 11+ runtime on PATH and a readable default truststore with password changeit. Set jks.truststorePath if the image stores its truststore elsewhere. The chart mounts a compiled Java program that preserves the image's CA certificates, adds the Speedscale CA, and creates or patches speedscale-jks using the Job's Kubernetes service account. No compiler, shell, kubectl, curl, or operator helper command is required. Existing Secret metadata and unrelated data keys are preserved, and non-certificate entries in the source truststore are skipped. Provisioning failures fail the Job; an existing Secret is replaced only when it rejects the patch, for example because it is immutable.

The Job runs under the chart's globalPodSecurityContext and globalSecurityContext (non-root, read-only root filesystem), so a custom jks.image must expose a truststore readable by that UID. Existing registry defaults and service-mesh settings are retained. The program attempts the existing Istio shutdown request before exiting. The Job does not depend on the operator image version. createJKS: false continues to support a pre-provisioned Secret.

Create pull Secrets in the installation namespace before installing. The operator adds them to replay components and to every workload it injects a sidecar into, so the Secret must also exist in each of those namespaces. Changing replayComponents or imageTags restarts the operator so subsequent replays use the new configuration. Truststore creation remains a pre-install hook; changing the Java image during an upgrade does not regenerate an existing truststore.

### Pre-install job failure

We use pre-install job to check provided API key and provision some of the required resources.

If the job failed during the installation, you'll see the following error during install:

```
Error: INSTALLATION FAILED: failed pre-install: job failed: BackoffLimitExceeded
```

You can inspect the logs using this command:

```bash
kubectl -n speedscale logs job/speedscale-operator-pre-install
```

After fixing the error, uninstall the helm release, delete the failed job
and try installing again:

```bash
helm -n speedscale uninstall speedscale-operator
kubectl -n speedscale delete job speedscale-operator-pre-install
```

## Uninstall Chart

```bash
helm -n speedscale uninstall speedscale-operator
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

CRDs created by this chart are not removed by default and should be manually cleaned up:

```bash
kubectl delete crd trafficreplays.speedscale.com
```

## Upgrading Chart

```bash
helm repo update
helm -n speedscale upgrade speedscale-operator speedscale/speedscale-operator
```

Resources capturing traffic will need to be rolled to pick up the latest
Speedscale sidecar. Use the rollout restart command for each namespace and
resource type:

```bash
kubectl -n <namespace> rollout restart deployment
```

With Helm v3, CRDs created by this chart are not updated by default
and should be manually updated.
Consult also the [Helm Documentation on CRDs](https://helm.sh/docs/chart_best_practices/custom_resource_definitions).

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

### Upgrading an existing Release to a new version

A major chart version change (like v1.2.3 -> v2.0.0) indicates that there is an
incompatible breaking change needing manual actions.


## Help

Speedscale docs information available at [docs.speedscale.com](https://docs.speedscale.com) or join us
on the [Speedscale community Slack](https://join.slack.com/t/speedscalecommunity/shared_invite/zt-x5rcrzn4-XHG1QqcHNXIM~4yozRrz8A)!
