# cf-runtime helm chart
To install the [Codefresh Runner](https://codefresh.io/docs/docs/administration/codefresh-runner/) using helm you need to follow these steps:

1. Download the Codefresh CLI and authenticate it with your Codefresh account. Click [here](https://codefresh-io.github.io/cli/getting-started/) for more detailed instructions.
2. Install [yq](https://github.com/mikefarah/yq)
3. Run the following command on your local machine to create all of the necessary enitites in Codefresh:
   
    ```
    codefresh runner init --generate-helm-values-file
    ```

   * This will not install anything on your cluster, except for running cluster acceptance tests, which may be skipped using the `--skip-cluster-test` option).
   * This command will also generate a `generated_values.yaml` file in your current directory, which you will need to provide to the `helm install` command later.
4. Download the default `values.yaml` file in the same path as the `generated_values.yaml` file. 
   ```
   curl -L https://raw.githubusercontent.com/codefresh-io/venona/release-1.0/charts/cf-runtime/values.yaml > values.yaml
   ```
5. Convert `generated_values.yaml` to yaml.
   ```
   yq eval -P generated_values.yaml > generated_values_converted.yaml
   ```
6. [Merge](https://mikefarah.gitbook.io/yq/operators/reduce#merge-all-yaml-files-together) the two files together using `yq`
   > **Note:** The order of the files being merged together is important. Please make sure the generated values file is in second place.
   ```
   yq eval-all '. as $item ireduce ({}; . * $item)' values.yaml generated_values_converted.yaml > merged-values.yaml
   ```
7. Select a namespace to install to. If it's a new namespace it will need to be created before using the wizard (e.g. a `codefresh` namespace). Click next.
8. On the following screen: Select all text and replace with the newly created `merged-values.yaml` file and click on **Install**.
