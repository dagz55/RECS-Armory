#!/bin/bash

# Function to check if a service is active
is_service_active() {
  local service_name=$1
  local status=$(systemctl is-active $service_name)
  echo "$status"
}

# Function to wait for a service to be active
wait_for_service() {
  local service_name=$1
  local max_attempts=10
  local attempt=1

  while [ $attempt -le $max_attempts ]; do
    status=$(is_service_active $service_name)
    if [ "$status" == "active" ]; then
      echo "Service $service_name is active."
      return 0
    fi
    echo "Waiting for service $service_name to be active (attempt $attempt/$max_attempts)..."
    sleep 5
    attempt=$((attempt + 1))
  done

  echo "Service $service_name did not become active within the maximum attempts."
  return 1
}

# Define the necessary services to wait for
services=("aks" "kubelet" "docker")

# Wait for each service to be active
for service in "${services[@]}"; do
  wait_for_service "$service"
  if [ $? -ne 0 ]; then
    echo "Failed to start the required services."
    exit 1
  fi
done

# Install Istio
/opt/istio/bin/istioctl install --set profile=demo -y

# Start the main process or command for the container
exec "$@"
