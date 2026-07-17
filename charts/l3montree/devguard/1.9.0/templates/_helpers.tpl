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

