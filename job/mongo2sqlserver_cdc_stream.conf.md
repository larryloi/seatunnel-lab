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

### sample data
```json
{
  [
    "_id":{"$oid":"68d78a9f7791f67245e13396"},"name":"竈門炭治郎","age":15},
    "_id":{"$oid":"68d78aa67791f67245e13398"},"name":"竈門禰豆子","age":14},
    "_id":{"$oid":"68d78aae7791f67245e1339a"},"name":"我妻善逸","age":16},
    "_id":{"$oid":"68d78ab47791f67245e1339c"},"name":"嘴平伊之助","age":15},
    "_id":{"$oid":"68d78abf7791f67245e1339e"},"name":"炎柱 煉獄杏壽郎","age":19},
    "_id":{"$oid":"68d78ac97791f67245e133a0"},"name":"鬼舞辻無惨","age":1000},
    "_id":{"$oid":"68d78ad17791f67245e133a2"},"name":"繼國緣一","age":81},
    "_id":{"$oid":"68d78ad97791f67245e133a4"},"name":"霞柱 時透無一郎","age":14},
    "_id":{"$oid":"68d78ae07791f67245e133a6"},"name":"岩柱 悲鳴嶼行冥","age":27},
    "_id":{"$oid":"68d78ae67791f67245e133a8"},"name":"水柱 富岡義勇","age":19},
    "_id":{"$oid":"68d78aed7791f67245e133aa"},"name":"風柱 不死川實彌","age":24},
    "_id":{"$oid":"68d78af47791f67245e133ac"},"name":"蛇柱 伊黑小芭內","age":21},
    "_id":{"$oid":"68d78b087791f67245e133ae"},"name":"黑死牟","age":480},
    "_id":{"$oid":"68d78b107791f67245e133b0"},"name":"猗窩座","age":215},
    "_id":{"$oid":"68e0a1f913b0ed8be4b52723"},"name":"童磨","age":132}
  ]
}
```
