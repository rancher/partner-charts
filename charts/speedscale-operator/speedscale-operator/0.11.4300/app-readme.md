# Speedscale Operator

The [Speedscale](https://www.speedscale.com) Operator is a [Kubernetes operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
that watches for deployments to be applied to the cluster and takes action based on annotations. The operator
can inject a proxy to capture traffic into or out of applications, or setup an isolation test environment around
a deployment for testing. The operator itself is a deployment that will be always present on the cluster once
the helm chart is installed.

## Install

Install the operator through this chart and annotate deployments to record traffic or replay snapshots.

## Help

Speedscale docs information available at [docs.speedscale.com](https://docs.speedscale.com) or join us
on the [Speedscale community Slack](https://join.slack.com/t/speedscalecommunity/shared_invite/zt-x5rcrzn4-XHG1QqcHNXIM~4yozRrz8A)!
