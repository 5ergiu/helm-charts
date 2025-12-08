# Helm Charts

Production-grade Helm charts for Kubernetes deployments following cloud-native best practices.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/charts-5ergiu)](https://artifacthub.io/packages/search?repo=charts-5ergiu)

## 📦 Available Charts

| Chart | Description | Version | Docs |
|-------|-------------|---------|------|
| <a href="https://laravel.com/docs/12.x" style="display:inline-flex;flex-direction:column;align-items:center;text-decoration:none;"><img src="https://cdn.brandfetch.io/ide68-31CH/w/346/h/346/theme/dark/icon.jpeg?c=1bxid64Mup7aczewSAYMX&t=1761211589926" alt="Laravel" width="48" height="48" style="border-radius:4px;margin-bottom:4px;"/><strong style="margin:0;">Laravel</strong></a> | Laravel application deployment with web/worker deployments, queue management, cron jobs, and auto-scaling | [`0.1.0`](https://github.com/5ergiu/helm-charts/releases/tag/laravel-0.1.0) | [README](./charts/laravel/README.md) |
| <a href="https://nextjs.org/" style="display:inline-flex;flex-direction:column;align-items:center;text-decoration:none;"><img src="https://cdn.brandfetch.io/id2alue-rx/w/800/h/800/theme/dark/symbol.png?c=1bxid64Mup7aczewSAYMX&t=1762498501254" alt="Next.js" width="48" height="48" style="border-radius:4px;margin-bottom:4px;"/><strong style="margin:0;">Next.js</strong></a> | High-performance Next.js application deployment with SSR/SSG support, image optimization, and CDN integration | [`0.1.0`](https://github.com/5ergiu/helm-charts/releases/tag/nextjs-0.1.0) | [README](./charts/nextjs/README.md) |

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
