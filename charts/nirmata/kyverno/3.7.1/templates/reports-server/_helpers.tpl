{{/*
Reports Server helpers
*/}}

{{/*
Check if reports-server is enabled
*/}}
{{- define "kyverno.reportsServer.enabled" -}}
{{- if .Values.reportsServer.enabled -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Reports Server readiness init container
Waits for reports-server pod to be running AND APIServices to be available
*/}}
{{- define "kyverno.reportsServer.initContainer" -}}
- name: wait-for-reports-server
  image: {{ include "kyverno.image" (dict "globalRegistry" .Values.global.image.registry "image" .Values.webhooksCleanup.image "defaultTag" (default .Chart.AppVersion .Values.webhooksCleanup.image.tag) "fipsEnabled" .Values.fipsEnabled) | quote }}
  imagePullPolicy: {{ .Values.webhooksCleanup.image.pullPolicy }}
  command:
    - /bin/sh
    - -c
    - |
      echo "Waiting for reports-server to be ready..."
      timeout={{ .Values.reportsServer.readinessTimeout | default 300 }}
      elapsed=0

      # Step 1: Wait for reports-server pod to be running
      echo "Step 1: Waiting for reports-server pod to be running..."
      while [ $elapsed -lt $timeout ]; do
        if kubectl get pods -n {{ include "kyverno.namespace" . }} -l app.kubernetes.io/name=reports-server --no-headers 2>/dev/null | grep -q "Running"; then
          echo "Reports-server pod is running!"
          break
        fi
        echo "Reports-server pod not running yet... ($elapsed/$timeout seconds)"
        sleep 5
        elapsed=$((elapsed + 5))
      done

      if [ $elapsed -ge $timeout ]; then
        echo "Timeout waiting for reports-server pod to be running"
        exit 1
      fi

      # Step 2: Wait for APIServices to be available
      echo "Step 2: Waiting for reports-server APIServices to be available..."
      while [ $elapsed -lt $timeout ]; do
        all_available=true
        for apiservice in "v1.reports.kyverno.io" "v1alpha2.wgpolicyk8s.io"; do
          if kubectl get apiservice "$apiservice" >/dev/null 2>&1; then
            status=$(kubectl get apiservice "$apiservice" -o jsonpath='{.status.conditions[?(@.type=="Available")].status}' 2>/dev/null || echo "False")
            if [ "$status" != "True" ]; then
              echo "APIService $apiservice is not available yet"
              all_available=false
            fi
          else
            echo "APIService $apiservice does not exist yet"
            all_available=false
          fi
        done
        if $all_available; then
          echo "All reports-server APIServices are available!"
          echo "Reports-server is ready!"
          exit 0
        fi
        echo "Waiting for APIServices... ($elapsed/$timeout seconds)"
        sleep 5
        elapsed=$((elapsed + 5))
      done

      echo "Timeout waiting for reports-server APIServices to be available"
      exit 1
  securityContext:
    runAsUser: 65534
    runAsGroup: 65534
    runAsNonRoot: true
    privileged: false
    allowPrivilegeEscalation: false
    readOnlyRootFilesystem: true
    capabilities:
      drop:
        - ALL
    seccompProfile:
      type: RuntimeDefault
  resources:
    limits:
      cpu: 100m
      memory: 128Mi
    requests:
      cpu: 10m
      memory: 32Mi
{{- end }}

{{/*
Reports Server service dependency annotation
*/}}
{{- define "kyverno.reportsServer.dependsOnAnnotation" -}}
{{- if .Values.reportsServer.enabled }}
"helm.sh/hook-depends-on": "Service/reports-server"
{{- end -}}
{{- end -}}