{{- define "exporter_nsip" -}}
{{- $match := .Values.ingressGateway.netscalerUrl | toString | regexFind "//.*[:]*" -}}
{{- $match | trimAll ":" | trimAll "/" -}}
{{- end -}}

{{/* A common function to generate name of the resource. 
   * Usage: {{ template "generate-name" (list . (dict "suffixname" "citrix-deployment")) }} 
   * In above example, arguments are given in the list. 
   * First one is `.` indicating global chart-level scope. 
   * Second argument name is `suffixname` and value is `citrix-deployment`.
   * If release name is `my-release`, then generate-name function would output "my-release-citrix-deployment".
   * The function truncates name to 63 chars due to Kubernetes name length restrictions
*/}}
{{- define "generate-name" -}}
{{- $top := index . 0 -}}
{{- $arg1 := index . 1 "suffixname" -}}
{{- printf "%s-%s" $top.Release.Name $arg1 | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Another common function to generate name of the resource. 
   * Usage: {{ template "generate-name" (list . "citrix-deployment") }} 
   * In above example, arguments are given in the list. 
   * First one is `.` indicating global chart-level scope. 
   * Second argument is unnamed and takes value as `citrix-deployment`.
   * If release name is `my-release`, then generate-name function would output "my-release-citrix-deployment".
   * The function truncates name to 63 chars due to Kubernetes name length restrictions
*/}}
{{- define "generate-name2" -}}
{{- $top := index . 0 -}}
{{- $arg1 := index . 1 -}}
{{- printf "%s-%s" $top.Release.Name $arg1 | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Below function is used to identify default value of jwtPolicy if not provided.
   * For on-prem Kubernetes v1.21+, it is third-party-jwt. Else first-party-jwt.
   * Note: Don't just do "helm template" to generate yaml file. Else https://github.com/helm/helm/issues/7991 
   * is possible. Use "helm template --validate" or "helm install --dry-run --debug".
   * Note2: For cloud environments, semverCompare should be ideally done with "<1.21.x-x" as 
   * Kubernetes version is generally of the format v1.20.7-eks-xxxxxx. So, it fails the "v1.21.x" check but that's fine
   * as in cloud environments third-party-jwt is enabled. 
*/}}

{{- define "jwtValue" -}}
{{- if .Values.certProvider.jwtPolicy -}}
{{- printf .Values.certProvider.jwtPolicy -}}
{{- else -}}
{{- if semverCompare "<1.21.x" .Capabilities.KubeVersion.Version -}}
{{- printf "first-party-jwt" -}}
{{- else -}}
{{- printf "third-party-jwt" -}}
{{- end -}}
{{- end -}}
{{- end -}}