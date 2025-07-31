#!/bin/bash

# Install ArgoCD and Argo Image Updater using Helm
echo "🚀 Installing ArgoCD and Argo Image Updater using Helm..."

# Add ArgoCD Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update


# Install ArgoCD and Argo Image Updater
helm install argocd argo/argo-cd -n argocd --create-namespace --wait
helm install argocd-image-updater argo/argocd-image-updater -n argocd


# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Wait for Argo Image Updater to be ready
echo "⏳ Waiting for Argo Image Updater to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-image-updater -n argocd --timeout=300s

# Get ArgoCD admin password

echo "To access ArgoCD UI, run: kubectl port-forward svc/argocd-argocd-server -n argocd 8080:443"

echo "✅ ArgoCD and Argo Image Updater installation complete!" 


#Create a ServiceAccount + RoleBinding:
kubectl apply -f image-updater-rbac.yaml

# Create a token for the image-updater service account  
TOKEN=$(kubectl -n argocd create token image-updater)

# Add the token to the ArgoCD iamge update
helm upgrade --install argocd-image-updater argo/argocd-image-updater \
  -n argocd \
  --set argocd.token=$TOKEN \
  --set argocd.serverAddr="argocd-server.argocd.svc"



kubectl create secret generic docker-registry-secret \
 --from-file=.dockerconfigjson=/home/omnia/.docker/config.json \
 --type=kubernetes.io/dockerconfigjson --namespace=todo-app 




