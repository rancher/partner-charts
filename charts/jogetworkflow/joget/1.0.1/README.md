# Joget DX

[Joget DX](https://www.joget.com) is an open source no-code / low-code application platform that combines the best of rapid application development, business process automation and workflow management. Joget empowers business users, non-coders or coders with a single platform to easily build, deliver, monitor and maintain enterprise applications.

# Introduction

This Helm chart bootstraps a Joget DX deployment on a Kubernetes cluster using the Helm package manager.

# Prerequisites

- Kubernetes 1.22+
- ReadWriteMany volumes for deployment scaling
- Supported database (MySQL, PostgreSQL, Oracle, MS SQL Server) 

# Installation

## Add Joget Repo
```sh
helm repo add joget https://dev.joget.org/helm
```

## Install Chart with Release Name `Joget`

1. Create the flux namespace:

   ```sh
   kubectl create namespace joget
   ```

1. Run helm install:

   ```sh
   helm install -i joget joget/joget --namespace joget
   ```

1. Perform [database setup](https://dev.joget.org/community/display/DX8/Setting+Up+Database)

# Resources

- [Get Started](https://dev.joget.org/community/display/DX8/Get+Started)

