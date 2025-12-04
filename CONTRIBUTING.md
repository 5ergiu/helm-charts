# Contributing to Helm Charts

Thank you for your interest in contributing to our Helm charts! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

This project follows standard open source best practices. Please be respectful and constructive in all interactions.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title**: Use a descriptive title
- **Steps to reproduce**: Exact steps to reproduce the problem
- **Expected behavior**: What you expected to happen
- **Actual behavior**: What actually happened
- **Environment details**: Kubernetes version, Helm version, chart version

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. Include:

- **Clear title**: Use a descriptive title
- **Detailed description**: Explain the enhancement and why it would be useful
- **Examples**: Provide specific examples demonstrating the use case
- **Current behavior**: Describe current behavior and explain what you'd like to see

### Types of Contributions

- **New Features**: Enhancements to existing charts
- **Bug Fixes**: Corrections to chart issues
- **Documentation**: Improvements to README files and values documentation
- **Tests**: Additional test coverage

## Development Setup

### Prerequisites

- **Kubernetes 1.23+**
- **Helm 3.8+**
- **helm-unittest plugin** for testing
- **Git** with commit signing configured

### Setting Up Your Development Environment

1. Fork the repository on GitHub

2. Clone your fork locally:
   ```bash
   git clone https://github.com/your-username/helm-charts.git
   cd helm-charts
   ```

3. Install the helm-unittest plugin:
   ```bash
   helm plugin install https://github.com/helm-unittest/helm-unittest
   ```

4. (Optional) Configure commit signing:
   ```bash
   # For SSH signing
   git config gpg.format ssh
   git config user.signingkey ~/.ssh/id_ed25519.pub
   git config commit.gpgsign true
   git config tag.gpgsign true
   
   # Add --global to apply to all repositories
   ```

   More information: [GitHub Docs on Commit Signature Verification](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification)

## Contributing Guidelines

### Chart Development Standards

All charts must follow these standards:

#### Security First

- **Read-only root filesystems** where possible
- **Drop unnecessary Linux capabilities**
- **Proper security contexts** (non-root, specific user/group IDs)
- **Never hardcode credentials** - use secrets or external secret providers

#### Production Ready

- **Comprehensive health checks** (liveness, readiness, startup probes)
- **Resource requests and limits** properly configured
- **Persistent storage** configurations when needed
- **Horizontal Pod Autoscaling** support
- **Pod Disruption Budgets** for high availability

#### Highly Configurable

- **Extensive values.yaml** with detailed inline documentation
- **Support for existing secrets** and ConfigMaps
- **Flexible ingress configurations**
- **Service account customization**
- **Common labels and annotations**

### Chart Structure

Follow this standard structure:

```
charts/your-chart/
├── Chart.yaml
├── README.md
├── values.yaml
├── values.example.yaml
├── publish-chart.sh
├── templates/
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── serviceaccount.yaml
│   ├── hpa.yaml
│   └── pdb.yaml
└── tests/
    ├── deployment_test.yaml
    ├── service_test.yaml
    └── ingress_test.yaml
```

### Documentation Requirements

Each chart must include:

1. **Chart.yaml**: Complete metadata with proper versioning
2. **README.md**: Comprehensive documentation including:
   - Chart description and purpose
   - Prerequisites and requirements
   - Installation instructions
   - Configuration parameters table
   - Examples and common configurations
   - Troubleshooting section
   - FAQ
3. **values.yaml**: Well-documented default values with inline comments
4. **values.example.yaml**: Example configuration for common use cases

### Versioning

We follow [Semantic Versioning](https://semver.org/) for chart versions:

- **MAJOR**: Incompatible API changes or breaking changes
- **MINOR**: New functionality in a backwards compatible manner
- **PATCH**: Backwards compatible bug fixes

**Pre-1.0 versions** (0.x.x): Indicate charts are in development and may have breaking changes.

**Important**: Always bump the chart version in `Chart.yaml` when making changes.

### Multi-Chart Repository Workflow

This repository hosts multiple Helm charts. Each chart has **independent versioning** and releases:

#### Working on a Specific Chart

When modifying an existing chart:

```bash
# 1. Create a feature branch
git checkout -b feat/laravel-redis-support

# 2. Make changes only to that chart
vim charts/laravel/values.yaml
vim charts/laravel/templates/configmap.yaml

# 3. Bump the chart version in Chart.yaml
# 0.1.0 -> 0.2.0 (new feature)
vim charts/laravel/Chart.yaml

# 4. Commit with chart-specific prefix
git add charts/laravel/
git commit -m "feat(laravel): add Redis configuration support"

# 5. Tag the chart release
git tag -a laravel-0.2.0 -m "Add Redis configuration support"

# 6. Generate changelog
./scripts/generate-changelog.sh --chart laravel

# 7. Commit the changelog
git add charts/laravel/
git commit -m "docs(laravel): add changelog for v0.2.0"

# 8. Push commits and tag
git push origin feat/laravel-redis-support
git push origin laravel-0.2.0
```

#### Adding a New Chart

When adding a new chart:

```bash
# 1. Create chart structure
mkdir -p charts/nginx
# ... add chart files ...

# 2. Start with version 0.1.0 in Chart.yaml

# 3. Commit the new chart
git add charts/nginx/
git commit -m "feat(nginx): add initial Nginx Helm chart"

# 4. Tag the initial release
git tag -a nginx-0.1.0 -m "Initial release of Nginx Helm chart"

# 5. Generate changelog
./scripts/generate-changelog.sh --chart nginx

# 6. Commit the changelog
git add charts/nginx/
git commit -m "docs(nginx): add changelog for v0.1.0"
```

#### Infrastructure Changes

For changes to repository infrastructure (workflows, scripts, docs):

```bash
# Commit without chart prefix
git add .github/ scripts/ README.md
git commit -m "chore: update CI/CD workflow for chart signing"

# NO TAG - infrastructure changes don't trigger chart releases
git push origin main
```

#### Commit Message Convention

Follow this pattern for clarity:

- `feat(chart-name): description` - New features
- `fix(chart-name): description` - Bug fixes
- `docs(chart-name): description` - Documentation changes
- `test(chart-name): description` - Test updates
- `chore: description` - Infrastructure/tooling changes (no chart prefix)

## Testing

### Running Tests Locally

All charts must include comprehensive unit tests using helm-unittest:

```bash
# Test specific chart
helm unittest charts/laravel

# Test all charts
for chart in charts/*; do
  if [ -d "$chart/tests" ]; then
    echo "Testing $chart..."
    helm unittest $chart
  fi
done
```

### Test Requirements

Your tests should cover:

- Template rendering with default values
- Template rendering with custom values
- Required value validation
- Common configuration scenarios
- Edge cases and error conditions

### Manual Testing

Before submitting, manually test your chart:

```bash
# Lint the chart
helm lint ./charts/your-chart

# Render templates locally
helm template test-release ./charts/your-chart -n test

# Install in a test cluster
helm install test-release ./charts/your-chart -n test --create-namespace

# Verify the deployment
kubectl get all -n test

# Test with custom values
helm install test-release ./charts/your-chart -n test -f custom-values.yaml

# Cleanup
helm uninstall test-release -n test
kubectl delete namespace test
```

### Integration Testing

Pull requests automatically run integration tests in a Kind cluster. Ensure your changes:

- Deploy successfully in a fresh cluster
- Pass all health checks
- Work with default values
- Work with common customizations

## Pull Request Process

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-chart-improvement
```

### 2. Make Your Changes

- Follow the guidelines above
- Write or update tests
- Update documentation
- Bump chart version in `Chart.yaml`

### 3. Run Tests

```bash
# Lint
helm lint ./charts/your-chart

# Unit tests
helm unittest ./charts/your-chart

# Template rendering
helm template test ./charts/your-chart
```

### 4. Commit Your Changes

Use clear, descriptive commit messages:

```bash
git commit -m "[chart-name] Add support for custom annotations"
```

### 5. Push and Create Pull Request

```bash
git push origin feature/your-chart-improvement
```

Create a PR on GitHub with:

- **Clear title** following pattern: `[chart-name] Descriptive title`
- **Description** explaining what and why
- **Reference** to related issues
- **Screenshots/examples** if relevant

### Pull Request Checklist

Before submitting, ensure:

- [ ] Chart version is bumped in `Chart.yaml` (following semver)
- [ ] All values are documented in `values.yaml` and `README.md`
- [ ] Unit tests pass (`helm unittest`)
- [ ] Chart passes linting (`helm lint`)
- [ ] Templates render successfully (`helm template`)
- [ ] Documentation is updated
- [ ] Changes are backwards compatible (or breaking changes are clearly documented)
- [ ] Tested manually in a local cluster

### Review Process

1. Automated checks run (linting, unit tests, integration tests)
2. Maintainers review the code
3. Address any feedback
4. Once approved, changes are merged to main
5. Charts are automatically published to OCI registries

## Development Tips

### Useful Commands

```bash
# Validate Chart.yaml
helm show chart ./charts/your-chart

# Show all values
helm show values ./charts/your-chart

# Debug template rendering
helm template test ./charts/your-chart --debug

# Dry-run installation
helm install test ./charts/your-chart --dry-run --debug

# Package chart locally
helm package ./charts/your-chart

# Test specific template
helm template test ./charts/your-chart -s templates/deployment.yaml
```

### Testing with Different Values

```bash
# Create test values file
cat > test-values.yaml <<EOF
replicaCount: 3
image:
  tag: latest
EOF

# Test with custom values
helm template test ./charts/your-chart -f test-values.yaml
```

### Local OCI Registry Testing

```bash
# Start local registry
docker run -d -p 5000:5000 --name registry registry:2

# Push chart
helm package ./charts/your-chart
helm push your-chart-1.0.0.tgz oci://localhost:5000/charts

# Pull chart
helm pull oci://localhost:5000/charts/your-chart --version 1.0.0

# Cleanup
docker rm -f registry
```

## Questions?

If you have questions about contributing, please:

1. Check existing issues and documentation
2. Create a new issue with the question label
3. Reach out to the maintainers

Thank you for contributing! 🎉
