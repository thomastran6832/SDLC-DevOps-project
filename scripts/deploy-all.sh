#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE_ARGOCD="argocd"
NAMESPACE_MONITORING="monitoring"
NAMESPACE_VAULT="vault"
NAMESPACE_PICTSHARE="pictshare-staging"

echo -e "${BLUE}🚀 Kubernetes DevOps Platform Deployment${NC}"
echo -e "${BLUE}==========================================${NC}"

# Check prerequisites
echo -e "\n${YELLOW}📋 Checking prerequisites...${NC}"

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed${NC}"
    exit 1
fi

if ! command -v helm &> /dev/null; then
    echo -e "${RED}❌ helm is not installed${NC}"
    exit 1
fi

if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ kubectl is not connected to a cluster${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Function to wait for deployment
wait_for_deployment() {
    local namespace=$1
    local deployment=$2
    local timeout=${3:-300}

    echo -e "${YELLOW}⏳ Waiting for $deployment in $namespace to be ready...${NC}"
    if kubectl wait --for=condition=available --timeout=${timeout}s deployment/$deployment -n $namespace &>/dev/null; then
        echo -e "${GREEN}✅ $deployment is ready${NC}"
    else
        echo -e "${RED}❌ $deployment failed to become ready${NC}"
        return 1
    fi
}

# Function to wait for pods
wait_for_pods() {
    local namespace=$1
    local selector=$2
    local timeout=${3:-300}

    echo -e "${YELLOW}⏳ Waiting for pods with selector $selector in $namespace...${NC}"
    if kubectl wait --for=condition=ready --timeout=${timeout}s pod -l $selector -n $namespace &>/dev/null; then
        echo -e "${GREEN}✅ Pods are ready${NC}"
    else
        echo -e "${RED}❌ Pods failed to become ready${NC}"
        return 1
    fi
}

# Create namespaces
echo -e "\n${BLUE}📦 Creating namespaces...${NC}"
kubectl create namespace $NAMESPACE_ARGOCD --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace $NAMESPACE_MONITORING --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace $NAMESPACE_VAULT --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace $NAMESPACE_PICTSHARE --dry-run=client -o yaml | kubectl apply -f -

echo -e "${GREEN}✅ Namespaces created${NC}"

# Add Helm repositories
echo -e "\n${BLUE}📚 Adding Helm repositories...${NC}"
helm repo add argo https://argoproj.github.io/argo-helm --force-update
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update
helm repo add hashicorp https://helm.releases.hashicorp.com --force-update
helm repo update

echo -e "${GREEN}✅ Helm repositories added${NC}"

# Deploy ArgoCD
echo -e "\n${BLUE}🔄 Deploying ArgoCD...${NC}"
helm upgrade --install argocd argo/argo-cd \
    --namespace $NAMESPACE_ARGOCD \
    --set server.service.type=NodePort \
    --set server.service.nodePortHttp=30180 \
    --set server.service.nodePortHttps=30183 \
    --set server.extraArgs[0]='--insecure' \
    --wait

wait_for_deployment $NAMESPACE_ARGOCD argocd-server

# Get ArgoCD admin password
ARGOCD_PASSWORD=$(kubectl -n $NAMESPACE_ARGOCD get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo -e "${GREEN}✅ ArgoCD deployed - Admin password: $ARGOCD_PASSWORD${NC}"

# Deploy Monitoring Stack
echo -e "\n${BLUE}📊 Deploying Monitoring Stack...${NC}"
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
    --namespace $NAMESPACE_MONITORING \
    --set grafana.service.type=NodePort \
    --set grafana.service.nodePort=30300 \
    --set prometheus.service.type=NodePort \
    --set prometheus.service.nodePort=30900 \
    --set grafana.adminPassword=admin123 \
    --wait

wait_for_deployment $NAMESPACE_MONITORING prometheus-grafana

echo -e "${GREEN}✅ Monitoring stack deployed${NC}"

# Deploy Vault
echo -e "\n${BLUE}🔐 Deploying HashiCorp Vault...${NC}"
helm upgrade --install vault hashicorp/vault \
    --namespace $NAMESPACE_VAULT \
    --set server.dev.enabled=true \
    --set server.service.type=NodePort \
    --set server.service.nodePort=30820 \
    --set ui.enabled=true \
    --set ui.serviceType=NodePort \
    --wait

wait_for_pods $NAMESPACE_VAULT app.kubernetes.io/name=vault

echo -e "${GREEN}✅ Vault deployed${NC}"

# Deploy PictShare Application
echo -e "\n${BLUE}🖼️ Deploying PictShare Application...${NC}"
helm upgrade --install pictshare ./charts/pictshare \
    --namespace $NAMESPACE_PICTSHARE \
    --wait

wait_for_deployment $NAMESPACE_PICTSHARE pictshare

echo -e "${GREEN}✅ PictShare deployed${NC}"

# Create Ingress resources
echo -e "\n${BLUE}🌐 Setting up Ingress resources...${NC}"
kubectl apply -f k8s/ingress/ || echo -e "${YELLOW}⚠️ Ingress resources may not be available${NC}"

# Deploy ArgoCD Applications
echo -e "\n${BLUE}🚀 Deploying ArgoCD Applications...${NC}"
kubectl apply -f argocd/projects/
kubectl apply -f argocd/applications/

echo -e "${GREEN}✅ ArgoCD applications deployed${NC}"

# Display access information
echo -e "\n${GREEN}🎉 Deployment Complete!${NC}"
echo -e "${BLUE}===========================================${NC}"
echo -e "\n${YELLOW}📋 Access Information:${NC}"
echo -e "${GREEN}🔄 ArgoCD:${NC}      http://argocd.local or http://$(minikube ip 2>/dev/null || echo 'CLUSTER-IP'):30180"
echo -e "${GREEN}   Username:${NC}   admin"
echo -e "${GREEN}   Password:${NC}   $ARGOCD_PASSWORD"
echo -e "\n${GREEN}📊 Grafana:${NC}     http://grafana.local or http://$(minikube ip 2>/dev/null || echo 'CLUSTER-IP'):30300"
echo -e "${GREEN}   Username:${NC}   admin"
echo -e "${GREEN}   Password:${NC}   admin123"
echo -e "\n${GREEN}🔍 Prometheus:${NC}  http://prometheus.local or http://$(minikube ip 2>/dev/null || echo 'CLUSTER-IP'):30900"
echo -e "\n${GREEN}🔐 Vault:${NC}       http://vault.local or http://$(minikube ip 2>/dev/null || echo 'CLUSTER-IP'):30820"
echo -e "${GREEN}   Token:${NC}      root"
echo -e "\n${GREEN}🖼️ PictShare:${NC}   http://pictshare.local"

echo -e "\n${YELLOW}💡 Tips:${NC}"
echo -e "- Run ${BLUE}./scripts/port-forward.sh${NC} for localhost access"
echo -e "- Add hosts entries for .local domains: ${BLUE}./scripts/setup-hosts.sh${NC}"
echo -e "- Check status: ${BLUE}kubectl get pods -A${NC}"

echo -e "\n${GREEN}🚀 Your DevOps platform is ready!${NC}"