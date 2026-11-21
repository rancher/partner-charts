{{- /* GENERATED FILE DO NOT EDIT */ -}}
{{- /* Transpiled by gotohelm from "github.com/redpanda-data/redpanda-operator/charts/redpanda/v25/chart/service.perport.go" */ -}}

{{- define "redpanda.PerPortServiceNames" -}}
{{- $state := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $names := (coalesce nil) -}}
{{- range $_, $kind := (get (fromJson (include "redpanda.perPortAPIs" (dict "a" (list $state)))) "r") -}}
{{- $names = (concat (default (list) $names) (list (get (fromJson (include "redpanda.perPortServiceName" (dict "a" (list $state $kind)))) "r"))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $names) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.perPortAPIs" -}}
{{- $state := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (not $state.PerPortServices.Enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $apis := (list "admin" "kafka") -}}
{{- if $state.Values.listeners.http.enabled -}}
{{- $apis = (concat (default (list) $apis) (list "http")) -}}
{{- end -}}
{{- if $state.Values.listeners.schemaRegistry.enabled -}}
{{- $apis = (concat (default (list) $apis) (list "schema")) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $apis) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.perPortServiceName" -}}
{{- $state := (index .a 0) -}}
{{- $kind := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $suffix := (get (fromJson (include "redpanda.perPortServiceSuffix" (dict "a" (list $kind)))) "r") -}}
{{- $base := (trimSuffix "-" (trunc ((sub (62 | int) ((get (fromJson (include "_shims.len" (dict "a" (list $suffix)))) "r") | int)) | int) (get (fromJson (include "redpanda.ServiceName" (dict "a" (list $state)))) "r"))) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf "%s-%s" $base $suffix)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.perPortServiceSuffix" -}}
{{- $kind := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (eq $kind "kafka") -}}
{{- $_is_returning = true -}}
{{- (dict "r" "seed") | toJson -}}
{{- break -}}
{{- end -}}
{{- if (eq $kind "http") -}}
{{- $_is_returning = true -}}
{{- (dict "r" "proxy") | toJson -}}
{{- break -}}
{{- end -}}
{{- if (eq $kind "schema") -}}
{{- $_is_returning = true -}}
{{- (dict "r" "schemaregistry") | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (toString $kind)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.perPortServiceConfigs" -}}
{{- $state := (index .a 0) -}}
{{- $reserved := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $clusterIP := "" -}}
{{- if $state.PerPortServices.Headless -}}
{{- $clusterIP = "None" -}}
{{- end -}}
{{- $configs := (coalesce nil) -}}
{{- range $_, $kind := (get (fromJson (include "redpanda.perPortAPIs" (dict "a" (list $state)))) "r") -}}
{{- $_100_api_ok := (get (fromJson (include "_shims.dicttest" (dict "a" (list $reserved.ByKind $kind (coalesce nil))))) "r") -}}
{{- $api := (index $_100_api_ok 0) -}}
{{- $ok := (index $_100_api_ok 1) -}}
{{- if (not $ok) -}}
{{- continue -}}
{{- end -}}
{{- $configs = (concat (default (list) $configs) (list (mustMergeOverwrite (dict "Kind" "" "Listeners" (dict "ByKind" (coalesce nil)) "Template" (dict "metadata" (dict) "spec" (dict) "status" (dict "loadBalancer" (dict))) "Brokers" (coalesce nil)) (dict "Kind" "perport" "Listeners" (get (fromJson (include "_redpanda.NewListeners" (dict "a" (list (list $api))))) "r") "Template" (mustMergeOverwrite (dict "metadata" (dict) "spec" (dict) "status" (dict "loadBalancer" (dict))) (mustMergeOverwrite (dict) (dict "apiVersion" "v1" "kind" "Service")) (dict "metadata" (mustMergeOverwrite (dict) (dict "name" (get (fromJson (include "redpanda.perPortServiceName" (dict "a" (list $state $kind)))) "r") "namespace" $state.Release.Namespace "labels" (get (fromJson (include "redpanda.FullLabels" (dict "a" (list $state)))) "r") "annotations" (get (fromJson (include "redpanda.FullAnnotations" (dict "a" (list $state)))) "r"))) "spec" (mustMergeOverwrite (dict) (dict "type" "ClusterIP" "clusterIP" $clusterIP)))))))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $configs) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

