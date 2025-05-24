#!/bin/bash

set -e  # Exit on any error

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

# Restart Docker (with error handling)
echo "Restarting Docker service..."
if ! sudo systemctl restart docker; then
    echo "Failed to restart Docker. Waiting 10 seconds and trying again..."
    sleep 10
    sudo systemctl restart docker
fi

# Create data directories
echo "Setting up data directories..."
sudo mkdir -p /prometheus-data /grafana-data
sudo chown -R 472:472 /grafana-data  # 472 is the Grafana user ID

# Pull and start containers
echo "Pulling latest container images..."
sudo docker-compose pull

echo "Starting containers..."
sudo docker-compose up -d

# Verify containers are running
echo "Verifying container status..."
sleep 5  # Give containers time to start

FAILED_CONTAINERS=""
for container in vastai-complete grafana prometheus node-exporter cadvisor dcgm-exporter; do
    if ! container_running $container; then
        FAILED_CONTAINERS="$FAILED_CONTAINERS $container"
    fi
done

if [ -n "$FAILED_CONTAINERS" ]; then
    echo "WARNING: The following containers failed to start:$FAILED_CONTAINERS"
    echo "Check the logs with: docker logs <container-name>"
else
    echo "\nSetup complete! You can access:"
    echo "- Grafana at http://localhost:3000 (admin/vastai2023)"
    echo "- Prometheus at http://localhost:9090"
    echo "- Node Exporter metrics at http://localhost:9100/metrics"
    echo "- cAdvisor at http://localhost:8080"
    echo "- DCGM Exporter metrics at http://localhost:9400/metrics"
fi

# Show docker logs if there were failures
if [ -n "$FAILED_CONTAINERS" ]; then
    for container in $FAILED_CONTAINERS; do
        echo "\nLogs for $container:"
        sudo docker logs $container 2>&1 || true
    done
fi
