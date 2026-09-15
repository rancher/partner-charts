# Nocoly HAP Single-Node

Deploy Nocoly HAP as a single-node installation with five components: **app**, **sc**, **command**, **doc**, and optional **flink** data integration.

**Prerequisite: install the external Captain license manager before installing this chart.** For HAP **7.3.5**, download [Captain 7.3.5 for Linux AMD64](https://pdpublic.nocoly.com/7.3.5/hap_captain_linux_amd64.tar.gz) and run it on a Linux AMD64 VM or physical server. Captain must match the HAP **x.y.z** version and remain reachable from HAP pods. Follow the detailed chart README, then enter `hap.captainEndpoint` (for example, `http://captain.example.internal:38880`) in the required installation field. Port `38881` is the installer UI, not the Captain endpoint. Set the main access URL, select an existing StorageClass, and confirm volume sizes. The default application NodePort is `30880`. For installation or licensing assistance, contact [ops@nocoly.com](mailto:ops@nocoly.com).
