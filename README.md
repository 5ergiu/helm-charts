# Helm Charts

Production-grade Helm charts for Kubernetes deployments following cloud-native best practices.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/charts-5ergiu)](https://artifacthub.io/packages/search?repo=charts-5ergiu)

## 📦 Available Charts

| Chart | Description | Version | Docs |
|-------|-------------|---------|------|
| <a href="https://laravel.com/docs/12.x" style="display:inline-flex;flex-direction:column;align-items:center;text-decoration:none;"><img src="https://cdn.brandfetch.io/ide68-31CH/w/346/h/346/theme/dark/icon.jpeg?c=1bxid64Mup7aczewSAYMX&t=1761211589926" alt="Laravel" width="48" height="48" style="border-radius:4px;margin-bottom:4px;"/><strong style="margin:0;">Laravel</strong></a> | Laravel application deployment with web/worker deployments, queue management, cron jobs, and auto-scaling | ![Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/5ergiu/helm-charts/main/charts/laravel/Chart.yaml&label=&query=version&prefix=v) | [README](./charts/laravel/README.md) |
| <a href="https://nextjs.org/" style="display:inline-flex;flex-direction:column;align-items:center;text-decoration:none;"><img src="https://cdn.brandfetch.io/id2alue-rx/w/800/h/800/theme/dark/symbol.png?c=1bxid64Mup7aczewSAYMX&t=1762498501254" alt="Next.js" width="48" height="48" style="border-radius:4px;margin-bottom:4px;"/><strong style="margin:0;">Next.js</strong></a> | High-performance Next.js application deployment with SSR/SSG support, image optimization, and CDN integration | ![Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/5ergiu/helm-charts/main/charts/nextjs/Chart.yaml&label=&query=version&prefix=v) | [README](./charts/nextjs/README.md) |

## 🚀 Quick Start

### Prerequisites

- **Kubernetes 1.24+**
- **Helm 3.8+**

### Installing Charts

#### From OCI Registry (Recommended)

```bash
# Install from GitHub Container Registry
helm install my-app oci://ghcr.io/5ergiu/helm-charts/my-chart \
  --version 0.1.0 \
  --namespace production \
  --create-namespace \
  --values values.yaml
```

#### From GitHub Release

```bash
# Download chart from releases
wget https://github.com/5ergiu/helm-charts/releases/download/my-chart-0.1.0/my-chart-0.1.0.tgz

# Install from local archive
helm install my-app my-chart-0.1.0.tgz \
  --namespace production \
  --create-namespace \
  --values values.yaml
```

#### From Local Clone

```bash
# Clone repository
git clone https://github.com/5ergiu/helm-charts.git
cd helm-charts

# Install chart
helm install my-app ./charts/my-chart \
  --namespace production \
  --create-namespace \
  --values values.yaml
```

## 💡 Chart Features

All charts in this repository provide:

### Security & Supply Chain

- **Non-root containers** by default
- **Read-only root filesystems** where possible
- **Dropped Linux capabilities** for minimal attack surface
- **Security contexts** properly configured
- **No hardcoded credentials** - use secrets or external secret providers
- **Cryptographically signed charts** with [Cosign](https://docs.sigstore.dev/cosign/) - see [COSIGN.md](./COSIGN.md)
- **Signed commits** encouraged for authenticity - see [CONTRIBUTING.md](./CONTRIBUTING.md)

### Production Ready

- **Comprehensive health checks** (liveness, readiness, startup probes)
- **Resource requests and limits** properly configured
- **Persistent storage** configurations when needed
- **Rolling update strategies** for zero-downtime deployments
- **Pod disruption budgets** for high availability
- **Horizontal pod autoscaling** support

## 📚 Configuration

Each chart provides extensive configuration options through `values.yaml`. Key configuration areas include:

- **Authentication & Security**: User credentials, existing secrets, security contexts
- **Storage**: Persistent volumes, storage classes, backup configurations
- **Networking**: Services, ingress, network policies
- **Scaling**: Replica counts, autoscaling, resource limits
- **Monitoring**: Metrics, service monitors, health checks

Refer to individual chart READMEs for detailed configuration options.

## 🐳 Building Example Images

The [examples/](./examples/) directory contains sample applications (Next.js, Laravel) with multi-stage Dockerfiles for demonstration purposes. These images are built separately and used by the Helm charts for testing.

### Automatic Builds

Docker images are built automatically and pushed to [GitHub Container Registry (GHCR)](https://github.com/orgs/5ergiu/packages?repo_name=helm-charts) using the **Build and Push Images** workflow.

**When to trigger builds:**
- When you modify Dockerfiles in the `examples/` directory
- When you want to update example application dependencies
- When creating new example applications

### Manual Workflow Trigger

Since Dockerfiles change rarely, image builds are **manually triggered** rather than running on every PR:

1. Go to [Actions → Build and Push Images](../../actions/workflows/build-push-images.yaml)
2. Click **Run workflow**
3. Optionally specify which apps to build (comma-separated), or leave empty to build all:
   ```
   nextjs,laravel
   ```

### Image Tagging Strategy

Images are tagged based on the build target:

- **Development builds** (`target: development`): Tagged as `appName:dev` (always overwritten)
- **Production builds** (`target: production`): Semantic versioning with `appName:vX.Y.Z` + `appName:latest`
  - Version bumping follows [Conventional Commits](https://www.conventionalcommits.org/)
  - Git tags are created as `appName/vX.Y.Z`

**Example tags:**
```bash
# Development
ghcr.io/5ergiu/nextjs:dev
ghcr.io/5ergiu/laravel:dev

# Production
ghcr.io/5ergiu/nextjs:latest
```

### Local Builds

You can also build images locally for testing:

```bash
# Build development target
cd examples/nextjs
docker build --target development -t nextjs:dev .

# Build production target
docker build --target production -t nextjs:latest .
```

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for details on:

- Setting up your development environment
- Code standards and best practices
- Testing requirements and running tests
- Pull request process
- Commit signing

**Questions or Need Help?**
- Check individual chart READMEs and [TESTING.md](./TESTING.md)
- Open an issue: [GitHub Issues](https://github.com/5ergiu/helm-charts/issues)
- Start a discussion: [GitHub Discussions](https://github.com/5ergiu/helm-charts/discussions)

## 📝 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

If you find this project useful, please consider giving it a star on GitHub!
