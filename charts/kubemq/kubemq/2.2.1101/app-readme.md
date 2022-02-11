# Introduction

## What is KubeMQ?

KubeMQ is a Kubernetes Message Queue Broker.

Enterprise-grade message broker and message queue, scalable, high available and secured. A Kubernetes native solution in a lightweight container, deployed in just one minute.

## Main Features

* All-batteries included Messaging Queue Broker for Kubernetes environment
* Deployed with Operator for full life cycle operation
* Blazing fast \(written in Go\), small and lightweight Docker container
* Asynchronous and Synchronous messaging with support for  `At Most Once Delivery` and `At Least Once Delivery` models
* Supports durable FIFO based Queue, Publish-Subscribe Events, Publish-Subscribe with Persistence \(Events Store\), RPC Command and Query messaging patterns
* Supports gRPC, Rest and WebSocket Transport protocols with TLS support \(both RPC and Stream modes\)
* Supports Access control Authorization and Authentication
* Supports message masticating and smart routing
* No Message broker configuration needed \(i.e., queues, exchanges\)
* .Net, Java, Python, Go and NodeJS SDKs
* Monitoring Dashboard

## Kubernetes Ready

* **Kubernetes** - KubeMQ can be deployed on any Kubernetes cluster as stateful set.
* **MicroK8s** - [Canonical's MicroK8s](https://microk8s.io/)
* **K3s** - [Rancher's](https://k3s.io/)

## Messaging Patterns

### Queues

KubeMQ supports distributed durable FIFO based queues with the following core features:

* **Guaranteed Delivery** - At-least-once delivery and most messages are delivered exactly once.
* **Single and Batch Messages Send and Receive** - Single and multiple messages in one call
* **RPC and Stream Flows** - RPC flow allows an insert and pull messages in one call. Stream flow allows single message consuming in transactional way
* **Message Policy** - Each message can be configured with expiration and delay timers. In addition, each message can specify a dead-letter queue for unprocessed messages attempts
* **Long Polling** - Consumers can wait until a message available in the queue to consume
* **Peak Messages** - Consumers can peek into a queue without removing them from the queue
* **Ack All Queue Messages** - Any client can mark all the messages in a queue as discarded and will not be available anymore to consume
* **Visibility timers** - Consumers can pull a message from the queue and set a timer which will cause the message not be visible to other consumers. This timer can be extended as needed.
* **Resend Messages** - Consumers can send back a message they pulled to a new queue or send a modified message to the same queue for further processing.

### Pub/Sub

KubeMQ supports Publish-Subscribe \(a.k.a Pub/Sub\) messages patterns with the following core features:

* **Events** -  An asynchronous real-time Pub/Sub pattern.
* **Events Store** -An asynchronous Pub/Sub pattern with persistence.
* **Grouping** - Load balancing of events between subscribers

### RPC

KubeMQ supports CQRS based RPC flows with the following core features:

* **Commands** -  A synchronous two ways Command pattern for CQRS types of system architecture.
* **Query** - A synchronous two ways Query pattern for CQRS types of system architecture.
* **Response** - An answer for a Query type RPC call
* **Timeout** - Timeout interval is set for each RPC call. Once no response is received within the Timeout interval, RPC call return an error
* **Grouping** - Load balancing of RPC calls between receivers
* **Caching** - RPC response can be cached for future requests without the need to process again by a receiver

## Interfaces

* **gRPC** - High performance RPC and streaming framework that can run in any environment, Open source and Cloud Native.
* **Rest** - Restful Api with WebSocket support for bi-directional streaming.

## SDK

* **C\#** - C\# SDK based on gRPC
* **Java** - Java SDK based on gRPC
* **Go** - Go SDK based on gRPC
* **Python** - Python SDK based on gRPC
* **cURL** - cURL SDK based on Rest
* **Node** - Node SDK based on gRPC and Rest
* **PHP** - PHP SDK based on Rest
* **Ruby** - Ruby SDK based on Rest
* **jQuery** jQuery SDK based Rest


