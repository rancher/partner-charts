# Linkerd 2 Chart

Linkerd is an ultra light, ultra simple, ultra powerful service mesh. Linkerd
adds security, observability, and reliability to Kubernetes, without the
complexity.

This particular Helm chart only installs the control plane core. You will also need to install the
linkerd-crds chart. This chart should be automatically installed along with any other dependencies.
If it is not installed as a dependency, install it first.

To gain access to the observability features, please install the linkerd-viz chart.
Other extensions are available (multicluster, jaeger) under the linkerd Helm repo.

Full documentation available at: https://linkerd.io/2/overview/
