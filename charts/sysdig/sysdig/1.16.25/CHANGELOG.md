# Chart: Sysdig

All notable changes to this chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Please note that it's automatically updated vía github actions.
Manual edits are supported only below '## Change Log' and should be used
exclusively to fix incorrect entries and not to add new ones.

## Change Log
# v1.16.25
### New Features
* **sysdig,hostAnalyzer** [a8e1124b](https://github.com/sysdiglabs/charts/commit/a8e1124bfb668e9f9d04095c26d6ada0235cda04): Update legacy engine HostAnalyzer to v0.1.19 components with security updates ([#1601](https://github.com/sysdiglabs/charts/issues/1601))
# v1.16.24
### Chores
* **sysdig, node-analyzer** [4a1a9a1d](https://github.com/sysdiglabs/charts/commit/4a1a9a1d7feaeb4ee04b2c17e4b84d8440cf6901): bump sysdig/vuln-runtime-scanner to v1.6.6 ([#1526](https://github.com/sysdiglabs/charts/issues/1526))
# v1.16.23
### New Features
* **sysdig** [048837fc](https://github.com/sysdiglabs/charts/commit/048837fcb04b48c5dc584d13f5a005fdb75fd230): Update legacy engine NIA component with security updates ([#1489](https://github.com/sysdiglabs/charts/issues/1489))
# v1.16.22
### Chores
* **sysdig** [d9d16526](https://github.com/sysdiglabs/charts/commit/d9d165266542cc04e9aaccfdbf5242bd8562b49f): Update HostAnalyzer to 0.1.18 components with security updates ([#1486](https://github.com/sysdiglabs/charts/issues/1486))
# v1.16.21
### Chores
* **sysdig, node-analyzer** [6c7c27bf](https://github.com/sysdiglabs/charts/commit/6c7c27bf845b30af0eb5a4cb8f5fe330923d564f): bump sysdig/vuln-runtime-scanner to v1.6.4 [SSPROD-3285] ([#1477](https://github.com/sysdiglabs/charts/issues/1477))
# v1.16.20
### Bug Fixes
* **agent,kspm-collector,node-analyzer,sysdig** [f378d192](https://github.com/sysdiglabs/charts/commit/f378d1922d0f21f5936c6ed872e6538536ccf1f2): whitespace errors ([#1436](https://github.com/sysdiglabs/charts/issues/1436))
# v1.16.19
### New Features
* [629c5f06](https://github.com/sysdiglabs/charts/commit/629c5f06ccab168b9460ec1fa6564aed1a54c015): release agent 12.17.1 ([#1430](https://github.com/sysdiglabs/charts/issues/1430))
# v1.16.18
### Chores
* **sysdig, node-analyzer** [2c6d3d0b](https://github.com/sysdiglabs/charts/commit/2c6d3d0bd9d1750d6f34c0bd7b3e2689482515b6): bump sysdig/vuln-runtime-scanner to v1.6.3 ([#1428](https://github.com/sysdiglabs/charts/issues/1428))
# v1.16.17
### New Features
* [eda0e7cd](https://github.com/sysdiglabs/charts/commit/eda0e7cdf12c0b40f0bb77c0a16e0fd5f0173256): release agent 12.17.0 ([#1410](https://github.com/sysdiglabs/charts/issues/1410))
# v1.16.16
### Chores
* **sysdig, node-analyzer** [84cfe9a5](https://github.com/sysdiglabs/charts/commit/84cfe9a5e6f989a9a42b14b3d16597436f23b4b1): update legacy nodeImageAnalyzer (0.1.29) and hostImageAnalyzer (0.1.17) ([#1407](https://github.com/sysdiglabs/charts/issues/1407))
# v1.16.15
### New Features
* [9fc9ddd4](https://github.com/sysdiglabs/charts/commit/9fc9ddd48e6cb2c3ea334bfc10048ffc15646fd2): release agent 12.16.3 ([#1395](https://github.com/sysdiglabs/charts/issues/1395))
# v1.16.14
### New Features
* [45e2f7a9](https://github.com/sysdiglabs/charts/commit/45e2f7a96c565bfe0687acaacf350e81f94a23bb): release agent 12.16.2 ([#1381](https://github.com/sysdiglabs/charts/issues/1381))
# v1.16.13
### Chores
* **sysdig, nodel-analyzer** [44e1c6a3](https://github.com/sysdiglabs/charts/commit/44e1c6a385faf3bdcdd0cb8427254338c68254c7): bump sysdig/vuln-runtime-scanner to v1.5.7 ([#1361](https://github.com/sysdiglabs/charts/issues/1361))
# v1.16.12
### New Features
* [b2146b31](https://github.com/sysdiglabs/charts/commit/b2146b31e56eb00a6dc270bbb9bb530a3ee69f4c): release agent 12.16.1 ([#1353](https://github.com/sysdiglabs/charts/issues/1353))
# v1.16.11
### New Features
* **agent,sysdig** [8aff7e6a](https://github.com/sysdiglabs/charts/commit/8aff7e6adcccd7ebbebabff7f7d89e5125fb8f46): use `updatecli` for agent version bumps during release ([#1338](https://github.com/sysdiglabs/charts/issues/1338))
# v1.16.10
### Chores
* **sysdig, node-analyzer** [6b2c2efd](https://github.com/sysdiglabs/charts/commit/6b2c2efd7eccb16ad74df29d75daef664e2df9f7): bump sysdig/vuln-runtime-scanner to v1.5.6 ([#1331](https://github.com/sysdiglabs/charts/issues/1331))
# v1.16.9
### Chores
* **sysdig, node-analyzer** [0ba5baa3](https://github.com/sysdiglabs/charts/commit/0ba5baa3e690be1c2c3a92c4928558efffb33539): bump sysdig/vuln-runtime-scanner to v1.5.5 ([#1320](https://github.com/sysdiglabs/charts/issues/1320))

    * * Runtime Scanner bumped to 1.5.5
     * Fixed a bug that could cause the Runtime Scanner to perform unneeded rescans
# v1.16.8
### Chores
* **sysdig, node-analyzer** [17d2e503](https://github.com/sysdiglabs/charts/commit/17d2e50326f587b154f43beb706627416ca6a4b6): bump sysdig/vuln-runtime-scanner to v1.5.4 ([#1305](https://github.com/sysdiglabs/charts/issues/1305))

    * * Runtime Scanner bumped to 1.5.4
     * Fixed a misbehavior of the image layer analyzer, which could lead to non-existing software artifacts being reported in the SBOM as a result of incorrect handling of opaque directories (ESC-3511).
# v1.16.7
### Chores
* **sysdig** [b38bf394](https://github.com/sysdiglabs/charts/commit/b38bf394fc121bffe546def326a5aaf019f0ebd7): bump agent version to 12.16.0 ([#1291](https://github.com/sysdiglabs/charts/issues/1291))
# v1.16.6
### New Features
* **node-analyzer** [0ad8696a](https://github.com/sysdiglabs/charts/commit/0ad8696a0b38d2564121e6e798589f568e3547a8): Release eveconnector 1.1.2 ([#1280](https://github.com/sysdiglabs/charts/issues/1280))
# v1.16.5
### Chores
* **sysdig,node-analyzer** [00316d04](https://github.com/sysdiglabs/charts/commit/00316d042378fa75ac0ed9277b547236766ce816): bumped RuntimeScanner to 1.5.2 version ([#1275](https://github.com/sysdiglabs/charts/issues/1275))

    * * Added env var flag for internal timeout on scheduled operations
* Added fallback when connection to detected container runtime fails
* Security updates (July 2023). Fixed CVE
  *  CVE-2023-33199
# v1.16.4
# v1.16.3
### New Features
* **sysdig** [ec78a545](https://github.com/sysdiglabs/charts/commit/ec78a545637a86aa98c5cef41010c8012bccdfc7): updated legacy engine NIA compoment with latest release. ([#1266](https://github.com/sysdiglabs/charts/issues/1266))

    * * Resolves possible compatibility issues with Kubernetes 1.26+ (CRI-O container runtime)
* Security updates (July 2023). Fixed CVEs
  *  CVE-2020-24736
  *  CVE-2023-1667
  *  CVE-2023-1667
  *  CVE-2023-2283
  *  CVE-2023-2283
  *  CVE-2023-26604
  *  CVE-2023-26604
  *  CVE-2023-26604
# v1.16.2
### Chores
* **sysdig** [f32bc89b](https://github.com/sysdiglabs/charts/commit/f32bc89be0587f6337a41b56cc5f7de715447d7d): bump agent version to 12.15.0 ([#1199](https://github.com/sysdiglabs/charts/issues/1199))
# v1.16.1
### Documentation
* **sysdig** [91306238](https://github.com/sysdiglabs/charts/commit/91306238bbcb7317f854f6efc8b13f0a517f19aa): DOC-3236 - clean up for consistency and clarity ([#1178](https://github.com/sysdiglabs/charts/issues/1178))
# v1.16.0
### New Features
* **admission-controller,agent,cloud-bench,cloud-connector,cloud-scanning,harbor-scanner-sysdig-secure,kspm-collector,node-analyzer,rapid-response,registry-scanner,sysdig,sysdig-deploy,sysdig-mcm-navmenu,sysdig-stackdriver-bridge** [5d99a03d](https://github.com/sysdiglabs/charts/commit/5d99a03dced132b4771dde1ce5b90b63c518b408): use a PGP private key to sign charts on release ([#1170](https://github.com/sysdiglabs/charts/issues/1170))
# v1.15.93
### Chores
* **sysdig, node-analyzer** [706d562f](https://github.com/sysdiglabs/charts/commit/706d562f3d473f88fd1d257974cd3a127d672a2a): bump sysdig/vuln-runtime-scanner to v1.5.1 ([#1187](https://github.com/sysdiglabs/charts/issues/1187))

    * Runtimescanner bumped to 1.5.1
- Fix for CVE-2023-2253
# v1.15.92
### Chores
* **sysdig, node-analyzer** [f9c8e102](https://github.com/sysdiglabs/charts/commit/f9c8e1028b4b4e79aba10e72f762f14956d54273): bump sysdig/vuln-runtime-scanner to v1.5 ([#1160](https://github.com/sysdiglabs/charts/issues/1160))

    * * Runtimescanner bumped to 1.5
     * Updated the analyzer to inspects also vendor paths
     * Added support to apply image based accepts for all versions of the image, that image in a specific registry & repository, as well as a contain string for customized subsets of the environment
# v1.15.91
### Chores
* **sysdig, node-analyzer** [601a0685](https://github.com/sysdiglabs/charts/commit/601a0685639cefc10ec9120c74153f4bb2ac2473): bump sysdig/vuln-runtime-scanner to v1.4.12 ([#1127](https://github.com/sysdiglabs/charts/issues/1127))
# v1.15.90
### New Features
* **sysdig** [a1a22e4c](https://github.com/sysdiglabs/charts/commit/a1a22e4c0d439a1dc254a172e3d8fb4eaa801dd4): Update legacy engine HostAnalyzer with security updates ([#1128](https://github.com/sysdiglabs/charts/issues/1128))

    * Security updates (May 2023) for HostAnalyzer. Fixed 1 CVE:
	* CVE-2023-28840
# v1.15.89
### New Features
* **sysdig** [a6d4b61e](https://github.com/sysdiglabs/charts/commit/a6d4b61e484b9c07df3fb195a6243f37cd4c9410): Update legacy engine NIA with security updates ([#1123](https://github.com/sysdiglabs/charts/issues/1123))

    * Security updates (May 2023) for NodeImageAnalyzer. Fixed 2 CVEs:
	* CVE-2023-30861
	* CVE-2023-28840
# v1.15.88
### Chores
* **sysdig** [c8398346](https://github.com/sysdiglabs/charts/commit/c83983463b32841eef524f9cf2302a67088363d5): bump agent version to 12.14.1 ([#1105](https://github.com/sysdiglabs/charts/issues/1105))
# v1.15.87
### Chores
* **sysdig** [82bedb7](https://github.com/sysdiglabs/charts/commit/82bedb791cc03edd950e96fb973531add97ad47c): bump agent version to 12.14.0 ([#1075](https://github.com/sysdiglabs/charts/issues/1075))
# v1.15.86
### New Features
* **sysdig** [727f9f8](https://github.com/sysdiglabs/charts/commit/727f9f836b38daf91090e843895dd4ea07126ec5): Update legacy engine NIA component with security updates ([#1065](https://github.com/sysdiglabs/charts/issues/1065))
# v1.15.85
### Chores
* **sysdig, node-analyzer** [a7564db](https://github.com/sysdiglabs/charts/commit/a7564dbac2f879064e000ef780b71ebc3d4463a7): bump sysdig/vuln-runtime-scanner to v1.4.11 ([#1061](https://github.com/sysdiglabs/charts/issues/1061))
# v1.15.84
### Bug Fixes
* **agent,sysdig** [0702edd](https://github.com/sysdiglabs/charts/commit/0702eddfc46c823b8362b5f0d42e7be9d3bfe1ac): do not mount /var/lib when GKE autopilot is enabled ([#1047](https://github.com/sysdiglabs/charts/issues/1047))
# v1.15.83
### Bug Fixes
* **admission-controller,agent,node-analyzer,rapid-response,registry-scanner,sysdig** [0bf9682](https://github.com/sysdiglabs/charts/commit/0bf96827ebf80d76aab61b8fa3d26b3903df220b): Improve KubeVersion Comparisons ([#1040](https://github.com/sysdiglabs/charts/issues/1040))
# v1.15.82
### New Features
* **agent** [99a4b36](https://github.com/sysdiglabs/charts/commit/99a4b36bfd535264766b30ce176f4e244da0eb1f): Include /var/libs host volume mount ([#1009](https://github.com/sysdiglabs/charts/issues/1009))
# v1.15.81
### Chores
* **sysdig** [b360599](https://github.com/sysdiglabs/charts/commit/b3605992c9167f3d5d1c54fb097b83dc66f9c6f5): bump agent version to 12.13.0 ([#1021](https://github.com/sysdiglabs/charts/issues/1021))
# v1.15.80
### New Features
* **agent** [d48ef54](https://github.com/sysdiglabs/charts/commit/d48ef54afb4c79c72d8b51a77d8e101f9d25a4f4): Add poddisruptionbudget permissions to the Agent clusterrole ([#968](https://github.com/sysdiglabs/charts/issues/968))
# v1.15.79
### New Features
* **sysdig** [eb8d0bc](https://github.com/sysdiglabs/charts/commit/eb8d0bc4a990036aef0c298e6aaaef0dd6ff9f85): Update legacy engine NIA/HostAnalyzer components with security updates ([#987](https://github.com/sysdiglabs/charts/issues/987))
# v1.15.78
### Chores
* **sysdig** [8cb737c](https://github.com/sysdiglabs/charts/commit/8cb737cc8d1f5124315f68409091fa4e4e5cd78e): bump agent version to 12.12.1 ([#981](https://github.com/sysdiglabs/charts/issues/981))
# v1.15.77
### Bug Fixes
* **sysdig,node-analyzer** [27ce551](https://github.com/sysdiglabs/charts/commit/27ce5515b64325ebe0e97762dbcc0a2b8deddbd3): Added missing volumeMount required for IBM OCP on legacy and new VM ([#955](https://github.com/sysdiglabs/charts/issues/955))
# v1.15.76
### Chores
* **sysdig** [40b4958](https://github.com/sysdiglabs/charts/commit/40b4958987085f6682751814a9276fdafa4d9c2e): bump agent version to 12.12.0 ([#973](https://github.com/sysdiglabs/charts/issues/973))
# v1.15.75
# v1.15.74
### New Features
* **node-analyzer,sysdig** [42e3aa5](https://github.com/sysdiglabs/charts/commit/42e3aa5c30a06166eb959632ec223149a6784421): Feat/bench runner bump to 1.1.0.8 ([#937](https://github.com/sysdiglabs/charts/issues/937))
# v1.15.73
### New Features
* **sysdig,node-analyzer** [407e669](https://github.com/sysdiglabs/charts/commit/407e6693e451059956838118d65a8e0cc68547c4): bump legacy NodeImageAnalyzer to v0.1.24 ([#935](https://github.com/sysdiglabs/charts/issues/935))
# v1.15.72
### Chores
* **sysdig** [38ce49c](https://github.com/sysdiglabs/charts/commit/38ce49c5e323b4703fa3cbe9e2a20c469fd784f0): bump agent version to 12.11.0 ([#926](https://github.com/sysdiglabs/charts/issues/926))
# v1.15.71
### New Features
* **sysdig,node-analyzer** [61deccc](https://github.com/sysdiglabs/charts/commit/61decccbf840632176424593b3959c7b8499c4a6): bump legacy NodeImageAnalyzer to v0.1.23 ([#924](https://github.com/sysdiglabs/charts/issues/924))
# v1.15.70
### New Features
* **agent,node-analyzer,rapid-response** [487b421](https://github.com/sysdiglabs/charts/commit/487b421c922e097047e5ca65c01cee466664daba): add Rancher-specific tolerations ([#884](https://github.com/sysdiglabs/charts/issues/884))
# v1.15.69
### Documentation
* **agent,node-analyzer,sysdig,sysdig-stackdriver-bridge** [da18fe5](https://github.com/sysdiglabs/charts/commit/da18fe5e7225be9bbfc484d6dcb22987d7d08066): remove references of the deprecated --purge option for 'helm delete' ([#864](https://github.com/sysdiglabs/charts/issues/864))
# v1.15.68
### Documentation
* **agent,node-analyzer,sysdig** [bd37186](https://github.com/sysdiglabs/charts/commit/bd371864313e64d7a7ac07f79fe30f296b46d540): Remove references to Get Started in the READMEs ([#819](https://github.com/sysdiglabs/charts/issues/819))
# v1.15.67
### Chores
* **sysdig** [577e003](https://github.com/sysdiglabs/charts/commit/577e003eddd43e6e9a71bb89e4265a3a2d131262): bump agent version to 12.10.1 ([#849](https://github.com/sysdiglabs/charts/issues/849))
# v1.15.66
### New Features
* **sysdig** [be92144](https://github.com/sysdiglabs/charts/commit/be92144be843bc46377c949c7f8c88a4b5df5fc4): Update legacy engine NIA/HostAnalyzer components with security updates ([#843](https://github.com/sysdiglabs/charts/issues/843))

    * Security updates (December 2022) for NodeImageAnalyzer and HostAnalyzer components
# v1.15.65
### New Features
* **sysdig** [3fa1178](https://github.com/sysdiglabs/charts/commit/3fa1178e722f921f595d056c0d91991a9ad85690): runtimescanner bump to 1.4.1 ([#838](https://github.com/sysdiglabs/charts/issues/838))

    * RuntimeScanner: bump to version 1.4.1. Fixed 1 CVE:
    * CVE-2022-41717
# v1.15.64
### Bug Fixes
* **sysdig,agent** [096d6e4](https://github.com/sysdiglabs/charts/commit/096d6e4d0326f36357fec6ac61342c17e73b33ab): add extra secrets and tests ([#821](https://github.com/sysdiglabs/charts/issues/821))
# v1.15.63
### New Features
* **sysdig** [ef5afd9](https://github.com/sysdiglabs/charts/commit/ef5afd9ed9a041a6af0464f55467f82e034fe05c): add extra secrets ([#820](https://github.com/sysdiglabs/charts/issues/820))
# v1.15.62
### Chores
* **sysdig** [0e014c2](https://github.com/sysdiglabs/charts/commit/0e014c2a2ebd285edd0e9c45422df6d98827cfc4): bump agent version to 12.10.0 ([#814](https://github.com/sysdiglabs/charts/issues/814))
# v1.15.61
### New Features
* [f4cb189](https://github.com/sysdiglabs/charts/commit/f4cb189afba6833fd458f99dcfcc0121f9d9dfa2)]: unify changelog headers ([#787](https://github.com/sysdiglabs/charts/issues/787))

## v1.15.60
### Minor changes:
* BenchmarkRunner
    * bump to runner version 1.1.0.5

## v1.15.59
### Minor changes:
* BenchmarkRunner
    * bump to runner version 1.1.0.4

## v1.15.58
### Minor changes
* Updated chart icon

## v1.15.57
### Minor changes
* NodeAnalyzer:
    * NodeImageAnalyzer: bump to version 0.1.21 which contains security updates (November 2022). Fixed 21 CVEs in total, the ones with high or critical severity are:
        * CVE-2022-1941
        * CVE-2022-1996
        * CVE-2022-27191
        * CVE-2022-27664
        * CVE-2022-29361
        * CVE-2022-32149
        * CVE-2022-3515
        * CVE-2022-39237
        * CVE-2022-40674
    * HostAnalyzer: bump to version 0.1.13 (November 2022)

## v1.15.56
### Minor changes:
* Added `node-role.kubernetes.io/control-plane` toleration to agent and node-analyzer

## v1.15.55
### Minor changes:
* BenchmarkRunner
    * bump to runner version 1.1.0.3

## v1.15.54
### Minor changes:
* NodeAnalyzer
    * RuntimeScanner: bump to version 1.3.0
        * fixes CVE-2022-32149
        * fixes CVE-2022-39237
        * add support for rhel9-based OSes

## v1.15.52
### Minor changes:
* BenchmarkRunner
    * bump to runner version 1.1.0.2

## v1.15.51
### Minor changes
* NodeAnalyzer:
    * NodeImageAnalyzer: bump to version 0.1.20 which contains security updates (October 2022)
        * CVE-2022-1941
        * CVE-2022-1996
        * CVE-2022-3515
        * CVE-2022-27191
        * CVE-2022-27664
        * CVE-2022-32149
        * CVE-2022-39237
        * CVE-2022-40674
    * HostAnalyzer: bump to version 0.1.12 which contains security updates (October 2022)
        * CVE-2022-27664
        * CVE-2022-32149

## v1.15.50
### Minor changes:
* BenchmarkRunner
    * multiarch builds
    * support arm64 hosts
    * bump to version 1.1.0.1

## v1.15.49
### Minor changes:
* EveConnector:
    * bump to 1.1.0 version
### Bugfix
* EveConnector:
    * reduce the size of the image
    * bump dependencies to resolve critical and high vulnerabilities:
      * CVE-2022-1996
      * CVE-2022-1271
      * CVE-2022-2526
      * CVE-2022-3515

## v1.15.48
### Minor changes:
* RuntimeScanner:
  * bump to 1.2.13 version
### Bugfix
* RuntimeScanner:
  * fix jar parser to avoid duplicated pkgs

## v1.15.47
### Minor changes:
* BenchmarkRunner
    * bump to version 1.0.19.0

## v1.15.46
### Minor changes
* RapidResponse:
    * bump to version 0.3.4

## v1.15.45
### Minor changes
* RuntimeScanner:
    * bump to 1.2.12 version
    * update vulnerable packages
    * bump to 1.19 Go version
### Bugfix
* RuntimeScanner:
    * fix container-storage locks

## v1.15.43
### Minor changes
* KSPMCollector updated to version 1.9.0
* KSPMAnalyzer updated to version 1.9.0

## v1.15.41
### Bugfix
* Don't deploy psp policies on k8s 1.25.x

## v1.15.40
### Minor changes
* RuntimeScanner:
    * bump to 1.2.10 version
    * add image size and storage info to warning log

## v1.15.39
### Minor changes
* RuntimeScanner:
	* bump to 1.2.9 version
  	* configurable thresholds for maxFileSize and maxImageSize. Bigger files/images will be skipped
	* logging about the skipping of a file to be analysed changed from error to warning.

## v1.15.38
### Minor changes
* Added cerftificatesigningrequests resources to clusterrole

## v1.15.37
### Minor changes
* HostAnalyzer: fixed certificates issue introduced in 0.1.10

## v1.15.36
### Minor changes
* RuntimeScanner: bumped to 1.2.8 with a fix regarding the dpkg packages version used to match vulnerabilities.

## v1.15.35
### Minor changes
* Security updates (August 2022) for NodeImageAnalyzer and HostAnalyzer components

## v1.15.34
### Minor changes
* RuntimeScanner: bumped to 1.2.7 which:
  * removed the old golang analyzer based on the go.sum files. Only go packages from binary will be analyzed.
  * fixes several bugs in loading images into openshift clusters.
  * improve memory consumption.

## v1.15.32
 ### Minor changes
 * Moved the clusterrole's Ingresses resource to the networking.k8s.io group

## v1.15.31
### Bugfixes
* Don't mount /etc in GKE Autopilot

## v1.15.30
### Minor changes
* RuntimeScanner: version 1.2.6 ignores the fix solution date of a vuln when no fix version is available

## v1.15.29

### Minor changes
* Added /etc to container and initContainer /host/etc volume bind

## v1.15.28

### Minor changes
* Readme fixes

## v1.15.26

### Minor changes
* Agent: Introduced support to proxy for agent initContainer

## v1.15.25

### Minor changes
* reverted change made in v1.15.21 that added /etc to container /host/etc volume bind

## v1.15.24
### Minor changes
* runtimeScanner: version 1.2.5 with fixes on ruby file analyzer

## v1.15.22
### Minor changes
* runtimeScanner: version 1.2.4 with fixes on tmp dirs to be used during analysis

## v1.15.21
### Minor changes
* Added /etc to container /host/etc volume bind

## v1.15.20
### Bugfixes
* Removed duplicate labels from deployment of `app.kubernetes.io/instance`

## v1.15.19
### Minor changes
* runtimeScanner: version 1.2.3 with fixes on java file analyzer


## v1.15.18
### Minor changes
* runtimeScanner: version 1.2.2 with performance improvement in pkgmeta client

## v1.15.17
### Minor changes
* runtimeScanner: version 1.2.0 with fixes on jar manifest parser

## v1.15.16
### Minor changes
* KSPM: version 1.5.0

## v1.15.14
### Minor changes
* Sysdig README file: merged KSPM collector & KSPM analyzer sections

## v1.15.13
### Minor changes
* HostAnalyzer bumped to version 0.1.9 (go 1.18)

## v1.15.12
### Minor changes
* KSPM Analyzer - fix container missing CPU\Memory limits & requests
* KSPM components - Merge analyzer and collector deploy flags into 1
* KSPM Chart components - fix KSPM serviceAccount that is created when KSPM not installed

## v1.15.11
### Minor change
* Security updates (July 2022) for NodeImageAnalyzer and HostAnalyzer component

## v1.15.10
### Minor changes
* Notes section reflects proper links based on deployment region
## v1.15.7
### Minor changes
* BenchmarkRunner: bump tag to 1.0.17.2

## v1.15.6
### Minor changes
* RuntimeScanner version 1.1.1 with Golang support

## v1.15.5
### Minor changes
* Fix expose node name to the Sysdig Agent container through Downward API
  through K8S_NODE environment variable.

## v1.15.2
### Minor changes
* KSPM: add kspmCollector.deploy parameter to docs
* KSPM: bump tag to 1.4.0

## v1.15.1
### Minor changes
* KSPM: bump tag to 1.3.0

## v1.15.0
### Major change
* KSPMAnalyzer: rename cspm-analyzer to kspm-analyzer
* KSPMCollector: rename cspm-collector to kspm-collector

### Minor changes
* KSPMAnalyzer: add documentation on port configuration

## v1.14.34
### Minor changes

* RuntimeScanner: added nodeAnalyzer.runtimeScanner.extraMounts for handle non-standard socket paths

## v1.14.32
### Bugfixes
* RuntimeScanner: enhanced detection of java packages

### Minor changes
* Release of runtime scanner 1.0.4

## v1.14.31
* Describe CSPM components in README and link to official Sysdig docs

## v1.14.3
### Minor change

* CSPMCollector: Handle failure on apis discovery
* CSPMAnalyzer: Send runtime parameters

## v1.14.1
### Minor change

* CSPM support AKS

## v1.14.0
### Major change

* Add CSPM Analyzer to Daemonset and CSPM Collector Deployment

## 1.13.4
### Bugfixes
* RuntimeScanner: added jitter on startup to distribute requests to the k8s api over 15 minutes
* RuntimeScanner: caching data to reduce the amount of requests to the k8s api

### Minor changes
* Release of runtime scanner 1.0.3

## v1.13.1
### Minor change

* Security updates (April 2022) for NodeImageAnalyzer and HostAnalyzer component

## v1.13.0
### Major change

* The slim agent is enabled by default

## 1.12.73
### Bugfixes
* RuntimeScanner: fixed usage of TLS settings when downloading vulnerabilities database
* RuntimeScanner: minor fixes

### Minor changes
* Release of runtime scanner 1.0.1

## 1.12.72
### Bugfixes
* Bugfixes on the runtime scanner

### Minor changes
* Release of runtime scanner 1.0.0

## v1.12.70
### Bugfixes

* Remove the maxSurge field from the rollingUpdate field because not all envs have the new k8s versions

## v1.12.69
### Minor changes

* RuntimeScanner: reduced and better disk usage for temporary files
* RuntimeScanner: added support for Runtime policies

## v1.12.67
### Minor changes

* Add s390x as one of the default architectures for Sysdig Agent node affinity

## v1.12.66
### Minor changes

* Add arm64 as one of the default architectures for Sysdig Agent node affinity

## v1.12.64
### Bugfixes

* RuntimeScanner provides correct image name in containerd environments
* RuntimeScanner provides correct image digest in dockerd environments

## v1.12.63
### Minor changes

* Added CRI-O support for runtime-scanner
* Improved runtime-scanner memory usage
* Updated runtime-scanner to the latest version

## v1.12.61
### Minor changes

 * Fix runtime-scanner `eve_enabled` check in configmap

## v1.12.59
### Minor changes

 * Fix link in README.md

## v1.12.58
### Minor changes

* Add the flag `gke.autopilot` to support the deployment on GKE Autopilot clusters.

## v1.12.57
### Minor changes

* The values for the default affinity settings now come from `daemonset.os` and `daemonset.arch`

## v1.12.55
### Minor changes

* Add dedicated service account for node analyzer

## v1.12.52
### Minor changes

* Fix errors in README.md

## v1.12.51
### Minor changes

* Tech preview release of Runtime Scanner

## v1.12.50
### Minor changes

* Add Runtime Scanner to Daemonset and Eve Connector Deployment

## v1.12.49
### Minor changes

* Bump agent to 12.3.0

## v1.12.48
### Minor changes

* Bump agent to 12.2.1

## v1.12.47
### Bugfixes

* Trim whitespace around image tag

## v1.12.46
### Minor changes

- Add digest value inputs for image pulls

## v1.12.45
### Minor changes

- Add ability to configure affinity and nodeSelector on imageAnalyzer daemonset

## v1.12.43
### Minor changes

- Add a flag to enable/disable Sysdig agent daemonset

## v1.12.41
### Minor changes

- Add custom labels for Sysdig and NodeAnalyzer daemonsets

## v1.12.40
### Minor changes

- Add priorityClassName for NodeAnalyzer

## v1.12.35
### Minor changes

- Removed invalid imagePullSecrets from initContainers

## v1.12.31

### Minor changes

- Add `slim.image.repository` value to allow full slim agent repo name to be configured

## v1.12.30
### Minor changes

- Add strorageclass resource in clusterrole

## v1.12.27

### Minor changes

- Add affinity to nodeImageAnalyzer DaemonSet

## v1.12.26

### Minor changes

- Fix Openshift SCC to allow downward API volumes

## v1.12.25

### Minor changes

- Add priorityclass option for image-analyzer daemonset

## v1.12.24

### Minor changes

- Update agent to 12.0.2

## v1.12.23

### Breaking change notification

- In chart version 1.12.13, the default agent container resources was set to [small](https://docs.sysdig.com/en/tuning-sysdig-agent.html). This was a breaking change (and not minor as originally stated) because upgrading the agent using this chart from an earlier chart where the default was [medium](https://docs.sysdig.com/en/tuning-sysdig-agent.html) could result in less resources configured for it than required.

## v1.12.20

### Minor changes

- Add downward API volume to autodetect agent namespace

## v1.12.16

### Minor changes

- Introduce resource profiles

## v1.12.15

### Minor changes

- Add new resources to ClusterRole to support collection of Kubelet metrics.

## v1.12.14

### Minor changes

- Bump host-analyzer version to 0.1.3

## v1.12.13

### Minor changes

- Change the default agent container resources to [the ones for small clusters](https://docs.sysdig.com/en/tuning-sysdig-agent.html)

## v1.12.12

### Bugfixes

* Add mountPath /sys/kernel/debug for eBPF

## v1.12.11

### Minor changes

- Change the default agent container resources

## v1.12.10

### Minor changes

- Update agent to 11.4.1

## v1.12.9

### Minor changes

- Introduce `leaderelection.enable` for the agent leader election algorithm

## v1.12.8

### Minor changes

- Update values.yaml and README.md to reflect no default value for `nodeAnalyzer.apiEndpoint`

## v1.12.7

### Minor changes

- Update agent to 11.3.0
- Include get/list/create/update/watch leases in agent clusterrole permissions.

## v.1.12.6

### Cleanup

* Rename `nodeAnalyzer.collectorEndpoint` to `nodeAnalyzer.apiEndpoint` to prevent confusion with the Agent collector.
* Update README to reflect deprecation of Node Image Analyzer

### Bugfixes

* Fix `collector_endpoint` in configmap for image-analyzer
* If `nodeImageAnalyzer.settings.collectorEndpoint` is set, deploy old NIA to prevent onboarding instructions from older Sysdig Secure versions from failing.

## v1.12.5

### Bugfixes

* eBPF with Agent slim image did not work on GKE (Google COS)

## v1.12.4

### Bugfixes

* Node analyzer configuration options not being honored due to invalid Configmap name
* Fix `hostBase` for Host Analyzer

## v1.12.3

### Minor changes

* Fix: Respect existingAccessKeySecret in `daemonset-node-analyzer.yaml`
* Update documentation links

## v1.12.2

### Minor changes

* Support eBPF with Agent slim image

## v1.12.1

### Minor changes

* Switch default registry from `docker.io` to `quay.io`
* Update Benchmark Runner to 1.0.6.0
* Correct error in Host Analyzer Configmap

## v1.12.0

### Major changes

* Add Node Analyzer (`nodeAnalyzer.deploy` set to `true` by default)
* Explain all Node Analyzer settings in values.yaml and README, and link to official Sysdig docs
* Disable Node Image Analyzer deployment (`nodeImageAnalyzer.deploy` set to `false` by default)

## v1.11.18

### Minor changes

* Update agent to 11.2.1

## v1.11.17

### Minor changes

* Fix `nodeImageAnalyzer.extraVolumes.volumes` not creating correctly the volumes

## v1.11.16

### Minor changes

* New option `sysdig.existingAccessKeySecret` to use existing or external secrets

## v1.11.15

### Minor changes

* Remove --name installation parameter for `helm install` in README.aws

## v1.11.14

### Minor changes

* Update agent to 11.2.0
* Remove --name installation parameter for `helm install` in README, unsupported in Helm 3.x

## v1.11.13

### Minor changes

* Update agent to 11.1.3

## v1.11.12

### Minor changes

* Fix in probes initialDelay

## v1.11.11

### Minor changes

* Update agent to 11.1.2

## v1.11.10

### Minor changes

* Fix the if in the imageanalyzer extravolumes

## v1.11.9

### Minor changes

* Improvements and fixes in README for installation instructions (use sysdig-agent namespace by default)

## v1.11.8

### Minor changes

* Improvements in CI process and testing

## v1.11.7

### Minor changes

* Update Node Image Analyzer to 0.1.10 by default
* Fix VERIFY_CERTIFICATE setting for Node Image Analyzer

## v1.11.6

### Minor changes

* Add tolerations configuration item to Node Image Analyzer

## v1.11.5

### Minor Changes

* Fix appversion

## v1.11.4

### Minor Changes

* Use the latest image from Agent (11.0.0)

## v1.11.3

### Minor Changes

* Use the latest image from Agent (10.9.0)

## v1.11.2

### Minor changes

* Allow for customization of liveness and readiness probes initial delay

## v1.11.1

### Minor Changes

* Use the latest image from Agent (10.8.0)
* Use the latest image from Node Image Analyzer (0.1.7)

## v1.11.0

### Major changes

* Node Image Analyzer now deployed by default (`nodeImageAnalyzer.deploy` set to `true` by default)
* Explain all Node Image Analyzer settings in values.yaml and README, and link to official Sysdig docs

### Minor changes

* Use the latest image from Agent (10.7.0)
* Change check_certificate to ssl_verify_certificate in NIA settings to sync with NIA configmap

## v1.10.5

* Use the latest image from Node Image Analyzer (0.1.6)

## v1.10.4

* Use the latest image from Agent (10.6.0)

## v1.10.3

### Minor changes

* Add options to add a nodeSelector.

## v1.10.2

### Minor changes

* Use the latest image from Agent (10.5.1)

## v1.10.1

### Minor changes

* Use latest image from Agent (10.5.0)
* Update documentation for agent connection HTTP proxy settings

## v1.10.0

### New features

* Desploy a PSP and the PSP use permission to allow agent running with the required privileges in PSP enabled clusters.

## v1.9.5

### Minor changes

* Use latest image from Agent (10.4.1)

## v1.9.4

### Minor changes

* Use latest image from Agent (10.4.0)

## v1.9.3

### Minor changes

* Redirect to agents dashboard instead of Explore tab.

## v1.9.2

### Minor changes

* Use latest image from Agent (10.3.0)

## v1.9.1

### Minor changes

* Remove explicit *onPrem* option. Use *collectorSettings* section instead.

## v1.9.0

### Major changes

* Option to deploy the [Node Image Analyzer](https://docs.sysdig.com/en/scan-running-images.html).

### Minor changes

* Include get/list/watch endpoints in agent clusterrole permissions.

## v1.8.1

### Minor changes

* Use the latest image from Agent (10.2.0) by default.

### Bug fixes

* Fix logic in template that was disabling captures in the agent settings.

## v1.8.0

### Major changes

* Migrated charts to *sysdiglabs* repository

###  Minor changes

* Add explicit *clusterName* option in values.yaml
* Add beta.kubernetes.io labels for node affinity, to support older versions
* SCC deployed by default in Openshift (check API security.openshift.io/v1)

## v1.7.20

###  Minor changes

* Use the latest image from Agent (10.1.1) by default.

## v1.7.19

###  Minor changes

* Use the latest image from Agent (10.1.0) by default.

## v1.7.18

### Minor changes

* Add explicit *disable captures* option to agent settings.

## v1.7.17

### Minor changes

* Add onPrem as explicit option to set collector host, port and settings
* Fail if no sysdig.accessKey value is provided

## v1.7.16

### Minor changes

* Include support links in README.md

## v1.7.15

### Minor changes

* Use the latest image from Agent (10.0.0) by default.

## v1.7.14

### Minor changes

* Implement a more comprehensive securityContext for running the pod.

## v1.7.13

### Minor changes

* Implement scheduling with affinity and not with nodeSelector on amd64 & linux nodes.
* Add support for custom annotations on daemonSet.

## v1.7.12

### Minor changes

* Use the latest image from Agent (9.9.1) by default.
* Use kubernetes.io/arch label on daemonSet to schedule pods only on amd64 nodes.
* Add a livenessProbe to daemonSet.

## v1.7.11

### Minor changes

* Use app.kubernetes.io labels instead of custom ones

## v1.7.10

### Minor changes

* Use the latest image from Agent (9.9.0) by default.

## v1.7.9

### Minor changes

* Add the SecurityContextConstraints if the security.openshift.io/v1 API is detected.

## v1.7.8

### Minor changes

* Add an image.overrideValue value which is a hack to support
  RELATED_IMAGE_<identifier> feature in Helm based operators.

## v1.7.7

### Minor changes

* Use the latest image from Agent (9.8.0) by default.

## v1.7.6

### Minor changes

* Use rbac.authorization.k8s.io/v1 instead of the beta1 API.
* Fix security key duplication when enabling secure and auditLog.

## v1.7.5

### Minor changes

* Use the latest image from Agent (9.7.0) by default.

## v1.7.4

### Minor changes

* Use the latest image from Agent (9.6.1) by default.

## v1.7.3

### Minor changes

* Removed dependency on ebpf.enabled to set environment variables

## v1.7.2

### Minor changes

* Use the latest image from Agent (9.5.0) by default.

## v1.7.1

### Major changes

* Remove the auditLog.clusterIP dependency. Using dynamic backend allows to
  rely on DNS queries.

## v1.7.0

### Major changes

* Enable Sysdig Secure by default.

## v1.6.0

### Major changes

* Add audit log configuration when deploying the agent.

## v1.5.0

### Major changes

* Add slim configuration for deploying the agent.

### Minor changes

* Mount /etc/modprobe.d from host.
* Drop permissions to read secrets and configmaps.

## v1.4.25

### Minor changes

* Use the latest image from Agent (0.94.0) by default.

## v1.4.24

### Minor changes

* Use the latest image from Agent (0.93.1) by default.

## v1.4.23

### Minor changes

* Update NOTES.txt to use the newest URL for finding the infrastructure.

## v1.4.22

### Minor changes

* Use the latest image from Agent (0.93.0) by default.

## v1.4.21

* Add 'How to upgrade to last version' to the README

## v1.4.20

### Minor changes

* Fixes compatibility errors introduced in v1.4.19.

## v1.4.19

### Minor changes

* Fixes compatibility with kubernetes 1.16.

## v1.4.18

### Minor changes

* Use the latest image from Agent (0.92.3) by default.

## v1.4.17

### Minor changes

* Use the latest image from Agent (0.92.2) by default.

## v1.4.16

### Minor changes

* Allow the DaemonSet to schedule using affinity rules

## v1.4.15

### Minor changes

* Add configmaps and secrets to the resources we can read
* Add support for priorityClassName, httpProxy, timezone and any env variable settings

## v1.4.14

### Minor changes

* Update REAMED.md to fix the example in how to use the `sysdig.settings.tags` in the command line with `--set`

## v1.4.13

### Minor changes

* Use the latest image from Agent (0.92.1) by default.
* Increase `resources.requests` and `resources.limits` to match the [values
  provided by Sysdig's agent team.](https://github.com/draios/sysdig-cloud-scripts/blob/master/agent_deploy/kubernetes/sysdig-agent-daemonset-v2.yaml#L70)

## v1.4.12

### Minor changes

* Use the latest image from Agent (0.92.0) by default.

## v1.4.11

### Minor Changes

* Add nestorsalceda as an approver in the OWNERS file

## v1.4.10

### Minor Changes

* Use the latest image from Agent (0.90.3) by default.

## v1.4.9

### Minor Changes

* Use the latest image from Agent (0.90.2) by default.

## v1.4.8

### Minor Changes

* Add a volume with the os release information.
* Use the latest image from Agent (0.90.1) by default.

## v1.4.7

### Minor Changes

* Add apiVersion to Chart.yaml.

## v1.4.6

### Minor Changes

* Dont allow to change the value of `new_k8s` flag.

## v1.4.5

### Minor Changes

* Enable `new_k8s` flag by default.  This allows kube state metrics to be
  automatically detected, monitored, and displayed in Sysdig Monitor.

## v1.4.4

### Minor Changes

* Use the latest image from Agent (0.89.5) by default.
* Add `persistentvolumes` and `persistentvolumeclaims` to ClusterRole

## v1.4.3

### Minor Changes

* Provide an empty value to `sysdig.accessKey` key.

## v1.4.2

### Minor Changes

* Use the latest image from Agent (0.89.4) by default.
* Use latest shovel logo.

## v1.4.0

### Major Changes

* Use the latest image from Agent (0.89.0) by default.
* eBPF support added.

## v1.3.2

### Minor Changes

* Provide sane defaults resources for the Sysdig Agent.
* Use RollingUpdate strategy by default.

## v1.3.1

### Minor Changes

* Revert v1.2.1 changes. The agent automatically restarts when detects a change in the configuration.

## v1.3.0

### Major Changes

* Use a lower pod termination grace period for avoiding data gaps when pod fails to terminate quickly.
* Check running file on readinessProbe instead of relaying on logs.
* Mount /run and /var/run instead of Docker socket. It allows to access CRI / containerd socket.
* Avoid floating references for the image.

## v1.2.2

### Minor Changes

* Fix value in the agent tags example.

## v1.2.1

### Minor Changes

* Add checksum annotations to DaemonSet so that rolling upgrades works when a ConfigMap changes.

## v1.2.0

### Major Changes

* Allow to use other Docker registries (ECR, Quay ...) to download the Sysdig agent image.

## v1.1.0

### Major Changes

* Add support for uploading custom app checks for Sysdig agent

## v1.0.4

### Minor Changes

* Update README file with instructions for setting up the agent with On-Premise deployments

## v1.0.3

### Minor Changes

* Fixed error in ClusterRoleBinding's roleRef

## v1.0.2

### Minor Changes

* Fix readinessProbe in daemonset's pod spec

## v1.0.1

### Minor Changes

* Add dnsPolicy to daemonset. Its value is ClusterFirstWithHostNet
* Fix link target for retrieving Sysdig Monitor Access Key in README

## v1.0.0

### Major Changes

* Run Sysdig agent as [daemonset v2.0](https://github.com/draios/sysdig-cloud-scripts/blob/master/agent_deploy/kubernetes/sysdig-agent-daemonset-v2.yaml).
* Fix value's naming in order to follow [best practices](https://docs.helm.sh/chart_best_practices/#naming-conventions).
* Use a secure.enabled flag for enabling Sysdig Secure.
* Allow rbac resource creation or use existing serviceAccountName.
* Use required function for retrieving sysdig.accessKey. This ensures that key is present.
