#!/bin/bash

# Start DCGM
systemctl start nvidia-dcgm

# Start Prometheus
/opt/vastai-monitoring/prometheus/prometheus \
    --config.file=/opt/vastai-monitoring/prometheus/prometheus.yml \
    --storage.tsdb.path=/prometheus-data \
    --storage.tsdb.retention.time=60d \
    --web.console.libraries=/opt/vastai-monitoring/prometheus/console_libraries \
    --web.console.templates=/opt/vastai-monitoring/prometheus/consoles &

# Start Node Exporter
/opt/vastai-monitoring/node_exporter/node_exporter &

# Start cAdvisor
/opt/vastai-monitoring/cadvisor/cadvisor \
    --port=8080 \
    --storage_driver=prometheus \
    --storage_driver_db=cadvisor \
    --storage_driver_host=localhost:9090 &

# Start DCGM Exporter
/opt/vastai-monitoring/dcgm-exporter/dcgm-exporter &

# Start Grafana
/opt/vastai-monitoring/grafana/bin/grafana-server \
    --config=/opt/vastai-monitoring/grafana/conf/defaults.ini \
    --homepath=/opt/vastai-monitoring/grafana \
    --packaging=docker &

# Start GPU Health Check
cd /opt/gpu-health-check && python3 health_check.py &

# Keep container running
tail -f /dev/null
