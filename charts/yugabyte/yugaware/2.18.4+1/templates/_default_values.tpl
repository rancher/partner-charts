{{/*
    The usage of helm upgrade [RELEASE] [CHART] --reuse-values --set [variable]:[value] throws an
    error in the event that new entries are inserted to the values chart.

    This is because reuse-values flag uses the values from the last release. If --set (/--set-file/
    --set-string/--values/-f) is applied with the reuse-values flag, the values from the last 
    release are overridden for those variables alone, and newer changes to the chart are 
    unacknowledged.

    https://medium.com/@kcatstack/understand-helm-upgrade-flags-reset-values-reuse-values-6e58ac8f127e

    To prevent errors while applying upgrade with --reuse-values and --set flags after introducing 
    new variables, default values can be specified in this file.
*/}}

{{- define "get_nginx_proxyReadTimeoutSec" -}}
    {{ .Values.nginx.proxyReadTimeoutSec | default 600 }}
{{- end -}}
