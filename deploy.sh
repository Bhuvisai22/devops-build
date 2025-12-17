#!/bin/bash
set -e

echo "Deploying React App using Docker Compose"

# Stop and remove existing containers and orphans
docker compose down --remove-orphans

# Optional: remove any leftover container manually by name
docker rm -f react-appcontainer 2>/dev/null || true

# Pull latest image from Docker Hub
docker compose pull

# Start containers
docker compose up -d --remove-orphans

# Optional: list running containers
docker compose ps

echo "✅ Application deployed successfully"
