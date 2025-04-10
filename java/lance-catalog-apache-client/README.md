# lance-catalog-apache-client

Lance Catalog REST Specification

- API version: 0.0.1

- Generator version: 7.12.0

**Lance Catalog** is an OpenAPI specification on top of the storage-based Lance format.
It provides an integration point for catalog service like Apache Hive MetaStore (HMS), Apache Gravitino, etc.
to store and use Lance tables. To integrate, the catalog service implements a **Lance Catalog Adapter**,
which is a REST server that converts the Lance catalog requests to native requests against the catalog service.
Different tools can integrate with Lance Catalog using the generated OpenAPI clients in various languages,
and invoke operations in Lance Catalog to read, write and manage Lance tables in the integrated catalog services.



*Automatically generated by the [OpenAPI Generator](https://openapi-generator.tech)*

## Requirements

Building the API client library requires:

1. Java 1.8+
2. Maven/Gradle

## Installation

To install the API client library to your local Maven repository, simply execute:

```shell
mvn clean install
```

To deploy it to a remote Maven repository instead, configure the settings of the repository and execute:

```shell
mvn clean deploy
```

Refer to the [OSSRH Guide](http://central.sonatype.org/pages/ossrh-guide.html) for more information.

### Maven users

Add this dependency to your project's POM:

```xml
<dependency>
  <groupId>com.lancedb</groupId>
  <artifactId>lance-catalog-apache-client</artifactId>
  <version>0.0.1</version>
  <scope>compile</scope>
</dependency>
```

### Gradle users

Add this dependency to your project's build file:

```groovy
compile "com.lancedb:lance-catalog-apache-client:0.0.1"
```

### Others

At first generate the JAR by executing:

```shell
mvn clean package
```

Then manually install the following JARs:

- `target/lance-catalog-apache-client-0.0.1.jar`
- `target/lib/*.jar`

## Getting Started

Please follow the [installation](#installation) instruction and execute the following Java code:

```java

import com.lancedb.lance.catalog.client.apache.*;
import com.lancedb.lance.catalog.client.apache.auth.*;
import com.lancedb.lance.catalog.client.apache.model.*;
import com.lancedb.lance.catalog.client.apache.api.DefaultApi;

public class DefaultApiExample {

    public static void main(String[] args) {
        ApiClient defaultClient = Configuration.getDefaultApiClient();
        defaultClient.setBasePath("http://localhost:2333");
        
        DefaultApi apiInstance = new DefaultApi(defaultClient);
        try {
            apiInstance.ping();
        } catch (ApiException e) {
            System.err.println("Exception when calling DefaultApi#ping");
            System.err.println("Status code: " + e.getCode());
            System.err.println("Reason: " + e.getResponseBody());
            System.err.println("Response headers: " + e.getResponseHeaders());
            e.printStackTrace();
        }
    }
}

```

## Documentation for API Endpoints

All URIs are relative to *http://localhost:2333*

Class | Method | HTTP request | Description
------------ | ------------- | ------------- | -------------
*DefaultApi* | [**ping**](docs/DefaultApi.md#ping) | **GET** /v1/ping | Ping the server for use cases like health check


## Documentation for Models



<a id="documentation-for-authorization"></a>
## Documentation for Authorization

Endpoints do not require authorization.


## Recommendation

It's recommended to create an instance of `ApiClient` per thread in a multithreaded environment to avoid any potential issues.

## Author



