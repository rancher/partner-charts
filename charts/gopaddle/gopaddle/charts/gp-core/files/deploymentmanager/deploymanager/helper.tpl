{{/*
Check ClusterRole Exist
*/}}
{{- define "gen.clusterrole" -}}
{{- $clusterrole := lookup "v1" "ClusterRole" "" "gopaddle:nginx-ingress-clusterrole" -}}
{{- if $clusterrole -}}
        {{- printf "%s" true -}}
{{- else -}}
        {{- printf "%s" false -}}
{{- end -}}
{{- end -}}
