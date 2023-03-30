## Codefresh Runner

![Version: 1.0.5](https://img.shields.io/badge/Version-1.0.5-informational?style=flat-square)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.8.0+

## Get Repo Info

```console
helm repo add cf-runtime http://chartmuseum.codefresh.io/cf-runtime
helm repo update
```

## Install Chart

**Important:** only helm3 is supported

1. Download the Codefresh CLI and authenticate it with your Codefresh account. Click [here](https://codefresh-io.github.io/cli/getting-started/) for more detailed instructions.
2. Run the following command to create mandatory values for Codefresh Runner:

    ```console
    codefresh runner init --generate-helm-values-file
    ```

   * This will not install anything on your cluster, except for running cluster acceptance tests, which may be skipped using the `--skip-cluster-test` option.
   * This command will also generate a `generated_values.yaml` file in your current directory, which you will need to provide to the `helm install` command later.
3. Now run the following to complete the installation:

    ```console
    helm repo add cf-runtime https://chartmuseum.codefresh.io/cf-runtime

    helm upgrade --install cf-runtime cf-runtime/cf-runtime -f ./generated_values.yaml --create-namespace --namespace codefresh
    ```
4. At this point you should have a working Codefresh Runner. You can verify the installation by running:
    ```console
    codefresh runner execute-test-pipeline --runtime-name <runtime-name>
    ```

## Requirements

Kubernetes: `>=1.19.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| appProxy.enabled | bool | `false` | Enable app-proxy |
| appProxy.env | object | `{}` |  |
| appProxy.image | string | `"codefresh/cf-app-proxy:latest"` | Set app-proxy image |
| appProxy.ingress.annotations | object | `{}` | Set extra annotations for ingress object |
| appProxy.ingress.class | string | `""` | Set ingress class |
| appProxy.ingress.host | string | `""` | Set DNS hostname the ingress will use |
| appProxy.ingress.pathPrefix | string | `"/"` | Set path prefix for ingress |
| appProxy.ingress.tlsSecret | string | `""` | Set k8s tls secret for the ingress object |
| appProxy.resources | object | `{}` |  |
| appProxy.serviceAccount.annotations | object | `{}` |  |
| dockerRegistry | string | `"quay.io"` | Set docker registry prefix for the runtime images |
| global.accountId | string | `""` |  |
| global.agentId | string | `""` |  |
| global.agentName | string | `""` |  |
| global.agentToken | string | `""` |  |
| global.codefreshHost | string | `""` |  |
| global.existingAgentToken | string | `""` | Existing secret (name-of-existing-secret) with API token from Codefresh (supersedes value for global.agentToken; secret must contain `codefresh.token` key) |
| global.existingDindCertsSecret | string | `""` | Existing secret (name has to be `codefresh-certs-server`) (supersedes value for global.keys; secret must contain `server-cert.pem` `server-key.pem` and `ca.pem`` keys) |
| global.keys.ca | string | `""` |  |
| global.keys.key | string | `""` |  |
| global.keys.serverCert | string | `""` |  |
| global.namespace | string | `"codefresh"` |  |
| global.runtimeName | string | `""` |  |
| monitor.clusterId | string | `""` | Cluster name as it registered in account |
| monitor.enabled | bool | `false` | Enable monitor Ref: https://codefresh.io/docs/docs/installation/codefresh-runner/#install-monitoring-component |
| monitor.env | object | `{}` |  |
| monitor.existingMonitorToken | string | `""` | Set Existing secret (name-of-existing-secret) with API token from Codefresh (supersedes value of monitor.token; secret must contain `codefresh.token` key) |
| monitor.helm3 | bool | `true` | keep true as default! |
| monitor.image | string | `"codefresh/agent:stable"` | Set monitor image |
| monitor.resources | object | `{}` |  |
| monitor.serviceAccount.annotations | object | `{}` |  |
| monitor.token | string | `""` | API token from Codefresh |
| monitor.useNamespaceWideRole | bool | `false` | Use ClusterRole (`false`) or Role (`true`) RBAC |
| re.dindDaemon.experimental | bool | `true` |  |
| re.dindDaemon.hosts[0] | string | `"unix:///var/run/docker.sock"` |  |
| re.dindDaemon.hosts[1] | string | `"tcp://0.0.0.0:1300"` |  |
| re.dindDaemon.insecure-registries[0] | string | `"192.168.99.100:5000"` |  |
| re.dindDaemon.metrics-addr | string | `"0.0.0.0:9323"` |  |
| re.dindDaemon.tls | bool | `true` |  |
| re.dindDaemon.tlscacert | string | `"/etc/ssl/cf-client/ca.pem"` |  |
| re.dindDaemon.tlscert | string | `"/etc/ssl/cf/server-cert.pem"` |  |
| re.dindDaemon.tlskey | string | `"/etc/ssl/cf/server-key.pem"` |  |
| re.dindDaemon.tlsverify | bool | `true` |  |
| re.serviceAccount | object | `{"annotations":{}}` | Set annotation on engine Service Account Ref: https://codefresh.io/docs/docs/administration/codefresh-runner/#injecting-aws-arn-roles-into-the-cluster |
| runner.env | object | `{}` | Add additional env vars |
| runner.image | string | `"codefresh/venona:1.9.14"` | Set runner image |
| runner.nodeSelector | object | `{}` | Set runner node selector |
| runner.resources | object | `{}` | Set runner requests and limits |
| runner.tolerations | list | `[]` | Set runner tolerations |
| storage.azuredisk.cachingMode | string | `"None"` |  |
| storage.azuredisk.skuName | string | `"Premium_LRS"` | Set storage type (`Premium_LRS`) |
| storage.backend | string | `"local"` | Set backend volume type (`local`/`ebs`/`ebs-csi`/`gcedisk`/`azuredisk`) |
| storage.ebs.accessKeyId | string | `""` | Set AWS_ACCESS_KEY_ID for volume-provisioner (optional) Ref: https://codefresh.io/docs/docs/installation/codefresh-runner/#dind-volume-provisioner-permissions |
| storage.ebs.availabilityZone | string | `"us-east-1a"` | Set EBS volumes availability zone (required) |
| storage.ebs.encrypted | string | `"false"` | Enable encryption (optional) |
| storage.ebs.kmsKeyId | string | `""` | Set KMS encryption key ID (optional) |
| storage.ebs.secretAccessKey | string | `""` | Set AWS_SECRET_ACCESS_KEY for volume-provisioner (optional) Ref: https://codefresh.io/docs/docs/installation/codefresh-runner/#dind-volume-provisioner-permissions |
| storage.ebs.volumeType | string | `"gp2"` | Set EBS volume type (`gp2`/`gp3`/`io1`) (required) |
| storage.fsType | string | `"ext4"` | Set filesystem type (`ext4`/`xfs`) |
| storage.gcedisk.availabilityZone | string | `"us-west1-a"` | Set GCP volume availability zone |
| storage.gcedisk.serviceAccountJson | string | `""` | Set Google SA JSON key for volume-provisioner (optional) |
| storage.gcedisk.volumeType | string | `"pd-ssd"` | Set GCP volume backend type (`pd-ssd`/`pd-standard`) |
| storage.local.volumeParentDir | string | `"/var/lib/codefresh/dind-volumes"` | Set volume path on the host filesystem |
| storage.localVolumeMonitor.env | object | `{}` |  |
| storage.localVolumeMonitor.image | string | `"codefresh/dind-volume-utils:1.29.3"` | Set `dind-lv-monitor` image |
| storage.localVolumeMonitor.initContainer.image | string | `"alpine"` |  |
| storage.localVolumeMonitor.nodeSelector | object | `{}` |  |
| storage.localVolumeMonitor.resources | object | `{}` |  |
| storage.localVolumeMonitor.tolerations | list | `[]` |  |
| volumeProvisioner.annotations | object | `{}` |  |
| volumeProvisioner.env | object | `{}` | Add additional env vars |
| volumeProvisioner.image | string | `"codefresh/dind-volume-provisioner:1.33.3"` | Set volume-provisioner image |
| volumeProvisioner.nodeSelector | object | `{}` | Set volume-provisioner node selector |
| volumeProvisioner.resources | object | `{}` | Set volume-provisioner requests and limits |
| volumeProvisioner.securityContext | object | `{"enabled":true}` | Enable volume-provisioner pod's security context (running as non root user) |
| volumeProvisioner.serviceAccount | object | `{}` | Set annotation on volume-provisioner Service Account |
| volumeProvisioner.tolerations | list | `[]` | Set volume-provisioner tolerations |
| volumeProvisioner.volume-cleanup.image | string | `"codefresh/dind-volume-cleanup:1.2.0"` | Set `dind-volume-cleanup` image |
