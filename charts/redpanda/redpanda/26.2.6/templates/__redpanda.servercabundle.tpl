{{- /* GENERATED FILE DO NOT EDIT */ -}}
{{- /* Transpiled by gotohelm from "github.com/redpanda-data/redpanda-operator/charts/redpanda/v25/servercabundle.go" */ -}}

{{- define "_redpanda.ServerCABundle.Arg" -}}
{{- $b := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf "--server-ca-bundle=%s=%s" $b.Path (join "," $b.Sources))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "_redpanda.NewServerCABundles" -}}
{{- $admin := (index .a 0) -}}
{{- $kafka := (index .a 1) -}}
{{- $schemaRegistry := (index .a 2) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "Admin" (coalesce nil) "Kafka" (coalesce nil) "SchemaRegistry" (coalesce nil)) (dict "Admin" (get (fromJson (include "_redpanda.newServerCABundle" (dict "a" (list "admin" $admin)))) "r") "Kafka" (get (fromJson (include "_redpanda.newServerCABundle" (dict "a" (list "kafka" $kafka)))) "r") "SchemaRegistry" (get (fromJson (include "_redpanda.newServerCABundle" (dict "a" (list "schema" $schemaRegistry)))) "r")))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "_redpanda.newServerCABundle" -}}
{{- $api := (index .a 0) -}}
{{- $sources := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (lt ((get (fromJson (include "_shims.len" (dict "a" (list $sources)))) "r") | int) (1 | int)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "Path" "" "Sources" (coalesce nil)) (dict "Path" (printf "%s/%s.pem" "/etc/tls/server-ca" $api) "Sources" $sources))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "_redpanda.ServerCABundles.All" -}}
{{- $b := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $bundles := (coalesce nil) -}}
{{- range $_, $bundle := (list $b.Admin $b.Kafka $b.SchemaRegistry) -}}
{{- if (ne (toJson $bundle) "null") -}}
{{- $bundles = (concat (default (list) $bundles) (list $bundle)) -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $bundles) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "_redpanda.ServerCABundles.Volume" -}}
{{- $b := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (lt ((get (fromJson (include "_shims.len" (dict "a" (list (get (fromJson (include "_redpanda.ServerCABundles.All" (dict "a" (list $b)))) "r"))))) "r") | int) (1 | int)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "emptyDir" (mustMergeOverwrite (dict) (dict)))) (dict "name" "server-ca"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "_redpanda.ServerCABundles.Mount" -}}
{{- $b := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (lt ((get (fromJson (include "_shims.len" (dict "a" (list (get (fromJson (include "_redpanda.ServerCABundles.All" (dict "a" (list $b)))) "r"))))) "r") | int) (1 | int)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "server-ca" "mountPath" "/etc/tls/server-ca" "readOnly" true))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "_redpanda.ServerCABundles.WriterMount" -}}
{{- $b := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (lt ((get (fromJson (include "_shims.len" (dict "a" (list (get (fromJson (include "_redpanda.ServerCABundles.All" (dict "a" (list $b)))) "r"))))) "r") | int) (1 | int)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "server-ca" "mountPath" "/etc/tls/server-ca"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "_redpanda.ServerCABundles.Args" -}}
{{- $b := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $args := (coalesce nil) -}}
{{- range $_, $bundle := (get (fromJson (include "_redpanda.ServerCABundles.All" (dict "a" (list $b)))) "r") -}}
{{- $args = (concat (default (list) $args) (list (get (fromJson (include "_redpanda.ServerCABundle.Arg" (dict "a" (list (deepCopy $bundle))))) "r"))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $args) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "_redpanda.ServerCABundles.Env" -}}
{{- $b := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $env := (coalesce nil) -}}
{{- if (ne (toJson $b.Admin) "null") -}}
{{- $env = (concat (default (list) $env) (list (mustMergeOverwrite (dict "name" "") (dict "name" "RPK_ADMIN_TLS_CA" "value" $b.Admin.Path)))) -}}
{{- end -}}
{{- if (ne (toJson $b.Kafka) "null") -}}
{{- $env = (concat (default (list) $env) (list (mustMergeOverwrite (dict "name" "") (dict "name" "RPK_TLS_CA" "value" $b.Kafka.Path)))) -}}
{{- end -}}
{{- if (ne (toJson $b.SchemaRegistry) "null") -}}
{{- $env = (concat (default (list) $env) (list (mustMergeOverwrite (dict "name" "") (dict "name" "RPK_REGISTRY_TLS_CA" "value" $b.SchemaRegistry.Path)))) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $env) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "_redpanda.CurlCACert" -}}
{{- $bundle := (index .a 0) -}}
{{- $fallback := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (eq (toJson $bundle) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" $fallback) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf "$([ -s %s ] && echo %s || echo %s)" $bundle.Path $bundle.Path $fallback)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

