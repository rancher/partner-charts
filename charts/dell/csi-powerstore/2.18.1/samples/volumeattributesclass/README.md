# VolumeAttributesClass Samples

This directory contains sample manifests for using VolumeAttributesClass (VAC) feature with CSI PowerStore driver.

## VolumeAttributesClass Overview

VolumeAttributesClass is a Kubernetes feature that allows modifying volume attributes after volume creation. This feature is available in Kubernetes 1.29+ with feature gate enabled and 1.34+ automatically.

## Prerequisites

- Kubernetes 1.29 or later (with feature gate enabled) or 1.34+ (automatically enabled)
- CSI PowerStore driver with VAC support enabled

## Sample Files

### vac-block.yaml
Defines a VolumeAttributesClass for block volumes.

### vac-nfs.yaml  
Defines a VolumeAttributesClass for file systems:

### pvc-with-vac.yaml
Sample PersistentVolumeClaim that references a VolumeAttributesClass.

## Usage

1. Create the VolumeAttributesClass:
```bash
kubectl apply -f vac-block.yaml
```

2. Create a PVC that references the VolumeAttributesClass:
```bash
kubectl apply -f pvc-with-vac.yaml
```

3. Modify an existing PVC to use a different VolumeAttributesClass:
```bash
kubectl patch pvc <pvc-name> --type merge -p '{"spec":{"volumeAttributesClassName":"<vac-name>"}}'
```

## Notes

- The VolumeAttributesClass modification is applied asynchronously by the CSI resizer sidecar
- Not all volume attributes may be modifiable depending on the storage array capabilities
- Refer to the CSI PowerStore driver documentation for supported attributes
