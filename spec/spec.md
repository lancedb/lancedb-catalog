# Lance Catalog Specification

**Lance Catalog** is an open specification on top of the storage-based Lance format
to standardize access to a collection of Lance tables.
It provides an integration point for catalog service like Apache Hive MetaStore (HMS), Apache Gravitino, etc.
to store and use Lance tables, as well as a guideline for how ML/AI tools and analytics compute engines
(will together be called _"tools"_ in this document) should access Lance tables in different systems.

There are in total 2 ways to store and access a collection of Lance tables: file system directory and REST protocol.

## Lance Directory

Lance directory is lightweight and simple for people to get started with creating and using Lance tables.

A directory can contain a list of Lance tables, where the name of each Lance table is the name of the subdirectory.
We call such a directory **Namespace Directory**, and the subdirectories **Table Directory**.
Consider the following example directory layout:

```
.
└── /my/dir1/
    ├── table1/
    │   ├── data/
    │   │   ├── 0aa36d91-8293-406b-958c-faf9e7547938.lance
    │   │   └── ed7af55d-b064-4442-bcb5-47b524e98d0e.lance
    │   ├── _versions/
    │   │   └── 9223372036854775707.manifest
    │   ├── _indices/
    │   │   └── 85814508-ed9a-41f2-b939-2050bb7a0ed5-fts/
    │   │       └── index.idx
    │   └── _deletions/
    │       └── 75c69434-cde5-4c80-9fe1-e79a6d952fbf.bin
    ├── table2
    └── table3
```

This describes a namespace directory `/my/dir1/` that contains tables `table1`, `table2`, `table3`
sitting at table directories `/my/dirs/table1`, `/my/dirs/table2`, `/my/dirs/table3` respectively.

### Namespace Directory Path

There are 3 ways to specify a directory path:

1. **URI**: a URI that follows the [RFC 3986 specification](https://datatracker.ietf.org/doc/html/rfc3986), e.g. `s3://mu-bucket/prefix`.
2. **Absolute POSIX file system path**: an absolute file path in a POSIX standard file system, e.g. `/my/dir`.
2. **Relative POSIX file system path**: a relative file path in a POSIX standard file system, e.g. `my/dir2`.
   The absolute path should be derived by using the current directory of the running process. 

### Table Directory Ignore File

`.lanceignore` is a file in the namespace directory that describes the directories that 
should not be treated as a table directory.  
It is a text file where each new line describes a new directory name.
Consider the following example directory layout:

```
.
└── /my/dir2/
    ├── table1
    ├── table2
    ├── table3
    ├── .git
    ├── build
    └── .lanceignore
```

We can have the following contents in `.lanceignore` in order to ignore the directories
that are not a table directory:

```
.git
build
```

## Lance REST Protocol

In an enterprise environment, typically there is a requirement to store tables in a catalog service 
such as Apache Hive MetaStore, Apache Gravitino, Unity Catalog, etc. 
for more advanced governance features around access control, auditing, lineage tracking, etc.

Lance REST Protocol is a standardized OpenAPI protocol for any catalog service to implement
in order to read, write and manage Lance tables in the catalog.
The detailed OpenAPI specification content can be found in [catalog.yaml](./catalog.yaml).

### Communication Modes

There are 2 communication modes supported by the Lance REST Protocol:

#### Remote Server Mode

Any REST HTTP server that implements the Lance REST Protocol is called a **Lance REST Server**.
Tools contact such server through configurations like its URL endpoint.

If the main purpose of this server is to be a proxy on top of an existing catalog service,
converting back and forth between Lance REST API models and native API models of the catalog service,
then this server is called a **Lance REST Adapter**.

#### Local Adapter Mode

Some Lance REST adapters do not serve any additional propose outside request response translation
between the Lance REST APIs and the target catalog service APIs.
In that case, it is possible for a tool to avoid running the adapter and making the remote network calls.
Instead, the tool can directly execute the adapter locally to contact the catalog service.

### Relationship with Table Directory

This section defines the possible relationships between a Lance table definition in a catalog and
the Lance table sitting in a table directory in some storage system.
A catalog should choose to support one or multiple types of relationships when integrating with Lance REST Protocol.

#### Catalog Managed

A catalog managed Lance table is a table that is fully managed by a catalog.
The catalog must contain information about the latest version of the Lance table,
and any modifications to the table must happen through the catalog.
If a user directly modifies the underlying table in the storage bypassing catalog,
the catalog must not reflect the change to the catalog users for this table.

This mode ensures the catalog service is aware of all activities in the table,
and can thus fully enforce any governance and management features for the table. 

#### Storage Managed

A storage managed Lance table is a table that is fully managed by the storage with a metadata definition in catalog.
The catalog only contains information about the table directory location.
It is expected that a tool find the latest version of the Lance table based on the contents 
in the table directory according to the Lance format specification,
A modification to the table can happen either directly against the storage,
or happen as a request to the catalog, where the catalog is responsible to apply the corresponding
change to the underlying storage according to the ance format specification.

This mode is more flexible for real world ML/AI workflows 
but the catalog loses full visibility and control over the actions performed against the table,
so it will be harder to enforce any governance and management features for the table.

## Tool Connection

There are 2 ways for a tool to connect to a collection of Lance tables:  

### Namespace Connection

Some tools connect directly to the object that contains a collection of tables.
Such connection is called a **Namespace Connection**.

A connection string for the namespace connection should be one of:
- a path following the [Lance Namespace Directory Path specification](#namespace-directory-path), e.g. `/my/dir`.
- a string that follows the pattern `ns://{namespace_name}`, e.g. `ns://ns1`. This pattern requires additional catalog configurations to enable the connection. 

For example in LanceDB:

```python
# connect to a Lance directory
dir = lancedb.connect("/my/dir")
tb1 = dir.open_table("tb1")

# connect to a Lance REST server
ns1 = lancedb.connect("ns://ns1", catalog_configs={"rest.uri": "https://mylancecatalog.com"})
tb2 = ns1.open_table("tb2")

# connect to a Lance REST adapter locally
ns2 = lancedb.connect("ns://ns2", catalog_configs={"adapter": "hms", "hms.uri": "thrift://localhost:10000"})
tb3 = ns2.open_table("tb3")
```

### Catalog Connection

Some tools connect to one higher level than the namespace, 
offering the functionalities to manipulate the namespaces in addition to the Lance tables in the namespaces.
Such connection is called a **Catalog Connection**.

#### Supporting Both Directory and REST Protocol

When the tool uses a catalog connection, the tool can choose to support just one access pattern or both.
To support both, the tool must first call the `GetConfig` REST API when initializing the catalog connection,
which will return a configuration `dir_namespace_prefix` (default to `dir:`).

Based on the prefix value, the tool will decide if a user is accessing a Lance directory,
or accessing a namespace through the REST protocol.
If the namespace name starts with the `dir_namespace_prefix`, it should be treated as a Lance directory.
Otherwise if should be treated as a namespace through the REST protocol.

For example, consider the following Apache Spark configuration:

```shell
spark-shell \
  --conf spark.sql.catalog.lance=com.lancedb.lance.spark.LanceCatalog \
  --conf spark.sql.catalog.lance.rest.uri=https://my.lance.catalog.com \
  --conf spark.sql.defaultCatalog=lance
```

When running Spark SQL, the following are expected:

```sql
-- show tables in Lance Directory /my/dir
SHOW TABLES IN `dir:/my/dir`
     
-- show tables in namespace ns1 in https://my.lance.catalog.com
SHOW TABLES IN `ns1`
```







