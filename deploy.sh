#!/bin/bash
set -e

# Assign host port per branch
if [ "$BRANCH_NAME" == "dev" ]; then
    export HOST_PORT=8081
elif [ "$BRANCH_NAME" == "main" ]; then
    export HOST_PORT=8080
else
    export HOST_PORT=8090
fi

docker compose down --remove-orphans
docker compose pull
docker compose up -d --remove-orphans
