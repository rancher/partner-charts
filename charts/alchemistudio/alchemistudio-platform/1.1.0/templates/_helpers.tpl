{{/*
Namespaces (chart 1.1.0+). global.namespaceMode picks the layout:
  single (default) — EVERYTHING in the release namespace (the one picked at install time /
                     the blueprint's targetNamespace). The chart creates no namespaces.
  split            — the app tier stays in the release namespace; every other tier gets its
                     own namespace "<global.namespacePrefix>-<tier>" (prefix default
                     "alchemistudio"), created and removed by the chart (namespaces.yaml).
                     Each instance on a cluster needs its own prefix.
Tiers: app (web/ai/compute/worker/zenith/guardrails/workflow/AIOS + ESO), data
(Postgres/Redis/SeaweedFS), auth (Keycloak), observability (OpenObserve), gateway
(APISIX/etcd/TLS), secrets (OpenBao), sandbox (user-code pods).
*/}}
{{- define "alchemi.ns.mode" -}}
{{- $m := .Values.global.namespaceMode | default "single" -}}
{{- if not (has $m (list "single" "split")) -}}{{ fail (printf "global.namespaceMode must be single or split (got %q)" $m) }}{{- end -}}
{{ $m }}
{{- end -}}
{{- define "alchemi.ns.tier" -}}
{{- $root := index . 0 -}}
{{- if eq (include "alchemi.ns.mode" $root) "split" -}}
{{ printf "%s-%s" ($root.Values.global.namespacePrefix | default "alchemistudio") (index . 1) }}
{{- else -}}
{{ $root.Release.Namespace }}
{{- end -}}
{{- end -}}
{{- define "alchemi.ns.app" -}}{{ .Release.Namespace }}{{- end -}}
{{- define "alchemi.ns.data" -}}{{ include "alchemi.ns.tier" (list . "data") }}{{- end -}}
{{- define "alchemi.ns.auth" -}}{{ include "alchemi.ns.tier" (list . "auth") }}{{- end -}}
{{- define "alchemi.ns.observability" -}}{{ include "alchemi.ns.tier" (list . "observability") }}{{- end -}}
{{- define "alchemi.ns.gateway" -}}{{ include "alchemi.ns.tier" (list . "gateway") }}{{- end -}}
{{- define "alchemi.ns.secrets" -}}{{ include "alchemi.ns.tier" (list . "secrets") }}{{- end -}}
{{- define "alchemi.ns.sandbox" -}}{{ include "alchemi.ns.tier" (list . "sandbox") }}{{- end -}}
{{/* Every namespace this instance uses (deduplicated), space-separated — for loops that
     place a copy of something (e.g. the image pull secret) in each one. */}}
{{- define "alchemi.ns.all" -}}
{{- $l := list (include "alchemi.ns.app" .) (include "alchemi.ns.data" .) (include "alchemi.ns.auth" .) (include "alchemi.ns.observability" .) (include "alchemi.ns.sandbox" .) -}}
{{- if eq .Values.gateway.mode "bundled" -}}{{- $l = append $l (include "alchemi.ns.gateway" .) -}}{{- end -}}
{{- if .Values.openbao.enabled -}}{{- $l = append $l (include "alchemi.ns.secrets" .) -}}{{- end -}}
{{ $l | uniq | join " " }}
{{- end -}}

{{/*
compute-api's ENVIRONMENT. Set explicitly in values (alchemi-compute-api.config.ENVIRONMENT)
so the namespace label that compute-api's AIOS sandbox NetworkPolicy matches
(namespace-labels-job.yaml) can never drift from what compute-api actually runs with.
*/}}
{{- define "alchemi.computeEnvironment" -}}
{{ (index .Values "alchemi-compute-api" "config" "ENVIRONMENT") | default "production" }}
{{- end -}}

{{/*
Small Python image for the chart's helper Jobs (OpenBao init, AIOS data-plane bridge).
Both scripts use only the Python standard library (json/ssl/urllib), so a ~17 MB
python:alpine replaces the ~1 GB azure-cli image used before. Pulled from
global.image.registry (so a mirrored registry works); openbao.initImage overrides it.
*/}}
{{- define "alchemi.jobImage" -}}
{{ .Values.openbao.initImage | default (printf "%s/platform/python:3.12.15-alpine3.24" .Values.global.image.registry) }}
{{- end -}}

{{/*
ACME HTTP-01 solver — the cluster ingress controller that answers the challenge.
tls.acme.ingressClass (default traefik, RKE2's default) picks cert-manager's solver Ingress
class; the solver Service selects that controller's pods (auto for traefik / nginx, or
tls.acme.solverSelector) on its HTTP port (auto, or tls.acme.solverTargetPort).
*/}}
{{- define "alchemi.acme.class" -}}{{ .Values.tls.acme.ingressClass | default "traefik" }}{{- end -}}
{{- define "alchemi.acme.solverNs" -}}{{ .Values.tls.acme.solverNamespace | default "kube-system" }}{{- end -}}
{{- define "alchemi.acme.solverName" -}}{{ include "alchemi.ns.app" . }}-acme-http-solver{{- end -}}
{{- define "alchemi.acme.solverSelector" -}}
{{- if .Values.tls.acme.solverSelector -}}{{ toYaml .Values.tls.acme.solverSelector }}
{{- else if eq (include "alchemi.acme.class" .) "nginx" -}}
app.kubernetes.io/name: rke2-ingress-nginx
app.kubernetes.io/component: controller
{{- else if eq (include "alchemi.acme.class" .) "traefik" -}}
app.kubernetes.io/name: rke2-traefik
{{- else -}}{{ fail (printf "tls.acme.ingressClass=%q: set tls.acme.solverSelector to the labels of that ingress controller's pods" (include "alchemi.acme.class" .)) }}
{{- end -}}
{{- end -}}
{{- define "alchemi.acme.solverPort" -}}
{{- if .Values.tls.acme.solverTargetPort -}}{{ .Values.tls.acme.solverTargetPort }}
{{- else if eq (include "alchemi.acme.class" .) "traefik" -}}web
{{- else -}}80{{- end -}}
{{- end -}}

{{/*
Domain fan-out — the single global.domain becomes the four hosts. Everything the
umbrella OWNS (APISIX routes, TLS SNIs, the endpoints ConfigMap) uses these.
*/}}
{{/* Effective base domain — the install needs EITHER a real domain OR a pinned static IP.
     Precedence:
       1. global.domain set                          -> use it (real DNS; point
          <subdomain>.<domain> at the gateway IP: kubectl -n <gateway-namespace> get svc apisix-gateway).
       2. global.domain blank + gateway.loadBalancerIP set -> derive "<ip>.<wildcardDns>"
          (global.wildcardDns: nip.io default, or sslip.io) automatically. The customer
          PINNED the IP, so we know it up front and the wildcard-DNS service resolves it
          with zero DNS setup. (This is why an IP alone is enough — the old
          "no nip.io fallback" limit only applied when the IP was unknown before install.)
       3. both blank                                 -> FAIL FAST: there is no usable
          hostname, so the install is stopped with a clear message instead of rendering
          hostnames that resolve nowhere.
     Everything the umbrella OWNS (APISIX routes, TLS SNIs, the endpoints ConfigMap) uses this. */}}
{{- define "alchemi.baseDomain" -}}
{{- if .Values.global.domain -}}
{{ .Values.global.domain }}
{{- else if .Values.gateway.loadBalancerIP -}}
{{- $wildcard := .Values.global.wildcardDns | default "nip.io" -}}
{{- if not (has $wildcard (list "nip.io" "sslip.io")) -}}
{{ fail (printf "global.wildcardDns must be nip.io or sslip.io (got %q)." $wildcard) }}
{{- end -}}
{{ printf "%s.%s" .Values.gateway.loadBalancerIP $wildcard }}
{{- else -}}
{{ fail "No usable hostname: set EITHER global.domain (a real base domain, e.g. ai.example.com — then point <subdomain>.<domain> DNS at the gateway IP) OR gateway.loadBalancerIP (a reserved static IP — the app is then served at <ip>.nip.io, or <ip>.sslip.io with global.wildcardDns, with no DNS setup). Both are currently empty, so the install is stopped." }}
{{- end -}}
{{- end -}}
{{- define "alchemi.appHost" -}}{{ .Values.global.subdomains.app }}.{{ include "alchemi.baseDomain" . }}{{- end -}}
{{- define "alchemi.authHost" -}}{{ .Values.global.subdomains.auth }}.{{ include "alchemi.baseDomain" . }}{{- end -}}
{{- define "alchemi.opsHost" -}}{{ .Values.global.subdomains.ops }}.{{ include "alchemi.baseDomain" . }}{{- end -}}
{{- define "alchemi.zenithHost" -}}{{ .Values.global.subdomains.zenith }}.{{ include "alchemi.baseDomain" . }}{{- end -}}

{{/* Full https URLs + the Keycloak OIDC callback (the login-critical redirect URI). */}}
{{- define "alchemi.appUrl"    -}}https://{{ include "alchemi.appHost" . }}{{- end -}}
{{- define "alchemi.authUrl"   -}}https://{{ include "alchemi.authHost" . }}{{- end -}}
{{- define "alchemi.nextauthUrl" -}}https://{{ include "alchemi.appHost" . }}{{- end -}}
{{- define "alchemi.redirectUri" -}}https://{{ include "alchemi.appHost" . }}/api/auth/callback/keycloak{{- end -}}

{{- define "alchemi.pullSecret" -}}{{ .Values.global.image.pullSecret }}{{- end -}}

{{/* -----------------------------------------------------------------------------
  Activation file ("license file") resolvers.

  A customer may paste a single per-customer ACTIVATION FILE (YAML) into the form
  field `activation` instead of baking creds into the public chart. It carries the
  registry pull token + the license JWT, e.g.:

    license: "<signed JWT>"
    registry:
      server: alchemiacr.azurecr.io
      username: acme-pull
      token: "<per-customer ACR token>"
    domain: ai.acme.com            # informational; authoritative domain is the form field

  These helpers return the EFFECTIVE value: the activation file wins when present,
  otherwise we fall back to the existing values (global.imageCredentials / license.jwt)
  so the legacy baked/trial path and `--set` installs keep working unchanged.
  `dig` safely returns the fallback when the activation key is absent or the file blank.
*/}}
{{- define "alchemi._activation" -}}{{- .Values.activation | default "" | fromYaml | toYaml -}}{{- end -}}
{{- define "alchemi.regUser" -}}
{{- $a := (.Values.activation | default "" | fromYaml) -}}
{{- dig "registry" "username" (.Values.global.imageCredentials.username | default "") $a -}}
{{- end -}}
{{- define "alchemi.regPass" -}}
{{- $a := (.Values.activation | default "" | fromYaml) -}}
{{- dig "registry" "token" (.Values.global.imageCredentials.password | default "") $a -}}
{{- end -}}
{{- define "alchemi.regServer" -}}
{{- $a := (.Values.activation | default "" | fromYaml) -}}
{{- dig "registry" "server" (.Values.global.image.registry) $a -}}
{{- end -}}
{{- define "alchemi.licenseJwt" -}}
{{- $a := (.Values.activation | default "" | fromYaml) -}}
{{- dig "license" (.Values.license.jwt | default "") $a -}}
{{- end -}}

{{/* Embedding endpoint (OpenAI base) — explicit override, else the bundled TEI service. */}}
{{- define "alchemi.embeddingEndpoint" -}}
{{- if .Values.selfHostedModel.embedding.endpointUrl -}}{{ .Values.selfHostedModel.embedding.endpointUrl }}
{{- else -}}http://alchemi-embeddings.{{ (include "alchemi.ns.app" $) }}.svc.cluster.local:80/v1{{- end -}}
{{- end -}}

{{/* First-user seed identity — derived exactly like the Azure bootstrap:
     ADMIN_NAME = email local-part, ACCOUNT_NAME = domain first label. Overridable. */}}
{{- define "alchemi.adminName" -}}{{ .Values.admin.name | default (splitList "@" (required "admin.email is required" .Values.admin.email) | first) }}{{- end -}}
{{- define "alchemi.accountName" -}}{{ .Values.admin.orgName | default (splitList "." (include "alchemi.baseDomain" .) | first) }}{{- end -}}

{{/* PostgreSQL connection — bundled pgvector service, or the customer's external host. */}}
{{- define "alchemi.pgHost" -}}
{{- if eq .Values.postgres.mode "external" -}}{{ required "postgres.external.host is required when postgres.mode=external" .Values.postgres.external.host }}
{{- else -}}alchemi-pgvector.{{ (include "alchemi.ns.data" $) }}.svc.cluster.local{{- end -}}
{{- end -}}
{{- define "alchemi.pgPort" -}}{{ if eq .Values.postgres.mode "external" }}{{ .Values.postgres.external.port }}{{ else }}5432{{ end }}{{- end -}}
{{- define "alchemi.pgDatabase" -}}{{ if eq .Values.postgres.mode "external" }}{{ .Values.postgres.external.database }}{{ else }}{{ .Values.postgres.database }}{{ end }}{{- end -}}
{{- define "alchemi.pgComputeDatabase" -}}{{ if eq .Values.postgres.mode "external" }}{{ .Values.postgres.external.computeDatabase }}{{ else }}{{ .Values.postgres.computeDatabase }}{{ end }}{{- end -}}
{{- define "alchemi.pgUser" -}}{{ if eq .Values.postgres.mode "external" }}{{ .Values.postgres.external.user }}{{ else }}{{ .Values.postgres.adminUser }}{{ end }}{{- end -}}
{{- define "alchemi.pgAiDatabase" -}}{{ .Values.postgres.aiDatabase | default "alchemi_ai_db" }}{{- end -}}
{{/* sslmode: bundled pgvector has NO SSL -> disable; external is per-config (default require). */}}
{{- define "alchemi.pgSslMode" -}}{{ if eq .Values.postgres.mode "external" }}{{ .Values.postgres.external.sslMode | default "require" }}{{ else }}disable{{ end }}{{- end -}}

{{/* Redis connection — bundled redis service, or the customer's external host. */}}
{{- define "alchemi.redisHost" -}}
{{- if eq .Values.redis.mode "external" -}}{{ required "redis.external.host is required when redis.mode=external" .Values.redis.external.host }}
{{- else -}}alchemi-redis.{{ (include "alchemi.ns.data" $) }}.svc.cluster.local{{- end -}}
{{- end -}}
{{- define "alchemi.redisPort" -}}{{ if eq .Values.redis.mode "external" }}{{ .Values.redis.external.port }}{{ else }}6379{{ end }}{{- end -}}
{{- define "alchemi.redisTls" -}}{{ if eq .Values.redis.mode "external" }}{{ .Values.redis.external.tls }}{{ else }}false{{ end }}{{- end -}}

{{/* OpenBao service URL — used by the init job + ESO ClusterSecretStore. */}}
{{- define "alchemi.baoAddr" -}}
http://openbao.{{ (include "alchemi.ns.secrets" $) }}.svc:8200
{{- end -}}

{{/* Object store — Azure Blob–compatible endpoint.
     bundled = SeaweedFS azblob port 10000; external = customer's blobEndpoint. */}}
{{- define "alchemi.blobEndpoint" -}}
{{- if eq .Values.objectStore.mode "bundled" -}}
http://seaweedfs.{{ (include "alchemi.ns.data" $) }}.svc:10000
{{- else -}}
{{- .Values.objectStore.external.blobEndpoint | default "" -}}
{{- end -}}
{{- end -}}

{{/* KC login theme brand-panel HTML.
     When branding.leftHtml is blank the chart supplies the Style 2 GIF default that
     matches cluster-deployments-nonprod. {{ "{{RESOURCES}}" }} is a FreeMarker token
     resolved by Keycloak at runtime to the theme's /resources/ URL — it is NOT a Helm
     expression and must reach the ConfigMap as the literal string {{RESOURCES}}.
     Using {{ "{{RESOURCES}}" }} here makes Helm emit the four literal characters. */}}
{{- define "alchemi.kcBrandLeftHtml" -}}
{{- if .Values.branding.leftHtml -}}
{{- .Values.branding.leftHtml -}}
{{- else -}}
<div style="position:relative;height:100%;box-sizing:border-box;overflow:hidden;background:#f2f1ec;background-image:linear-gradient(#e6e5df 1px,transparent 1px),linear-gradient(90deg,#e6e5df 1px,transparent 1px);background-size:44px 44px;font-family:Inter,-apple-system,'Segoe UI',sans-serif;color:#111827"><div style="position:absolute;top:46%;left:50%;transform:translate(-50%,-50%);width:min(390px,62%)"><img src="{{ "{{RESOURCES}}" }}/img/module-cycle.gif" alt="AlchemiStudio platform" style="width:100%;height:auto;border-radius:12px;box-shadow:0 24px 60px rgba(0,0,0,.12)"/></div><div style="position:absolute;bottom:34px;left:0;right:0;text-align:center;font-size:13px;font-weight:600;color:#111827">Business Productivity&nbsp;&nbsp;&middot;&nbsp;&nbsp;Engineering Speed&nbsp;&nbsp;&middot;&nbsp;&nbsp;Enterprise Governance&nbsp;&nbsp;&middot;&nbsp;&nbsp;AI Sovereignty</div></div>
{{- end -}}
{{- end -}}

{{/* PGPASSWORD env entry — bundled reads the generated secret; external reads the
     customer's password (value) or an existing secret. Include with `| nindent 12`. */}}
{{- define "alchemi.pgPasswordEnv" -}}
- name: PGPASSWORD
{{- if eq .Values.postgres.mode "external" }}
{{- if .Values.postgres.external.passwordSecret }}
  valueFrom:
    secretKeyRef: { name: {{ .Values.postgres.external.passwordSecret }}, key: POSTGRES_PASSWORD }
{{- else }}
  value: {{ required "postgres.external.password is required when mode=external (or set external.passwordSecret)" .Values.postgres.external.password | quote }}
{{- end }}
{{- else }}
  valueFrom:
    secretKeyRef: { name: alchemi-secrets, key: PG_SUPER_PASSWORD }
{{- end }}
{{- end -}}
