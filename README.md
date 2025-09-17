# 🚀 Kubernetes DevOps Platform

A complete, production-ready DevOps platform built on Kubernetes with GitOps workflow, monitoring, and secret management.

![Platform Overview](docs/images/architecture-overview.png)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.25+-blue.svg)](https://kubernetes.io/)
[![Helm](https://img.shields.io/badge/Helm-3.0+-blue.svg)](https://helm.sh/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-orange.svg)](https://argoproj.github.io/cd/)

## 🎯 Overview

This platform provides a complete DevOps solution featuring:

- **🔄 GitOps Workflow** - ArgoCD for continuous deployment
- **📊 Monitoring Stack** - Prometheus & Grafana for observability
- **🔐 Secret Management** - HashiCorp Vault for secure secrets
- **🖼️ Sample Application** - PictShare for demonstration
- **🏗️ Infrastructure as Code** - Terraform and Helm charts
- **🔧 CI/CD Pipeline** - GitLab CI integration ready

## ✨ Features

### Core Components
- ✅ **ArgoCD** - GitOps continuous deployment
- ✅ **Prometheus & Grafana** - Complete monitoring solution
- ✅ **HashiCorp Vault** - Secret management and encryption
- ✅ **NGINX Ingress** - Load balancing and routing
- ✅ **Helm Charts** - Package management for Kubernetes

### DevOps Workflow
- ✅ **GitOps Integration** - Automated deployment via ArgoCD
- ✅ **CI/CD Pipeline** - Build, test, security scan, deploy
- ✅ **Infrastructure as Code** - Terraform modules
- ✅ **Environment Management** - Staging and production configurations
- ✅ **Security Scanning** - Container and SAST integration

## 🚀 Quick Start

### Prerequisites
- Kubernetes cluster (minikube, kind, or cloud provider)
- kubectl configured
- Helm 3.x installed
- (Optional) Terraform for infrastructure provisioning

### One-Command Deployment
```bash
git clone https://github.com/yourusername/kubernetes-devops-platform.git
cd kubernetes-devops-platform
./scripts/deploy-all.sh
```

### Manual Deployment
```bash
# 1. Deploy ArgoCD
kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd -f charts/argocd/values.yaml

# 2. Deploy Monitoring
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring -f charts/monitoring/values.yaml

# 3. Deploy Vault
kubectl create namespace vault
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install vault hashicorp/vault -n vault -f charts/vault/values.yaml

# 4. Deploy Applications
kubectl apply -f argocd/applications/
```

## 📋 Access Information

After deployment, access your services:

| Service | URL | Credentials |
|---------|-----|-------------|
| **ArgoCD** | http://argocd.local | admin / (get from secret) |
| **Grafana** | http://grafana.local | admin / admin123 |
| **Prometheus** | http://prometheus.local | - |
| **Vault** | http://vault.local | token: root |
| **PictShare** | http://pictshare.local | - |

### Port Forward Access (Alternative)
```bash
# Run the port forwarding script
./scripts/port-forward.sh

# Access via localhost:
# ArgoCD:      http://localhost:8081
# Grafana:     http://localhost:8082
# Prometheus:  http://localhost:8083
# Vault:       http://localhost:8084
# PictShare:   http://localhost:8080
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Developer     │───▶│   GitLab CI     │───▶│   Container     │
│   Commits       │    │   Pipeline      │    │   Registry      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   ArgoCD        │◀───│   GitOps Repo   │◀───│   Image Update  │
│   GitOps        │    │   (This Repo)   │    │   Automation    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                          │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │   Vault     │  │ Monitoring  │  │      Applications       │ │
│  │  (Secrets)  │  │(Prom/Graf)  │  │    (PictShare, etc)     │ │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
kubernetes-devops-platform/
├── 📄 README.md                    # Main documentation
├── 📁 charts/                      # Helm charts
│   ├── 📁 argocd/                  # ArgoCD configuration
│   ├── 📁 monitoring/              # Prometheus & Grafana
│   ├── 📁 vault/                   # HashiCorp Vault
│   └── 📁 pictshare/               # Sample application
├── 📁 argocd/                      # ArgoCD applications
│   ├── 📁 applications/            # Application definitions
│   └── 📁 projects/                # ArgoCD projects
├── 📁 terraform/                   # Infrastructure as Code
│   ├── 📁 modules/                 # Reusable modules
│   └── 📁 environments/            # Environment configs
├── 📁 k8s/                         # Raw Kubernetes manifests
│   ├── 📁 namespaces/              # Namespace definitions
│   └── 📁 ingress/                 # Ingress configurations
├── 📁 scripts/                     # Automation scripts
│   ├── 🔧 deploy-all.sh           # One-click deployment
│   ├── 🔧 port-forward.sh         # Port forwarding setup
│   └── 🔧 cleanup.sh              # Environment cleanup
├── 📁 .github/workflows/           # GitHub Actions
│   └── 📄 ci-cd.yml               # CI/CD pipeline
├── 📁 docs/                        # Documentation
│   ├── 📄 ARCHITECTURE.md         # Architecture details
│   ├── 📄 DEPLOYMENT.md           # Deployment guide
│   └── 📄 TROUBLESHOOTING.md      # Common issues
└── 📁 examples/                    # Usage examples
    ├── 📄 gitlab-ci.yml           # GitLab CI example
    └── 📁 sample-app/             # Sample application
```

## 🔧 Configuration

### Environment Variables
```bash
# Required for deployment
export CLUSTER_NAME="your-cluster"
export ENVIRONMENT="staging|production"
export DOMAIN="your-domain.com"

# Optional
export VAULT_TOKEN="your-vault-token"
export ARGOCD_PASSWORD="your-argocd-password"
```

### Customization
1. **Update Helm values** in `charts/*/values.yaml`
2. **Modify ArgoCD applications** in `argocd/applications/`
3. **Adjust Terraform variables** in `terraform/environments/`
4. **Configure ingress domains** in `k8s/ingress/`

## 🔍 Monitoring & Observability

### Grafana Dashboards
- **Kubernetes Cluster Overview** - Node and pod metrics
- **Application Performance** - Custom application metrics
- **ArgoCD Dashboard** - GitOps deployment status
- **Vault Metrics** - Secret management monitoring

### Prometheus Alerts
- High CPU/Memory usage
- Pod restart loops
- Deployment failures
- Certificate expiration

## 🔐 Security Features

### Vault Integration
- **Secret Management** - Centralized secret storage
- **Dynamic Secrets** - Database credential rotation
- **Encryption as a Service** - Data encryption
- **PKI Management** - Certificate lifecycle

### Security Scanning
- **Container Scanning** - Trivy integration
- **SAST** - Static Application Security Testing
- **Network Policies** - Pod-to-pod communication control
- **RBAC** - Role-based access control

## 🚀 CI/CD Integration

### GitLab CI Pipeline
```yaml
stages:
  - build
  - test
  - security
  - package
  - deploy-staging
  - deploy-production
```

### GitHub Actions
```yaml
name: CI/CD Pipeline
on: [push, pull_request]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Kubernetes
        run: ./scripts/deploy-all.sh
```

## 📚 Documentation

- [📖 Architecture Guide](docs/ARCHITECTURE.md)
- [🚀 Deployment Guide](docs/DEPLOYMENT.md)
- [🔧 Configuration Guide](docs/CONFIGURATION.md)
- [🐛 Troubleshooting](docs/TROUBLESHOOTING.md)
- [🔐 Security Guide](docs/SECURITY.md)
- [📊 Monitoring Guide](docs/MONITORING.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Kubernetes best practices
- Update documentation for any changes
- Test in staging environment first
- Follow semantic versioning

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [ArgoCD](https://argoproj.github.io/cd/) for GitOps workflow
- [Prometheus](https://prometheus.io/) for monitoring
- [Grafana](https://grafana.com/) for visualization
- [HashiCorp Vault](https://www.vaultproject.io/) for secret management
- [Helm](https://helm.sh/) for package management

## 📞 Support

- 📧 Email: your-email@example.com
- 💬 Slack: [Your Slack Channel]
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/kubernetes-devops-platform/issues)
- 📖 Wiki: [Project Wiki](https://github.com/yourusername/kubernetes-devops-platform/wiki)

---

⭐ **If this project helped you, please give it a star!** ⭐