{{/* vim: set filetype=mustache: */}}

{{/*
Node_IP for gopaddle
*/}}
{{- define "gopaddle.nodeIP" -}}
{{- if eq (.Values.global.routingType | toString) "NodePortWithIngress" -}}
      {{- if .Values.global.gopaddle.https -}}
      {{- printf "https://%s:30002" .Values.global.gopaddle.domainName -}}
      {{- else -}}
      {{- printf "http://%s:30002" .Values.global.gopaddle.domainName -}}
      {{- end -}}
{{- else if eq (.Values.global.routingType | toString) "LoadBalancer" -}}
      {{- if .Values.global.gopaddle.https -}}
      {{- printf "https://%s" .Values.global.gopaddle.domainName -}}
      {{- else -}}
      {{- printf "http://%s" .Values.global.gopaddle.domainName -}}
      {{- end -}}
{{- else if eq (.Values.global.routingType | toString) "NodePortWithOutIngress" -}}
   {{- if eq (.Values.global.accessMode | toString) "public" -}}
    {{/* ExternalIP from node*/}}
    {{- $externalIP := "" -}}
    {{- $internalIP :="" -}}
    {{- range $index, $node := (lookup "v1" "Node" "" "").items -}}
        {{- range $address:= $node.status.addresses -}}
            {{- if eq ($address.type | toString) "ExternalIP" -}}
                {{- $externalIP = $address.address -}}
            {{- else if eq ($address.type | toString) "InternalIP" -}}
                {{- $internalIP = $address.address -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{/*asign a value to Node_IP */}}
    {{- if .Values.global.staticIP -}}
         {{- printf "http://%s:30004" .Values.global.staticIP -}}
    {{- else if $externalIP -}}
         {{- printf "http://%s:30004" $externalIP -}}
    {{- else -}}
         {{- printf "http://%s:30004" $internalIP -}}
    {{- end -}}
   {{- else if eq (.Values.global.accessMode | toString) "private" -}}
    {{/* InternalIP from node*/}}
    {{- $internalIP := "" -}}
    {{- range $index, $node := (lookup "v1" "Node" "" "").items -}}
        {{- range $address:= $node.status.addresses -}}
            {{- if eq ($address.type | toString) "InternalIP" -}}
                {{- $internalIP = $address.address -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{/*asign a value to Node_IP */}}
    {{- if .Values.global.staticIP -}}
         {{- printf "http://%s:30004" .Values.global.staticIP -}}
    {{- else -}}
         {{- printf "http://%s:30004" $internalIP -}}
    {{- end -}}
   {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Node_IP for gopaddle webhook
*/}}
{{- define "gopaddleWebhook.nodeIP" -}}
{{- if eq (.Values.global.routingType | toString) "NodePortWithIngress" -}}
      {{- if .Values.global.gopaddleWebhook.https -}}
      {{- printf "https://%s:30002" .Values.global.gopaddleWebhook.domainName -}}
      {{- else -}}
      {{- printf "http://%s:30002" .Values.global.gopaddleWebhook.domainName -}}
      {{- end -}}
{{- else if eq (.Values.global.routingType | toString) "LoadBalancer" -}}
      {{- if .Values.global.gopaddleWebhook.https -}}
      {{- printf "https://%s" .Values.global.gopaddleWebhook.domainName -}}
      {{- else -}}
      {{- printf "http://%s" .Values.global.gopaddleWebhook.domainName -}}
      {{- end -}}
{{- else if eq (.Values.global.routingType | toString) "NodePortWithOutIngress" -}}
   {{- if eq (.Values.global.accessMode | toString) "public" -}}
    {{/* ExternalIP from node*/}}
    {{- $externalIP := "" -}}
    {{- $internalIP :="" -}}
    {{- range $index, $node := (lookup "v1" "Node" "" "").items -}}
        {{- range $address:= $node.status.addresses -}}
            {{- if eq ($address.type | toString) "ExternalIP" -}}
                {{- $externalIP = $address.address -}}
            {{- else if eq ($address.type | toString) "InternalIP" -}}
                {{- $internalIP = $address.address -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{/*asign a value to Node_IP */}}
    {{- if .Values.global.staticIP -}}
         {{- printf "http://%s:30004" .Values.global.staticIP -}}
    {{- else if $externalIP -}}
         {{- printf "http://%s:30004" $externalIP -}}
    {{- else -}}
         {{- printf "http://%s:30004" $internalIP -}}
    {{- end -}}
   {{- else if eq (.Values.global.accessMode | toString) "private" -}}
    {{/* InternalIP from node*/}}
    {{- $internalIP := "" -}}
    {{- range $index, $node := (lookup "v1" "Node" "" "").items -}}
        {{- range $address:= $node.status.addresses -}}
            {{- if eq ($address.type | toString) "InternalIP" -}}
                {{- $internalIP = $address.address -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{/*asign a value to Node_IP */}}
    {{- if .Values.global.staticIP -}}
         {{- printf "http://%s:30004" .Values.global.staticIP -}}
    {{- else -}}
         {{- printf "http://%s:30004" $internalIP -}}
    {{- end -}}
   {{- end -}}

{{- end -}}
{{- end -}}

{{/*
BASE_SERVER for gopaddle ui
*/}}
{{- define "gopaddle.baseServer" -}}
{{- if eq (.Values.global.routingType | toString) "NodePortWithIngress" -}}
      {{- if .Values.global.gopaddle.https -}}
      {{- printf "https://%s:30002" .Values.global.gopaddle.domainName -}}
      {{- else -}}
      {{- printf "https://%s:30002" .Values.global.gopaddle.domainName -}}
      {{- end -}}
{{- else if eq (.Values.global.routingType | toString) "LoadBalancer" -}}
      {{- if .Values.global.gopaddle.https -}}
      {{- printf "https://%s" .Values.global.gopaddle.domainName -}}
      {{- else -}}
      {{- printf "https//:%s" .Values.global.gopaddle.domainName -}}
      {{- end -}}
{{- else if eq (.Values.global.routingType | toString) "NodePortWithOutIngress" -}}
  {{- if eq (.Values.global.accessMode | toString) "public" -}}
    {{/* ExternalIP from node*/}}
    {{- $externalIP := "" -}}
    {{- $internalIP :="" -}}
    {{- range $index, $node := (lookup "v1" "Node" "" "").items -}}
        {{- range $address:= $node.status.addresses -}}
            {{- if eq ($address.type | toString) "ExternalIP" -}}
                {{- $externalIP = $address.address -}}
            {{- else if eq ($address.type | toString) "InternalIP" -}}
                {{- $internalIP = $address.address -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{/*asign a value to BASE_SERVER */}}
    {{- if .Values.global.staticIP -}}
         {{- printf "http://%s:30004" .Values.global.staticIP -}}
    {{- else if $externalIP -}}
         {{- printf "http://%s:30004" $externalIP -}}
    {{- else -}}
         {{- printf "http://%s:30004" $internalIP -}}
    {{- end -}}
   {{- else if eq (.Values.global.accessMode | toString) "private" -}}
    {{/* InternalIP from node*/}}
    {{- $internalIP := "" -}}
    {{- range $index, $node := (lookup "v1" "Node" "" "").items -}}
        {{- range $address:= $node.status.addresses -}}
            {{- if eq ($address.type | toString) "InternalIP" -}}
                {{- $internalIP = $address.address -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{/*asign a value to BASE_SERVER */}}
    {{- if .Values.global.staticIP -}}
         {{- printf "http://%s:30004" .Values.global.staticIP -}}
    {{- else -}}
         {{- printf "http://%s:30004" $internalIP -}}
    {{- end -}}
   {{- end -}}

{{- end -}}
{{- end -}}

{{/*
NODE_IP_ENDPOINT for gopaddle GPCTL
*/}}
{{- define "gopaddle.clusterNodeIP" -}}
{{- if eq (.Values.global.cluster.type | toString) "docker" -}}
    {{- printf "http://%s:30004" .Values.global.cluster.nodeIP -}}
{{- end -}}
{{- end -}}

{{/*
    cluster provider handdle appworker
*/}}
{{- define "cluster.provider.appworker" -}}
{{- if eq (.Values.global.cluster.provider | toString) "other" -}}
        args:
        - |-
          #!/bin/bash
          echo "cd /var/log/gopaddle/" > /app/logcleanscript.sh
          echo "rm -rf appworker.tar.gz" >> /app/logcleanscript.sh
          echo "tar -cvzf appworker.tar.gz appworker.log" >>/app/logcleanscript.sh
          echo "echo  > appworker.log" >> /app/logcleanscript.sh
          crontab -l
          chmod 0777 /app/logcleanscript.sh
          echo */1 */8 * * */5 /app/logcleanscript.sh > /var/log/cron.log 2>&1 >> logclean.cron
          crontab logclean.cron
          service cron restart

          echo "----------- start conatainer ------------"
          ./appworker kube > /var/log/gopaddle/appworker.log
          tail -f /var/log/gopaddle/appworker.log
{{- else if eq (.Values.global.cluster.provider | toString) "hpe" -}}
        args:
        - |-
          #!/bin/bash
          echo "cd /var/log/gopaddle/" > /app/logcleanscript.sh
          echo "rm -rf appworker.tar.gz" >> /app/logcleanscript.sh
          echo "tar -cvzf appworker.tar.gz appworker.log" >>/app/logcleanscript.sh
          echo "echo  > appworker.log" >> /app/logcleanscript.sh
          crontab -l
          chmod 0777 /app/logcleanscript.sh
          echo */1 */8 * * */5 /app/logcleanscript.sh > /var/log/cron.log 2>&1 >> logclean.cron
          crontab logclean.cron
          service cron restart

          echo "----------- start appworker --------"
          ./appworker kube > /var/log/gopaddle/appworker.log
          tail -f /var/log/gopaddle/appworker.log
{{- end -}}
{{- end -}}


{{/*
    cluster provider handdle deploymentmanager
*/}}
{{- define "cluster.provider.deploymentmanager" -}}
{{- if eq (.Values.global.cluster.provider | toString) "other" -}}
        args:
        - |-
          #!/bin/bash
          echo "cd /var/log/gopaddle/" > /app/logcleanscript.sh
          echo "rm -rf deploymentmanager.tar.gz" >> /app/logcleanscript.sh
          echo "tar -cvzf deploymentmanager.tar.gz deploymentmanager.log" >>/app/logcleanscript.sh
          echo "echo  > deploymentmanager.log" >> /app/logcleanscript.sh
          crontab -l
          chmod 0777 /app/logcleanscript.sh
          echo */1 */8 * * */5 /app/logcleanscript.sh > /var/log/cron.log 2>&1 >> logclean.cron
          crontab logclean.cron
          service cron restart

          echo "----------- start conatainer ------------"
          ./deploymentmanager kube > /var/log/gopaddle/deploymentmanager.log
          tail -f /var/log/gopaddle/deploymentmanager.log
{{- else if eq (.Values.global.cluster.provider | toString) "hpe" -}}
        args:
        - |-
          #!/bin/bash
          echo "cd /var/log/gopaddle/" > /app/logcleanscript.sh
          echo "rm -rf deploymentmanager.tar.gz" >> /app/logcleanscript.sh
          echo "tar -cvzf deploymentmanager.tar.gz deploymentmanager.log" >>/app/logcleanscript.sh
          echo "echo  > deploymentmanager.log" >> /app/logcleanscript.sh
          crontab -l
          chmod 0777 /app/logcleanscript.sh
          echo */1 */8 * * */5 /app/logcleanscript.sh > /var/log/cron.log 2>&1 >> logclean.cron
          crontab logclean.cron
          service cron restart

          echo "----------- start deploymentmanager --------"
          ./deploymentmanager kube > /var/log/gopaddle/deploymentmanager.log
          tail -f /var/log/gopaddle/deploymentmanager.log
{{- end -}}
{{- end -}}


{{/*
    cluster provider handdle clustermanager
*/}}
{{- define "cluster.provider.clustermanager" -}}
{{- if eq (.Values.global.cluster.provider | toString) "other" -}}
        args:
        - |-
          #!/bin/bash
          echo "cd /var/log/gopaddle/" > /app/logcleanscript.sh
          echo "rm -rf clustermanager.tar.gz" >> /app/logcleanscript.sh
          echo "tar -cvzf clustermanager.tar.gz clustermanager.log" >>/app/logcleanscript.sh
          echo "echo  > clustermanager.log" >> /app/logcleanscript.sh
          crontab -l
          chmod 0777 /app/logcleanscript.sh
          echo */1 */8 * * */5 /app/logcleanscript.sh > /var/log/cron.log 2>&1 >> logclean.cron
          crontab logclean.cron
          service cron restart

          echo "----------- start conatainer ------------"
          ./clustermanager kube > /var/log/gopaddle/clustermanager.log
          tail -f /var/log/gopaddle/clustermanager.log
{{- else if eq (.Values.global.cluster.provider | toString) "hpe" -}}
        args:
        - |-
          #!/bin/bash
          echo "cd /var/log/gopaddle/" > /app/logcleanscript.sh
          echo "rm -rf clustermanager.tar.gz" >> /app/logcleanscript.sh
          echo "tar -cvzf clustermanager.tar.gz clustermanager.log" >>/app/logcleanscript.sh
          echo "echo  > clustermanager.log" >> /app/logcleanscript.sh
          crontab -l
          chmod 0777 /app/logcleanscript.sh
          echo */1 */8 * * */5 /app/logcleanscript.sh > /var/log/cron.log 2>&1 >> logclean.cron
          crontab logclean.cron
          service cron restart

          echo "----------- start clustermanager --------"
          ./clustermanager kube > /var/log/gopaddle/clustermanager.log
          tail -f /var/log/gopaddle/clustermanager.log
{{- end -}}
{{- end -}}


{{/*
    cluster provider handdle gpcore
*/}}
{{- define "cluster.provider.gpcore" -}}
{{- if eq (.Values.global.cluster.provider | toString) "other" -}}
        args:
        - |-
          #!/bin/bash
          echo "cd /var/log/gopaddle/" > /app/logcleanscript.sh
          echo "rm -rf gpcore.tar.gz" >> /app/logcleanscript.sh
          echo "tar -cvzf gpcore.tar.gz gpcore.log" >>/app/logcleanscript.sh
          echo "echo  > gpcore.log" >> /app/logcleanscript.sh
          crontab -l
          chmod 0777 /app/logcleanscript.sh
          echo */1 */8 * * */5 /app/logcleanscript.sh > /var/log/cron.log 2>&1 >> logclean.cron
          crontab logclean.cron
          service cron restart

          echo "----------- start conatainer ------------"
          ./gpcore kube > /var/log/gopaddle/gpcore.log
          tail -f /var/log/gopaddle/gpcore.log
{{- else if eq (.Values.global.cluster.provider | toString) "hpe" -}}
        args:
        - |-
          #!/bin/bash
          echo "cd /var/log/gopaddle/" > /app/logcleanscript.sh
          echo "tar -cvzf gpcore.tar.gz gpcore.log" >>/app/logcleanscript.sh
          echo "echo  > gpcore.log" >> /app/logcleanscript.sh
          crontab -l
          chmod 0777 /app/logcleanscript.sh
          echo */1 */8 * * */5 /app/logcleanscript.sh > /var/log/cron.log 2>&1 >> logclean.cron
          crontab logclean.cron
          service cron restart

          echo "----------- start conatainer ------------"
          ./gpcore kube > /var/log/gopaddle/gpcore.log
          tail -f /var/log/gopaddle/gpcore.log
{{- end -}}
{{- end -}}


{{/*
Node_IP for gopaddle gpcore
*/}}
{{- define "gopaddle.gpcore.ip" -}}
{{- if eq (.Values.global.routingType | toString) "LoadBalancer" -}}
  {{/*asign a value to NODE_IP */}}
  {{- (index (lookup "v1" "Service" .Release.Namespace "rabbitmq-build-external").status.loadBalancer.ingress 0).ip -}}
{{- else if eq (.Values.global.routingType | toString) "NodePortWithIngress" -}}
  {{- if eq (.Values.global.accessMode | toString) "public" -}}
      {{/* ExternalIP from node*/}}
      {{- $externalIP := "" -}}
      {{- $internalIP := "" -}}
      {{- range $index, $node := (lookup "v1" "Node" "" "").items -}}
          {{- range $address:= $node.status.addresses -}}
              {{- if eq ($address.type | toString) "ExternalIP" -}}
                  {{- $externalIP = $address.address -}}
              {{- else if eq ($address.type | toString) "InternalIP" -}}
                  {{- $internalIP = $address.address -}}
              {{- end -}}
          {{- end -}}
      {{- end -}}
      {{/*asign a value to NODE_IP */}}
      {{- if .Values.global.staticIP -}}
          {{- .Values.global.staticIP -}}
      {{- else if $externalIP -}}
            {{- $externalIP -}}
      {{- else -}}
            {{- $internalIP -}}
      {{- end -}}
  {{- else if eq (.Values.global.accessMode | toString) "private" -}}
        {{/*asign a value to NODE_IP */}}
        {{- if .Values.global.staticIP -}}
            {{- .Values.global.staticIP -}}
        {{- else -}}   
            {{- .Values.gpcore.core.envMap.NODE_IP -}}
        {{- end -}}
  {{- end -}}
{{- else if eq (.Values.global.routingType | toString) "NodePortWithOutIngress" -}}
    {{- if eq (.Values.global.accessMode | toString) "public" -}}
    {{/* ExternalIP from node*/}}
    {{- $externalIP := "" -}}
    {{- $internalIP := "" -}}
    {{- range $index, $node := (lookup "v1" "Node" "" "").items -}}
        {{- range $address:= $node.status.addresses -}}
            {{- if eq ($address.type | toString) "ExternalIP" -}}
                {{- $externalIP = $address.address -}}
            {{- else if eq ($address.type | toString) "InternalIP" -}}
                {{- $internalIP = $address.address -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
        {{/*asign a value to NODE_IP */}}
        {{- if .Values.global.staticIP -}}
            {{- .Values.global.staticIP -}}
        {{- else if $externalIP -}}
            {{- $externalIP -}}
        {{- else -}}
            {{- $internalIP -}}
        {{- end -}}
    {{- else if eq (.Values.global.accessMode | toString) "private" -}}
        {{/*asign a value to NODE_IP */}}
        {{- if .Values.global.staticIP -}}
            {{- .Values.global.staticIP -}}
        {{- else -}}
            {{- .Values.gpcore.core.envMap.NODE_IP -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}


{{/*
Node_PORT for gopaddle gpcore
*/}}
{{- define "gopaddle.gpcore.port" -}}
{{- if eq (.Values.global.routingType | toString) "LoadBalancer" -}}
  {{- printf "5672" | quote -}}
{{- else if eq (.Values.global.routingType | toString) "NodePortWithIngress" -}}
  {{- if eq (.Values.global.accessMode | toString) "public" -}}
     {{- printf "30000" | quote -}}
  {{- else if eq (.Values.global.accessMode | toString) "private" -}}
      {{- if .Values.global.staticIP -}}
          {{- printf "30000" | quote -}}
      {{- else -}}
          {{- .Values.gpcore.core.envMap.NODE_PORT | quote -}}
      {{- end -}}
  {{- end -}}
{{- else if eq (.Values.global.routingType | toString) "NodePortWithOutIngress" -}}
  {{- if eq (.Values.global.accessMode | toString) "public" -}}
     {{- printf "30000" | quote -}}
  {{- else if eq (.Values.global.accessMode | toString) "private" -}}
      {{- if .Values.global.staticIP -}}
          {{- printf "30000" | quote -}}
      {{- else -}}
        {{- .Values.gpcore.core.envMap.NODE_PORT | quote -}}
      {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}


{{/* finding storageClass */}}
{{- define "gopaddle.storageClass" -}}
{{- if .Values.global.storageClassName -}}
   {{- .Values.global.storageClassName -}}
{{- else -}}
  {{- $storageClass:= "" -}}
  {{- range $index, $sc := (lookup "storage.k8s.io/v1" "StorageClass" "" "").items -}}
    {{- if eq (get $sc.metadata.annotations "storageclass.kubernetes.io/is-default-class") "true" -}}
            {{- $storageClass = $sc.metadata.name -}}
    {{- end -}}
  {{- end -}}
  {{- $storageClass -}}
{{- end -}}
{{- end -}}

{{/*
ServiceType for gopaddle
*/}}
{{- define "gopaddle.serviceType" -}}
{{- if eq (.Values.global.routingType | toString) "NodePortWithOutIngress" -}}
  {{- "NodePort" -}}
{{- else -}}
  {{- "ClusterIP" -}}
{{- end -}}
{{- end -}}


{{/*
routingType for gopaddle
*/}}
{{- define "gopaddle.routingType" -}}
{{- if eq (.Values.global.routingType | toString) "NodePortWithIngress" -}}
  {{- "NodePort" -}}
{{- else if eq (.Values.global.routingType | toString) "LoadBalancer" -}}
  {{- "LoadBalancer" -}}
{{- end -}}
{{- end -}}


{{/* finding airgapped mode or not */}}
{{-  define "gopaddle.registryUrl" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
    {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
    {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
    {{- printf "%s/%s" $registryUrl $repoPath -}}
{{- else -}}
    {{- printf "gcr.io/bluemeric-1308" -}}
{{- end -}}
{{- end -}}

{{/* finding airgapped mode or not */}}
{{-  define "gopaddle.googleContainer.registryUrl" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
    {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
    {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
    {{- printf "%s/%s" $registryUrl $repoPath -}}
{{- else -}}
    {{- printf "gcr.io/google_containers" -}}
{{- end -}}
{{- end -}}

{{/* finding airgapped mode or not */}}
{{-  define "gopaddle.nginx.registryUrl" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
    {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
    {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
    {{- printf "%s/%s" $registryUrl $repoPath -}}
{{- else -}}
    {{- printf "us.gcr.io/k8s-artifacts-prod" -}}
{{- end -}}
{{- end -}}

{{/* preparing build image */}}
{{- define "gopaddle.gpcore.buildagent" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/buildagent-v1:agent-1.14" $registryUrl $repoPath  -}}
{{- end -}}
{{- end -}}

{{/* preparing kaniko-default image */}}
{{- define "gopaddle.gpcore.kaniko-default" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/executor:v1.3.0 " $registryUrl $repoPath -}}
{{- else if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "local") -}}
      {{- printf "gcr.io/kaniko-project/executor:v1.3.0" -}}
{{- end -}}
{{- end -}}

{{/* preparing kaniko-amd64 image */}}
{{- define "gopaddle.gpcore.kaniko-amd64" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/executor:amd64-v1.3.0" $registryUrl $repoPath -}}
{{- else if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "local") -}}
      {{- printf "gcr.io/kaniko-project/executor:amd64-v1.3.0" -}}
{{- end -}}
{{- end -}}

{{/* preparing kaniko-arm64 image */}}
{{- define "gopaddle.gpcore.kaniko-arm64" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/executor:arm64-v1.3.0" $registryUrl $repoPath -}}
{{- else if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "local") -}}
      {{- printf "gcr.io/kaniko-project/executor:arm64-v1.3.0" -}}
{{- end -}}
{{- end -}}

{{/* preparing kaniko-multi-arch image */}}
{{- define "gopaddle.gpcore.kaniko-multi-arch" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/executor:multi-arch-v1.3.0" $registryUrl $repoPath -}}
{{- else if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "local") -}}
      {{- printf "gcr.io/kaniko-project/executor:multi-arch-v1.3.0" -}}
{{- end -}}
{{- end -}}

{{/* preparing crane image */}}
{{- define "gopaddle.gpcore.crane" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/crane:debug" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}

{{/* preparing trivy image */}}
{{- define "gopaddle.gpcore.trivy" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/trivy:0.18.3" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}


{{/*clustermanger addons images*/}}

{{/* preparing kube-state-metrics image*/}}
{{- define "gopaddle.clustermanger.kube-state-metrics" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/kube-state-metrics:v1.5.0" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}

{{/* preparing node-exporter image*/}}
{{- define "gopaddle.clustermanager.node-exporter" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/node-exporter:v0.16.0" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}


{{/* preparing busybox image*/}}
{{- define "gopaddle.clustermanager.busybox" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/busybox:latest" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}

{{/* preparing prometheus image*/}}
{{- define "gopaddle.clustermanager.prometheus" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/prometheus:v2.5.0" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}

{{/* preparing configmap-reload image*/}}
{{- define "gopaddle.clustermanager.configmap-reload" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/configmap-reload:v0.2.2" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}


{{/* preparing defaultbackend image*/}}
{{- define "gopaddle.clustermanager.defaultbackend" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/defaultbackend:1.4" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}

{{/* preparing grafana image*/}}
{{- define "gopaddle.clustermanager.grafana" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/grafana:v7.0.3-00ee734baf" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}

{{/* preparing event-exporter image*/}}
{{- define "gopaddle.clustermanager.event-exporter" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/event-exporter:v1.0.0" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}

{{/* preparing cert-manager-cainjector image*/}}
{{- define "gopaddle.clustermanager.cert-manager-cainjector" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/cert-manager-cainjector:v1.5.4" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}


{{/* preparing cert-manager-controller image*/}}
{{- define "gopaddle.clustermanager.cert-manager-controller" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/cert-manager-controller:v1.5.4" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}


{{/* preparing cert-manager-webhook image*/}}
{{- define "gopaddle.clustermanager.cert-manager-webhook" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/cert-manager-webhook:v1.5.4" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}


{{/* preparing aws-alb-ingress-controller image*/}}
{{- define "gopaddle.clustermanager.aws-alb-ingress-controller" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/aws-alb-ingress-controller:v2.3.1" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}

{{/* preparing controllerwebhook image*/}}
{{- define "gopaddle.clustermanager.controllerwebhook" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.imageimageRegistryInfoRegistry.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/controllerwebhook:v0.1.1" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}


{{/* preparing configurator-controller image*/}}
{{- define "gopaddle.clustermanager.configurator-controller" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/configurator-controller:v0.1.1  " $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}



{{/* preparing controllerinit image*/}}
{{- define "gopaddle.clustermanager.controllerinit" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/controllerinit:v0.1.1" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}

{{/* deploymentmanager addons images*/}}

{{/* preparing nginx-ingress-controller image*/}}
{{- define "gopaddle.deploymentmanager.nginx-ingress-controller" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/nginx-ingress-controller:0.9.0-beta.15" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}

{{/* preparing controller image*/}}
{{- define "gopaddle.deploymentmanager.controller" -}}
{{- if and (.Values.global.airgapped.enabled) (eq (.Values.global.airgapped.imageRegistryType | toString ) "private") -}}
      {{- $registryUrl := .Values.global.airgapped.imageRegistryInfo.registryUrl | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/"  -}}
      {{- $repoPath := .Values.global.airgapped.imageRegistryInfo.repoPath | trimPrefix "/" | trimSuffix "/"  -}}
      {{- printf "%s/%s/controller:v1.3.0" $registryUrl $repoPath -}}
{{- end -}}
{{- end -}}

{{/* mongo */}}
{{- define "gopaddle.mongo" -}}
{{- if ne (.Values.global.installer.arch | toString) "arm64" -}}
    {{- printf "mongo" -}}
{{- else -}}
     {{- printf "arm64v8/mongo" -}}
{{- end -}}
{{- end -}}


{{/* influxdb */}}
{{- define "gopaddle.influxdb" -}}
{{- if ne (.Values.global.installer.arch | toString) "arm64" -}}
    {{- printf "influxdb" -}}
{{- else -}}
    {{- printf "arm64v8/influxdb" -}}
{{- end -}}
{{- end -}}

{{/* esearch */}}
{{- define "gopaddle.esearch" -}}
{{- if ne (.Values.global.installer.arch | toString) "arm64" -}}
    {{- printf "elasticsearch" -}}
{{- else -}}
    {{- printf "arm64v8/elasticsearch" -}}
{{- end -}}
{{- end -}}


{{/* redis */}}
{{- define "gopaddle.redis" -}}
{{- if ne (.Values.global.installer.arch | toString) "arm64" -}}
    {{- printf "redis" -}}
{{- else -}}
    {{- printf "arm64v8/redis" -}}
{{- end -}}
{{- end -}}

{{/* rabbitmq */}}
{{- define "gopaddle.rabbitmq" -}}
{{- if ne (.Values.global.installer.arch | toString) "arm64" -}}
    {{- printf "rabbitmq" -}}
{{- else -}}
    {{- printf "arm64v8/rabbitmq" -}}
{{- end -}}
{{- end -}}

{{/* defaultbackend */}}
{{- define "gopaddle.defaultbackend" -}}
{{- if ne (.Values.global.installer.arch | toString) "arm64" -}}
    {{- printf "defaultbackend" -}}
{{- else -}}
    {{- printf "defaultbackend-arm64" -}}
{{- end -}}
{{- end -}}


{{/* nginx */}}
{{- define "gopaddle.esearch.imageTag" -}}
{{- if ne (.Values.global.installer.arch | toString) "arm64" -}}
    {{- .Values.esearch.esearch.imageTag -}}
{{- else -}}
    {{- printf "7.8.0" -}} 
{{- end -}}
{{- end -}}