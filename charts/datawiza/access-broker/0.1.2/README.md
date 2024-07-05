# Access Proxy Helm Chart

* Installs the Identity Aware proxy [Access Proxy](https://www.datawiza.com/access-broker)

## Get Repo Info

```sh
helm repo add datawiza https://datawiza-inc.github.io/helm-charts/
helm repo update
```

## Installing the Chart

Please follow the [doc](https://docs.datawiza.com/step-by-step/step2.html) to create an application on the Datawiza Cloud Management Console (DCMC) to generate a pair of `PROVISIONING_KEY`, `PROVISIONING_SECRET`, and the command line to log in to our docker repo.

Use the command line to log in and create a Kubernetes Secret based on the Docker credentials. You can see [here](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) for more details.

Then, create a yaml file named `example.yaml` based on these values:

```yaml
PROVISIONING_KEY: replace-with-your-provisioning-key
PROVISIONING_SECRET: replace-with-your-provisioning-key
containerPort: replace-with-your-app-listen-port
imagePullSecrets: replace-with-you-secret
```

To install the chart with the release name `my-release` in the namespace `my-namespace`:

```console
helm install my-release -f example.yaml datawiza/access-broker -n my-namespace
```

## Uninstalling the Chart

To uninstall/delete the my-release deployment:

```console
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Note

The DAP uses a Cookie to track user sessions and will store the session data on the `Server Side` (default) or the `Client Side`. In the k8s cluster, you need to add the sticky session config if you use the `Server Side` cookie. Or you need to change the `Session Option` (`Application` -> `Advanced` -> `Advanced Options`) in DCMC to `Client Side`.

## Examples

### Example with ingress

A very basic example using ingress is like this:

```yaml
PROVISIONING_KEY: replace-with-your-provisioning-key
PROVISIONING_SECRET: replace-with-your-provisioning-key
containerPort: replace-with-your-listen-port
imagePullSecrets: replace-with-you-secret
service:
  type: ClusterIP
  port: replace-with-your-listen-port
ingress:
  annotations:
    kubernetes.io/ingress.class: replace-with-your-ingress-class
  className: ''
  enabled: true
  hosts:
    - host: replace-with-your-public-domain
      paths:
        - path: /
          pathType: Prefix
```

#### AWS Load Balancer Controller

Follow the [Installation Guide](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/deploy/installation/) to install the AWS Load Balancer Controller.

##### Sticky Session

Add needed annotations in the ingress block in DAP helm value.yaml file:

```yaml
  ...
  annotations:
    alb.ingress.kubernetes.io/target-group-attributes: stickiness.enabled=true,stickiness.lb_cookie.duration_seconds=60
    alb.ingress.kubernetes.io/target-type: ip
  ...
```

You can go to [AWS doc](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/#target-group-attributes) to see more details.

##### TLS Termination

Add the `alb.ingress.kubernetes.io/certificate-arn: replace-with-your-cert-arn` in the ingress annotations. You can see more details [here](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/#ssl).

And in DCMC, you need to disable the SSL config.

#### Nginx Ingress Controller

Follow the [Installation Guide](https://kubernetes.github.io/ingress-nginx/deploy/) to install the Nginx Ingress Controller.

##### Sticky Session

Add needed annotations in the ingress block in DAP helm value.yaml file:

```yaml
  ...
  annotations:
    nginx.ingress.kubernetes.io/affinity: "cookie"
  ...
```

Meanwhile, Nginx Ingress Controller provides more customized configurations for the sticky session. You can see more details [here](https://kubernetes.github.io/ingress-nginx/examples/affinity/cookie/).

##### TLS Termination

Create the TLS secret based on your cert and key:

```sh
kubectl create secret tls tls-secret --key you-key --cert your-cert  -n your-namespace

```

Add TLS block in ingress config:

```yaml
  ...
  tls:
    - hosts:
        - your-public-domain
      secretName: tls-secret
  ...
```

And likewise, you need to disable the SSL config in DCMC.
