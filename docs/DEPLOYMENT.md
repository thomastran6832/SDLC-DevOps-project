# 🚀 Deployment Guide

This guide provides comprehensive instructions for deploying the Kubernetes DevOps Platform in various environments.

## 📋 Prerequisites

### Required Tools
- **kubectl** 1.25+ - Kubernetes command-line tool
- **helm** 3.x - Kubernetes package manager
- **git** - Version control
- **curl** - For API testing

### Optional Tools
- **terraform** 1.0+ - Infrastructure provisioning
- **docker** - Container building and testing
- **minikube/kind** - Local Kubernetes development

### System Requirements
- **Kubernetes cluster** with at least:
  - 4 CPU cores
  - 8GB RAM
  - 50GB storage
- **Ingress controller** (NGINX recommended)
- **StorageClass** for persistent volumes

## 🎯 Deployment Options

### Option 1: Quick Start (Recommended)
```bash
# Clone the repository
git clone https://github.com/yourusername/kubernetes-devops-platform.git
cd kubernetes-devops-platform

# One-command deployment
./scripts/deploy-all.sh
```

### Option 2: Step-by-Step Deployment
```bash
# 1. Create namespaces
kubectl create namespace argocd
kubectl create namespace monitoring
kubectl create namespace vault
kubectl create namespace pictshare-staging

# 2. Add Helm repositories
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# 3. Deploy ArgoCD
helm install argocd argo/argo-cd -n argocd -f charts/argocd/values.yaml

# 4. Deploy Monitoring
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring -f charts/monitoring/values.yaml

# 5. Deploy Vault
helm install vault hashicorp/vault -n vault -f charts/vault/values.yaml

# 6. Deploy Applications
kubectl apply -f argocd/applications/
```

### Option 3: Terraform Deployment
```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

## 🏗️ Environment-Specific Deployments

### Development Environment
```bash
# Minimal resource configuration
helm install pictshare charts/pictshare \
  --namespace pictshare-dev \
  --create-namespace \
  --set replicaCount=1 \
  --set resources.requests.cpu=100m \
  --set resources.requests.memory=128Mi
```

### Staging Environment
```bash
# Production-like configuration with reduced resources
helm install pictshare-staging charts/pictshare \
  --namespace pictshare-staging \
  --create-namespace \
  --values charts/pictshare/values-staging.yaml
```

### Production Environment
```bash
# Full production configuration
helm install pictshare-production charts/pictshare \
  --namespace pictshare-production \
  --create-namespace \
  --values charts/pictshare/values-production.yaml
```

## 🔧 Configuration

### Environment Variables
Create a `.env` file with your configuration:
```bash
# Cluster Configuration
CLUSTER_NAME=my-cluster
ENVIRONMENT=staging
DOMAIN=example.com

# ArgoCD Configuration
ARGOCD_ADMIN_PASSWORD=secure-password
ARGOCD_REPO_URL=https://github.com/yourusername/kubernetes-devops-platform.git

# Monitoring Configuration
GRAFANA_ADMIN_PASSWORD=admin123
SLACK_WEBHOOK_URL=https://hooks.slack.com/your-webhook

# Vault Configuration
VAULT_ROOT_TOKEN=your-root-token
VAULT_UNSEAL_KEYS=key1,key2,key3

# Registry Configuration
REGISTRY_URL=registry.example.com
REGISTRY_USERNAME=username
REGISTRY_PASSWORD=password
```

### Custom Values Files
Override default configurations by creating custom values files:

```yaml
# values-custom.yaml
pictshare:
  image:
    repository: your-registry.com/pictshare
    tag: "v1.2.3"

  ingress:
    hosts:
      - host: pictshare.your-domain.com
        paths:
          - path: /
            pathType: Prefix

  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 512Mi
```

## 🌐 Ingress Configuration

### NGINX Ingress (Recommended)
```bash
# Install NGINX Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace
```

### Domain Configuration
Add these entries to your DNS or `/etc/hosts`:
```
<CLUSTER-IP>  pictshare.local
<CLUSTER-IP>  argocd.local
<CLUSTER-IP>  grafana.local
<CLUSTER-IP>  prometheus.local
<CLUSTER-IP>  vault.local
```

### SSL/TLS Setup
```bash
# Install cert-manager for automatic SSL certificates
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

# Create ClusterIssuer for Let's Encrypt
kubectl apply -f k8s/cert-manager/cluster-issuer.yaml
```

## 🔐 Security Configuration

### RBAC Setup
```bash
# Create service accounts and roles
kubectl apply -f k8s/rbac/

# Verify RBAC configuration
kubectl auth can-i --list --as=system:serviceaccount:argocd:argocd-server
```

### Network Policies
```bash
# Apply network policies for security
kubectl apply -f k8s/network-policies/

# Verify network policies
kubectl get networkpolicies -A
```

### Pod Security Standards
```bash
# Apply pod security standards
kubectl label namespace pictshare-staging pod-security.kubernetes.io/enforce=restricted
kubectl label namespace pictshare-production pod-security.kubernetes.io/enforce=restricted
```

## 📊 Monitoring Setup

### Grafana Dashboards
```bash
# Import custom dashboards
kubectl create configmap custom-dashboards \
  --from-file=docs/grafana-dashboards/ \
  -n monitoring

# Update Grafana to load custom dashboards
helm upgrade prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f charts/monitoring/values.yaml
```

### AlertManager Configuration
```bash
# Configure alert routing
kubectl apply -f k8s/monitoring/alertmanager-config.yaml

# Test alert routing
curl -XPOST http://alertmanager.local/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '[{"labels":{"alertname":"TestAlert","severity":"warning"}}]'
```

## 🔄 GitOps Configuration

### ArgoCD Applications
```bash
# Deploy ArgoCD applications
kubectl apply -f argocd/projects/
kubectl apply -f argocd/applications/

# Sync applications
kubectl patch app pictshare-staging -n argocd --type merge -p '{"operation":{"sync":{"syncStrategy":{"force":true}}}}'
```

### Repository Access
```bash
# Add Git repository to ArgoCD
argocd repo add https://github.com/yourusername/kubernetes-devops-platform.git \
  --username <username> \
  --password <token>

# Verify repository connection
argocd repo list
```

## 🧪 Testing Deployment

### Health Checks
```bash
# Check all pods are running
kubectl get pods -A

# Check services are accessible
kubectl get svc -A

# Check ingress configuration
kubectl get ingress -A
```

### Functional Tests
```bash
# Test PictShare application
curl -f http://pictshare.local/health

# Test ArgoCD API
curl -f http://argocd.local/api/version

# Test Grafana
curl -f http://grafana.local/api/health

# Test Prometheus
curl -f http://prometheus.local/-/healthy

# Test Vault
curl -f http://vault.local/v1/sys/health
```

### Load Testing
```bash
# Install k6 for load testing
kubectl apply -f examples/load-testing/k6-configmap.yaml
kubectl apply -f examples/load-testing/k6-job.yaml

# Monitor results
kubectl logs job/load-test
```

## 🐛 Troubleshooting

### Common Issues

#### Pods Not Starting
```bash
# Check pod status and events
kubectl describe pod <pod-name> -n <namespace>
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Check resource constraints
kubectl top nodes
kubectl top pods -A
```

#### Ingress Not Working
```bash
# Check ingress controller
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Check ingress configuration
kubectl describe ingress <ingress-name> -n <namespace>
```

#### ArgoCD Sync Issues
```bash
# Check ArgoCD application status
kubectl get applications -n argocd
kubectl describe application <app-name> -n argocd

# Refresh and sync
argocd app sync <app-name> --force
```

#### Monitoring Not Working
```bash
# Check Prometheus targets
kubectl port-forward svc/prometheus-operated -n monitoring 9090:9090
# Visit http://localhost:9090/targets

# Check Grafana datasource
kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80
# Visit http://localhost:3000
```

### Log Collection
```bash
# Collect logs from all components
mkdir -p logs
kubectl logs -n argocd deployment/argocd-server > logs/argocd.log
kubectl logs -n monitoring deployment/prometheus-grafana > logs/grafana.log
kubectl logs -n vault deployment/vault > logs/vault.log
kubectl logs -n pictshare-staging deployment/pictshare > logs/pictshare.log
```

## 🔄 Updates and Maintenance

### Updating Components
```bash
# Update Helm repositories
helm repo update

# Upgrade ArgoCD
helm upgrade argocd argo/argo-cd -n argocd -f charts/argocd/values.yaml

# Upgrade monitoring stack
helm upgrade prometheus prometheus-community/kube-prometheus-stack -n monitoring -f charts/monitoring/values.yaml

# Upgrade Vault
helm upgrade vault hashicorp/vault -n vault -f charts/vault/values.yaml
```

### Backup Procedures
```bash
# Backup ArgoCD configuration
kubectl get applications -n argocd -o yaml > backups/argocd-applications.yaml
kubectl get secrets -n argocd -o yaml > backups/argocd-secrets.yaml

# Backup Vault data (if using external storage)
vault operator raft snapshot save backup.snap

# Backup Grafana dashboards
kubectl get configmaps -n monitoring -l grafana_dashboard=1 -o yaml > backups/grafana-dashboards.yaml
```

### Disaster Recovery
```bash
# Restore from backup
kubectl apply -f backups/

# Verify restoration
./scripts/deploy-all.sh --verify-only
```

## 📈 Scaling

### Horizontal Scaling
```bash
# Scale applications
kubectl scale deployment pictshare --replicas=3 -n pictshare-staging

# Configure HPA
kubectl apply -f k8s/hpa/pictshare-hpa.yaml
```

### Vertical Scaling
```bash
# Update resource requests/limits
helm upgrade pictshare-staging charts/pictshare \
  --set resources.requests.cpu=500m \
  --set resources.requests.memory=512Mi
```

### Cluster Scaling
```bash
# Add nodes (cloud-specific)
# AWS EKS
eksctl scale nodegroup --cluster=my-cluster --name=my-nodegroup --nodes=5

# GKE
gcloud container clusters resize my-cluster --num-nodes=5

# Azure AKS
az aks scale --resource-group=my-rg --name=my-cluster --node-count=5
```

This guide covers the most common deployment scenarios. For specific issues or advanced configurations, refer to the component-specific documentation or open an issue in the repository.