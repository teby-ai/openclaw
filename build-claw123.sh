#!/bin/bash
# Build claw123-openclaw Docker image with date tag

TAG="claw123-openclaw:$(date +%Y.%m.%d)"

echo "Building image: $TAG"
docker build -f Dockerfile.claw123 -t "$TAG" .

# Also tag as latest
echo "Tagging as claw123-openclaw:latest"
docker tag "$TAG" claw123-openclaw:latest

echo "Done!"
echo ""
echo "Images built:"
docker images | grep claw123-openclaw
