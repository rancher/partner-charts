# Dynatrace OneAgent Operator

This is the home of the Dynatrace OneAgent Operator's Helm Chart which supports the rollout and lifecycle of [Dynatrace OneAgent](https://www.dynatrace.com/support/help/get-started/introduction/what-is-oneagent/) in Kubernetes and OpenShift clusters.

Rolling out Dynatrace OneAgent via DaemonSet on a cluster is straightforward.
Maintaining its lifecycle places a burden on the operational team.

Dynatrace OneAgent Operator closes this gap by automating the repetitive steps involved in keeping Dynatrace OneAgent at its latest desired version.

## Additional Instructions

Please make sure the CRD is applied before using this chart!

```
kubectl apply -f https://github.com/Dynatrace/dynatrace-oneagent-operator/releases/latest/download/dynatrace.com_oneagents.yaml
kubectl apply -f https://github.com/Dynatrace/dynatrace-oneagent-operator/releases/latest/download/dynatrace.com_oneagentapms.yaml
```

To apply the CRD for Openshift or Openshift 3.11 follow the instructions in the [Github Repository](https://github.com/Dynatrace/helm-charts/tree/master/dynatrace-oneagent-operator/chart/default#chart-installation).