## Prerequisites

1. Create a namespace named isilon 
2. Create a secret named "isilon-creds" in the namespace created above. Sample [secret.yaml](https://github.com/dell/csi-powerscale/blob/main/samples/secret/secret.yaml).
    >Secret must be of type opaque.
3. Create a secret named "Isilon-cert-0" in the namespace created above. Sample [empty-secret.yaml](https://github.com/dell/csi-powerscale/blob/main/samples/secret/empty-secret.yaml).
    >Secret must be of type opaque.
4. Create storage classes using ones from [samples](https://github.com/dell/csi-powerscale/blob/main/samples/storageclass) folder as an example.
5. Install the chart with the name "csi-islon". 
The table [here](https://github.com/dell/csi-powerscale/blob/main/helm/csi-isilon/values.yaml) lists the configurable parameters of the chart and their default values
