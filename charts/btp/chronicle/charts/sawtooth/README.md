# Sawtoooth

| field | description | default |
|-|-|-|
| `affinity.enabled` | false: no effect   true: then validators will be deployed only to k8s nodes with the label `app={{ .sawtooth.networkName }}-validator` | false  |
| `commonLabels` |
| `imagePullSecrets.enabled` | if true use the list of named imagePullSecrets | false |
| `imagePullSecrets.value` | a list if named secret references of the form   ```- name: secretName```| [] |
| `ingress.apiVersion` | if necessary the apiVersion of the ingress may be overridden | "" |
| `ingress.enabled` | true to enable the ingress to the main service rest-api | false |
| `ingress.certManager` | true to enable the acme certmanager for this ingress | false |
| `ingress.hostname` | primary hostname for the ingress | false |
| `ingress.path` | path for the ingress's primary hostname | / |
| `ingress.pathType` | pathType for the ingress's primary hostname | nil |
| `ingress.annotations` | annotations for the ingress | {} |
| `ingress.tls` | true to enable tls on the ingress with a secrete at hostname-tls | false |
| `ingress.extraHosts` | list of extra hosts to add to the ingress | [] |
| `ingress.extraPaths` | list of extra paths to add to the primary host of the ingress | [] |
| `ingress.extraTls` | list of extra tls entries | [] |
| `pagerduty.enabled` | if true send pagerduty alerts | false |
| `pagerduty.token` | pagerduty user token | nil |
| `pagerduty.serviceid` | pagerduty serviceid | nil |
| `sawtooth.opentsdb.db` | name of the opentsdb database to be used | metrics |
| `sawtooth.opentsdb.url` | url of the opentsdb database to be used | nil |
| `sawtooth.opentsdb.enabled` | whether to enable the opentsdb metrics | false |
| `sawtooth.minReadySeconds` | the minimum time a pod must be Running before proceeding on a rolling update | 120 |
| `sawtooth.maxUnavailable` | maximum number of pods allowed down on a rollout or update  | 1 |
| `sawtooth.containers.block_info.args` | extra args for block-info-tp | nil |
| `sawtooth.containers.identity_tp.args` | extra args for identity-tp | nil |
| `sawtooth.containers.rest_api.args` | extra args for rest-api | nil |
| `sawtooth.containers.settings_tp.args` | extra args for settings-tp | nil |
| `sawtooth.containers.validator.args` | extra args for validator | nil |
| `sawtooth.containers.validator.env` | list of environment name/value dicts | nil |
| `sawtooth.ports.sawnet` | port for the sawtooth validator network | 8800 |
| `sawtooth.ports.consensus` | port for the sawtooth consensus network | 5050 |
| `sawtooth.ports.sawcomp` | port for the sawtooth component network | 4004 |
| `sawtooth.ports.rest` | port for the sawtooth rest-api | 8008 |
| `sawtooth.livenessProbe.enabled` | whether to run the livenessProbe on the validator | false |
| `sawtooth.livenessProbe.initialDelaySeconds` | seconds to wait before running the liveness probe the first time | 300 |
| `sawtooth.livenessProbe.periodSeconds` | interval in seconds to re-run the liveness probe | 120 |
| `sawtooth.livenessProbe.active` | if false, the liveness probe will run and evaluate the the situation, but always return successfully | string | "false"
| `sawtooth.livenessProbe.exitSignals` | when restarting due to a livenessProbe failure, the validator pod has a "signal" system which will cause it to restart the named containers in this var | "block-info-tp" |
| `sawtooth.heartbeat.interval` | interval in seconds to issue a heartbeat | 300 |
| `sawtooth.permissioned` | Whether to run this chain as a permissioned chain or not | false |
| `sawtooth.namespace` | namespace to render these templates into (deprecated) | "prod" |
| `sawtooth.networkName` | name of this sawtooth network (deprecated) | "mynetwork" |
| `sawtooth.scheduler` | name of the sawtooth transaction scheduler to use | string | "serial"
| `sawtooth.consensus` | id of the the consensus algorithm to use< valid values: 100:DevMode, 200, PoET, 300 - Raft, 400, PBFT | int | 200
| `sawtooth.genesis.enabled` | If true, and the cluster is starting for the first time, then   a node will be selected to create and submit the genesis block | true |
| `sawtooth.genesis.seed` | The seed is an arbitrary string which identifies a given genesis  If the data of a given set of nodes is to be wiped out, change this value. | "9a2de774-90b5-11e9-9df0-87e889b0f1c9" |
| `sawtooth.dynamicPeering` | Dynamic Peering should default to false, since it is a bit unreliable  | false |
| `sawtooth.externalSeeds` | a list of maps defining validator endpoints external to this deployment | [] |
| `sawtooth.seth.enabled` | enabled sawtooth-seth | false |
| `sawtooth.xo.enabled` | enabled sawtooth-xo-tp | false |
| `sawtooth.smallbank.enabled` | enabled sawtooth-smallbank-tp | false |
| `sawtooth.hostPathBaseDir` | all sawtooth hostPath directories will be based here | string | /var/lib/btp
| `sawtooth.client_wait` | arbitrary delay to validator client startup, such as the rest-api | 90 |
| `sawtooth.customTPs` | a list of [custom tp definitions](#custom-tp-definitions) | nil |
| `sawtooth.affinity` | custom affinity rules for the sawtooth validator deamonset | nil |
| `images` | a map containing all of the image urls used by this template| N/A |

## Images

| field | default |
|- |- |
| `images.devmode_engine` | blockchaintp/sawtooth-devmode-engine-rust:BTP2.1.0
| `images.pbft_engine` | blockchaintp/sawtooth-pbft-engine:BTP2.1.0
| `images.poet_cli` | blockchaintp/sawtooth-poet-cli:BTP2.1.0
| `images.poet_engine` | blockchaintp/sawtooth-poet-engine:BTP2.1.0
| `images.poet_validator_registry_tp` | blockchaintp/sawtooth-poet-validator-registry-tp:BTP2.1.0
| `images.raft_engine` | blockchaintp/sawtooth-raft-engine:BTP2.1.0
| `images.block_info_tp` | blockchaintp/sawtooth-block-info-tp:BTP2.1.0
| `images.identity_tp` | blockchaintp/sawtooth-identity-tp:BTP2.1.0
| `images.intkey_tp` | blockchaintp/sawtooth-intkey-tp-go:BTP2.1.0
| `images.settings_tp` | blockchaintp/sawtooth-settings-tp:BTP2.1.0
| `images.shell` | blockchaintp/sawtooth-shell:BTP2.1.0
| `images.smallbank_tp` | blockchaintp/sawtooth-smallbank-tp-go:BTP2.1.0
| `images.validator` | blockchaintp/sawtooth-validator:BTP2.1.0
| `images.xo_tp` | blockchaintp/sawtooth-xo-tp-go:BTP2.1.0
| `images.rest_api` | blockchaintp/sawtooth-rest-api:BTP2.1.0
| `images.seth_rpc` | blockchaintp/sawtooth-seth-rpc:BTP2.1.0
| `images.seth_tp` | blockchaintp/sawtooth-seth-tp:BTP2.1.0
| `images.xo_demo` | blockchaintp/xo-demo:BTP2.1.0

## Custom TP Definitions

Custom TP definitions are describe using maps with the following fields

| field | description | default |
|-|-|-|
| `name` | name of the custom tp container(must be unique within the pod) | nil |
| `image` | url of the image for this tp | nil |
| `command` | list of command tokens for this tp | list | nil
| `arg` | list of arguments to the command | nil] |
| `extraVolumes` | a list of additional volumes to add to all StatefulSets, Deployments, and DaemonSets | `[]` |
| `extraVolumeMounts` | a list of additional volume mounts to add to all StatefulSet, Deployment, and DaemonSet containers | `[]` |
