FROM nvidia/cuda:11.8.0-base-ubuntu20.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (required for some dashboards)
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Docker (for cAdvisor)
RUN curl -fsSL https://get.docker.com -o get-docker.sh \
    && sh get-docker.sh \
    && rm get-docker.sh

# Copy monitoring stack
COPY vastai-monitoring /opt/vastai-monitoring

# Copy GPU health check
COPY gpu-health-check /opt/gpu-health-check

# Install Python requirements for GPU health check
RUN pip3 install -r /opt/gpu-health-check/requirements.txt

# Install DCGM
RUN curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb -o cuda-keyring.deb \
    && dpkg -i cuda-keyring.deb \
    && apt-get update \
    && apt-get install -y datacenter-gpu-manager \
    && rm -rf /var/lib/apt/lists/* cuda-keyring.deb

# Create directory for persistent storage
RUN mkdir -p /prometheus-data /grafana-data

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose ports
EXPOSE 3000 9090 9100 8080 9400

# Set environment variables
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

ENTRYPOINT ["/entrypoint.sh"]
