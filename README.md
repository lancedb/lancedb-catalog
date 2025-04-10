# Lance Catalog

**Lance Catalog** is an OpenAPI specification on top of the storage-based Lance format.
It provides an integration point for catalog service like Apache Hive MetaStore (HMS), Apache Gravitino, etc. 
to store and use Lance tables. To integrate, the catalog service implements a **Lance Catalog Adapter**, 
which is a REST server that converts the Lance catalog requests to native requests against the catalog service.
Different tools can integrate with Lance Catalog using the generated OpenAPI clients in various languages,
and invoke operations in Lance Catalog to read, write and manage Lance tables in the integrated catalog services.

## Repository structure

| Directory                                      | Description                                    |
|------------------------------------------------|------------------------------------------------|
| [spec](./spec)                                 | Lance Catalog OpenAPI specification            |
| [rust](./rust/lance-catalog-reqwest-client)            | Generated Rust client for Lance Catalog        |
| [java](./java/lance-catalog-apache-client)     | Generated Apache HTTP client for Lance Catalog |
| [java](./java/lance-catalog-springboot-server) | Generated SpringBoot server for Lance          |