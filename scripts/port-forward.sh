#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Setting up port forwarding for DevOps platform...${NC}"

# Kill any existing port forwards
echo -e "${YELLOW}🧹 Cleaning up existing port forwards...${NC}"
pkill -f "kubectl port-forward" 2>/dev/null || true
sleep 2

echo -e "\n${BLUE}🔄 Starting port forwards...${NC}"

# Create log directory
mkdir -p /tmp/k8s-port-forwards

# PictShare Application
echo -e "${GREEN}📸 PictShare:${NC} http://localhost:8080"
kubectl port-forward svc/pictshare -n pictshare-staging 8080:80 > /tmp/k8s-port-forwards/pictshare.log 2>&1 &

# ArgoCD
echo -e "${GREEN}🔄 ArgoCD:${NC} http://localhost:8081"
kubectl port-forward svc/argocd-server -n argocd 8081:80 > /tmp/k8s-port-forwards/argocd.log 2>&1 &

# Grafana
echo -e "${GREEN}📊 Grafana:${NC} http://localhost:8082"
kubectl port-forward svc/prometheus-grafana -n monitoring 8082:80 > /tmp/k8s-port-forwards/grafana.log 2>&1 &

# Prometheus
echo -e "${GREEN}🔍 Prometheus:${NC} http://localhost:8083"
kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 8083:9090 > /tmp/k8s-port-forwards/prometheus.log 2>&1 &

# Vault
echo -e "${GREEN}🔐 Vault:${NC} http://localhost:8084"
kubectl port-forward svc/vault -n vault 8084:8200 > /tmp/k8s-port-forwards/vault.log 2>&1 &

# Solemate Frontend
echo -e "${GREEN}👟 Solemate Frontend:${NC} http://localhost:8085"
kubectl port-forward svc/solemate-frontend-argocd -n solemate 8085:3000 > /tmp/k8s-port-forwards/solemate-frontend.log 2>&1 &

# Solemate Backend
echo -e "${GREEN}⚙️ Solemate Backend:${NC} http://localhost:8086"
kubectl port-forward svc/solemate-backend-argocd -n solemate 8086:5000 > /tmp/k8s-port-forwards/solemate-backend.log 2>&1 &

# Wait for port forwards to establish
sleep 5

echo -e "\n${GREEN}✅ Port forwarding setup complete!${NC}"
echo -e "\n${YELLOW}🌐 Access URLs:${NC}"
echo -e "   📸 PictShare:   ${BLUE}http://localhost:8080${NC}"
echo -e "   🔄 ArgoCD:      ${BLUE}http://localhost:8081${NC} (admin/\$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d))"
echo -e "   📊 Grafana:     ${BLUE}http://localhost:8082${NC} (admin/admin123)"
echo -e "   🔍 Prometheus:  ${BLUE}http://localhost:8083${NC}"
echo -e "   🔐 Vault:       ${BLUE}http://localhost:8084${NC} (token: root)"
echo -e "   👟 Solemate:    ${BLUE}http://localhost:8085${NC}"
echo -e "   ⚙️ API:         ${BLUE}http://localhost:8086${NC}"

echo -e "\n${YELLOW}🔧 Management:${NC}"
echo -e "   Stop all:       ${BLUE}pkill -f 'kubectl port-forward'${NC}"
echo -e "   Check status:   ${BLUE}ps aux | grep 'kubectl port-forward' | grep -v grep${NC}"
echo -e "   View logs:      ${BLUE}ls /tmp/k8s-port-forwards/${NC}"

echo -e "\n${GREEN}💡 Port forwards are running in the background${NC}"

# Function to check if port forwards are working
check_port_forwards() {
    echo -e "\n${YELLOW}🔍 Checking port forward status...${NC}"
    local failed=0

    for port in 8080 8081 8082 8083 8084 8085 8086; do
        if nc -z localhost $port 2>/dev/null; then
            echo -e "${GREEN}✅ Port $port: OK${NC}"
        else
            echo -e "${RED}❌ Port $port: Failed${NC}"
            failed=1
        fi
    done

    if [ $failed -eq 0 ]; then
        echo -e "\n${GREEN}🎉 All port forwards are working!${NC}"
    else
        echo -e "\n${YELLOW}⚠️ Some port forwards failed. Check logs in /tmp/k8s-port-forwards/${NC}"
    fi
}

# Check if netcat is available and run check
if command -v nc &> /dev/null; then
    check_port_forwards
else
    echo -e "\n${YELLOW}💡 Install 'nc' (netcat) to verify port forward status${NC}"
fi