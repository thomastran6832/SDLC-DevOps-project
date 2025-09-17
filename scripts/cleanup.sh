#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${RED}🧹 Kubernetes DevOps Platform Cleanup${NC}"
echo -e "${RED}====================================${NC}"

# Confirmation prompt
read -p "$(echo -e ${YELLOW}⚠️ This will remove all deployed resources. Continue? [y/N]: ${NC})" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}👋 Cleanup cancelled${NC}"
    exit 0
fi

echo -e "\n${YELLOW}🔄 Starting cleanup...${NC}"

# Kill port forwards
echo -e "\n${BLUE}🛑 Stopping port forwards...${NC}"
pkill -f "kubectl port-forward" 2>/dev/null || true
rm -rf /tmp/k8s-port-forwards 2>/dev/null || true
echo -e "${GREEN}✅ Port forwards stopped${NC}"

# Remove Helm releases
echo -e "\n${BLUE}📦 Removing Helm releases...${NC}"

helm uninstall argocd -n argocd 2>/dev/null && echo -e "${GREEN}✅ ArgoCD removed${NC}" || echo -e "${YELLOW}⚠️ ArgoCD not found${NC}"
helm uninstall prometheus -n monitoring 2>/dev/null && echo -e "${GREEN}✅ Prometheus removed${NC}" || echo -e "${YELLOW}⚠️ Prometheus not found${NC}"
helm uninstall vault -n vault 2>/dev/null && echo -e "${GREEN}✅ Vault removed${NC}" || echo -e "${YELLOW}⚠️ Vault not found${NC}"
helm uninstall pictshare -n pictshare-staging 2>/dev/null && echo -e "${GREEN}✅ PictShare removed${NC}" || echo -e "${YELLOW}⚠️ PictShare not found${NC}"

# Remove ArgoCD applications and projects
echo -e "\n${BLUE}🗑️ Removing ArgoCD resources...${NC}"
kubectl delete -f argocd/applications/ 2>/dev/null || true
kubectl delete -f argocd/projects/ 2>/dev/null || true
echo -e "${GREEN}✅ ArgoCD resources removed${NC}"

# Remove ingress resources
echo -e "\n${BLUE}🌐 Removing ingress resources...${NC}"
kubectl delete -f k8s/ingress/ 2>/dev/null || true
echo -e "${GREEN}✅ Ingress resources removed${NC}"

# Remove namespaces (this will clean up everything else)
echo -e "\n${BLUE}📦 Removing namespaces...${NC}"
kubectl delete namespace argocd --timeout=60s 2>/dev/null && echo -e "${GREEN}✅ argocd namespace removed${NC}" || echo -e "${YELLOW}⚠️ argocd namespace not found${NC}"
kubectl delete namespace monitoring --timeout=60s 2>/dev/null && echo -e "${GREEN}✅ monitoring namespace removed${NC}" || echo -e "${YELLOW}⚠️ monitoring namespace not found${NC}"
kubectl delete namespace vault --timeout=60s 2>/dev/null && echo -e "${GREEN}✅ vault namespace removed${NC}" || echo -e "${YELLOW}⚠️ vault namespace not found${NC}"
kubectl delete namespace pictshare-staging --timeout=60s 2>/dev/null && echo -e "${GREEN}✅ pictshare-staging namespace removed${NC}" || echo -e "${YELLOW}⚠️ pictshare-staging namespace not found${NC}"

# Clean up CRDs (optional - be careful with this in shared clusters)
echo -e "\n${YELLOW}🔧 Cleaning up Custom Resource Definitions...${NC}"
read -p "$(echo -e ${YELLOW}Remove ArgoCD CRDs? This affects all ArgoCD instances in the cluster [y/N]: ${NC})" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl delete crd applications.argoproj.io 2>/dev/null || true
    kubectl delete crd applicationsets.argoproj.io 2>/dev/null || true
    kubectl delete crd appprojects.argoproj.io 2>/dev/null || true
    echo -e "${GREEN}✅ ArgoCD CRDs removed${NC}"
fi

read -p "$(echo -e ${YELLOW}Remove Prometheus CRDs? This affects all Prometheus instances in the cluster [y/N]: ${NC})" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl delete crd alertmanagerconfigs.monitoring.coreos.com 2>/dev/null || true
    kubectl delete crd alertmanagers.monitoring.coreos.com 2>/dev/null || true
    kubectl delete crd podmonitors.monitoring.coreos.com 2>/dev/null || true
    kubectl delete crd probes.monitoring.coreos.com 2>/dev/null || true
    kubectl delete crd prometheuses.monitoring.coreos.com 2>/dev/null || true
    kubectl delete crd prometheusrules.monitoring.coreos.com 2>/dev/null || true
    kubectl delete crd servicemonitors.monitoring.coreos.com 2>/dev/null || true
    kubectl delete crd thanosrulers.monitoring.coreos.com 2>/dev/null || true
    echo -e "${GREEN}✅ Prometheus CRDs removed${NC}"
fi

# Verify cleanup
echo -e "\n${BLUE}🔍 Verifying cleanup...${NC}"
REMAINING_PODS=$(kubectl get pods -A | grep -E "(argocd|monitoring|vault|pictshare)" | wc -l)
if [ "$REMAINING_PODS" -eq 0 ]; then
    echo -e "${GREEN}✅ Cleanup completed successfully${NC}"
else
    echo -e "${YELLOW}⚠️ Some resources may still be terminating:${NC}"
    kubectl get pods -A | grep -E "(argocd|monitoring|vault|pictshare)" || true
    echo -e "${YELLOW}💡 This is normal - resources may take a few minutes to fully terminate${NC}"
fi

echo -e "\n${GREEN}🎉 Cleanup process completed!${NC}"
echo -e "${BLUE}💡 To redeploy: ./scripts/deploy-all.sh${NC}"