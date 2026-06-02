{{/*
Helper to get k10 service image
The details on how these image are being generated
is in below issue
https://kasten.atlassian.net/browse/K10-4036
*/}}
{{- define "serviceImage" -}}
{{/*
we are maintaining the field .Values.global.images to override it when
we install the chart for red hat marketplace. If we dont
have the value specified use earlier flow, if it is, use the
value that is specified.
*/}}
{{- include "image.values.check" . -}}
{{- if not .main.Values.global.rhMarketPlace }}
{{- $serviceImage := "" -}}
{{- $tagFromDefs := "" -}}
{{- if .main.Values.global.airgapped.repository }}
{{- $serviceImage = (include "get.k10ImageTag" .main) | print .main.Values.global.airgapped.repository "/" .k10_service ":" }}
{{- else if .main.Values.global.azMarketPlace }}
{{- $az_image := (get .main.Values.global.azure.images .k10_service) }}
{{- $serviceImage = print $az_image.registry "/" $az_image.image  ":"  $az_image.tag }}
{{- else }}
{{- $serviceImage = (include "get.k10ImageTag" .main)  | print .main.Values.global.image.registry "/" .k10_service ":" }}
{{- end }}{{/* if .main.Values.global.airgapped.repository */}}
{{- $serviceImageKey := print (replace "-" "" .k10_service) "Image" }}
{{- if eq $serviceImageKey "dexImage" }}
{{- $tagFromDefs = (include "dex.dexImageTag" .) }}
{{- end }}{{/* if eq $serviceImageKey "dexImage" */}}
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
