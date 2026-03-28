Confluent for Kubernetes
==================================================================

Confluent for Kubernetes (CFK) is a cloud-native control plane for deploying and managing Confluent in your private cloud environment. It provides standard and simple interface to customize, deploy, and manage Confluent Platform through declarative API.

Confluent for Kubernetes runs on Kubernetes, the runtime for private cloud architectures.





    NOTE: Confluent for Kubernetes is the next generation of Confluent Operator. For Confluent Operator 1.x documentation, see [Confluent Operator 1](https://docs.confluent.io/operator/1.7.0/overview.html), or use the version picker to browse to a specific version of the documentation.

See [Introducing Confluent for Kubernetes](https://www.confluent.io/blog/confluent-for-kubernetes-offers-cloud-native-kafka-automation/) for an overview.

The following shows the high-level architecture of Confluent for Kubernetes and Confluent Platform in Kubernetes.

[![_images/co-architecture.png](https://docs.confluent.io/operator/current/_images/co-architecture.png)](_images/co-architecture.png)

Features
---------------------------------------------------

The following are summaries of the main, notable features of Confluent for Kubernetes.

#### Cloud Native Declarative API

*   Declarative Kubernetes-native API approach to configure, deploy, and manage Confluent Platform components (Apache KafkaB., Connect workers, ksqlDB, Schema Registry, Confluent Control Center) and resources (topics, rolebindings) through Infrastructure as Code (IaC).
*   Provides built-in automation for cloud-native security best practices:
    *   Complete granular RBAC, authentication and TLS network encryption
    *   Auto-generated certificates
    *   Support for credential management systems, such as Hashicorp Vault, to inject sensitive configurations in memory to Confluent deployments
*   Provides server properties, JVM, and Log4j configuration overrides for customization of all Confluent Platform components.

#### Upgrades

*   Provides automated rolling updates for configuration changes.
*   Provides automated rolling upgrades with no impact to Kafka availability.

#### Scaling

*   Provides single command, automated scaling and reliability checks of Confluent Platform.

#### Resiliency

*   Restores a Kafka pod with the same Kafka broker ID, configuration, and persistent storage volumes if a failure occurs.
*   Provides automated rack awareness to spread replicas of a partition across different racks (or zones), improving availability of Kafka brokers and limiting the risk of data loss.

#### Scheduling

*   Supports Kubernetes labels and annotations to provide useful context to DevOps teams and ecosystem tooling.
*   Supports Kubernetes tolerations and pod/node affinity for efficient resource utilization and pod placement.

#### Monitoring

*   Supports metrics aggregation using JMX/Jolokia.
*   Supports aggregated metrics export to Prometheus.

Licensing
-----------------------------------------------------

You can use Confluent for Kubernetes and Confluent Control Center for a 30-day trial period without a license key.

After 30 days, Confluent for Kubernetes and Control Center require a license key. Confluent issues keys to subscribers, along with providing [enterprise-level support](https://www.confluent.io/subscription/) for Confluent components and Confluent for Kubernetes.

If you are a subscriber, contact Confluent Support at [support@confluent.io](mailto:support@confluent.io) for more information.

See [Update Confluent Platform License](co-license.html#co-license-key) if you have received a key for Confluent for Kubernetes.

&copy; Copyright 2021 , Confluent, Inc. [Privacy Policy](https://www.confluent.io/confluent-privacy-statement/) | [Terms & Conditions](https://www.confluent.io/terms-of-use/). Apache, Apache Kafka, Kafka and the Kafka logo are trademarks of the [Apache Software Foundation](http://www.apache.org/). All other trademarks, servicemarks, and copyrights are the property of their respective owners.

[Please report any inaccuracies on this page or suggest an edit.](mailto:docs@confluent.io)

