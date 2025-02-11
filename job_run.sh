#!/bin/bash
#nohup ./bin/seatunnel.sh --config ./JOBS/kafka_starrocks/mysql_inventory_cp_json_DebeziumSrc02_my_orders__console.yaml > seatunnel.log 2>&1 &
job_config=$1
nohup ./bin/seatunnel.sh --config $job_config > seatunnel.log 2>&1 &

