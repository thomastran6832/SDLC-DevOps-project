# 🤝 Contributing to Kubernetes DevOps Platform

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## 📋 Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Contribution Guidelines](#contribution-guidelines)
- [Testing](#testing)
- [Documentation](#documentation)
- [Review Process](#review-process)

## 📜 Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

### Our Standards
- **Be respectful** and inclusive
- **Be collaborative** and helpful
- **Be patient** with newcomers
- **Focus on what's best** for the community

## 🚀 Getting Started

### Prerequisites
- Git
- Docker
- Kubernetes cluster (minikube, kind, or cloud)
- kubectl
- Helm 3.x
- (Optional) Terraform

### Fork and Clone
```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/yourusername/kubernetes-devops-platform.git
cd kubernetes-devops-platform

# Add upstream remote
git remote add upstream https://github.com/originalowner/kubernetes-devops-platform.git
```

### Local Development Setup
```bash
# Deploy to local development cluster
./scripts/deploy-all.sh

# Set up port forwarding for testing
./scripts/port-forward.sh

# Verify everything is working
curl http://localhost:8080  # PictShare
curl http://localhost:8081  # ArgoCD
```

## 🔄 Development Workflow

### Branch Strategy
We use **GitFlow** branching model:

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/feature-name` - New features
- `hotfix/fix-name` - Critical fixes
- `release/version` - Release preparation

### Creating a Feature Branch
```bash
# Update your local repository
git checkout develop
git pull upstream develop

# Create feature branch
git checkout -b feature/amazing-feature

# Make your changes
# ... code, test, commit ...

# Push to your fork
git push origin feature/amazing-feature
```

### Commit Guidelines
We follow **Conventional Commits** specification:

```bash
# Format: type(scope): description
git commit -m "feat(helm): add autoscaling support to pictshare chart"
git commit -m "fix(argocd): resolve sync issue with staging environment"
git commit -m "docs(readme): update installation instructions"
git commit -m "test(ci): add integration tests for monitoring stack"
```

#### Commit Types
- `feat` - New features
- `fix` - Bug fixes
- `docs` - Documentation changes
- `style` - Code style changes
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance tasks
- `ci` - CI/CD changes

## 📝 Contribution Guidelines

### What We're Looking For
- 🐛 **Bug fixes** - Help us identify and fix issues
- ✨ **New features** - Add functionality that benefits the community
- 📚 **Documentation** - Improve or add documentation
- 🧪 **Tests** - Add or improve test coverage
- 🔧 **DevOps improvements** - Enhance CI/CD, monitoring, security

### Areas for Contribution

#### Infrastructure & DevOps
- Terraform modules for different cloud providers
- Helm chart improvements
- CI/CD pipeline enhancements
- Security hardening
- Performance optimizations

#### Applications
- New sample applications
- Application monitoring improvements
- Health check implementations
- Configuration management

#### Documentation
- Installation guides for different environments
- Troubleshooting guides
- Architecture documentation
- Video tutorials

#### Monitoring & Observability
- Custom Grafana dashboards
- Prometheus alert rules
- Log aggregation improvements
- Distributed tracing

### Coding Standards

#### Helm Charts
```yaml
# Use consistent naming
apiVersion: v2
name: my-app
version: 1.0.0

# Include proper labels
metadata:
  labels:
    app.kubernetes.io/name: my-app
    app.kubernetes.io/version: "1.0.0"
    app.kubernetes.io/managed-by: Helm

# Use values for configuration
spec:
  replicas: {{ .Values.replicaCount }}
```

#### Kubernetes Manifests
- Use proper resource limits and requests
- Include health checks (liveness/readiness probes)
- Follow security best practices
- Use meaningful labels and annotations

#### Terraform
```hcl
# Use consistent formatting
resource "kubernetes_deployment" "example" {
  metadata {
    name      = "example"
    namespace = var.namespace

    labels = {
      app = "example"
    }
  }

  spec {
    replicas = var.replica_count
    # ... rest of configuration
  }
}

# Include proper outputs
output "service_url" {
  description = "The URL of the service"
  value       = "http://${kubernetes_service.example.metadata[0].name}"
}
```

#### Documentation
- Use clear, concise language
- Include code examples
- Add diagrams where helpful
- Keep README files up to date

## 🧪 Testing

### Required Tests
Before submitting a PR, ensure your changes pass all tests:

```bash
# Lint Helm charts
helm lint charts/*/

# Validate Kubernetes manifests
kubeval k8s/**/*.yaml

# Test Terraform modules
cd terraform/modules/example
terraform init
terraform validate
terraform plan

# Run integration tests
./scripts/test-integration.sh
```

### Test Categories

#### Unit Tests
- Helm chart template rendering
- Terraform module validation
- Configuration validation

#### Integration Tests
- End-to-end deployment testing
- Service connectivity tests
- Health check validation

#### Security Tests
- Container vulnerability scanning
- Configuration security analysis
- RBAC validation

### Adding New Tests
```bash
# Add test for new Helm chart
mkdir -p charts/my-app/tests
cat > charts/my-app/tests/deployment_test.yaml << EOF
suite: test deployment
tests:
  - it: should render deployment correctly
    template: deployment.yaml
    asserts:
      - isKind:
          of: Deployment
      - equal:
          path: metadata.name
          value: my-app
EOF
```

## 📚 Documentation

### Documentation Structure
```
docs/
├── ARCHITECTURE.md     # System architecture
├── DEPLOYMENT.md       # Deployment guide
├── TROUBLESHOOTING.md  # Common issues
├── SECURITY.md         # Security guidelines
└── examples/           # Usage examples
```

### Writing Guidelines
- **Start with user needs** - What problem does this solve?
- **Provide context** - Why is this important?
- **Include examples** - Show, don't just tell
- **Test your instructions** - Ensure they work
- **Update related docs** - Keep everything consistent

### Adding New Documentation
1. Check if existing docs can be updated instead
2. Follow the established structure and style
3. Include table of contents for long documents
4. Add links to related documentation
5. Include diagrams using Mermaid or similar tools

## 🔍 Review Process

### Pull Request Guidelines
1. **Create descriptive PRs**
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Documentation update
   - [ ] Breaking change

   ## Testing
   - [ ] Unit tests pass
   - [ ] Integration tests pass
   - [ ] Manual testing completed

   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Documentation updated
   - [ ] Tests added/updated
   ```

2. **Keep PRs focused** - One feature/fix per PR
3. **Update documentation** - Include doc updates in the same PR
4. **Test thoroughly** - Ensure your changes don't break existing functionality

### Review Criteria
- **Functionality** - Does it work as intended?
- **Code quality** - Is it well-written and maintainable?
- **Documentation** - Is it properly documented?
- **Testing** - Are there adequate tests?
- **Security** - Does it follow security best practices?
- **Performance** - Does it impact system performance?

### Getting Your PR Merged
1. **Address feedback** promptly and thoroughly
2. **Be responsive** to questions and suggestions
3. **Test again** after making changes
4. **Squash commits** if requested (we prefer clean history)

## 🏷️ Issue Guidelines

### Reporting Bugs
Use the bug report template and include:
- **Environment details** (OS, Kubernetes version, etc.)
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Logs and error messages**
- **Screenshots** if applicable

### Requesting Features
Use the feature request template and include:
- **Problem description** - What need does this address?
- **Proposed solution** - How should it work?
- **Alternatives considered** - What other options did you consider?
- **Additional context** - Any other relevant information

### Security Issues
For security vulnerabilities:
1. **Do NOT** create a public issue
2. Email security@yourproject.com
3. Include detailed reproduction steps
4. We'll respond within 48 hours

## 🙏 Recognition

### Contributors
We recognize contributors in several ways:
- **Contributors.md** file listing all contributors
- **GitHub contributors** widget in README
- **Releases notes** mention significant contributions
- **Blog posts** highlighting major contributions

### Becoming a Maintainer
Active contributors may be invited to become maintainers. We look for:
- **Consistent contributions** over time
- **High-quality code and documentation**
- **Helpful community interaction**
- **Understanding of project goals**

## 📞 Getting Help

### Community Support
- **GitHub Discussions** - General questions and discussions
- **Slack Channel** - Real-time chat with maintainers
- **Stack Overflow** - Tag questions with `kubernetes-devops-platform`

### Maintainer Contact
- **Email**: maintainers@yourproject.com
- **Slack**: @maintainer-team
- **Twitter**: @yourproject

---

Thank you for contributing to making this project better! 🚀