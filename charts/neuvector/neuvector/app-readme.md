### Run-Time Protection Without Compromise

NeuVector delivers a complete run-time security solution with container process/file system protection and vulnerability scanning combined with the only true Layer 7 container firewall. Protect sensitive data with a complete container security platform.

NeuVector integrates tightly with Rancher and Kubernetes to extend the built-in security features for applications that require defense in depth. Security features include:

+ Build phase vulnerability scanning with Jenkins plug-in and registry scanning
+ Admission control to prevent vulnerable or unauthorized image deployments using Kubernetes admission control webhooks
+ Complete run-time scanning with network, process, and file system monitoring and protection
+ The industry's only layer 7 container firewall for multi-protocol threat detection and automated segmentation
+ Advanced network controls including DLP detection, service mesh integration, connection blocking and packet captures
+ Run-time vulnerability scanning and CIS benchmarks

Additional Notes:
+ Configure correct container runtime and runtime path under container runtime. Enable only one runtime.
+ Neuvector deployed from Partners chart repository do not support Single Sign On from Rancher Manager. Please deploy Neuvector from Rancher charts for Single Sign On to work.
+ For deploying on hardened RKE2 and K3s clusters, enable PSP and set user id from other configuration for Manager, Scanner and Updater deployments. User id can be any number other than 0.
+ For deploying on hardened RKE cluster, enable PSP from other configuration.

Migrating to Feature Chart Notes:
+ To take advantage of NeuVector integration in Rancher, please migrate to Feature Chart.
+ NeuVector integration in Rancher is available from Rancher version v2.6.5.
+ NeuVector will be deployed in cattle-neuvector-system namespace.
+ Migration will upgrade NeuVector version to 5.*.* if Neuvector version 4.*.* in the current deployment.
+ PVC should be used in existing NeuVector deployment to retain NeuVector configuration after migration.
+ Follow below steps to Migrate to Feature Chart and retain NeuVector configuration.
  + Export configuration from NeuVector UI -> Settings -> Configuration -> Export -> All -> Submit.
      + import configuartion if PV data is not available to restore in new deployment.
  + Delete NeuVector partner chart.
  + Make sure neuvector-data PVC is deleted and PV is available for reusing.
  + Deploy Neuvector from Rancher Feature chart with PVC enabled.
  + Lauch Neuvector from Rancher Manager to do SSO to NeuVector UI. 
  + NeuVector configuration data should be retained if PVC is correctly bound to PV. 
