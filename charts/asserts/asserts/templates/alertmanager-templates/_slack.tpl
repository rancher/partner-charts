{{/*
Slack template
*/}}
{{- define "slack.template" -}}
{{- $assertsUrl := .Values.assertsUrl }}
{{- $plus30min := "%2B30m" }}
{{- printf "{{/* Slack Notification */}}\n    " -}}
{{- printf "\n    {{ define \"slack.notification.icon_url\" -}}" -}}
{{- printf "\n      https://avatars.slack-edge.com/2021-08-06/2380420447616_6fa2cce9f76fca45b41d_512.png" -}}
{{- printf "\n    {{- end }}" -}}
{{- printf "\n    " -}}
{{- printf "\n    {{ define \"slack.notification.title\" -}}" -}}
{{- printf "\n      [{{ .Status | toUpper }}{{ if eq .Status \"firing\" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .CommonLabels.asserts_notification_rule_name }}" -}}
{{- printf "\n      {{- if .CommonLabels.job }} for {{ .CommonLabels.job }}" -}}
{{- printf "\n      {{- else if .CommonLabels.service }} for {{ .CommonLabels.service }}" -}}
{{- printf "\n      {{- end }}" -}}
{{- printf "\n    {{- end }}" -}}
{{- printf "\n    " -}}
{{- printf "\n    {{ define \"slack.notification.text\" -}}" -}}
{{- printf "\n      {{- if eq .Status \"firing\" }}" -}}
{{- printf "\n      {{- if .CommonLabels.asserts_site }}" -}}
{{- printf "\n      :warning: *<%s/incidents?env[0]={{ .CommonLabels.asserts_env }}&site[0]={{ .CommonLabels.asserts_site }}&start={{(index .Alerts 0).StartsAt.Unix}}000-30m&end={{(index .Alerts 0).StartsAt.Unix}}000%s&search={{ .CommonLabels.asserts_notification_rule_name }}|View Impact>*" $assertsUrl $plus30min -}}
{{- printf "\n     :fire: *<%s/insights/top?env[0]={{ .CommonLabels.asserts_env }}&site[0]={{ .CommonLabels.asserts_site }}&start={{(index .Alerts 0).StartsAt.Unix}}000-30m&end={{(index .Alerts 0).StartsAt.Unix}}000%s&search={{ .CommonLabels.asserts_assertion_name }}|Start Troubleshooting>*" $assertsUrl $plus30min -}}
{{- printf "\n      {{- else }}" -}}
{{- printf "\n      :warning: *<%s/incidents?env[0]={{ .CommonLabels.asserts_env }}&start={{(index .Alerts 0).StartsAt.Unix}}000-30m&end={{(index .Alerts 0).StartsAt.Unix}}000%s&search={{ .CommonLabels.asserts_notification_rule_name }}|View Impact>*" $assertsUrl $plus30min -}}
{{- printf "\n     :fire: *<%s/insights/top?env[0]={{ .CommonLabels.asserts_env }}&start={{(index .Alerts 0).StartsAt.Unix}}000-30m&end={{(index .Alerts 0).StartsAt.Unix}}000%s&search={{ .CommonLabels.asserts_assertion_name }}|Start Troubleshooting>*" $assertsUrl $plus30min -}}
{{- printf "\n      {{- end }}" -}}
{{- printf "\n      {{- end }}" -}}
{{- printf "\n      *Alert details*:" -}}
{{- printf "\n    " -}}
{{- printf "\n      {{ range .Alerts -}}" -}}
{{- printf "\n      {{ if .Annotations.description }}*Description:* {{ .Annotations.description }}{{ end }}" -}}
{{- printf "\n    " -}}
{{- printf "\n        {{ range .Labels.SortedPairs -}}" -}}
{{- printf "\n        {{- if eq .Name \"source_alertname\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"asserts_env\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"asserts_site\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"deployment\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"statefulset\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"daemonset\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"replicaset\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"job\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"name\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"asserts_severity\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"asserts_request_type\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"asserts_error_type\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"asserts_request_context\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"instance\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"pod\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"d_executed_version\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"configmap\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"config\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- if eq .Name \"persistentvolumeclaim\" }} • *{{ .Name }}:* `{{ .Value }}`{{ end }}" -}}
{{- printf "\n        {{- end }}" -}}
{{- printf "\n      {{- end }}" -}}
{{- printf "\n    {{- end }}" -}}
{{- printf "\n    " -}}
{{- printf "\n    {{/* Slack Slo */}}" -}}
{{- printf "\n    {{ define \"slack.slo.title\" -}}" -}}
{{- printf "\n      [{{ .Status | toUpper }}]: Elevated burn rate on SLO \"{{ .GroupLabels.asserts_slo_name }}\"" -}}
{{- printf "\n    {{- end }}" -}}
{{- printf "\n    " -}}
{{- printf "\n    {{ define \"slack.slo.text\" -}}" -}}
{{- printf "\n      {{- if eq .Status \"firing\" }}" -}}
{{- printf "\n      {{- if .CommonLabels.asserts_site }}" -}}
{{- printf "\n      :warning: *<%s/incidents?env[0]={{ .CommonLabels.asserts_env }}&site[0]={{ .CommonLabels.asserts_site }}&start={{(index .Alerts 0).StartsAt.Unix}}000-30m&end={{(index .Alerts 0).StartsAt.Unix}}000%s&search={{ .GroupLabels.asserts_slo_name }}|View Impact>*" $assertsUrl $plus30min -}}
{{- printf "\n     :fire: *<%s/assertions?env[0]={{ .CommonLabels.asserts_env }}&site[0]={{ .CommonLabels.asserts_site }}&slo_name={{.CommonLabels.asserts_slo_name}}&start={{(index .Alerts 0).StartsAt.Unix}}000-30m&end={{(index .Alerts 0).StartsAt.Unix}}000%s|Start Troubleshooting>*" $assertsUrl $plus30min -}}
{{- printf "\n      {{- else }}" -}}
{{- printf "\n      :warning: *<%s/incidents?env[0]={{ .CommonLabels.asserts_env }}&start={{(index .Alerts 0).StartsAt.Unix}}000-30m&end={{(index .Alerts 0).StartsAt.Unix}}000%s&search={{ .GroupLabels.asserts_slo_name }}|View Impact>*" $assertsUrl $plus30min -}}
{{- printf "\n     :fire: *<%s/assertions?env[0]={{ .CommonLabels.asserts_env }}&slo_name={{.CommonLabels.asserts_slo_name}}&start={{(index .Alerts 0).StartsAt.Unix}}000-30m&end={{(index .Alerts 0).StartsAt.Unix}}000%s|Start Troubleshooting>*" $assertsUrl $plus30min -}}
{{- printf "\n      {{- end }}" -}}
{{- printf "\n    " -}}
{{- printf "\n      Asserts has detected an elevated burn rate on the \"{{ .GroupLabels.asserts_slo_name }}\" service level objective. These compliance windows are off track:" -}}
{{- printf "\n      {{ range .Alerts }} {{ if .Annotations.description }}*Description:* {{ printf \"%s%s\" .Annotations.description }}{{ end }}{{ end }}" "%s" "\\n" -}}
{{- printf "\n      {{- end }}" -}}
{{- printf "\n    {{- end }}" -}}
{{- end }}
