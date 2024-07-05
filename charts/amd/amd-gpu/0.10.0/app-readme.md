# AMD GPU Helm Chart

[Kubernetes][k8s] [device plugin][dp] implementation that enables the registration of AMD GPU in a container cluster for compute workload.

More information about [RadeonOpenCompute (ROCm)][rocm]

## Prerequisites
* [ROCm capable machines][sysreq]
* [ROCm kernel][rock] ([Installation guide][rocminstall]) or latest AMD GPU Linux driver ([Installation guide][amdgpuinstall])

[dp]: https://kubernetes.io/docs/concepts/cluster-administration/device-plugins/
[k8s]: https://kubernetes.io
[rocm]: https://docs.amd.com/en/latest/rocm.html
[rock]: https://github.com/RadeonOpenCompute/ROCK-Kernel-Driver
[rocminstall]: https://docs.amd.com/en/latest/deploy/linux/quick_start.html
[amdgpuinstall]: https://amdgpu-install.readthedocs.io/en/latest/
[sysreq]: https://docs.amd.com/en/latest/release/gpu_os_support.html
