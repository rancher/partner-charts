/**
 * Single source of truth for the DevGuard Helm chart configuration.
 *
 * Plain values render straight into values.yaml. Wrap a value in `f(value, opts)`
 * to attach a comment, an inline comment, a blank line, or Rancher `question`
 * metadata. Run `bun run generate` (see generate.ts) to emit:
 *   - values.yaml     the full chart defaults, with comments
 *   - questions.yaml  the Rancher install form (subset of fields with `question`)
 */
import { f, banner, type Question } from "./builder";


export const devguardVersion = "1.7.0";

const dependencies = {
  kratos: {
    repo: "oryd/kratos",
    tag: "v25.4.0-distroless",
    digest:
      "sha256:368667ee3713797f86ddec669c36751f6484c7d675c78fd27c795b2e79271c31",
  },
  api: {
    repo: "ghcr.io/l3montree-dev/devguard",
    tag: `v${devguardVersion}`,
  },
  web: {
    repo: "ghcr.io/l3montree-dev/devguard-web",
    tag: `v${devguardVersion}`,
  },
  postgresql: {
    repo: "ghcr.io/l3montree-dev/devguard/postgresql",
    tag: `v${devguardVersion}`,
  },
  postgresVolumePermissionImage: {
    repo: "busybox",
    tag: "1.37.0@sha256:1487d0af5f52b4ba31c7e465126ee2123fe3f2305d638e7827681e7cf6c83d5e",
  },
  postgresExporter: {
    repo: "prometheuscommunity/postgres-exporter",
    tag: "v0.19.1",
  },
  ciComponents: {
    version: "v1.6.0",
  }
}




// Group headings in the order they should appear in the Rancher install form.
// Questions are sorted by (group index, encounter order); this list — not the
// position of a field in the tree — controls group ordering.
export const GROUP_ORDER = [
  "API (required for web and API access)",
  "Web (required for web access)",
  "Authentication",
  "Mail (required for account verification)",
  "Storage",
  "CSAF (optional, for advisory generation)",
];

const G_API = "API (required for web and API access)";
const G_WEB = "Web (required for web access)";
const G_AUTH = "Authentication";
const G_MAIL = "Mail (required for account verification)";
const G_STORAGE = "Storage";
const G_CSAF = "Common Security Advisory Framework (CSAF) support (optional)";

// Reusable question fragments ------------------------------------------------

const ingressQuestion = (kind: "API" | "Web", group: string): Question => ({
  label: `${kind} Ingress Enabled`,
  group,
  required: true,
  default: true,
  showSubquestionIf: true,
});

export const schema = {
  kratos: f(
    {
      image: {
        repository: dependencies.kratos.repo,
        tag: dependencies.kratos.tag,
        digest: dependencies.kratos.digest,
        pullPolicy: "IfNotPresent",
      },
      webauthn: { enabled: false },
      password: {
        enabled: f(true, {
          question: {
            variable: "password",
            label: "Password Authentication Enabled",
            group: G_AUTH,
            type: "boolean",
            required: true,
            default: true,
          },
        }),
      },
      passkey: {
        enabled: f(true, {
          question: {
            variable: "passkey",
            label: "Passkey Authentication Enabled",
            group: G_AUTH,
            type: "boolean",
            required: true,
            default: true,
          },
        }),
      },
      totp: { enabled: false },
      verificationAfterSignUp: { enabled: true },
      oidc: {
        enabled: false,
        // The commented example below documents the provider shape; it renders
        // as a comment block before `providers: []` in values.yaml.
        providers: f([], {
          comment:
            '- id: github\n  provider: github\n  clientId: "sample-client-id"\n  disableTicketSync: false\n  existingClientSecretName: github-client-secret # needs to contain key "secret"\n- id: gitlab\n  provider: gitlab\n  issuerUrl: https://gitlab.de\n  clientId: client-id\n  existingClientSecretName: gitlab-secret\n  existingAdminTokenSecretName: gitlab-admin-token # needs to contain key "token"\n  scope:\n    - read_user\n    - openid\n    - profile\n    - email\ningressNamespaceSelectorKey: "role"\ningressNamespaceSelectorValue: "ingress"',
        }),
      },
      cleanup: f(
        {
          enabled: true,
          schedule: f("*/10 * * * *", {
            comment: "Default: every 10 minutes.",
          }),
        },
        { comment: "Cleans up expired flows" },
      ),
    },
    {
      comment:
        "Default values for devguard.\nThis is a YAML-formatted file.\nDeclare variables to be passed into templates.\n\n" +
        banner("Authentication Related Settings (Kratos)"),
    },
  ),

  mail: {
    existingSMTPConnectionUriSecret: f("", {
      comment:
        'needs to contain key: "uri". Format should be like: smtps://<user>@<your-domain.com>:<secret>@<mail-server.de>:465/?skip_ssl_verify=false',
      question: {
        label: "SMTP Connection URI Secret",
        group: G_MAIL,
        type: "string",
        required: true,
      },
    }),
    fromAddress: f("noreply@devguard.org", {
      question: {
        label: "SMTP From Address",
        group: G_MAIL,
        type: "string",
        required: true,
      },
    }),
    fromName: f("DevGuard", {
      question: {
        label: "SMTP From Name",
        group: G_MAIL,
        type: "string",
        required: true,
        default: "DevGuard",
      },
    }),
  },

  networkPolicy: f(
    { enabled: true },
    { blankBefore: true, comment: banner("Miscellaneous Settings") },
  ),

  kyvernoPolicy: f(
    {
      enabled: false,
      validationFailureAction: f("Audit", {
        comment:
          "Enforce blocks non-compliant pods; Audit only logs violations",
      }),
    },
    { blankBefore: true },
  ),

  api: f(
    {
      debug: f(
        {
          profile: f(false, {
            inline: 'set to "true" to enable pprof profiling endpoints on /debug/pprof',
          }),
        },
        {
          comment:
            'Gen a keypair using the devguard-cli gen-admin-key (https://github.com/l3montree-dev/devguard/blob/main/cmd/devguard-cli/commands/gen_admin_key.go)\ncommand. Place only the PUBLIC key here. The corresponding private key allows you access to the instance admin /admin dashboard. \nEnsure to keep the private key secret and secure. \nKeeping it empty disables admin endpoint access.\nadminPublicKey: ""',
        },
      ),
      replicaCount: 1,
      ciComponentBase: `https://gitlab.com/l3montree/devguard/-/raw/${dependencies.ciComponents.version}`,
      resources: {
        limits: { cpu: "2", memory: "2048Mi" },
        requests: { cpu: "100m", memory: "1024Mi" },
      },
      migrate: {
        resources: {
          limits: { cpu: "2", memory: "3048Mi" },
          requests: { cpu: "100m", memory: "1548Mi" },
        },
      },
      csaf: {
        existingCsafSecretName: f("", {
          comment:
            '######## CSAF Keys\nneeds to contain keys: "passphrase", "privateKey", "publicKey", "fingerprint"\nthe openGpg keys need to be in pem format.\nGenerate keys: gpg --full-generate-key\nList key ids: gpg --list-secret-keys --keyid-format LONG\nExport public key: gpg --armor --export "$KEY_ID" > public.asc\nExport private key: gpg --armor --export-secret-keys "$KEY_ID" > private.asc\nGet fingerprint: gpg --fingerprint "$KEY_ID"\nkubectl create secret generic csaf-key-pair --from-file=privateKey=private.asc --from-file=publicKey=public.asc --from-literal=passphrase="..." --from-literal=fingerprint="1C10 446..." -n devguard\n###\nIf you don\'t want to use CSAF features, leave this as empty string.',
          question: {
            label: "CSAF Secret Name",
            group: G_CSAF,
            type: "string",
            required: false,
            default: "csaf-key-pair",
            description: "Follow instructions here: https://docs.devguard.org/how-to-guides/administration/deploy-with-helm/#optional-csaf-support\nThe name of the Kubernetes secret that contains the CSAF key pair and passphrase.",
          },
        }),
        aggregatorNamespace: f("", {
          inline: 'e.g. "example.com"',
          question: {
            label: "CSAF Aggregator Namespace",
            group: G_CSAF,
            type: "string",
            required: false,
            description: "The namespace (domain) of the CSAF aggregator (e.g. example.com).",
          },
        }),
        aggregatorName: f("", {
          inline: 'e.g. "Example GmbH"',
          question: {
            label: "CSAF Aggregator Name",
            group: G_CSAF,
            type: "string",
            required: false,
            description: "The name of the CSAF aggregator organization (e.g. Example GmbH).",
          },
        }),
        aggregatorContactDetails: f("", {
          inline: 'e.g. "csaf@example.com"',
          question: {
            label: "CSAF Aggregator Contact Details",
            group: G_CSAF,
            type: "string",
            required: false,
            description: "The contact details for the CSAF aggregator (e.g. csaf@example.com).",
          },
        }),
      },
      image: {
        repository: f(dependencies.api.repo, {
          comment:
            `Accepts either a full image string (e.g. ${dependencies.api.repo}:${dependencies.api.tag})\nor an object with repository/tag/digest/pullPolicy.`,
        }),
        pullPolicy: "IfNotPresent",
        tag: f(dependencies.api.tag, {
          comment:
            "Overrides the image tag whose default is the chart appVersion.",
        }),
      },
      imagePullSecrets: [],
      errorTracking: {
        dsn: f("", { comment: "https://<your-error-tracking-dsn>" }),
        environment: f("dev", { comment: "can be dev, stage or prod" }),
      },
      tracing: {
        enabled: false,
        sampleRate: f("0.1", {
          comment:
            "Fraction of requests to sample for distributed tracing (0.0 - 1.0)",
        }),
        otlpEndpoint: f("", {
          comment:
            "OTLP endpoint the sidecar collector forwards traces to, e.g. https://jaeger:4318",
        }),
        existingSecretName: f("", {
          comment:
            "Existing secret with basic auth credentials for the OTLP exporter (keys: username, password)",
        }),
        spanMetrics: {
          image: f(
            {
              repository: "otel/opentelemetry-collector-contrib",
              tag: "0.147.0",
            },
            {
              comment:
                "OTel Collector sidecar image — receives traces from the API on localhost:4317,\ngenerates span metrics (port 8889) and forwards traces to otlpEndpoint.",
            },
          ),
          histogram: {
            buckets: ["100us", "1ms", "2ms", "6ms", "10ms", "100ms", "250ms"],
          },
          dimensions: [
            { name: "http.method" },
            { name: "http.status_code" },
            { name: "http.route" },
          ],
          resources: {
            limits: { cpu: "200m", memory: "256Mi" },
            requests: { cpu: "50m", memory: "64Mi" },
          },
        },
      },
      intoto: {
        generate: f(true, {
          comment: `When true, the chart generates the EC (prime256v1) private key used for\nsigning In-Toto attestations and stores it in the secret named below.\nThe key is generated once and preserved across upgrades.\nSet to false to bring your own secret (must contain key "privateKey"):\nopenssl ecparam -name prime256v1 -genkey -noout -out private.ec.key\nkubectl create secret generic ec-private-key \--from-file=privateKey=private.ec.key -n devguard"`
        }),
        existingPrivateKeySecretName: "ec-private-key"
      },
      github: f(
        {
          enabled: true,
          appId: "abc",
          existingWebhookSecretSecretName: f("github-app-webhook-secret", {
            comment: 'needs to contain "webhookSecret"',
          }),
          existingPrivateKeySecretName: f("github-app-private-key", {
            comment: 'needs to contain key "privateKey"',
          }),
        },
        { comment: "GitHub App Integration Settings" },
      ),
      ingress: f({
        enabled: f(true, {
          question: ingressQuestion("API", G_API),
        }),
        className: "",
        annotations: {},
        host: f("api.devguard.example.com", {
          comment:
            "The chart supports a single ingress host (path below, pathType Prefix)\nbecause the Rancher install form cannot address list entries like hosts[0].\nIf you need multiple hosts, please open a ticket describing your use case:\nhttps://github.com/l3montree-dev/devguard-helm-chart/issues",
          question: {
            label: "API Ingress Host",
            group: G_API,
            type: "hostname",
            required: true,
            subquestionOf: "api.ingress.enabled",
            description:
              "The hostname for the API ingress. This should be a fully qualified domain name (FQDN) that resolves to the IP address of the ingress controller (e.g. api.devguard.example.com).",
          },
        }),
        path: f("/", {
          question: {
            label: "API Ingress Path",
            group: G_API,
            type: "string",
            required: true,
            default: "/",
            subquestionOf: "api.ingress.enabled",
            description:
              "The path for the API ingress. This should be a valid URL path (e.g. / or /devguard/).",
          },
        }),
      }, { blankBefore: true }),
      podAnnotations: f({}, { blankBefore: true }),
      podLabels: {},
      nodeSelector: {},
      tolerations: [],
      affinity: {},
      autoscaling: {
        enabled: false,
        minReplicas: 1,
        maxReplicas: 100,
        targetCPUUtilizationPercentage: f(80, {
          inline: "targetMemoryUtilizationPercentage: 80",
        }),
      },
    },
    { blankBefore: true, comment: banner("DevGuard API Settings") },
  ),

  web: f(
    {
      registrationEnabled: f(true, {
        comment: "needs to match the setting in the kratos.yaml",
      }),
      replicaCount: 1,
      resources: {
        limits: { cpu: "0.5", memory: "1024Mi" },
        requests: { cpu: "100m", memory: "128Mi" },
      },
      image: {
        repository: f(dependencies.web.repo, {
          comment:
            `Accepts either a full image string (e.g. ${dependencies.web.repo}:${dependencies.web.tag})\nor an object with repository/tag/digest/pullPolicy.`,
        }),
        pullPolicy: "IfNotPresent",
        tag: f(dependencies.web.tag, {
          comment:
            "Overrides the image tag whose default is the chart appVersion.",
        }),
      },
      imagePullSecrets: [],
      ciComponentBase: f(`https://gitlab.com/l3montree/devguard/-/raw/${dependencies.ciComponents.version}`, {
        blankBefore: true,
      }),
      devguardApiUrl: "http://devguard-api-service:8080",
      devguardApiUrlPublicInternet: "",
      privacyPolicyLink: "",
      termsOfUseLink: "",
      imprintLink: "",
      accountDeletionMail: "",
      themeJsUrl: f("", {
        comment: "Custom Theme URLs (leave empty to use default theme)",
      }),
      themeCssUrl: "",
      errorTracking: {
        dsn: f("", { comment: "https://<your-error-tracking-dsn>" }),
      },
      ingress: f({
        enabled: f(true, {
          question: ingressQuestion("Web", G_WEB),
        }),
        className: "",
        annotations: {},
        host: f("devguard.example.com", {
          comment:
            "The chart supports a single ingress host (path below, pathType Prefix)\nbecause the Rancher install form cannot address list entries like hosts[0].\nIf you need multiple hosts, please open a ticket describing your use case:\nhttps://github.com/l3montree-dev/devguard-helm-chart/issues",
          question: {
            label: "Web Ingress Host",
            group: G_WEB,
            type: "hostname",
            required: true,
            subquestionOf: "web.ingress.enabled",
            description:
              "The hostname for the web ingress. This should be a fully qualified domain name (FQDN) that resolves to the IP address of the ingress controller (e.g. web.devguard.example.com).",
          },
        }),
        path: f("/", {
          question: {
            label: "Web Ingress Path",
            group: G_WEB,
            type: "string",
            required: true,
            default: "/",
            subquestionOf: "web.ingress.enabled",
            description:
              "The path for the web ingress. This should be a valid URL path (e.g. / or /devguard/).",
          },
        }),
      }, { blankBefore: true }),
      podAnnotations: f({}, { blankBefore: true }),
      podLabels: {},
      nodeSelector: {},
      tolerations: [],
      affinity: {},
      autoscaling: {
        enabled: false,
        minReplicas: 1,
        maxReplicas: 100,
        targetCPUUtilizationPercentage: f(80, {
          inline: "targetMemoryUtilizationPercentage: 80",
        }),
      },
    },
    { blankBefore: true, comment: banner("DevGuard Web Frontend Settings") },
  ),

  postgresql: f(
    {
      image: {
        repository: f(dependencies.postgresql.repo, {
          comment:
            `Accepts either a full image string (e.g. ${dependencies.postgresql.repo}:${dependencies.postgresql.tag})\nor an object with repository/tag/digest/pullPolicy.\nPlease note: we are using a custom PostgreSQL image that has the required\nextensions pre-installed.`,
        }),
        pullPolicy: "IfNotPresent",
        tag: f(dependencies.postgresql.tag, {
          comment:
            "Overrides the image tag whose default is the chart appVersion.",
        }),
      },
      pvc: {
        size: "21Gi",
        storageClassName: f("", {
          comment:
            'StorageClass for the PostgreSQL data volume.\nLeave empty to use the cluster\'s default StorageClass.\nSet explicitly (e.g. "local-path", "longhorn") on clusters that\nhave no default StorageClass.',
          question: {
            label: "PostgreSQL StorageClass",
            description:
              "StorageClass for the PostgreSQL data volume. Leave empty to use the cluster's default StorageClass; set explicitly if your cluster has no default.",
            group: G_STORAGE,
            type: "storageclass",
            required: false,
          },
        }),
      },
      podAnnotations: {},
      config: {
        maxConnections: f("100", {
          comment:
            "Max number of concurrent connections. (change requires restart)",
        }),
        sharedBuffers: f("1GB", {
          comment: "Recommended: 25% of total RAM. (change requires restart)",
        }),
        effectiveCacheSize: f("3GB", {
          comment:
            "Hint to the query planner: shared_buffers + OS page cache. Rule of thumb: 75% of total RAM.\nDoes not allocate memory — only affects query planning decisions.",
        }),
        maintenanceWorkMem: f("256MB", {
          comment:
            "Memory for VACUUM, CREATE INDEX, ALTER TABLE. Recommended: 5–10% of total RAM.",
        }),
        workMem: f("32MB", {
          comment:
            "Per-sort / per-hash memory. Each query can use this multiple times.\nFormula: (RAM - sharedBuffers) / (maxConnections * 3) for worst-case safety.\nFor web workloads with low actual concurrency, 32–64MB is a good balance.",
        }),
        walBuffers: f("-1", {
          comment:
            "WAL write buffer. -1 = auto (1/32 of sharedBuffers). Only change if you see WAL write bottlenecks.",
        }),
        effectiveIoConcurrency: f("200", {
          comment:
            "Concurrent I/O requests for bitmap heap scans. SSD: 200, HDD: 2–4.\nNote: for network-attached volumes (EBS, GCP PD) the optimal value varies — tune if needed.",
        }),
        randomPageCost: f("1.1", {
          comment:
            "Planner cost for random page access relative to sequential. SSD: 1.1, HDD: 4.0 (default).",
        }),
        minWalSize: f("1GB", {
          comment:
            "Lower bound on WAL disk space retained. Prevents constant WAL recycling under write load.",
        }),
        maxWalSize: f("4GB", {
          comment:
            "Max WAL size before forcing a checkpoint. Higher = fewer checkpoints, more I/O smoothing.",
        }),
        maxWorkerProcesses: f("4", {
          comment:
            "Total background worker processes. Should not exceed CPU count. (change requires restart)",
        }),
        maxParallelWorkers: f("4", {
          comment:
            "Max parallel workers across all parallel operations. Should not exceed CPU count.",
        }),
      },
      shm: f(
        { sizeLimit: "2Gi" },
        {
          comment:
            "Shared memory size for /dev/shm. Should be at least as large as sharedBuffers.\nKubernetes caps /dev/shm at 64Mi by default — this overrides that limit.",
        },
      ),
      volumePermissions: f(
        {
          enabled: true,
          image: {
            repository: dependencies.postgresVolumePermissionImage.repo,
            tag: dependencies.postgresVolumePermissionImage.tag,
            pullPolicy: "IfNotPresent",
          },
          resources: {
            limits: { cpu: "100m", memory: "64Mi" },
            requests: { cpu: "10m", memory: "16Mi" },
          },
        },
        {
          comment:
            "An init container that chowns the data directory to UID/GID 999 before\npostgres starts. Required because the chart's postgresql image ships with\nUSER 999 baked in, which prevents the upstream entrypoint from chowning\nthe volume itself. On storage classes that mount volumes as root (e.g.\nAzure Disk on AKS, hostpath on minikube), this init container is what\nmakes the data dir writable by the postgres user.",
        },
      ),
      podSecurityContext: f(
        {},
        {
          comment:
            "Pod-level security context. fsGroup is left unset by default — the init\ncontainer above handles ownership. Set fsGroup if you need it for other\nreasons (e.g. shared sidecar access to the data volume).",
        },
      ),
      containerSecurityContext: f(
        {
          seccompProfile: { type: "RuntimeDefault" },
          allowPrivilegeEscalation: false,
          runAsNonRoot: true,
          runAsUser: 999,
          runAsGroup: 999,
          capabilities: { drop: ["ALL"] },
        },
        {
          comment:
            "Container-level security context for the postgresql container. Runs as\nUID 999 (matches the image's USER directive); the volume has already\nbeen chowned by the init container.",
        },
      ),
      resources: {
        limits: { cpu: "4000m", memory: "8024Mi" },
        requests: { cpu: "1000m", memory: "2056Mi" },
      },
    },
    { blankBefore: true, comment: banner("DevGuard PostgreSQL Database Settings") },
  ),

  observability: f(
    {
      serviceMonitor: {
        enabled: f(false, {
          comment: "Set to true if you have the Prometheus Operator installed",
        }),
        additionalLabels: f(
          {},
          {
            comment:
              "Labels added to every ServiceMonitor (used by Prometheus Operator to discover monitors)",
          },
        ),
        prometheusNamespace: f("monitoring", {
          comment:
            "Namespace where Prometheus is running — used to open NetworkPolicy egress",
        }),
        prometheusNamespaceSelectorKey: f("kubernetes.io/metadata.name", {
          comment:
            "Namespace selector key/value used in NetworkPolicy to allow Prometheus scraping",
        }),
        interval: "30s",
        scrapeTimeout: "10s",
      },
      grafanaDashboard: f(
        {
          enabled: f(false, {
            comment:
              "Set to true to deploy Grafana dashboard ConfigMaps for span metrics and postgresql\nRequires the Grafana sidecar to watch for ConfigMaps with the label you can configure below",
          }),
        },
        {
          trailingComment:
            'The label name which the Grafana sidecar is searching for. Defaults to "grafana_dashboard"\nlabelName: "grafana_dashboard"\nThe label value which the Grafana sidecar is searching for. Defaults to "1"\nlabelValue: "1"',
        },
      ),
      api: {
        metrics: {
          path: f("/api/v1/metrics", {
            comment:
              "Path of the metrics endpoint exposed by the DevGuard API",
          }),
        },
      },
      postgresql: {
        exporter: {
          image: {
            repository: dependencies.postgresExporter.repo,
            tag: dependencies.postgresExporter.tag,
            pullPolicy: "IfNotPresent",
          },
          containerSecurityContext: f(
            {
              seccompProfile: { type: "RuntimeDefault" },
              allowPrivilegeEscalation: false,
              runAsNonRoot: true,
              runAsUser: 65534,
              capabilities: { drop: ["ALL"] },
            },
            {
              comment:
                "Container-level security context for the postgres-exporter sidecar.",
            },
          ),
          resources: {
            limits: { cpu: "100m", memory: "128Mi" },
            requests: { cpu: "10m", memory: "32Mi" },
          },
        },
      },
    },
    { blankBefore: true, comment: banner("Observability Settings") },
  ),
};
