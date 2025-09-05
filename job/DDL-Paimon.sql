CREATE CATALOG `paimon_ods` WITH (
  's3.access-key' = 'seatunnel_sink',
  's3.secret-key' = 'Abcd1234',
  's3.endpoint' = 'http://dev02:9000',
  'type' = 'paimon',
  'warehouse' = 's3://lakehouse/paimon_ods/',
  's3.path.style.access' = 'true'
  );
