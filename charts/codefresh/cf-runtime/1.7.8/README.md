# cf-runtime helm chart
To install the [Codefresh Runner](https://codefresh.io/docs/docs/administration/codefresh-runner/) using helm you need to follow these steps:

1. Download the Codefresh CLI and authenticate it with your Codefresh account. Click [here](https://codefresh-io.github.io/cli/getting-started/) for more detailed instructions.
2. Run the following command to create all of the necessary enitites in Codefresh:
   
    ```
    codefresh runner init --generate-helm-values-file
    ```

   * This will not install anything on your cluster, except for running cluster acceptance tests, which may be skipped using the `--skip-cluster-test` option).
   * This command will also generate a `generated_values.yaml` file in your current directory, which you will need to provide to the `helm install` command later.
3. Now run the following to complete the installation: 

    ```
    helm repo add cf-runtime https://chartmuseum.codefresh.io/cf-runtime
    
    helm install cf-runtime cf-runtime/cf-runtime -f ./generated_values.yaml --create-namespace --namespace codefresh
    ```
4. At this point you should have a working Codefresh Runner. You can verify the installation by running: 
    ```
    codefresh runner execute-test-pipeline --runtime-name <runtime-name>
    ```
