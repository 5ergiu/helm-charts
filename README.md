# Helm Charts

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/5ergiu)](https://artifacthub.io/packages/search?repo=5ergiu)

Production-grade Helm charts for Kubernetes deployments following cloud-native best practices.

## Available Charts

| Chart | Description |
|-------|-------------|
| Laravel | A production-grade Helm chart for Laravel applications with web server, queue workers, cron jobs, and migrations |

## Quick Start

### Prerequisites

- **Kubernetes 1.24+**
- **Helm 3.8+**
- **PV provisioner** support in the underlying infrastructure (if persistence is enabled)

### Installing Charts

```bash
# From GitHub Container Registry
helm install my-app oci://ghcr.io/5ergiu/helm-charts/laravel \
  --version 0.1.0 \
  --namespace production \
  --create-namespace \
  --values values.yaml

# From local clone
git clone https://github.com/5ergiu/helm-charts.git
helm install my-app ./helm-charts/charts/laravel \
  --namespace production \
  --values values.yaml
```

## Chart Features

All charts in this repository provide:

### 🔒 Security First

- **Non-root containers** by default
- **Read-only root filesystems** where possible
- **Dropped Linux capabilities** for minimal attack surface
- **Security contexts** properly configured
- **No hardcoded credentials** - use secrets or external secret providers
- **Cryptographically Signed** - Charts are signed with Cosign for supply chain security

### 📊 Production Ready

- **Comprehensive health checks** (liveness, readiness, startup probes)
- **Resource requests and limits** properly configured
- **Persistent storage** configurations when needed
- **Rolling update strategies** for zero-downtime deployments
- **Pod disruption budgets** for high availability
- **Horizontal Pod Autoscaling** support

### 🎛️ Highly Configurable

- **Extensive values.yaml** with detailed inline documentation
- **Support for existing secrets** and ConfigMaps
- **Flexible ingress configurations** (Traefik, Nginx, etc.)
- **Service account customization**
- **Common labels and annotations** support
- **JSON Schema validation** for values

## Configuration

Each chart provides extensive configuration options through `values.yaml`. Key configuration areas include:

- **Authentication & Security**: User credentials, existing secrets, security contexts
- **Storage**: Persistent volumes, storage classes, backup configurations
- **Networking**: Services, ingress, network policies
- **Scaling**: Replica counts, autoscaling, resource limits
- **Monitoring**: Metrics, service monitors, health checks

Refer to individual chart READMEs for detailed configuration options.

## Contributing

We welcome contributions! Please see our [Contributing Guide](https://github.com/5ergiu/helm-charts/blob/main/CONTRIBUTING.md) for details.

### Development Commands

```bash
# Lint chart
helm lint ./charts/<chart-name>

# Test chart
helm unittest ./charts/<chart-name>

# Render templates locally
helm template test-release ./charts/<chart-name> -n test

# Install for testing
helm install test-release ./charts/<chart-name> -n test

# Package chart
helm package ./charts/<chart-name>
```

## Support

### Chart Issues

For issues specific to these Helm charts:

- Check individual chart README files for troubleshooting
- Review chart documentation and examples
- Verify configuration values
- [Open an issue on GitHub](https://github.com/5ergiu/helm-charts/issues)

## License

Apache 2.0 - See [LICENSE](https://github.com/5ergiu/helm-charts/blob/main/LICENSE) for details.

---

This site is open source. [Improve this page](https://github.com/5ergiu/helm-charts/edit/gh-pages/README.md).
