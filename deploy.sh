#!/bin/bash

echo "Deploying React App using Docker Compose"

docker compose down
docker compose up -d

if [ $? -eq 0 ]; then
  echo "Application deployed successfully"
else
  echo "Deployment failed"
  exit 1
fi

