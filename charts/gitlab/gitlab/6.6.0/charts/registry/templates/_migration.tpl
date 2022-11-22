{{/*
Return migration configuration.
*/}}
{{- define "registry.migration.config" -}}
migration:
  enabled: {{ .Values.migration.enabled | eq true }}
{{-   if .Values.migration.disablemirrorfs }}
  disablemirrorfs: true
{{-   end }}
{{-   if .Values.migration.rootdirectory }}
  rootdirectory: {{ .Values.migration.rootdirectory }}
{{-   end }}
{{-   if .Values.migration.importtimeout }}
  importtimeout: {{ .Values.migration.importtimeout }}
{{-   end }}
{{-   if .Values.migration.preimporttimeout }}
  preimporttimeout: {{ .Values.migration.preimporttimeout }}
{{-   end }}
{{-   if .Values.migration.tagconcurrency }}
  tagconcurrency: {{ .Values.migration.tagconcurrency }}
{{-   end }}
{{-   if .Values.migration.maxconcurrentimports }}
  maxconcurrentimports: {{ .Values.migration.maxconcurrentimports }}
{{-   end }}
{{- if and .Values.migration.enabled .Values.migration.importnotification.enabled }}
  importnotification:
    enabled: true
    {{- if .Values.migration.importnotification.url }}
    url: {{ .Values.migration.importnotification.url | quote }}
    {{- else }}
    url:  "{{ template "gitlab.gitlab.url" . }}/api/v4/internal/registry/repositories/{path}/migration/status"
    {{- end }}
    timeout: {{ .Values.migration.importnotification.timeout }}
    secret: "NOTIFICATION_SECRET"
{{- end -}}
{{- end -}}
