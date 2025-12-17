#!/bin/bash
set -e

echo "Deploying React App using Docker Compose"

# Stop and remove existing containers safely
docker compose down || true

# Pull latest image from Docker Hub
docker compose pull

# Start containers
docker compose up -d --remove-orphans

echo "✅ Application deployed successfully"
