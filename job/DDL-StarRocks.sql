

CREATE TABLE `orders_demo00_from_kafka` (
  `id` bigint(20) NOT NULL COMMENT "",
  `order_id` varchar(36) NOT NULL COMMENT "",
  `supplier_id` int(11) NOT NULL COMMENT "",
  `item_id` int(11) NOT NULL COMMENT "",
  `status` varchar(20) NOT NULL COMMENT "",
  `qty` int(11) NOT NULL COMMENT "",
  `net_price` int(11) NOT NULL COMMENT "",
  `issued_at` datetime NOT NULL COMMENT "",
  `completed_at` datetime NOT NULL COMMENT "",
  `spec` json NULL COMMENT "",
  `created_at` datetime NOT NULL COMMENT "",
  `updated_at` datetime NOT NULL COMMENT "",
  `ingested_at` datetime NOT NULL COMMENT "",
  `__table` varchar(128) NULL COMMENT "",
  `__source_ts_ms` datetime NULL COMMENT "",
  `__ts_ms` datetime NULL COMMENT "",
  `__deleted` boolean NULL COMMENT ""
) ENGINE=OLAP 
PRIMARY KEY(`id`)
COMMENT "OLAP"
DISTRIBUTED BY HASH(`id`) BUCKETS 10 
PROPERTIES (
"replication_num" = "1",
"in_memory" = "false",
"enable_persistent_index" = "true",
"replicated_storage" = "true",
"compression" = "LZ4"
);


CREATE TABLE `orders_demo00_from_kafka1` (
  `id` bigint(20) NOT NULL COMMENT "",
  `order_id` varchar(36) NOT NULL COMMENT "",
  `supplier_id` int(11) NOT NULL COMMENT "",
  `item_id` int(11) NOT NULL COMMENT "",
  `status` varchar(20) NOT NULL COMMENT "",
  `qty` int(11) NOT NULL COMMENT "",
  `net_price` int(11) NOT NULL COMMENT "",
  `issued_at` datetime NOT NULL COMMENT "",
  `completed_at` datetime NOT NULL COMMENT "",
  `spec` json NULL COMMENT "",
  `created_at` datetime NOT NULL COMMENT "",
  `updated_at` datetime NOT NULL COMMENT ""
) ENGINE=OLAP 
PRIMARY KEY(`id`)
COMMENT "OLAP"
DISTRIBUTED BY HASH(`id`) BUCKETS 10 
PROPERTIES (
"replication_num" = "1",
"in_memory" = "false",
"enable_persistent_index" = "true",
"replicated_storage" = "true",
"compression" = "LZ4"
);
