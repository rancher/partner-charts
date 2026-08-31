{{/*
Domain fan-out — the single global.domain becomes the four hosts. Everything the
umbrella OWNS (APISIX routes, TLS SNIs, the endpoints ConfigMap) uses these.
*/}}
{{- define "alchemi.appHost" -}}{{ .Values.global.subdomains.app }}.{{ required "global.domain is required" .Values.global.domain }}{{- end -}}
{{- define "alchemi.authHost" -}}{{ .Values.global.subdomains.auth }}.{{ required "global.domain is required" .Values.global.domain }}{{- end -}}
{{- define "alchemi.opsHost" -}}{{ .Values.global.subdomains.ops }}.{{ required "global.domain is required" .Values.global.domain }}{{- end -}}
{{- define "alchemi.zenithHost" -}}{{ .Values.global.subdomains.zenith }}.{{ required "global.domain is required" .Values.global.domain }}{{- end -}}

{{/* Full https URLs + the Keycloak OIDC callback (the login-critical redirect URI). */}}
{{- define "alchemi.appUrl"    -}}https://{{ include "alchemi.appHost" . }}{{- end -}}
{{- define "alchemi.authUrl"   -}}https://{{ include "alchemi.authHost" . }}{{- end -}}
{{- define "alchemi.nextauthUrl" -}}https://{{ include "alchemi.appHost" . }}{{- end -}}
{{- define "alchemi.redirectUri" -}}https://{{ include "alchemi.appHost" . }}/api/auth/callback/keycloak{{- end -}}

{{- define "alchemi.pullSecret" -}}{{ .Values.global.image.pullSecret }}{{- end -}}

{{/* First-user seed identity — derived exactly like the Azure bootstrap:
     ADMIN_NAME = email local-part, ACCOUNT_NAME = domain first label. Overridable. */}}
{{- define "alchemi.adminName" -}}{{ .Values.admin.name | default (splitList "@" (required "admin.email is required" .Values.admin.email) | first) }}{{- end -}}
{{- define "alchemi.accountName" -}}{{ .Values.admin.orgName | default (splitList "." (required "global.domain is required" .Values.global.domain) | first) }}{{- end -}}

{{/* PostgreSQL connection — bundled pgvector service, or the customer's external host. */}}
{{- define "alchemi.pgHost" -}}
{{- if eq .Values.postgres.mode "external" -}}{{ required "postgres.external.host is required when postgres.mode=external" .Values.postgres.external.host }}
{{- else -}}alchemi-pgvector.{{ .Values.global.namespaces.data }}.svc.cluster.local{{- end -}}
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
{{- else -}}alchemi-redis.{{ .Values.global.namespaces.data }}.svc.cluster.local{{- end -}}
{{- end -}}
{{- define "alchemi.redisPort" -}}{{ if eq .Values.redis.mode "external" }}{{ .Values.redis.external.port }}{{ else }}6379{{ end }}{{- end -}}
{{- define "alchemi.redisTls" -}}{{ if eq .Values.redis.mode "external" }}{{ .Values.redis.external.tls }}{{ else }}false{{ end }}{{- end -}}

{{/* OpenBao service URL — used by the init job + ESO ClusterSecretStore. */}}
{{- define "alchemi.baoAddr" -}}
http://openbao.{{ .Values.openbao.namespace | default "openbao" }}.svc:8200
{{- end -}}

{{/* Object store — Azure Blob–compatible endpoint.
     bundled = SeaweedFS azblob port 10000; external = customer's blobEndpoint. */}}
{{- define "alchemi.blobEndpoint" -}}
{{- if eq .Values.objectStore.mode "bundled" -}}
http://seaweedfs.{{ .Values.global.namespaces.data }}.svc:10000
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
