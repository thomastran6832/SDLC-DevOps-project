# 🏗️ Platform Architecture

## Overview

This document describes the complete architecture of the Kubernetes DevOps Platform, including component interactions, data flows, and design decisions.

## 🎯 Design Principles

### 1. GitOps-First Approach
- **Infrastructure as Code**: All configurations stored in Git
- **Declarative**: Desired state defined in YAML manifests
- **Automated**: ArgoCD continuously syncs Git state to cluster

### 2. Security by Design
- **Least Privilege**: RBAC controls access at granular level
- **Secret Management**: Vault centralizes all sensitive data
- **Network Policies**: Pod-to-pod communication restrictions
- **Image Scanning**: Automated vulnerability detection

### 3. Observability
- **Metrics**: Prometheus collects comprehensive metrics
- **Visualization**: Grafana provides rich dashboards
- **Alerting**: PrometheusAlert manager handles notifications
- **Logging**: Structured logging with correlation IDs

## 🔄 Component Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Developer Workflow                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                  │
│  │   Feature    │───▶│  Git Commit  │───▶│  GitLab CI   │                  │
│  │ Development  │    │   & Push     │    │   Pipeline   │                  │
│  └──────────────┘    └──────────────┘    └──────────────┘                  │
│                                                   │                        │
└───────────────────────────────────────────────────┼────────────────────────┘
                                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            CI/CD Pipeline                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │
│  │  Build   │─▶│   Test   │─▶│ Security │─▶│ Package  │─▶│   Deploy     │  │
│  │  Stage   │  │  Stage   │  │   Scan   │  │  Stage   │  │  (GitOps)    │  │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────────┘  │
│                                                                  │          │
└──────────────────────────────────────────────────────────────────┼──────────┘
                                                                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           GitOps Repository                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                      │
│  │    Helm      │  │   ArgoCD     │  │   Config     │                      │
│  │   Charts     │  │ Applications │  │ Manifests    │                      │
│  └──────────────┘  └──────────────┘  └──────────────┘                      │
│                                            │                               │
└────────────────────────────────────────────┼───────────────────────────────┘
                                             ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Kubernetes Cluster                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────────┐  │
│  │     ArgoCD      │  │   Monitoring    │  │        Applications         │  │
│  │   (GitOps)      │  │ (Prom/Grafana)  │  │     (PictShare, etc)        │  │
│  │                 │  │                 │  │                             │  │
│  │ ┌─────────────┐ │  │ ┌─────────────┐ │  │ ┌─────────────────────────┐ │  │
│  │ │ Application │ │  │ │ Prometheus  │ │  │ │      PictShare          │ │  │
│  │ │ Controller  │ │  │ │  Server     │ │  │ │                         │ │  │
│  │ └─────────────┘ │  │ └─────────────┘ │  │ │ ┌─────────────────────┐ │ │  │
│  │ ┌─────────────┐ │  │ ┌─────────────┐ │  │ │ │      Frontend       │ │ │  │
│  │ │   Server    │ │  │ │   Grafana   │ │  │ │ └─────────────────────┘ │ │  │
│  │ │     UI      │ │  │ │ Dashboard   │ │  │ │ ┌─────────────────────┐ │ │  │
│  │ └─────────────┘ │  │ └─────────────┘ │  │ │ │      Backend        │ │ │  │
│  └─────────────────┘  └─────────────────┘  │ │ └─────────────────────┘ │ │  │
│                                           │ └─────────────────────────┘ │  │
│  ┌─────────────────┐  ┌─────────────────┐  └─────────────────────────────┘  │
│  │      Vault      │  │     Ingress     │                                  │
│  │   (Secrets)     │  │   Controller    │                                  │
│  │                 │  │     (NGINX)     │                                  │
│  │ ┌─────────────┐ │  │                 │                                  │
│  │ │   Server    │ │  │ ┌─────────────┐ │                                  │
│  │ │     UI      │ │  │ │  Load       │ │                                  │
│  │ └─────────────┘ │  │ │ Balancer    │ │                                  │
│  │ ┌─────────────┐ │  │ └─────────────┘ │                                  │
│  │ │ Secret      │ │  │ ┌─────────────┐ │                                  │
│  │ │ Store       │ │  │ │   SSL       │ │                                  │
│  │ └─────────────┘ │  │ │Termination  │ │                                  │
│  └─────────────────┘  │ └─────────────┘ │                                  │
│                       └─────────────────┘                                  │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flows

### 1. Application Deployment Flow

```
Developer ─┐
           ├─▶ Git Push ─▶ GitLab CI ─▶ Build & Test ─▶ Security Scan
           │                                                    │
           │                                                    ▼
           │                                            Container Registry
           │                                                    │
           │                                                    ▼
           └─▶ Config Update ─▶ GitOps Repo ─▶ ArgoCD ◀────────────┘
                                                │
                                                ▼
                                         Kubernetes Deploy
```

### 2. Monitoring Data Flow

```
Applications ─▶ Metrics ─▶ Prometheus ─▶ Storage ─▶ Grafana ─▶ Dashboards
     │                         │                      │
     ▼                         ▼                      ▼
  Log Files ─▶ Log Agents ─▶ Queries ─▶ Alerts ─▶ Notifications
```

### 3. Secret Management Flow

```
Developer ─▶ Secret Request ─▶ Vault ─▶ Dynamic Secret ─▶ Application
                                │              │
                                ▼              ▼
                           Secret Store ─▶ Rotation ─▶ Auto-Update
```

## 🏗️ Namespace Architecture

```
Kubernetes Cluster
├── argocd                    # GitOps Controller
│   ├── argocd-server        # Web UI & API
│   ├── argocd-controller    # Application Controller
│   ├── argocd-repo-server   # Git Repository Interface
│   └── argocd-redis         # Cache
│
├── monitoring               # Observability Stack
│   ├── prometheus-server    # Metrics Collection
│   ├── grafana             # Visualization
│   ├── alertmanager        # Alert Routing
│   └── node-exporter       # Host Metrics
│
├── vault                   # Secret Management
│   ├── vault-server        # Secret Storage
│   ├── vault-agent         # Secret Injection
│   └── vault-ui            # Management Interface
│
├── pictshare-staging       # Application - Staging
│   ├── pictshare-frontend  # Web Interface
│   ├── pictshare-backend   # API Server
│   └── pictshare-database  # Data Storage
│
└── pictshare-production    # Application - Production
    ├── pictshare-frontend  # Web Interface (HA)
    ├── pictshare-backend   # API Server (HA)
    └── pictshare-database  # Data Storage (HA)
```

## 🔐 Security Architecture

### 1. Authentication & Authorization

```
External Access
       │
       ▼
┌─────────────┐
│   Ingress   │ ◀── TLS Termination
│ Controller  │
└─────────────┘
       │
       ▼
┌─────────────┐
│   Service   │ ◀── Service Mesh (Optional)
│   Mesh      │
└─────────────┘
       │
       ▼
┌─────────────┐
│ Kubernetes  │ ◀── RBAC Policies
│    RBAC     │
└─────────────┘
       │
       ▼
┌─────────────┐
│ Application │ ◀── Pod Security Standards
│   Pods      │
└─────────────┘
```

### 2. Secret Management

```
Vault Secret Engines
├── KV Secrets Engine        # Static secrets
├── Database Engine          # Dynamic DB credentials
├── PKI Engine              # Certificate management
└── Transit Engine          # Encryption as a service

Secret Injection Methods
├── Vault Agent Sidecar     # Automatic secret injection
├── CSI Secret Store        # Volume mounted secrets
└── Operator Integration    # Custom resource secrets
```

### 3. Network Security

```
Network Policies
├── Default Deny All        # Baseline security
├── Namespace Isolation     # Cross-namespace blocking
├── Ingress Rules          # Allow external traffic
└── Egress Rules           # Control outbound traffic

Traffic Flow
External ─▶ Ingress ─▶ Service ─▶ Pod
    │          │          │       │
    └─ TLS ────┘          │       │
               └─ mTLS ───┘       │
                          └─ Pod ─┘
                           Security
                           Context
```

## 📊 Monitoring Architecture

### 1. Metrics Collection

```
Application Metrics
├── Custom Metrics          # Business metrics
├── Runtime Metrics         # JVM, Node.js, etc.
└── Framework Metrics       # Spring, Express, etc.

Infrastructure Metrics
├── Node Metrics           # CPU, Memory, Disk
├── Pod Metrics            # Container resources
├── Network Metrics        # Traffic, latency
└── Storage Metrics        # Volume usage

Platform Metrics
├── Kubernetes API         # Cluster state
├── ArgoCD Metrics         # Deployment status
├── Vault Metrics          # Secret operations
└── Ingress Metrics        # Traffic patterns
```

### 2. Alerting Strategy

```
Alert Levels
├── Critical               # Immediate action required
│   ├── Service Down       # Application unavailable
│   ├── High Error Rate    # >10% error rate
│   └── Resource Exhausted # Out of CPU/Memory
│
├── Warning                # Attention needed
│   ├── High Latency       # >1s response time
│   ├── Resource High      # >80% utilization
│   └── Failed Deployments # ArgoCD sync failures
│
└── Info                   # Informational
    ├── Deployment Success # New version deployed
    ├── Scaling Events     # HPA scaling
    └── Certificate Expiry # SSL cert warnings
```

## 🚀 Scalability Design

### 1. Horizontal Scaling

```
Application Scaling
├── HPA (Horizontal Pod Autoscaler)
│   ├── CPU-based scaling
│   ├── Memory-based scaling
│   └── Custom metrics scaling
│
├── VPA (Vertical Pod Autoscaler)
│   ├── Automatic resource adjustment
│   └── Right-sizing recommendations
│
└── Cluster Autoscaler
    ├── Node auto-provisioning
    └── Cost optimization
```

### 2. Multi-Environment Strategy

```
Environment Promotion
Development ─▶ Staging ─▶ Production
     │            │           │
     ▼            ▼           ▼
Single Pod    Multi-Pod   High Availability
Basic Config  Full Stack  Full Monitoring
     │            │           │
     ▼            ▼           ▼
Feature Tests Integration   Load Testing
              Testing      Chaos Testing
```

## 🔄 Disaster Recovery

### 1. Backup Strategy

```
Backup Targets
├── Application Data
│   ├── Database backups
│   ├── File storage backups
│   └── Configuration backups
│
├── Platform State
│   ├── Kubernetes etcd
│   ├── Vault data
│   └── Monitoring data
│
└── Infrastructure Config
    ├── Terraform state
    ├── Helm releases
    └── ArgoCD applications
```

### 2. Recovery Procedures

```
Recovery Levels
├── Application Recovery     # Single app restoration
├── Service Recovery        # Multiple service restoration
├── Cluster Recovery        # Full cluster rebuild
└── Region Recovery         # Cross-region failover

RTO/RPO Targets
├── Critical Services: RTO <30min, RPO <5min
├── Standard Services: RTO <2hr, RPO <30min
└── Development: RTO <4hr, RPO <2hr
```

This architecture provides a robust, scalable, and secure foundation for modern DevOps workflows while maintaining operational simplicity and developer productivity.