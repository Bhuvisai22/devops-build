#!/bin/bash
echo "Deploying with Docker Compose..."
docker-compose down
docker-compose up -di
