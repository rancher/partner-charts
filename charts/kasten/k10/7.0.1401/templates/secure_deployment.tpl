{{/*
This file is used to fail the helm deployment if certain values are set which are
not compatible with a secure deployment.

A secure deployment is defined as one of the following:
- Iron Bank
- FIPS
*/}}

{{/* Iron Bank */}}
{{- include "k10.fail.ironbankGrafana" . -}}
{{- include "k10.fail.ironbankPrometheus" . -}}
{{- include "k10.fail.ironbankRHMarketplace" . -}}

{{/* FIPS */}}
{{- include "k10.fail.fipsGrafana" . -}}
{{- include "k10.fail.fipsPrometheus" . -}}
