#!/bin/bash
set -e

echo "Deploying React App using Docker Compose"

# Stop and remove existing containers, networks, volumes, and orphans
docker compose down --remove-orphans || true

# Remove any leftover container manually (force remove if it exists)
docker rm -f react-appcontainer 2>/dev/null || true

# Pull the latest images from Docker Hub
docker compose pull

# Start containers in detached mode
docker compose up -d --remove-orphans

# List running containers to verify deployment
docker compose ps

echo "✅ Application deployed successfully"
