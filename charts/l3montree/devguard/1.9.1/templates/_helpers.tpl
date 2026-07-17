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

