#!/bin/sh
apt install curl -y
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Executer la commande docker version et capturer la sortie
docker_version_output=$(docker version --format '{{.Server.Version}}' 2>/dev/null)

# Verifier si docker_version_output est non vide
if [ -n "$docker_version_output" ]; then
    echo "Docker version: $docker_version_output"
else
    echo "Docker is not installed or not running."
    exit 1
fi
