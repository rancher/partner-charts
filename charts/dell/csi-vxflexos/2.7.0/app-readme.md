CSI Driver for PowerFlex is part of the CSM (Container Storage Modules) open-source suite of Kubernetes storage enablers for Dell EMC products. CSI Driver for PowerFlex is a Container Storage Interface (CSI) driver that provides support for provisioning persistent storage using Dell EMC PowerFlex storage array.

Pre-Install
- All nodes must have the SDC client installed to satisfy the CSI driver for PowerFlex. Ensure that nodes are provided at least two (2) interfaces and potentially up to four (4) interfaces depending on the PowerFlex system configuration. 
- [Install Storage Data Client](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/powerflex/#manual-sdc-deployment)
- [Create Configuration Secret (Step 4)](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/powerflex/#install-the-driver)

Post-Install
- [Create Storage Class(es)](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/powerflex/#storage-classes)
  [Storage Class Examples](https://github.com/dell/csi-powerflex/tree/main/samples/storageclass)
