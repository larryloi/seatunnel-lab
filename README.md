# seatunnel-study

### **Use cases**
|Source Extraction|Transformation|Sink Destination|Status/Result|Reference
|--|--|--|--|--|
|SQL server CDC table|None|Starrocks|<mark style="color: green"> **Done. correctly** </span>| ./JOBS/mssql_starrocks/inventory.INV.orders__ODS.yaml
|SQL server CDC table + Data Model Change|None|Starrocks|None||
|SQL server CDC table|None|Starrocks|...||
|MySQL CDC table|None|Starrocks|<mark style="color: green"> **Done. correctly** </span>| ./JOBS/mysql_starrocks/inventory.my_orders__ODS.yaml