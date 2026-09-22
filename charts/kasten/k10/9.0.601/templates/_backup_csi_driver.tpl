{{/*
Helpers for the Kopia backup CSI driver. The driver image, pull secrets, pull
policy and container resources come from K10's shared helpers ("serviceImage",
"k10.imagePullSecrets", "k10.resource.request") so the driver behaves like every
other K10 component.

Everything else the driver needs is fixed here rather than exposed in values.yaml.
These are internal contracts, not deployment choices: names that must agree with
the driver binary and the kubelet, ports the manifests cross-reference, and
upstream sidecar versions this chart is tested against. Repository configuration
and the backup/restore StorageClasses are not here either -- K10 creates those at
run time, per location profile.
*/}}

{{/*
Name of the driver. Literal (not .Chart.Name, which is "k10") so the selector
label app.kubernetes.io/name stays "backup-csi-driver" and does not collide with
K10's own pods.
*/}}
{{- define "backup-csi-driver.name" -}}
backup-csi-driver
{{- end }}

{{/*
Resource name prefix for the driver's objects. The driver is cluster-singleton
(its CSIDriver/StorageClass/VolumeSnapshotClass names are fixed), so a plain
literal is used.
*/}}
{{- define "backup-csi-driver.fullname" -}}
{{- include "backup-csi-driver.name" . }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "backup-csi-driver.labels" -}}
app.kubernetes.io/name: {{ include "backup-csi-driver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels (node)
*/}}
{{- define "backup-csi-driver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "backup-csi-driver.name" . }}
app.kubernetes.io/component: node
{{- end }}

{{/*
Controller selector labels
*/}}
{{- define "backup-csi-driver.controllerSelectorLabels" -}}
app.kubernetes.io/name: {{ include "backup-csi-driver.name" . }}
app.kubernetes.io/component: controller
{{- end }}

{{/*
CSI driver name. The kubelet derives the plugin socket path from it and the
CSIDriver object registers it, so all four places that need the name -- the
CSIDriver, the VolumeSnapshotClass, the registrar's socket path and the plugin-dir
hostPath -- must agree. Renaming it would leave the VolumeSnapshotClass pointing at
a driver the kubelet never registered, and snapshots would never become ready.
*/}}
{{- define "backup-csi-driver.driverName" -}}
backup.csi.kastenhq.io
{{- end }}

{{/*
ServiceAccount the driver's Kopia server pods run as. It must match
csi.KopiaServerServiceAccountName in go/src/kasten.io/bsd/pkg/csi/server_manager.go,
which the driver applies when it creates those pods. Renaming it here would only
rename the ServiceAccount object, leaving the pods pointing at one that no longer
exists -- and silently dropping the IAM/workload-identity annotations below.
*/}}
{{- define "backup-csi-driver.kopiaServerServiceAccountName" -}}
kopia-server-sa
{{- end }}

{{/*
Ports. Each is referenced by several manifests at once -- a container arg, a
container port, a probe, a Service and a NetworkPolicy rule -- so they are defined
once here to keep those in step. The values match the driver's own defaults.
*/}}
{{- define "backup-csi-driver.metricsPort" -}}9090{{- end }}
{{- define "backup-csi-driver.snapshotPort" -}}9091{{- end }}
{{- define "backup-csi-driver.healthzPort" -}}9808{{- end }}

{{/*
Upstream CSI sidecar images, pinned to the versions this chart is tested against.
Bump them here.

Unlike the driver image these are third-party images and are not resolved through
global.image.registry, global.airgapped.repository or global.images, so airgapped
and marketplace installs cannot reach them yet. That gap is tracked separately.
*/}}
{{- define "backup-csi-driver.registrarImage" -}}
registry.k8s.io/sig-storage/csi-node-driver-registrar:v2.10.0
{{- end }}

{{- define "backup-csi-driver.livenessProbeImage" -}}
registry.k8s.io/sig-storage/livenessprobe:v2.15.0
{{- end }}

{{- define "backup-csi-driver.provisionerImage" -}}
registry.k8s.io/sig-storage/csi-provisioner:v6.2.0
{{- end }}

{{- define "backup-csi-driver.snapshotterImage" -}}
registry.k8s.io/sig-storage/csi-snapshotter:v8.5.0
{{- end }}

{{/*
Pull policy for the pinned sidecars. Deliberately not global.image.pullPolicy,
which defaults to Always: these tags are immutable, so re-pulling buys nothing and
would make every pod start on every node depend on reaching registry.k8s.io, which
this chart cannot mirror for them yet. The driver's own containers do follow
global.image.pullPolicy.
*/}}
{{- define "backup-csi-driver.sidecarPullPolicy" -}}
IfNotPresent
{{- end }}
