# ⚡ Quick Start Guide

Get your DevOps platform up and running in 5 minutes!

## 🚀 One-Command Deployment

```bash
# Clone and deploy
git clone https://github.com/yourusername/kubernetes-devops-platform.git
cd kubernetes-devops-platform
./scripts/deploy-all.sh
```

## 🌐 Access Your Services

After deployment completes, set up port forwarding:
```bash
./scripts/port-forward.sh
```

Then open these URLs in your browser:

| Service | URL | Login |
|---------|-----|-------|
| **📸 PictShare** | http://localhost:8080 | - |
| **🔄 ArgoCD** | http://localhost:8081 | admin / [see output] |
| **📊 Grafana** | http://localhost:8082 | admin / admin123 |
| **🔍 Prometheus** | http://localhost:8083 | - |
| **🔐 Vault** | http://localhost:8084 | token: root |

## ✅ Verify Everything Works

```bash
# Check all pods are running
kubectl get pods -A

# Test the PictShare application
curl http://localhost:8080

# View ArgoCD applications
kubectl get applications -n argocd
```

## 🎯 What You Get

✅ **Complete GitOps Platform** - ArgoCD managing all deployments
✅ **Full Monitoring Stack** - Prometheus + Grafana dashboards
✅ **Secret Management** - HashiCorp Vault for all secrets
✅ **Sample Application** - PictShare running in staging
✅ **CI/CD Ready** - GitHub Actions and GitLab CI examples
✅ **Production Ready** - Security, monitoring, and scalability built-in

## 🧹 Clean Up (Optional)

```bash
./scripts/cleanup.sh
```

## 📚 Next Steps

- [📖 Read the full documentation](README.md)
- [🏗️ Learn about the architecture](docs/ARCHITECTURE.md)
- [🔧 Customize your deployment](docs/DEPLOYMENT.md)
- [🤝 Contribute to the project](CONTRIBUTING.md)

---

🎉 **That's it! You now have a complete DevOps platform running!** 🎉