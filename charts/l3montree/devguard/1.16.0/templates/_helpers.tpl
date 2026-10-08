{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "devguard.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "devguard.labels" -}}
helm.sh/chart: {{ include "devguard.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Build an image reference from either a full image string or an object.
Supported object keys: repository, tag, digest.
*/}}
{{- define "devguard.image" -}}
{{- $image := .image -}}
{{- $defaultTag := .defaultTag -}}
{{- if kindIs "string" $image -}}
{{- $image -}}
{{- else -}}
{{- $repository := required "image.repository is required" $image.repository -}}
{{- if and (hasKey $image "digest") $image.digest -}}
{{- printf "%s@%s" $repository $image.digest -}}
{{- else -}}
{{- printf "%s:%s" $repository ($image.tag | default $defaultTag) -}}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
Resolve the web ingress hostname. Prefers the single-host scalar
(web.ingress.host); falls back to the legacy list shape
(web.ingress.hosts[0].host), kept for backwards compatibility with values
files written before the single-host migration.
Usage: include "devguard.webHost" .
*/}}
{{- define "devguard.webHost" -}}
{{- if .Values.web.ingress.host -}}
{{- .Values.web.ingress.host -}}
{{- else if .Values.web.ingress.hosts -}}
{{- (index .Values.web.ingress.hosts 0).host -}}
{{- else -}}
{{- fail "web.ingress.host must be set" -}}
{{- end -}}
{{- end }}

{{/*
Resolve the API ingress hostname. Prefers the single-host scalar
(api.ingress.host); falls back to the legacy list shape
(api.ingress.hosts[0].host), kept for backwards compatibility with values
files written before the single-host migration.
Usage: include "devguard.apiHost" .
*/}}
{{- define "devguard.apiHost" -}}
{{- if .Values.api.ingress.host -}}
{{- .Values.api.ingress.host -}}
{{- else if .Values.api.ingress.hosts -}}
{{- (index .Values.api.ingress.hosts 0).host -}}
{{- else -}}
{{- fail "api.ingress.host must be set" -}}
{{- end -}}
{{- end }}

{{/*
Resolve the PostgreSQL endpoint. Returns the in-release Service when the
bundled StatefulSet is deployed (postgresql.enabled), otherwise the external
database configured under postgresql.external.
Usage: include "devguard.postgresHost" . / "devguard.postgresPort" .
*/}}
{{- define "devguard.postgresHost" -}}
{{- if .Values.postgresql.enabled -}}
postgresql
{{- else -}}
{{- required "postgresql.external.host is required when postgresql.enabled is false" .Values.postgresql.external.host -}}
{{- end -}}
{{- end }}

{{- define "devguard.postgresSslMode" -}}
{{- if .Values.postgresql.enabled -}}
disable
{{- else -}}
{{- .Values.postgresql.external.sslMode | default "disable" -}}
{{- end -}}
{{- end }}

{{- define "devguard.postgresPort" -}}
{{- if .Values.postgresql.enabled -}}
5432
{{- else -}}
{{- .Values.postgresql.external.port | default 5432 -}}
{{- end -}}
{{- end }}

{{/*
DSN for kratos and the kratos cleanup job. Expects DB_PASSWORD in the env.
Usage: include "devguard.kratosDsn" .
*/}}
{{- define "devguard.kratosDsn" -}}
{{- $sslMode := "disable" -}}
{{- if not .Values.postgresql.enabled -}}
{{- $sslMode = .Values.postgresql.external.sslMode | default "disable" -}}
{{- end -}}
{{- printf "postgres://kratos:$(DB_PASSWORD)@%s:%s/kratos?sslmode=%s" (include "devguard.postgresHost" .) (include "devguard.postgresPort" .) $sslMode -}}
{{- end }}

{{/*
Parse the otel-collector sidecar memory limit (e.g. "768Mi", "1Gi") into an
integer number of MiB. Used to derive the memory_limiter processor limits and
GOMEMLIMIT so the collector stays below its Kubernetes memory limit.
Usage: include "devguard.otelMemLimitMib" .
*/}}
{{- define "devguard.otelMemLimitMib" -}}
{{- $mem := .Values.api.tracing.spanMetrics.resources.limits.memory | toString -}}
{{- if hasSuffix "Gi" $mem -}}
{{- mul (trimSuffix "Gi" $mem | int) 1024 -}}
{{- else if hasSuffix "Mi" $mem -}}
{{- trimSuffix "Mi" $mem | int -}}
{{- else -}}
{{- fail "api.tracing.spanMetrics.resources.limits.memory must use a Mi or Gi suffix" -}}
{{- end -}}
{{- end }}

{{/*
Resolve image pull policy for both image input styles.
*/}}
{{- define "devguard.imagePullPolicy" -}}
{{- $image := .image -}}
{{- if kindIs "map" $image -}}
{{- $image.pullPolicy | default "IfNotPresent" -}}
{{- else -}}
IfNotPresent
{{- end -}}
{{- end }}

