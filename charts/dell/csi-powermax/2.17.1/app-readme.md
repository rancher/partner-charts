

## Prerequisites

1. Create a namespace where you want to install the driver (e.g. "csi-powermax"). You can choose any name for the namespace, but make sure to align to the same namespace during the whole installation.
2. Create a secret named "powermax-creds" in the namespace created above. Sample [secret.yaml](https://github.com/dell/csi-powermax/blob/main/samples/secret/secret.yaml).
    >Secret must be of type opaque.
3. Install Cert Manager
    >Create issuer for Cert Manager
    >Create TLS Certificate in powermax namespace
4. Create storage classes using ones from [samples](https://github.com/dell/csi-powermax/tree/main/samples/storageclass) folder as an example.
    > If you do not specify `arrayID` parameter in the storage class then the array that was specified as the default would be used for provisioning volumes.
5. Install the chart with the name "csi-powermax". The value.yaml file used during installation can be found [here](https://github.com/dell/csi-powermax/blob/main/helm/csi-powermax/values.yaml)

The table [here](https://dell.github.io/csm-docs/docs/csidriver/installation/helm/powermax/#:~:text=powermax%2Dsettings.yaml-,Parameter,Default,-global) lists the configurable parameters of the chart and their default values. 

