# [s3gw][s3gw-url]

s3gw is an S3-compatible service focused on deployments in a Kubernetes
environment backed by any PVC, including Longhorn. Since its inception, the
primary focus has been on cloud native deployments. However, the s3gw can be
deployed in a myriad of scenarios, provided some form of storage is attached.

s3gw is based on Ceph’s RADOSGW (RGW) but runs as a stand–alone service without
the RADOS cluster and relies on a storage backend still under heavy development
by the storage team at SUSE. A web-based UI for management and an object
explorer are also part of s3gw.

## Quickstart

To install s3gw using Helm add the chart to your Helm repository and then run
`helm install`:

```bash
helm repo add s3gw https://aquarist-labs.github.io/s3gw-charts/
helm \
  --namespace s3gw-system \
  install s3gw \
  s3gw/s3gw \
  --create-namespace \
  -f /path/to/your/custom/values.yaml
```

## Rancher

Installing s3gw via the Rancher App Catalog is made easy, the steps are as
follows:

- Cluster -> Projects/Namespaces - create the `s3gw` namespace.
- Apps -> Repositories -> Create `s3gw` using the s3gw-charts Git URL
  <https://aquarist-labs.github.io/s3gw-charts/> and the `main` branch.
- Apps -> Charts -> Install `Traefik`.
- Apps -> Charts -> Install `s3gw`. Select the `s3gw` namespace previously
  created. A `pvc` for `s3gw` will be created automatically during installation.

## Develop and test charts on the local machine

We have defined a set of common tasks frequently used during the
development and the testing process of the s3gw's charts.

### Requirements

- make
- Python 3, pip
- Docker, Docker compose
- Helm
- k3d
- Kubectl
- [ct][ct-url]

### Setup the test environment

It creates a Python venv and downloads the required pip packages used
during the charts testing.

```shell
make setup-test-environment
```

### Start a k3d cluster and deploy charts

This task spawns a k3d cluster and deploys the local charts version on it.

```shell
make cluster-start
```

### Delete the k3d cluster

It deletes the cluster created with `make cluster-start`.

```shell
make cluster-delete
```

### Lint and unittest the charts

It lints and runs the all the unittest using the ct tool.
This task requires you previously created the k3d cluster with
`make cluster-start`

```shell
make lint-test-all
```

## Documentation

You can access our documentation [here][docs-url].

## License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use licensed files except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

or the LICENSE file in this repository.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[s3gw-url]: https://s3gw.io
[docs-url]: https://s3gw-docs.readthedocs.io/en/latest/helm-charts/
[ct-url]: https://github.com/helm/chart-testing
