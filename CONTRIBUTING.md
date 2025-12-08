# Contributing Guidelines

Contributions are welcome via GitHub pull requests. This document outlines the process to help get your contribution accepted.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](./CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

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
- [**helm-unittest plugin**](https://github.com/helm-unittest/helm-unittest) for testing
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

4. Set up commit message enforcement:
   - This repository uses [Lefthook](https://github.com/evilmartians/lefthook) for git hooks.
   - Commit messages are checked against the Conventional Commits format using a shell-based `commit-msg` hook.
   - If your commit message does not match the required format, the commit will be rejected with an error.

5. (Optional) Configure commit signing:
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

### Technical Requirements

- **[Charts best practices](https://helm.sh/docs/topics/chart_best_practices/)**
- **Must pass CI jobs** for linting and installing changed charts with the chart-testing tool
- **Any change to a chart requires a version bump following semver principles**. See [Immutability](#immutability) and [Versioning](#versioning) below

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

- **Extensive `values.yaml`** with detailed inline documentation
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
    └── *_test.yaml
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

### Immutability

Chart releases must be immutable. Any change to a chart warrants a chart version bump even if it is only changed to the documentation.

### Versioning & Changelog

We follow [Semantic Versioning](https://semver.org/) for chart versions:

- **MAJOR**: Incompatible API changes or breaking changes
- **MINOR**: New functionality in a backwards compatible manner
- **PATCH**: Backwards compatible bug fixes

**Pre-1.0 versions** (0.x.x): Indicate charts are in development and may have breaking changes.

**Important**: Always bump the chart version in `Chart.yaml` when making changes.

Changelogs are generated automatically using [git-cliff](https://github.com/orhun/git-cliff), based on Conventional Commits.

### Multi-Chart Repository Workflow

This repository hosts multiple Helm charts. Each chart has **independent versioning** and releases.

**IMPORTANT**: Never push directly to `main`. All changes must go through pull requests.

#### Scenario 1: Adding a New Feature to Existing Chart

Example: Adding Redis support to MyChart chart (MINOR version bump: 0.1.0 → 0.2.0)

```bash
# 1. Create a feature branch from main
git checkout main
git pull origin main
git checkout -b feat/my-chart-redis-support

# 2. Make your changes
vim charts/my-chart/values.yaml
vim charts/my-chart/templates/configmap.yaml
vim charts/my-chart/README.md

# 3. Bump the chart version in Chart.yaml (0.1.0 → 0.2.0)
vim charts/my-chart/Chart.yaml

# 4. Run tests locally
./scripts/test.sh my-chart

# 5. Commit with conventional prefix
git add charts/my-chart/
git commit -m "feat(my-chart): add Redis configuration support"

# 6. Push branch and create pull request
git push origin feat/my-chart-redis-support
# Then create PR on GitHub targeting main branch

# 7. After PR is approved and merged, maintainer will:
#    - Pull main branch
#    - Tag the release: git tag -a my-chart-0.2.0 -m "Add Redis support"
#    - Push: git push origin main --follow-tags
```

#### Scenario 2: Fixing a Bug (PATCH version bump)

Example: Fix deployment template issue (0.2.0 → 0.2.1)

```bash
# 1. Create a fix branch
git checkout main
git pull origin main
git checkout -b fix/my-chart-deployment-probe

# 2. Fix the issue
vim charts/my-chart/templates/web-deployment.yaml

# 3. Bump version (0.2.0 → 0.2.1)
vim charts/my-chart/Chart.yaml

# 4. Test locally
./scripts/test.sh my-chart

# 5. Commit with fix prefix
git add charts/my-chart/
git commit -m "fix(my-chart): correct readiness probe path"

# 6. Push and create pull request
git push origin fix/my-chart-deployment-probe
# Create PR on GitHub

# 7. After merge, maintainer tags and releases
```

#### Scenario 3: Documentation Updates (PATCH version bump)

Example: Update README examples (0.2.1 → 0.2.2)

```bash
# 1. Create docs branch
git checkout main
git pull origin main
git checkout -b docs/my-chart-examples

# 2. Update documentation
vim charts/my-chart/README.md
vim charts/my-chart/values.yaml  # Update inline comments

# 3. Bump version (0.2.1 → 0.2.2)
vim charts/my-chart/Chart.yaml

# 4. Commit with docs prefix
git add charts/my-chart/
git commit -m "docs(my-chart): add PostgreSQL configuration examples"

# 5. Push and create pull request
git push origin docs/my-chart-examples
# Create PR on GitHub

# 6. After merge, maintainer tags and releases
```

#### Scenario 4: Adding a New Chart

Example: Creating an Nginx chart starting at 0.1.0

```bash
# 1. Create feature branch
git checkout main
git pull origin main
git checkout -b feat/nginx-chart

# 2. Create chart structure
mkdir -p charts/nginx/{templates,tests}
# ... create all necessary files ...

# 3. Set initial version to 0.1.0 in Chart.yaml

# 4. Add comprehensive documentation
vim charts/nginx/README.md
vim charts/nginx/values.yaml

# 5. Write tests
vim charts/nginx/tests/deployment_test.yaml

# 6. Test the new chart
./scripts/test.sh nginx

# 7. Commit with feat prefix
git add charts/nginx/
git commit -m "feat(nginx): add initial Nginx Helm chart"

# 8. Push and create pull request
git push origin feat/nginx-chart
# Create PR on GitHub

# 9. After merge, maintainer will:
#    - Tag: git tag -a nginx-0.1.0 -m "Initial Nginx chart release"
#    - Push: git push origin main --follow-tags
```

#### Scenario 5: Infrastructure Changes (No Release)

Example: Updating CI/CD workflows or repository scripts

```bash
# 1. Create infrastructure branch
git checkout main
git pull origin main
git checkout -b chore/update-workflow

# 2. Make changes to infrastructure files
vim .github/workflows/release.yaml
vim README.md

# 3. NO version bump needed (not touching charts)

# 4. Commit with chore prefix (no chart name)
git add .github/ scripts/ README.md
git commit -m "chore: improve chart signing in release workflow"

# 5. Push and create pull request
git push origin chore/update-workflow
# Create PR on GitHub

# 6. After merge, NO tagging or release (only chart changes trigger releases)
```

#### Version Bump Quick Reference

| Change Type | Version Bump | Commit Prefix | Example | Tag Required | Release Triggered |
|-------------|--------------|---------------|---------|--------------|-------------------|
| New feature | MINOR (0.1.0→0.2.0) | `feat(chart/scope):` | Add Redis support | ✅ Yes | ✅ Yes |
| Bug fix | PATCH (0.2.0→0.2.1) | `fix(chart/scope):` | Fix probe path | ✅ Yes | ✅ Yes |
| Documentation | PATCH (0.2.1→0.2.2) | `docs(chart/scope):` | Update README | ✅ Yes | ✅ Yes |
| Tests only | PATCH (0.2.2→0.2.3) | `test(chart/scope):` | Add edge cases | ✅ Yes | ✅ Yes |
| Breaking change | MAJOR (0.x.x→1.0.0) | `feat(chart/scope)!:` | Remove deprecated values | ✅ Yes | ✅ Yes |
| Infrastructure | None | `chore:` | Update workflows | ❌ No | ❌ No |
| New chart | Start at 0.1.0 | `feat(chart/scope):` | Initial release | ✅ Yes | ✅ Yes |

#### Commit Message Convention

Commit messages **must** follow [Conventional Commits](https://www.conventionalcommits.org/) and are enforced by a git hook:

**For chart changes:**
- `feat(chart/scope): description` - New features (MINOR bump)
- `fix(chart/scope): description` - Bug fixes (PATCH bump)
- `docs(chart/scope): description` - Documentation only (PATCH bump)
- `test(chart/scope): description` - Test updates (PATCH bump)
- `feat(chart/scope)!: description` - Breaking changes (MAJOR bump)

**For infrastructure changes:**
- `chore: description` - Tooling, CI/CD, scripts (no release)
- `docs: description` - Root documentation (no release)

**Note**: Documentation changes within a chart directory (`charts/*/README.md`) warrant a PATCH release because the README is part of the chart package displayed on ArtifactHub.

If your commit message does not match the required format, the commit will be rejected. Example:

```
feat(my-chart): add Redis configuration support
```

## Testing

All charts must include comprehensive unit tests using helm-unittest. **For detailed testing documentation, see [TESTING.md](./TESTING.md).**

### Quick Testing Guide

```bash
# Test all charts
./scripts/test.sh

# Test specific chart
./scripts/test.sh laravel

# Test without Kind cluster (unit tests only)
./scripts/test.sh laravel --no-kind
```

### Test Requirements

Your tests should cover:

- Template rendering with default values
- Template rendering with custom values
- Required value validation
- Common configuration scenarios
- Edge cases and error conditions

## Pull Request Process

### 1. Create a Feature Branch from `main`

```bash
git checkout -b feature/your-chart-improvement
```

### 2. Make Your Changes

- Follow the guidelines above
- Write or update tests
- Update documentation
- Bump chart version in `Chart.yaml`

### 3. Run all tests and ensure they pass

```bash
./scripts/test.sh
```

### 4. Update documentation as needed

### 5. Commit Your Changes

Use clear, descriptive commit messages following [Conventional Commits](https://www.conventionalcommits.org/):

```bash
git commit -m "feat(chart/scope): add support for custom annotations"
```

### 5. Push and Create Pull Request

```bash
git push origin feature/your-chart-improvement
```

Create a PR on GitHub with:

- **Clear title** following pattern: `[chart/scope] Descriptive title`
- **Complete** the PR template
- **Reference** to related issues
- **Screenshots/examples** if relevant

### Pull Request Checklist

Before submitting, ensure:

- [ ] Chart version is bumped in `Chart.yaml` (following semver)
- [ ] All values are documented in `values.yaml` and `README.md`
- [ ] All tests pass (`./scripts/test.sh`)
- [ ] Chart passes linting (`helm lint`)
- [ ] Templates render successfully (`helm template`)
- [ ] Documentation is updated
- [ ] Changes are backwards compatible (or breaking changes are clearly documented)

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
