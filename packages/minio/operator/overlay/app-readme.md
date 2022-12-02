# MinIO Operator

MinIO is a Kubernetes-native high performance object store with an S3-compatible API. The
MinIO Kubernetes Operator supports deploying MinIO Tenants onto private and public
cloud infrastructures ("Hybrid" Cloud).

## Procedure

### 1) Verify installation the MinIO Operator
Run the following command to verify the status of the Operator:

```sh
kubectl get pods -n minio-operator
```

The output resembles the following:

```sh
NAME                              READY   STATUS    RESTARTS   AGE
console-6b6cf8946c-9cj25          1/1     Running   0          99s
minio-operator-69fd675557-lsrqg   1/1     Running   0          99s
```

The `console-*` pod runs the MinIO Operator Console, a graphical user
interface for creating and managing MinIO Tenants.

The `minio-operator-*` pod runs the MinIO Operator itself.

### 2) Access the Operator Console

Get the service-account token to access the UI:

```sh
kubectl -n minio-operator  get secret $(kubectl -n minio-operator get serviceaccount console-sa -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode 
```

Run the following command to create a local proxy to the MinIO Operator
Console:

```sh
kubectl -n minio-operator port-forward svc/console 9090
```

Open your browser to http://localhost:9090 and use the JWT token to log in
to the Operator Console.



Click **+ Create Tenant** to open the Tenant Creation workflow.

### 3) Build the Tenant Configuration

The Operator Console **Create New Tenant** walkthrough builds out
a MinIO Tenant. The following list describes the basic configuration sections.

- **Name** - Specify the *Name*, *Namespace*, and *Storage Class* for the new Tenant.

  The *Storage Class* must correspond to a [Storage Class](#default-storage-class) that corresponds to [Local Persistent Volumes](#local-persistent-volumes) that can support the MinIO Tenant.

  The *Namespace* must correspond to an existing [Namespace](#minio-tenant-namespace) that does *not* contain any other MinIO Tenant.

  Enable *Advanced Mode* to access additional advanced configuration options.

- **Tenant Size** - Specify the *Number of Servers*, *Number of Drives per Server*, and *Total Size* of the Tenant.

  The *Resource Allocation* section summarizes the Tenant configuration
  based on the inputs above.

  Additional configuration inputs may be visible if *Advanced Mode* was enabled
  in the previous step.

- **Preview Configuration** - summarizes the details of the new Tenant.

After configuring the Tenant to your requirements, click **Create** to create the new tenant.

The Operator Console displays credentials for connecting to the MinIO Tenant. You *must* download and secure these credentials at this stage. You cannot trivially retrieve these credentials later.

You can monitor Tenant creation from the Operator Console.