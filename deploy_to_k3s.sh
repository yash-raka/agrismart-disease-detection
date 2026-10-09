#!/bin/bash
set -e

echo "Cloning repo..."
git clone https://github.com/yash-raka/agrismart-disease-detection.git
cd agrismart-disease-detection

echo "Setting up model..."
mkdir -p ./model
cp ../model/potatoes.h5 ./model/

echo "Building backend image..."
sudo docker build -t backend:latest ./backend
sudo docker save backend:latest > backend.tar
echo "Importing backend to k3s..."
sudo k3s ctr images import backend.tar

echo "Building frontend image..."
# Inject the K8s node API URL into the frontend build
echo "REACT_APP_API_URL=http://3.109.155.119:31000/predict" > frontend/.env
sudo docker build -t frontend:latest ./frontend
sudo docker save frontend:latest > frontend.tar
echo "Importing frontend to k3s..."
sudo k3s ctr images import frontend.tar

# Ensure image pull policies are set to Never so K3s uses the local imported images
sed -i 's/imagePullPolicy: IfNotPresent/imagePullPolicy: Never/g' infrastructure/kubernetes/backend-deployment.yaml
sed -i 's/imagePullPolicy: IfNotPresent/imagePullPolicy: Never/g' infrastructure/kubernetes/frontend-deployment.yaml

echo "Deploying to Kubernetes..."
sudo k3s kubectl apply -f infrastructure/kubernetes/

echo "Deployment complete! Waiting for pods to start..."
sleep 5
sudo k3s kubectl get pods
sudo k3s kubectl get svc
