#!/bin/bash

echo "Building Docker image: react-app"

docker build -t react-app:latest .

if [ $? -eq 0 ]; then
  echo "Docker image built successfully"
else
  echo "Docker build failed"
  exit 1
fi

