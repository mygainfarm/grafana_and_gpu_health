#!/bin/bash

echo "Starting VastAI Complete Setup..."

# Function to check if a container is running
container_running() {
    sudo docker ps --format '{{.Names}}' | grep -q "^$1$"
}

# Stop existing monitoring containers if they exist
echo "Checking for existing containers..."
for container in vastai-complete grafana prometheus node-exporter cadvisor dcgm-exporter; do
    if container_running $container; then
        echo "Stopping existing $container container..."
        sudo docker stop $container || true
        sudo docker rm $container || true
    fi
done

# Create and enter directory
echo "Creating working directory..."
mkdir -p vastai-complete
cd vastai-complete

# Download docker-compose file
echo "Downloading docker-compose configuration..."
curl -O https://raw.githubusercontent.com/mygainfarm/grafana_and_gpu_health/master/docker-compose.yml

# Install NVIDIA Container Toolkit
echo "Installing NVIDIA Container Toolkit..."
if ! command -v nvidia-smi &> /dev/null; then
    echo "WARNING: nvidia-smi not found. Make sure NVIDIA drivers are installed."
fi

distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - || true
curl -fsSL https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | 
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# Configure Docker
echo "Configuring Docker NVIDIA runtime..."
sudo nvidia-ctk runtime configure --runtime=docker

echo "NOTE: Please restart the Docker service manually with: sudo systemctl restart docker"

# Create data directories
echo "Setting up data directories..."
sudo mkdir -p /prometheus-data /grafana-data
sudo chown -R 472:472 /grafana-data  # 472 is the Grafana user ID

# Pull and start containers
echo "Pulling latest container images..."
sudo docker compose pull

echo "Starting containers..."
sudo docker compose up -d

echo "\nSetup complete! You can access:"
echo "- Grafana at http://localhost:3000 (admin/vastai2023)"
echo "- Prometheus at http://localhost:9090"
echo "- Node Exporter metrics at http://localhost:9100/metrics"
echo "- cAdvisor at http://localhost:8080"
echo "- DCGM Exporter metrics at http://localhost:9400/metrics"
