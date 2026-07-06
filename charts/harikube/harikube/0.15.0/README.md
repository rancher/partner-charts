# HariKube

## What is this?

Normally, Kubernetes uses a database called ETCD. [Kine](https://github.com/k3s-io/kine) (the origin of this project) is a tool that allows Kubernetes to use other databases (like SQLite, MySQL or PostgreSQL) instead.

This specific version of Kine is unique because it handles filtering adirectly at the database level, which can make your cluster much faster and more efficient.

## Why this fork exists?

Both ETCD and Kine are limited by Kubernetes API server itself and how it filters data. API server manages an O(n) cache in memory, and filters data at client side, because both ETCD and Kine are lacking on data filtering. The only real option is vertical scaling of all (API, ETCD, Kine). An average cluster dies at 50-100k records. Of course, you can add more ram, more iops, but these are just postponing the problem.

By changing a few lines of Kubernetes and a few lines of Kine, this project is able to send filtering to the database level. With these changes it is able to disable watch cache in Kubernetes API, and consumes O(1) memory during operation.

Here are some benchmark results on Ultra 7 165H 18 Core 4G, single VM ran everything including the k6 benchmark itself. 120 vus, each vu created a custom resource (6 different type) and read it back via label selector:

- Vanilla Kubernetes with 3 node ETCD cluster:

```
checks_succeeded...: 100.00% 51236 out of 51236
checks_failed......: 0.00% 0 out of 51236
http_req_duration..............: avg=799.54ms min=3.87ms med=82.39ms max=4.17s p(90)=2.47s p(95)=2.82s
http_req_failed................: 0.00% 0 out of 51236
http_reqs......................: 51236 24.976013/s

time="2026-02-14T19:07:26Z" level=error msg="test run was aborted because k6 received a 'interrupt' signal" make: *** [Makefile:589: k6s-start] Error 105

OOM Killed, thanks API server
```

- HariKube OSS with Postgres:

```
checks_succeeded...: 100.00% 101772 out of 101772
checks_failed......: 0.00%   0 out of 101772
http_req_duration..............: avg=708.33ms min=6.4ms    med=300.67ms max=6.2s  p(90)=1.99s p(95)=2.48s
http_req_failed................: 0.00%  0 out of 101772
http_reqs......................: 101772 28.188433/s
```

## The numbers are talking for themselves

| Metric | HariKube OSS | Vanilla K8s |
| - | - | - |
| Throughput | 28 req/s ✅ | 25 req/s ❌ |
| Success Rate | 100% ✅ | 100% (OOM) ❌ |
| Latency average | 708ms ✅ | 799ms ❌ |
| Latency p95 | 2480ms ✅ | 2820ms ❌ |
| Latency p90 | 1990ms ✅ | 2470ms ❌ |
| Test Duration | 60m ✅ | ~34m (OOM) ❌ |
| Stability | Completed ✅ | KILLED ❌ |
| Objects Handled | 50k ✅ | ~26k (OOM) ❌ |

### HariKube on steroids with 6 Postgres

```
checks_succeeded...: 100.00% 429180 out of 429180
checks_failed......: 0.00% 0 out of 429180
http_req_duration..............: avg=167.17ms min=7.75ms med=71.06ms max=3.71s p(90)=398ms p(95)=543.76ms
http_req_failed................: 0.00% 0 out of 429180
http_reqs......................: 429180 119.106435/s
```

| Metric | HariKube AE | Vanilla K8s | Gain |
| - | - | - | - |
| Throughput | 119 req/s ✅ | 25 req/s ❌ | 4.8x |
| Success Rate | 100% ✅ | 100% (then OOM) ❌ | not comparable |
| Latency average | 167ms ✅ | 799ms ❌ | 4.8x |
| Latency p95 | 543ms ✅ | 2820ms ❌ | 5.2x |
| Latency p90 | 398ms ✅ | 2470ms ❌ | 6.2x |
| Test Duration | 60m ✅ | ~34m (OOM) ❌ | not comparable |
| Stability | Completed ✅ | KILLED ❌ | not comparable |
| Objects Handled | 200k+ ✅ | ~26k (crashed) ❌ | 4x |

Open-Source edition is designed to interface with a single backend database instance at a time, which can become a performance bottleneck as your cluster grows. To address this, our business editions introduce various data routing capabilities. This allows you to distribute workloads across multiple database backends simultaneously, ensuring horizontal scalability for even the most demanding environments. Check out which [edition](https://harikube.info/editions/) fit's to your use-case.

## Installation

For installation details please follow release notes.

## 🤝 Contribution Guide

We welcome and encourage contributions from the community! Whether it's a bug fix, a new feature, or an improvement to the documentation, your help is greatly appreciated.

Before you get started, please take a moment to review our guidelines:

- Read the Documentation: Familiarize yourself with the framework's architecture and existing features.
- Open an Issue: For any significant changes or new features, please open an issue first to discuss the idea. This helps prevent duplicated work and ensures alignment with the project's goals.
- Fork the Repository: Fork the repository to your own GitHub account.
- Create a Branch: Create a new branch for your feature or bug fix: git checkout -b feature-my-awesome-feature.
- Commit Your Changes: Make your changes and commit them with a clear and descriptive message.
- Submit a Pull Request: Push your branch to your forked repository and open a pull request against the main branch of this repository. Please provide a clear description of your changes in the PR.

We are committed to providing a friendly, safe, and welcoming environment for all, regardless of background or experience. We are following Kubernetes Please see them [Code of Conduct](https://kubernetes.io/community/code-of-conduct/) for more details.

## 🙏 Share Feedback and Report Issues

Your feedback is invaluable in helping us improve this operator. If you encounter any issues, have a suggestion for a new feature, or simply want to share your experience, we want to hear from you!

- Report Bugs: If you find a bug, please open a [GitHub Issue](https://github.com/HariKube/harikube-helm-charts/issues). Include as much detail as possible, such as steps to reproduce the bug, expected behavior, and your environment (e.g., Kubernetes version, Go version).
- Request a Feature: If you have an idea for a new feature, open a [GitHub Issue](https://github.com/HariKube/harikube-helm-charts/issues) and use the `enhancement` label. Describe the use case and how the new feature would benefit the community.
- Ask a Question: For general questions or discussions, please use the [GitHub Discussions](https://github.com/HariKube/harikube-helm-charts/discussions).
