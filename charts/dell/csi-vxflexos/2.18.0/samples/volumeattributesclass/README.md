# VolumeAttributesClass Samples

This directory contains sample manifests for using VolumeAttributesClass (VAC) feature with CSI PowerFlex driver.

## VolumeAttributesClass Overview

VolumeAttributesClass is a Kubernetes feature that allows modifying volume attributes after volume creation. This feature is available in Kubernetes 1.29+ with feature gate enabled and 1.34+ automatically.

## Prerequisites

- Kubernetes 1.29 or later (with feature gate enabled) or 1.34+ (automatically enabled)
- CSI PowerFlex driver with VAC support enabled

## Sample Files

### vac-qos-unlimited.yaml
Defines a VolumeAttributesClass with unlimited QoS settings for volumes.

### vac-qos.yaml  
Defines a VolumeAttributesClass with specific QoS limits.

### pvc-with-vac.yaml
Sample PersistentVolumeClaim that references a VolumeAttributesClass.

## Usage

1. Create the VolumeAttributesClass:
```bash
kubectl apply -f vac-qos.yaml
```

2. Create a PVC that references the VolumeAttributesClass:
```bash
kubectl apply -f pvc-with-vac.yaml
```

3. Modify an existing PVC to use a different VolumeAttributesClass:
```bash
kubectl patch pvc <pvc-name> --type merge -p '{"spec":{"volumeAttributesClassName":"vac-qos-unlimited"}}'
```

## Notes

- The VolumeAttributesClass modification is applied asynchronously by the CSI resizer sidecar
- Not all volume attributes may be modifiable depending on the storage array capabilities
- Refer to the CSI PowerFlex driver documentation for supported attributes
