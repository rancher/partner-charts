# NetScaler Observability Exporter  

NetScaler Observability Exporter is a container which collects metrics and transactions from NetScalers and transforms them to suitable formats (such as JSON, AVRO) for supported endpoints. You can export the data collected by NetScaler Observability Exporter to the desired endpoint for analysis and get valuable insights at a microservices level for applications proxied by NetScalers.

NetScaler Observability Exporter supports collecting transactions and streaming them to Elasticsearch, Kafka or Splunk.

NetScaler Observability Exporter implements distributed tracing for NetScaler and currently supports Zipkin as the distributed tracer.

NetScaler Observability Exporter supports collecting timeseries data (metrics) from NetScaler instances and exports them to Prometheus. 

We can configure NetScaler Observability Exporter helm chart to export transactional, tracing and timeseries (metrics) data to their corresponding endpoints. 

### TL; DR; 
```
   helm repo add netscaler https://netscaler.github.io/netscaler-helm-charts/

   For streaming transactions to Kafka, timeseries to Prometheus and tracing to zipkin:
     helm install nsoe netscaler/netscaler-observability-exporter --set kafka.enabled=true --set kafka.broker="X.X.X.X\,Y.Y.Y.Y" --set kafka.topic=HTTP --set kafka.dataFormat=AVRO --set timeseries.enabled=true --set ns_tracing.enabled=true --set ns_tracing.server="zipkin:9411/api/v1/spans"

   For streaming transactions to Elasticsearch, timeseries to Prometheus and tracing to zipkin:
     helm install nsoe netscaler/netscaler-observability-exporter --set elasticsearch.enabled=true --set elasticsearch.server=elasticsearch:9200 --set timeseries.enabled=true --set ns_tracing.enabled=true --set ns_tracing.server="zipkin:9411/api/v1/spans"

   For streaming transactions to Splunk, timeseries to Prometheus and tracing to zipkin:
     helm install nsoe netscaler/netscaler-observability-exporter --set splunk.enabled=true --set splunk.server="splunkServer:port" --set splunk.authtoken="authtoken" --set timeseries.enabled=true --set ns_tracing.enabled=true --set ns_tracing.server="zipkin:9411/api/v1/spans"

   For streaming timeseries data to Prometheus:
     helm install nsoe netscaler/netscaler-observability-exporter --set timeseries.enabled=true

   For streaming tracing data to Zipkin:
     helm install nsoe netscaler/netscaler-observability-exporter --set ns_tracing.enabled=true --set ns_tracing.server="zipkin:9411/api/v1/spans"

   For streaming transactions, auditlogs and events to Kafka in JSON format, and metrics to Prometheus in Prometheus line format:
     helm install nsoe netscaler/netscaler-observability-exporter --set kafka.enabled=true --set kafka.broker="X.X.X.X\,Y.Y.Y.Y" --set kafka.topic=HTTP --set kafka.dataFormat=JSON --set timeseries.enabled=true --set kafka.events=yes --set kafka.auditlogs=yes

```

## Introduction
This Helm chart deploys NetScaler Observability Exporter in the [Kubernetes](https://kubernetes.io) cluster using [Helm](https://helm.sh) package manager.

### Prerequisites

-  The [Kubernetes](https://kubernetes.io/) version 1.6 or later if using Kubernetes environment.
-  The [Helm](https://helm.sh/) version is 3.x or later. You can follow instruction given [here](https://github.com/netscaler/netscaler-helm-charts/blob/master/Helm_Installation_version_3.md) to install Helm in Kubernetes environment.

   - To enable Tracing, set ns_tracing.enabled to true and ns_tracing.server to the tracer endpoint like `zipkin.default.cluster.svc.local:9411/api/v1/spans`. Default value for Zipkin server is `zipkin:9411/api/v1/spans`. 

   - To enable Elasticsearch endpoint for transactions, set elasticsearch.enabled to true and server to the elasticsearch endpoint like `elasticsearch.default.svc.cluster.local:9200`. Default value for Elasticsearch endpoint is `elasticsearch:9200`.

   - To enable Kafka endpoint for transactions, set kafka.enabled to true, kafka.broker to kafka broker IPs, kafka.topic, and kafka.dataFormat . Default value for kafka topic is `HTTP`. Default value for kafka.dataFormat is `AVRO`. To further enable auditlogs and events, set kafka.events to `yes` and kafka.auditlogs to `yes` (note that timeseries.enabled should be `true` for this to work, and currently kafka.dataFormat should be `JSON` for this to work).

   - To enable Timeseries data upload in prometheus format, set timeseries.enabled to true.  Currently Prometheus is the only timeseries endpoint supported.

   - To enable Splunk endpoint for transactions, set splunk.enabled to true, splunk.server to Splunk server with port, splunk.authtoken to the token and splunk.indexprefix to the index prefix to upload the transactions. Default value for splunk.indexprefix is adc_nsoe .

## Installing the Chart
Add the NetScaler Observability Exporter helm chart repository using command:

```
   helm repo add netscaler https://netscaler.github.io/netscaler-helm-charts/
```

### For Kubernetes:
#### 1. NetScaler Observability Exporter
To install the chart with the release name, `my-release`, use the following command, after setting the required endpoint in values.yaml:
```
    helm install my-release netscaler/netscaler-observability-exporter
```

### Configuration

The following table lists the mandatory and optional parameters that you can configure during installation:

| Parameters | Mandatory or Optional | Default value | Description |
| --------- | --------------------- | ------------- | ----------- |
| license.accept | Mandatory | no | Set `yes` to accept the NetScaler end user license agreement. |
| imageRegistry                   | Mandatory  |  `quay.io`               |  The NSOE image registry             |  
| imageRepository                 | Mandatory  |  `netscaler/netscaler-observability-exporter`              |   The NSOE image repository             | 
| imageTag                  | Mandatory  |  `1.10.001`               |  The NSOE image tag            |
| pullPolicy | Mandatory | IfNotPresent | The NSOE image pull policy. |
| nodePortRequired | Optional | false | Set true to create a nodeport NSOE service. |
| headless | Optional | false | Set true to create Headless service. |
| transaction.nodePort | Optional | N/A | Specify the port used to expose NSOE service outside cluster for transaction endpoint. |
| ns_tracing.enabled | Optional | false | Set true to enable sending trace data to tracing server. |
| ns_tracing.server | Optional | `zipkin:9411/api/v1/spans` | The tracing server api endpoint. |
| elasticsearch.enabled | Optional | false | Set true to enable sending transaction data to elasticsearch server. |
| elasticsearch.server | Optional | `elasticsearch:9200` | The Elasticsearch server api endpoint. |
| elasticsearch.indexprefix | Optional | adc_nsoe | The elasticsearch index prefix. |
| splunk.enabled | Optional | false | Set true to enable sending transaction data to splunk server. |
| splunk.authtoken | Optional |  | Set the authtoken for splunk. |
| splunk.indexprefix | Optional | adc_nsoe | The splunk index prefix. |
| kafka.enabled | Optional | false | Set true to enable sending transaction data to kafka server. |
| kafka.broker | Optional |  | The kafka broker IP details. |
| kafka.topic | Optional | `HTTP` | The kafka topic details to upload data. |
| kafka.dataFormat | Optional | `AVRO` | The format of the data exported to Kafka -- can be either JSON or AVRO, and defaults to AVRO |
| kafka.events | Optional | `no` | Whether events should be exported to Kafka (JSON) -- can be either yes or no and defaults to no |
| kafka.auditlogs | Optional | `no` | Whether auditlogs should be exported to Kafka (JSON) -- can be either yes or no and defaults to no |
| timeseries.enabled | Optional | false | Set true to enable sending timeseries data to Prometheus or Kafka. |
| timeseries.nodePort | Optional | N/A | Specify the port used to expose NSOE service outside cluster for timeseries endpoint. |
| json_trans_rate_limiting.enabled | Optional | false | Set true to enable rate-limiting of transactions for JSON-based endpoints: Splunk, ElasticSearch and Zipkin. |
| json_trans_rate_limiting.limit | Optional | 100 | Specify the rate-limit: 100 means approximately 800 TPS. |
| json_trans_rate_limiting.queuelimit | Optional | 1000 | The amount of transactional data that can pile up, before NSOE starts shedding them. For Zipkin, 1000 is approximately 64 MB of data; For Splunk and ElasticSearch, this is approximately 32 MB of data. |
| json_trans_rate_limiting.window | Optional | 5 | The recalculation window in seconds-the lower the window size ( must be greater than 0), the more effective will be the rate-limiting but it will have CPU overhead |
| podAnnotations | Optional | N/A | Map of annotations to add to the pods. |
| resources | Optional | N/A | CPU/Memory resource requests/limits for NetScaler observability exporter container. |
| tolerations | Optional | N/A | Specify the tolerations for the NSOE deployment. |
| affinity | Optional | N/A | Affinity labels for pod assignment. |
| nsoeLogLevel | Optional | INFO | Logging severity for NSOE can be one of- DEBUG, INFO, ERROR, FATAL or NONE. |
| nameOverride | Optional | N/A | String to partially override deployment fullname template with a string (will prepend the release name)
| fullNameOverride | Optional | N/A | String to fully override deployment fullname template with a string |

Alternatively, you can define a YAML file with the values for the parameters and pass the values while installing the chart.

For example:
```
   helm install my-release netscaler/netscaler-observability-exporter -f values.yaml
```

> **Note:**
> 1. It might be required to expose NSOE using nodePort. In such case, nodePort service can also be created additionally using the set option 'nodePortRequired=true'
> 3. It might be required to stream only transactional data, without streaming timeseries or tracing data:
>      - For disabling timeseries, set the option 'timeseries.enabled=false'
>      - For disabling tracing, set the option 'ns_tracing.enabled=false' and do not set 'ns_tracing.server'

> **Tip:**
>
> The [values.yaml](https://github.com/netscaler/netscaler-helm-charts/blob/master/netscaler-observability-exporter/values.yaml) contains the default values of the parameters.

## Uninstalling the Chart
To uninstall/delete the ```my-release``` deployment:

```
   helm delete my-release
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

## Related documentation

-  [NetScaler Observability Exporter Documentation](https://github.com/netscaler/netscaler-observability-exporter)
