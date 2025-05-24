# VastAI Complete Monitoring

This Docker container combines the VastAI monitoring stack with GPU health checking capabilities.

## Features

- Prometheus monitoring
- Grafana dashboards
- Node Exporter for system metrics
- cAdvisor for container metrics
- DCGM Exporter for GPU metrics
- GPU Health Check

## Quick Start

```bash
# Pull and run the container
docker-compose up -d

# Access the services:
- Grafana: http://localhost:3000 (admin/vastai2023)
- Prometheus: http://localhost:9090
- Node Exporter: http://localhost:9100
- cAdvisor: http://localhost:8080
- DCGM Exporter: http://localhost:9400
```

## Data Retention

- Metrics are stored for 60 days
- Storage is configured with 50GB capacity

## Dashboards

- System Overview
- Container Metrics
- GPU Metrics
- Process Monitoring
- GPU Health Status

## Environment Variables

- `NVIDIA_VISIBLE_DEVICES=all`: Expose all GPUs to the container
- `NVIDIA_DRIVER_CAPABILITIES=all`: Enable all NVIDIA driver capabilities

## Prerequisites

- Docker
- NVIDIA Container Runtime
- NVIDIA Drivers installed on the host

## Building from Source

```bash
git clone https://github.com/yourusername/vastai-complete.git
cd vastai-complete
docker-compose up -d
```
