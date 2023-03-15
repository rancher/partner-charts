Chronicle records provenance information of any physical or digital asset on a distributed ledger.

- Chronicle is available with Hyperledger Sawtooth as its default backing ledger.
- Chronicle is built on the established W3C PROV Ontology standard; it uses the lightweight JSON-LD linked data format, and the data query language GraphQL.
- Chronicle is easily adaptable to enable users to model, capture, and query provenance information pertinent to their industry, application and use case.

You can find example domains and further instructions at https://examples.btp.works

## *Important*

*As Chronicle uses Sawtooth as it backing ledger, a minimum of 4 nodes is required for deployment.*
*This helm chart will deploy and configure a 4 node Sawtooth network on your target cluster, so less than 4 nodes will result in the deployment failing.*
