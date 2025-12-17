#!/bin/bash
set -e

echo "Deploying React App using Docker Compose"

# Stop and remove existing containers safely
docker compose down || true

# Pull latest image from Docker Hub
docker compose pull

# Start containers
docker compose up -d --remove-orphans

# Stop and remove the existing container if it exists
docker rm -f react-appcontainer || true

# Then deploy
docker-compose up -d

echo "✅ Application deployed successfully"
