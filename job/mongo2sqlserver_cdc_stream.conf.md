# https://seatunnel.apache.org/docs/2.3.10/connector-v2/source/MongoDB-CDC
# Check README.md for more details about how to use MongoDB source connector.


### MongoDB CDC Availability Settings
- MongoDB version: MongoDB version >= 4.0
- Cluster deployment: replica sets or sharded clusters.
- Storage Engine: WiredTiger Storage Engine.
- Permissions:changeStream and read
```java
use admin;
db.createRole(
    {
        role: "strole",
        privileges: [{
            resource: { db: "", collection: "" },
            actions: [
                "splitVector",
                "listDatabases",
                "listCollections",
                "collStats",
                "find",
                "changeStream" ]
        }],
        roles: [
            { role: 'read', db: 'config' }
        ]
    }
);

db.createUser(
  {
      user: 'stuser',
      pwd: 'stpw',
      roles: [
         { role: 'strole', db: 'admin' }
      ]
  }
);
```

### Sink table
```sql
CREATE TABLE company_dwh.DW_ETL.mongo_company_users_cdc (
  [_id] nvarchar(85) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
  name nvarchar(85) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
  age int NULL,
  [database] nvarchar(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
  [table] nvarchar(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
  op nvarchar(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
  ts_ms bigint NULL,
  delay bigint NULL,
  ingested_at datetime2 NULL,
  CONSTRAINT PK_mongo_company_users_cdc PRIMARY KEY (_id)
);

```