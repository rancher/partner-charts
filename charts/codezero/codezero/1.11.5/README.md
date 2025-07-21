# Helm charts for Codezero Space Agent

For further information regarding Codezero, please refer to the [Codezero documentation](https://docs.codezero.io).

## Installing the Chart

```sh
helm repo add --force-update codezero https://charts.codezero.io
helm install --create-namespace --namespace=codezero \
  --set space.name='<TEAMSPACE NAME>' \
  --set org.id='<ORG_ID>' \
  --set org.apikey='<ORG_API_KEY>' \
  codezero codezero/codezero
```

## Upgrading the Chart

```sh
helm repo add --force-update codezero https://charts.codezero.io
helm upgrade --namespace=codezero codezero codezero/codezero
```

## Uninstalling the Chart

```sh
helm -n codezero uninstall codezero
kubectl delete ns codezero
```

## Configuration Options

| Name                                   | Default | Description                                                                                                                                                                                                                        |
| -------------------------------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `image.repository`                     | `""`    | Override default image repository for all codezero deployments. |
| `image.tag`                            | `""`    | Override default image tag for all codezero deployments |
| `org.apikey`                           | `""`    | Your Organization API Key                                                                                                                                                                                                          |
| `org.id`                               | `""`    | Your Organization ID                                                                                                                                                                                                               |
| `org.secret`                           | `""`    | Provide custom secret for `org.id` and `org.apikey`. Secret data must have the keys `CZ_HUB_ORG_ID` and `CZ_HUB_ORG_APIKEY`. Takes precedence over `org.id` and `org.apikey` helm values.
| `opa.url`                              | `""`    | URL of your Open Policy Agent                                                                                                                                                                                                      |
| `opa.enabled`                          | `false` | If true enable OPA                                                                                                                                                                                                                 |
| `operator.image.tag`                   | `""`    | Override default image tag for operator deployment |
| `operator.image.repository`            | `""`    | Override default image repository for operator deployment |
| `operator.labels`                      | `{}`    | Set operator deployment labels |
| `operator.podLabels`                   | `{}`    | Set operator pod labels |
| `router.image.tag`                     | `""`    | Override default image tag for router deployment |
| `router.image.repository`              | `""`    | Override default image repository for router deployment |
| `router.labels`                        | `{}`    | Sets router deployment labels |
| `router.privilegedAccess`              | `false` | If true router pods are deployed with an empty securityContext                                                                                                                                                                     |
| `router.podAnnotations`                | `{}`    | Set pod annotations |
| `router.podLabels`                     | `{}`    | Sets pod labels |
| `router.replicas`                      | `1`     | Number of replicas for router deployments on Serves                                                                                                                                                                                |
| `router.serviceLabels`                 | `{}`    | Set router service labels |
| `router.topologySpreadConstraints`     | `[]`    | Pod Topology Spread Constraints of router deployments                                                                                                                                                                              |
| `space.name`                           | `""`    | Name of Teamspace                                                                                                                                                                                                                  |
| `spaceagent.externalHost`              | `""`    | For cases where codezero's loadbalancer host is not public and custom networking/ingress is used to make the spaceagent publicly accessible                                                                                        |
| `spaceagent.image.tag`                 | `""`    | Override default image tag for spaceagent deployment |
| `spaceagent.image.repository`          | `""`    | Override default image repository for spaceagent deployment |                                                         
| `spaceagent.logLevel`                  | `info`  | Set logging verbosity, valid log levels are: debug, info, warn, error.                                                                                                                                                             |
| `spaceagent.labels`                    | `{}`    | Set spaceagent deployment labels |
| `spaceagent.podLabels`                 | `{}`    | Set spaceagent pod labels |
| `spaceagent.replicas`                  | `1`     | Number of replicas for the Space Agent deployment`                                                                                                                                                                                 |
| `spaceagent.redis.secret`              | `""`    | Required when `spaceagent.replicas` is greater than 1. Name of the K8s Secret that contains the Redis connection parameters with the following `data` keys: `host`, `password`. The Secret must be in the Space Agent's namespace. |
| `spaceagent.service.annotations`       | `{}`    | Set annotations for the spaceagent service, e.g. to set cloud provider specific annotations for loadbalancer creation.
| `spaceagent.service.loadBalancerIP`    | `""`    | Sets the IP address for the spaceagent service. If the IP address is the public IP for contacting the spaceagent set `spaceagent.externalHost` to the same value                                                          |
| `spaceagent.topologySpreadConstraints` | `[]`    | Pod Topology Spread Constraints of Space Agent deployment                                                                                                                                                                          |
