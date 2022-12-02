{{/* Common templates for HorizontalPodAutoscaler */}}

{{/*
Returns the appropriate apiVersion for HoritonzalPodAutoscaler.

It expects a dictionary with three entries:
  - `global` which contains global HPA settings, e.g. .Values.global.hpa
  - `local` which contains local HPA settings, e.g. .Values.sidekiq.hpa
  - `context` which is the parent context (either `.` or `$`)
*/}}
{{- define "gitlab.hpa.apiVersion" -}}
{{-   if .local.apiVersion -}}
{{-     .local.apiVersion -}}
{{-   else if .global.apiVersion -}}
{{-     .global.apiVersion -}}
{{-   else if .context.Capabilities.APIVersions.Has "autoscaling/v2/HorizontalPodAutoscaler" -}}
{{-     print "autoscaling/v2" -}}
{{-   else if .context.Capabilities.APIVersions.Has "autoscaling/v2beta2/HorizontalPodAutoscaler" -}}
{{-     print "autoscaling/v2beta2" -}}
{{-   else -}}
{{-     print "autoscaling/v2beta1" -}}
{{-   end -}}
{{- end -}}

{{/*
Checks if the autoscaling/v2 metrics spec is supported

It expects a dictionary with three entries:
  - `global` which contains global HPA settings, e.g. .Values.global.hpa
  - `local` which contains local HPA settings, e.g. .Values.sidekiq.hpa
  - `context` which is the parent context (either `.` or `$`)
*/}}
{{- define "gitlab.hpa.supportsV2MetricsSpec" -}}
{{-   $apiVersion := include "gitlab.hpa.apiVersion" . -}}
{{-   if or (eq $apiVersion "autoscaling/v2") (eq $apiVersion "autoscaling/v2beta2") -}}
true
{{-   end -}}
{{- end -}}

{{/*
Checks if the autoscaling/v2 behavior spec is supported

It expects a dictionary with three entries:
  - `global` which contains global HPA settings, e.g. .Values.global.hpa
  - `local` which contains local HPA settings, e.g. .Values.sidekiq.hpa
  - `context` which is the parent context (either `.` or `$`)
*/}}
{{- define "gitlab.hpa.supportsV2BehaviorSpec" -}}
{{-   $apiVersion := include "gitlab.hpa.apiVersion" . -}}
{{-   if or (eq $apiVersion "autoscaling/v2") (and (eq $apiVersion "autoscaling/v2beta2") (semverCompare ">=1.18.0-0" .context.Capabilities.KubeVersion.Version)) -}}
true
{{-   end -}}
{{- end -}}

{{/*
Returns the HorizontalPodAutoscaler metrics spec properly formatted for the
highest supported API version of HorizontalPodAutoscaler

It expects a dictionary with three entries:
  - `global` which contains global HPA settings, e.g. .Values.global.hpa
  - `local` which contains local HPA settings, e.g. .Values.sidekiq.hpa
  - `context` which is the parent context (either `.` or `$`)
*/}}
{{- define "gitlab.hpa.metrics" -}}
{{- $params := . -}}
metrics:
{{- if not .local.customMetrics }}
  {{- with .local.cpu }}
  {{- $targetType := default "Utilization" .targetType }}
  - type: Resource
    resource:
      name: cpu
      {{- if (include "gitlab.hpa.supportsV2MetricsSpec" $params) }}
      target:
        type: {{ $targetType }}
        {{- if eq $targetType "Utilization" }}
        averageUtilization: {{ default .targetAverageUtilization $params.local.targetAverageUtilization }}
        {{- else }}
        averageValue: {{ default .targetAverageValue $params.local.targetAverageValue }}
        {{- end }}
      {{- else }}
        {{- if eq $targetType "Utilization" }}
      targetAverageUtilization: {{ default .targetAverageUtilization $params.local.targetAverageUtilization }}
        {{- else }}
      targetAverageValue: {{ default .targetAverageValue $params.local.targetAverageValue }}
        {{- end }}
      {{- end }}
  {{- end }}
  {{- with .local.memory }}
  {{- $targetType := default "Utilization" .targetType }}
  - type: Resource
    resource:
      name: memory
      {{- if (include "gitlab.hpa.supportsV2MetricsSpec" $params) }}
      target:
        type: {{ $targetType }}
        {{- if eq $targetType "Utilization" }}
        averageUtilization: {{ .targetAverageUtilization }}
        {{- else }}
        averageValue: {{ .targetAverageValue }}
        {{- end }}
      {{- else }}
        {{- if eq $targetType "Utilization" }}
      targetAverageUtilization: {{ .targetAverageUtilization }}
        {{- else }}
      targetAverageValue: {{ .targetAverageValue }}
        {{- end }}
      {{- end }}
  {{- end }}
{{- else }}
  {{- toYaml .local.customMetrics | nindent 4 }}
{{- end }}
{{- end -}}

{{/*
Returns the HorizontalPodAutoscaler behavior spec if supported

It expects a dictionary with three entries:
  - `global` which contains global HPA settings, e.g. .Values.global.hpa
  - `local` which contains local HPA settings, e.g. .Values.sidekiq.hpa
  - `context` which is the parent context (either `.` or `$`)
*/}}
{{- define "gitlab.hpa.behavior" -}}
{{- if (include "gitlab.hpa.supportsV2BehaviorSpec" .) }}
{{-     with .local.behavior -}}
behavior:
  {{- toYaml . | nindent 2 }}
{{-     end -}}
{{-   end -}}
{{- end -}}
