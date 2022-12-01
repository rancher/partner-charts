# Speedscale Operator

The [Speedscale](https://www.speedscale.com) Operator is a [Kubernetes operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
that watches for deployments to be applied to the cluster and takes action based on annotations. The operator
can inject a proxy to capture traffic into or out of applications, or setup an isolation test environment around
a deployment for testing. The operator itself is a deployment that will be always present on the cluster once
the helm chart is installed.

## Prerequisites

- Kubernetes 1.16+
- Helm 3+
- Appropriate [network and firewall configuration](http://docs.speedscale.com/reference/networking) for Speedscale cloud and webhook traffic

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

With Helm v3, CRDs created by this chart are not updated by default
and should be manually updated.
Consult also the [Helm Documentation on CRDs](https://helm.sh/docs/chart_best_practices/custom_resource_definitions).

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

### Upgrading an existing Release to a new version

A major chart version change (like v1.2.3 -> v2.0.0) indicates that there is an
incompatible breaking change needing manual actions.

### Upgrade to 1.0.3

BEFORE UPGRADE:

```bash
kubectl -n speedscale delete secret speedscale-gcrcreds speedscale-apikey
kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io speedscale-operator
kubectl delete mutatingwebhookconfigurations.admissionregistration.k8s.io speedscale-operator
```

```bash
kubectl apply --server-side -f https://raw.githubusercontent.com/speedscale/operator-helm/main/1.0.3/templates/crds/trafficreplays.yaml
```

### Upgrade to 1.0.0

```bash
kubectl apply --server-side -f https://raw.githubusercontent.com/speedscale/operator-helm/main/1.0.0/templates/crds/trafficreplays.yaml
```

### Upgrade to 0.12.3

```bash
kubectl apply --server-side -f https://raw.githubusercontent.com/speedscale/operator-helm/main/0.12.3/templates/crds/trafficreplays.yaml
```

### From version below 0.12.0 to 0.12.x
This upgrades speedscale-operator to v0.12.x.

Uninstall the previous release and install the chart from scratch.

## Help

Speedscale docs information available at [docs.speedscale.com](https://docs.speedscale.com) or join us
on the [Speedscale community Slack](https://join.slack.com/t/speedscalecommunity/shared_invite/zt-x5rcrzn4-XHG1QqcHNXIM~4yozRrz8A)!
