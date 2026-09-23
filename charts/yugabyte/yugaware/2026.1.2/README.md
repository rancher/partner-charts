YugabyteDB Anywhere gives you the simplicity and support to deliver a private database-as-a-service (DBaaS) at scale. Use YugabyteDB Anywhere to deploy YugabyteDB across any cloud anywhere in the world with a few clicks, simplify day 2 operations through automation, and get the services needed to realize business outcomes with the database.

YugabyteDB Anywhere can be deployed using this Helm chart. Detailed documentation is available at:
- [Install YugabyteDB Anywhere software - Kubernetes](https://docs.yugabyte.com/preview/yugabyte-platform/install-yugabyte-platform/install-software/kubernetes/)
- [Install YugabyteDB Anywhere software - OpenShift (Helm based)](https://docs.yugabyte.com/preview/yugabyte-platform/install-yugabyte-platform/install-software/openshift/#helm-based-installation)

[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/yugabyte)](https://artifacthub.io/packages/search?repo=yugabyte)

## Perf Advisor

Perf Advisor ships as a sub-chart, pulled from its own Helm repository (see
[Updating the Perf Advisor version](#updating-the-perf-advisor-version)), and is installed by
default. To skip it:

```yaml
perf-advisor-chart:
  yugaware:
    enabled: false
```

It is not deployed on OpenShift — `openshift.values.yaml` disables it.

### What it shares with YugabyteDB Anywhere

Perf Advisor does not run its own PostgreSQL or Prometheus. It uses the ones this chart
already deploys, which means three values it depends on:

| Value | Default | Why |
| --- | --- | --- |
| `postgres.service.enabled` | `true` | Publishes the database as `<release>-postgres:5432` |
| `yugaware.service.enabled` | `true` | Publishes Prometheus on port 9090 of `<release>-yugaware-ui` |
| `prometheus.enableRemoteWriteReceiver` | `true` | Lets Perf Advisor remote-write the metrics it collects |

Perf Advisor creates its own `ts` database on first start and reads the password from the
`<release>-yugaware-global-config` secret.

`<release>-postgres` is only published for the database running inside the yugaware pod —
the bundled PostgreSQL, or YugabyteDB when `useYugabyteDB` is set, in which case the Service
maps port 5432 onto the YSQL port. With an external database there is nothing in the pod to
select, and Perf Advisor is pointed straight at the server instead (below).

The account Perf Advisor connects as needs **`CREATE DATABASE`** — it creates its own `ts`
database on first start, separate from the one YugabyteDB Anywhere uses. The bundled
PostgreSQL already grants this; on an external server it is yours to grant.

### Non-default database topologies

Helm resolves values before templates render, so this chart cannot pass its own settings
down to the sub-chart — they have to be repeated under `perf-advisor-chart.postgres.external`:

```yaml
postgres:
  external:
    host: db.example.com
    port: 6432
    user: myuser
    pass: s3cret

perf-advisor-chart:
  postgres:
    external:
      host: db.example.com   # must match postgres.external.host
      port: 6432             # must match postgres.external.port
      user: myuser           # must match postgres.external.user
      dbname: ts             # Perf Advisor's own database, deliberately different
```

`templates/perf-advisor-validation.yaml` compares the two and fails the render naming the
exact value to fix, so a database change made in one place but not the other cannot quietly
leave Perf Advisor pointed at the wrong server.

Two things never need repeating. The **password** comes from
`<release>-yugaware-global-config`, which this chart already fills with whichever
credentials are in use — note that `perf-advisor-chart.postgres.external.pass` has no effect
at all here, since the sub-chart template consuming it is skipped in yugaware mode (use
`postgres.external.secret.name`/`key` to point at a different password). And **dbname** is
Perf Advisor's own.

| Topology | What to set |
| --- | --- |
| Bundled PostgreSQL | Nothing |
| Bundled PostgreSQL, renamed `postgres.user` | `perf-advisor-chart.postgres.external.user` to match |
| External PostgreSQL | `perf-advisor-chart.postgres.external.host`, `.port` and `.user` to match `postgres.external.*` |
| `useYugabyteDB: true` | `perf-advisor-chart.postgres.external.user: yugabyte` (or whatever `yugabytedb.user` is) |
| `prometheus.enabled: false` | `perf-advisor-chart.prometheus.external.url` |

`stable/yugaware/values.yaml` spells the same out inline; every other knob is documented in
the sub-chart's own `values.yaml`, which `helm show values` will print:

```sh
helm show values perf-advisor-chart --repo https://releases.yugabyte.com/perf-advisor \
  --version 9999.9.0-b322
```

### How YugabyteDB Anywhere reaches Perf Advisor

`templates/configs.yaml` points YBA at the sub-chart's Service:

```
pa.url = "http://<release>-perf-advisor-service:80"
pa.api_token = ${PA_API_TOKEN}
```

The scheme follows `perf-advisor-chart.tls.enabled` and the port comes from the sub-chart's
`getServicePort`. `PA_API_TOKEN` is an env var the statefulset wires into the yugaware
container from `<release>-perf-advisor-secret`, the secret the sub-chart creates. Reading it
from that secret matters: generating the token again on this side would produce a second,
unrelated value on a fresh install, and YBA could not authenticate.

### Updating the Perf Advisor version

Perf Advisor is pulled from its own Helm repository, declared in the `dependencies` entry of
`Chart.yaml`:

```yaml
- name: perf-advisor-chart
  version: "1.3.0-b9"
  repository: "https://releases.yugabyte.com/perf-advisor"
```

To move to a newer build, set `version` to it (the repo indexes chart versions by perf-advisor
build number), update `perf-advisor-chart.perfAdvisor.version` in `values.yaml` if the image
tag moved, then refresh the lock file and verify:

```sh
helm dependency update stable/yugaware
helm template test stable/yugaware -n test | grep spring.datasource.url
helm unittest -f "tests/test_*.yaml" stable/yugaware
```

`curl -s https://releases.yugabyte.com/perf-advisor/index.yaml` lists the available versions.

### Known issue - colliding template names

Helm resolves all templates in one namespace, and both charts define the unprefixed helpers
`allowedCorsOrigins` and `getOrCreateServerPem`. This chart's definitions win, so:

* Perf Advisor renders `pa.security.cors.origin=["http://"]` instead of `http://localhost` -
  this chart's helper emits a bracketed list and reads `.Values.tls.hostname`, which does not
  exist in the sub-chart's values
* `perf-advisor-chart.tls.enabled=true` fails to render outright, on
  `$root.Values.tls.hostname: wrong type for value`

The fix is upstream: prefix those helpers (and `getServicePort`) with `perf-advisor-chart.`,
as the sub-chart already does for the rest of its templates.
