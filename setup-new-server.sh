#!/bin/bash

# Create directory and enter it
mkdir -p vastai-complete && cd vastai-complete

# Download docker-compose file
curl -O https://raw.githubusercontent.com/mygainfarm/grafana_and_gpu_health/master/docker-compose.yml

# Make sure NVIDIA runtime is installed
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - \
    && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
    && sudo apt-get update \
    && sudo apt-get install -y nvidia-container-toolkit

# Configure Docker to use NVIDIA runtime
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Create data directories with correct permissions
sudo mkdir -p /prometheus-data /grafana-data
sudo chown -R 472:472 /grafana-data  # 472 is the Grafana user ID

# Pull and start the containers
sudo docker-compose pull
sudo docker-compose up -d

echo "Setup complete! You can access:"
echo "- Grafana at http://localhost:3000 (admin/vastai2023)"
echo "- Prometheus at http://localhost:9090"
echo "- Node Exporter metrics at http://localhost:9100/metrics"
echo "- cAdvisor at http://localhost:8080"
echo "- DCGM Exporter metrics at http://localhost:9400/metrics"
