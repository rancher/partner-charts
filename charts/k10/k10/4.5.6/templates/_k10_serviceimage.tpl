{{/*
Helper to get k10 service image
The details on how these image are being generated
is in below issue
https://kasten.atlassian.net/browse/K10-4036
Using substr to remove repo from ambassadorImage
*/}}
{{- define "serviceImage" -}}
{{/*
we are maintaining the field .Values.images to override it when
we install the chart for red hat marketplace. If we dont
have the value specified use earlier flow, if it is, use the
value that is specified.
*/}}
{{- if not .main.Values.global.rhMarketPlace }}
{{- $serviceImage := "" -}}
{{- $tagFromDefs := "" -}}
{{- if .main.Values.global.airgapped.repository }}
{{- $serviceImage = default .main.Chart.Version .main.Values.image.tag | print .main.Values.global.airgapped.repository "/" .k10_service ":" }}
{{- else if contains .main.Values.image.registry .main.Values.image.repository }}
{{- $serviceImage = default .main.Chart.Version .main.Values.image.tag | print .main.Values.image.repository "/" .k10_service ":" }}
{{- else }}
{{- $serviceImage = default .main.Chart.Version .main.Values.image.tag | print .main.Values.image.registry "/" .main.Values.image.repository "/" .k10_service ":" }}
{{- end }}{{/* if .main.Values.global.airgapped.repository */}}
{{- $serviceImageKey := print (replace "-" "" .k10_service) "Image" }}
{{- if eq $serviceImageKey "ambassadorImage" }}
{{- $tagFromDefs = (include "k10.ambassadorImageTag" .) }}
{{- else if eq $serviceImageKey "dexImage" }}
{{- $tagFromDefs = (include "k10.dexImageTag" .) }}
{{- end }}{{/* if eq $serviceImageKey "ambassadorImage" */}}
{{- if index .main.Values $serviceImageKey }}
{{- $service_values := index .main.Values $serviceImageKey }}
{{- if .main.Values.global.airgapped.repository }}
{{ $valuesImage := (splitList "/" (index $service_values "image")) }}
{{- if $tagFromDefs }}
image: {{ printf "%s/%s:k10-%s" .main.Values.global.airgapped.repository (index $valuesImage (sub (len $valuesImage) 1) ) $tagFromDefs -}}
{{- end }}
{{- else }}{{/* .main.Values.global.airgapped.repository */}}
{{- if $tagFromDefs }}
image: {{ printf "%s:%s" (index $service_values "image") $tagFromDefs }}
{{- else }}
image: {{ index $service_values "image" }}
{{- end }}
{{- end }}{{/* .main.Values.global.airgapped.repository */}}
{{- else }}
image: {{ $serviceImage }}
{{- end -}}{{/* index .main.Values $serviceImageKey */}}
{{- else }}
image: {{ printf "%s" (get .main.Values.global.images .k10_service) }}
{{- end }}{{/* if not .main.Values.images.executor */}}
{{- end -}}{{/* define "serviceImage" */}}
