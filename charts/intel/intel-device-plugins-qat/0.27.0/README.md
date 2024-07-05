# Intel QAT Device Plugin Helm Chart

## Get Helm Repository Info
```
helm repo add intel https://intel.github.io/helm-charts/
helm repo update
```

You can execute `helm search repo intel` command to see pulled charts [optional].

## Dependencies

QAT Device Plugin depends on Node Feature Discovery (NFD). See NFD's Helm install page [here](https://kubernetes-sigs.github.io/node-feature-discovery/v0.12/deployment/helm.html?highlight=helm#deployment). If you do not want to use NFD in you cluster, you'll need to change the nodeSelector in the [values](values.yaml) file to match nodes with QAT device.

## Install Helm Chart
```
helm install qat-device-plugin intel/intel-device-plugins-qat [flags]
```

## Upgrade Chart
```
helm upgrade qat-device-plugin intel/intel-device-plugins-qat [flags]
```

## Uninstall Chart
```
helm uninstall qat-device-plugin
```

## Configuration
See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments:

```console
helm show values intel/intel-device-plugins-qat
```

You may also run `helm show values` on this chart's dependencies for additional options.

|parameter| value |
|---------|-----------|
| `hub` | `intel` |
| `tag` | `` |
| `dpdkDriver` | `vfio-pci` |
| `kernelVfDrivers` | `c6xxvf`, `4xxxvf` |
| `maxNumDevices` | `128` |
| `logLevel` | `4` |
| `nodeFeatureRule` | `true` |

