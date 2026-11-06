### Deployment steps for Perf-Advisor service using Helm Chart locally
1. kubectl create serviceaccount <service-account-name> -n <namespace-name>
2. docker login quay.io
3. kubectl create secret docker-registry <secret-name> --docker-server=https://quay.io --docker-username=<quay-username> --docker-password=<quay-password>  --docker-email=<quay-email-id> -n <namespace-name>
4. If you need to override some values defined in values.yml - create overrides.yml file locally.
5. To install the chart "helm install perf-advisor ./perf-advisor-chart -n <namespace-name> -f <path-to-overrides-file>"
6. To apply update values from overrides.yml - use "helm upgrade perf-advisor ./perf-advisor-chart -n <namespace-name> -f <path-to-overrides-file>"
7. To uninstall the chart "helm uninstall perf-advisor -n <namespace-name>"
8. To get pod status, run "kubectl get pods -n <namespace-name>"
9. To get services status, run "kubectl get services -n <namespace-name>"
10. You can access the app via `<perf-advisor-service-external-ip>:<service-port>`. By default, the chart
    exposes service port `80` (or `443` when TLS is enabled). In YBM/cloud mode, the default service port
    is `8080` unless overridden by `perfAdvisor.port`.
11. Internally, the perf-advisor container listens on port `8080` by default.
    The service `targetPort` is aligned to this internal port.
12. You can access Prometheus UI via `<prometheus-service-external-ip>:9090`.

### Perf-Advisor Port Matrix
| Scenario | Service port (`spec.ports.port`) | Service target port (`spec.ports.targetPort`) | Container listen port |
|---|---:|---:|---:|
| Default (non-TLS, non-cloud) | `80` (or `perfAdvisor.port`) | `8080` | `8080` |
| TLS enabled | `443` (or `perfAdvisor.port`) | `8080` | `8080` |
| YBM/cloud mode (`perfAdvisor.cloud.enabled=true`) | `8080` (or `perfAdvisor.port`) | `8080` | `8080` |

### Validate Chart Port Wiring
Run the render-based port checks:

```bash
./perf-advisor-chart/tests/port_render_test.sh
```

### Running as a sub-chart of the yugaware helm chart
The chart can be deployed as a sub-chart of the [yugaware helm chart](https://github.com/yugabyte/charts) by adding it to the `dependencies` section of yugaware's `Chart.yaml`:
```yaml
dependencies:
  - name: perf-advisor-chart
    version: 0.3.0
    repository: <chart repository>
    condition: perf-advisor-chart.yugaware.enabled
```
and enabling it in yugaware's `values.yaml` (or via overrides):
```yaml
perf-advisor-chart:
  yugaware:
    enabled: true
```
In this mode the chart does not deploy its own postgres and prometheus. Instead it:
* connects to the postgres deployed by yugaware (`{{ .Release.Name }}-postgres:5432`), reading the
  password from the `{{ .Release.Name }}-yugaware-global-config` secret (key `postgres_password`),
  and creates the perf-advisor database on startup if it does not exist
* uses the prometheus deployed by yugaware (`http://{{ .Release.Name }}-yugaware-ui:9090`), both for
  queries and for remote-writing collected metrics (yugaware enables
  `--web.enable-remote-write-receiver` on its prometheus when perf-advisor is enabled)
* runs with the spring profiles `api,task-runner,collector`
* deploys all resources into the release namespace (the `namespace` value is ignored)
* keeps the perf-advisor Service on `ClusterIP`, and **refuses** `perfAdvisor.service.type` if it
  is set to anything else rather than discarding it. YugabyteDB Anywhere reaches the Service
  in-cluster and reverse-proxies the Perf Advisor UI behind its own login; an external address
  would expose what the auth filters exempt, `/api/login` among them

Node placement is not inherited. The yugaware chart's `nodeSelector`, `tolerations` and
`zoneAffinity` place the YugabyteDB Anywhere pod only - Helm resolves values before templates
render, so a parent chart cannot pass its own placement down to a sub-chart. This chart takes the
same three values, in the same shape, so mirroring that chart's placement is a copy:
```yaml
perf-advisor-chart:
  nodeSelector:
    topology.kubernetes.io/region: us-west1
  tolerations:
    - key: dedicated
      operator: Exists
      effect: NoSchedule
  zoneAffinity:
    - us-west1-a
```
`zoneAffinity` is a list of zone names, not a `nodeAffinity` structure - the chart expands it into
one matching both `failure-domain.beta.kubernetes.io/zone` and `topology.kubernetes.io/zone`, as
the yugaware chart does. The yugaware chart fails the render if it is placed and this is left
empty, so the two cannot silently drift apart.

Standalone, the same three values also place the bundled postgres and prometheus, so a placed
release stays together. That check lives in the yugaware chart
([D58125](https://phorge.dev.yugabyte.com/D58125)), not here, and nothing in this repository
renders or tests it.

If yugaware itself runs against an external postgres, or you want to use a different
postgres/prometheus, set the connection details explicitly:
```yaml
perf-advisor-chart:
  yugaware:
    enabled: true
  postgres:
    external:
      host: my-postgres.example.com
      port: 5432
      user: postgres
      dbname: ts
      # either provide the password directly via `pass`, or reference an existing secret:
      secret:
        name: my-postgres-secret
        key: POSTGRES_PASSWORD
  prometheus:
    external:
      url: http://my-prometheus.example.com:9090
```
