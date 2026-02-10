#!/bin/bash

# Configuration
PROJECT_DIR="/home/k8s-master/web"  # Update this path if different
IMAGE_NAME="dashboard"
IMAGE_TAG="energy5" # Updated tag for this deployment
HARBOR_URL="10.2.2.40:5000/library/web-v2-dashboard"
DEPLOYMENT_NAME="web-v2-dashboard"

# Ensure we are in the project directory
cd $PROJECT_DIR || { echo "Directory not found: $PROJECT_DIR"; exit 1; }

echo "Step 1: Pulling latest code..."
# Reset and clean to avoid conflicts
git reset --hard
git clean -fd
git pull origin master

echo "Step 2: Building Docker image..."
docker build --no-cache -t $IMAGE_NAME:$IMAGE_TAG .

echo "Step 3: Tagging and Pushing to Harbor..."
docker tag $IMAGE_NAME:$IMAGE_TAG $HARBOR_URL:$IMAGE_TAG
docker push $HARBOR_URL:$IMAGE_TAG

echo "Step 4: Updating Kubernetes Deployment..."
kubectl set image deployment/$DEPLOYMENT_NAME $DEPLOYMENT_NAME=$HARBOR_URL:$IMAGE_TAG

echo "Step 5: Restarting Deployment to ensure fresh pods..."
kubectl rollout restart deployment/$DEPLOYMENT_NAME
kubectl rollout status deployment/$DEPLOYMENT_NAME

echo "Deployment Complete!"
