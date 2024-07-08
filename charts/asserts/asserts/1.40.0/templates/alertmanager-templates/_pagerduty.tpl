{{/*
PagerDuty template
*/}}
{{- define "pagerduty.template" -}}
{{- $assertsUrl := .Values.assertsUrl }}
{{- $plus30min := "%2B30m" }}
{{- printf "\n    {{ define \"pagerduty.notification.description\" -}}" -}}
{{- printf "\n      [{{ .Status | toUpper }}{{ if eq .Status \"firing\" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .CommonLabels.asserts_notification_rule_name }}" -}}
{{- printf "\n      {{- if .CommonLabels.job }} for {{ .CommonLabels.job }}" -}}
{{- printf "\n      {{- else if .CommonLabels.service }} for {{ .CommonLabels.service }}" -}}
{{- printf "\n      {{- end }}" -}}
{{- printf "\n    {{- end }}" -}}
{{- printf "\n    " -}}
{{- printf "\n    {{ define \"pagerduty.notification.link.incidents\" -}}" -}}
{{- printf "\n      %s/incidents?start={{(index .Alerts 0).StartsAt.Unix}}000-30m&end={{(index .Alerts 0).StartsAt.Unix}}000%s&search={{ .CommonLabels.asserts_notification_rule_name }}" $assertsUrl $plus30min -}}
{{- printf "\n    {{- end }}" -}}
{{- printf "\n    " -}}
{{- printf "\n    {{ define \"pagerduty.notification.link.insights\" -}}" -}}
{{- printf "\n      %s/insights/top?start={{(index .Alerts 0).StartsAt.Unix}}000-30m&end={{(index .Alerts 0).StartsAt.Unix}}000%s&search={{ .CommonLabels.asserts_assertion_name }}" $assertsUrl $plus30min -}}
{{- printf "\n    {{- end }}" -}}
{{- printf "\n    " -}}
{{- printf "\n    {{/* PagerDuty Slo */}}" -}}
{{- printf "\n    {{ define \"pagerduty.slo.description\" -}}" -}}
{{- printf "\n      [{{ .Status | toUpper }}]: Elevated burn rate on SLO \"{{ .GroupLabels.asserts_slo_name }}\"" -}}
{{- printf "\n    " -}}
{{- printf "\n      Asserts has detected an elevated burn rate on the \"{{ .GroupLabels.asserts_slo_name }}\" service level objective. These compliance windows are off track:" -}}
{{- printf "\n      {{ range .Alerts }} {{ if .Annotations.description }}*Description:* {{ printf \"%s%s\" .Annotations.description }}{{ end }}{{ end }}" "%s" "\\n" -}}
{{- printf "\n    {{- end }}" -}}
{{- printf "\n    " -}}
{{- printf "\n    {{ define \"pagerduty.slo.link.incidents\" -}}" -}}
{{- printf "\n      {{- if .CommonLabels.asserts_site }}" -}}
{{- printf "\n      %s/incidents?env[0]={{ .CommonLabels.asserts_env }}&site[0]={{ .CommonLabels.asserts_site }}&start={{(index .Alerts 0).StartsAt.Unix}}000-30m&end={{(index .Alerts 0).StartsAt.Unix}}000%s&search={{ .GroupLabels.asserts_slo_name }}" $assertsUrl $plus30min -}}
{{- printf "\n      {{- else }}" -}}
{{- printf "\n      %s/incidents?env[0]={{ .CommonLabels.asserts_env }}&start={{(index .Alerts 0).StartsAt.Unix}}000-30m&end={{(index .Alerts 0).StartsAt.Unix}}000%s&search={{ .GroupLabels.asserts_slo_name }}" $assertsUrl $plus30min -}}
{{- printf "\n      {{- end }}" -}}
{{- printf "\n    {{- end }}" -}}
{{- printf "\n    " -}}
{{- printf "\n    {{ define \"pagerduty.slo.link.assertions\" -}}" -}}
{{- printf "\n      {{- if .CommonLabels.asserts_site }}" -}}
{{- printf "\n      %s/assertions?env[0]={{ .CommonLabels.asserts_env }}&site[0]={{ .CommonLabels.asserts_site }}&slo_name={{.CommonLabels.asserts_slo_name}}&start={{(index .Alerts 0).StartsAt.Unix}}000-30m&end={{(index .Alerts 0).StartsAt.Unix}}000%s" $assertsUrl $plus30min -}}
{{- printf "\n      {{- else }}" -}}
{{- printf "\n      %s/incidents?env[0]={{ .CommonLabels.asserts_env }}&start={{(index .Alerts 0).StartsAt.Unix}}000-30m&end={{(index .Alerts 0).StartsAt.Unix}}000%s&search={{ .GroupLabels.asserts_slo_name }}" $assertsUrl $plus30min -}}
{{- printf "\n      {{- end }}" -}}
{{- printf "\n    {{- end }}" -}}
{{- end }}
