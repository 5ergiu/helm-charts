# Helm Charts

Production-grade Helm charts for Kubernetes deployments following cloud-native best practices.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/5ergiu)](https://artifacthub.io/packages/search?repo=5ergiu)

## 📦 Available Charts

### Laravel Helm Chart

A comprehensive Helm chart for deploying Laravel applications on Kubernetes with all production features.

**Features:**
- 🚀 Web server deployment with horizontal autoscaling
- 👷 Queue workers with Laravel Horizon support
- ⏰ Scheduled task runner (cron)
- 🔄 Automatic database migrations
- 🔒 Security hardened (non-root, read-only filesystem)
- 📊 Built-in observability (Prometheus metrics, health checks)
- 🌐 Traefik ingress with TLS support
- 💾 Persistent storage for uploads/logs
- 🎯 Pod disruption budgets for high availability

**Documentation:** [charts/laravel/README.md](./charts/laravel/README.md)

## 🚀 Quick Start

### Prerequisites

- **Kubernetes 1.24+**
- **Helm 3.8+**
- **PV provisioner** support in the underlying infrastructure (if persistence is enabled)

### Installing Charts

#### From OCI Registry (GitHub Container Registry)

#### From OCI Registry (GitHub Container Registry)

```bash
# Install from GitHub Container Registry
helm install my-app oci://ghcr.io/5ergiu/helm-charts/laravel \
  --version 1.0.0 \
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
helm install my-app ./charts/laravel \
  --namespace production \
  --values values.yaml
```

#### As Git Submodulem install my-app ./helm-chart/charts/laravel \
  --namespace production \
  --values values.yaml
```

#### As Git Submodule

```bash
# Add to your application repository
git submodule add https://github.com/5ergiu/helm-charts.git helm-chart

# Install chart
helm install my-app ./helm-chart/charts/laravel \
  --namespace production \
  --values values.yaml
```

## 💡 Chart Features

All charts in this repository provide:

### Security First

- **Non-root containers** by default
- **Read-only root filesystems** where possible
- **Dropped Linux capabilities** for minimal attack surface
- **Security contexts** properly configured
- **No hardcoded credentials** - use secrets or external secret providers

### Production Ready

- **Comprehensive health checks** (liveness, readiness, startup probes)
- **Resource requests and limits** properly configured
- **Persistent storage** configurations when needed
- **Rolling update strategies** for zero-downtime deployments
- **Pod disruption budgets** for high availability

### Highly Configurable

- **Extensive values.yaml** with detailed documentation
- **Support for existing secrets** and ConfigMaps
- **Flexible ingress** configurations (Traefik, nginx, etc.)
- **Service account customization**
- **Common labels and annotations** support

## 🧪 Testing Charts

## 🧪 Testing Charts

**See [TESTING.md](./TESTING.md) for detailed testing documentation.**

### Quick Start scripts/test.sh laravel

# Test without Kind cluster (unit tests only)
./scripts/test.sh laravel --no-kind
```

### Quick Start

```bash
# Install helm-unittest plugin
helm plugin install https://github.com/helm-unittest/helm-unittest

# Test all charts
./scripts/test.sh

# Test specific chart
./scripts/test.sh laravel

# Test without Kind cluster (unit tests only)
./scripts/test.sh laravel --no-kind
```

## 📚 Configuration

Each chart provides extensive configuration options through `values.yaml`. Key configuration areas include:

- **Authentication & Security**: User credentials, existing secrets, security contexts
- **Storage**: Persistent volumes, storage classes, backup configurations
- **Networking**: Services, ingress, network policies
- **Scaling**: Replica counts, autoscaling, resource limits
- **Monitoring**: Metrics, service monitors, health checks

Refer to individual chart READMEs for detailed configuration options.

## 🔐 Security & Supply Chain

### Signed Commits

This repository encourages signed commits for security and authenticity. See [CONTRIBUTING.md](./CONTRIBUTING.md) for setup instructions.

### Chart Signing with Cosign

Charts can be cryptographically signed using [Cosign](https://docs.sigstore.dev/cosign/) for supply chain security. See [COSIGN.md](./COSIGN.md) for details on verification.

Charts can be cryptographically signed using [Cosign](https://docs.sigstore.dev/cosign/) for supply chain security. See [COSIGN.md](./COSIGN.md) for details on verification.

## 📚 Repository Structure

``` charts/                    # Helm charts
│   └── laravel/              # Laravel application chart
│       ├── Chart.yaml        # Chart metadata
│       ├── values.yaml       # Default configuration
│       ├── values.schema.json # JSON schema for values validation
│       ├── values.example.yaml
│       ├── README.md         # Chart documentation
│       ├── .helmignore       # Files to exclude from chart package
│       ├── templates/        # Kubernetes manifests
│       │   ├── NOTES.txt
│       │   ├── _helpers.tpl
│       │   ├── web-deployment.yaml
│       │   ├── worker-deployment.yaml
│       │   ├── cronjob.yaml
│       │   ├── migration-job.yaml
│       │   ├── service.yaml
│       │   ├── ingress.yaml
│       │   ├── configmap.yaml
│       │   ├── secret.yaml
│       │   ├── serviceaccount.yaml
│       │   ├── hpa.yaml
│       │   ├── pdb.yaml
│       │   ├── pvc.yaml
│       │   └── middleware.yaml
│       └── tests/            # Unit tests
│           ├── web-deployment_test.yaml
│           ├── worker-deployment_test.yaml
│           ├── service_test.yaml
│           ├── ingress_test.yaml
│           ├── cronjob_test.yaml
│           ├── migration-job_test.yaml
│           └── hpa_test.yaml
├── scripts/                   # Helper scripts
│   ├── generate-changelog.sh # Changelog generator
|   ├── test.sh               # Chart testing suite
│   └── update-appversion.sh  # AppVersion updater
├── .github/                   # GitHub Actions
│   └── workflows/e.yaml      # Automated chart publishing
│       ├── pull-request.yaml # PR validation & testing
│       ├── check-signed-commits.yaml
│       └── stale.yaml
├── .editorconfig             # Editor configuration
├── .gitignore                # Git ignore patterns
├── CODE_OF_CONDUCT.md        # Code of Conduct
├── CONTRIBUTING.md           # Contribution guidelines
├── COSIGN.md                 # Chart signing documentation
├── LICENSE                   # Apache 2.0 License
├── README.md                 # This file
├── TESTING.md                # Testing documentation
└── renovate.json             # Renovate configuration
```

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for details on:

- Setting up your development environment
- Code standards and best practices
- Testing requirements
- Pull request process
- Commit signing

## 📝 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 📧 Support

- **Documentation**: Check individual chart READMEs and our [TESTING.md](./TESTING.md)
- **Issues**: [GitHub Issues](https://github.com/5ergiu/helm-charts/issues)
- **Discussions**: [GitHub Discussions](https://github.com/5ergiu/helm-charts/discussions)

## 🌟 Acknowledgments

This project follows best practices inspired by:
- [CloudPirates Helm Charts](https://github.com/CloudPirates-io/helm-charts)
- [Bitnami Charts](https://github.com/bitnami/charts)
- [Artifact Hub](https://artifacthub.io/)

## ⭐ Star History

If you find this project useful, please consider giving it a star on GitHub!

2. **Clone** your fork locally
3. **Create** a feature branch
4. **Make** your changes
5. **Test** your changes: `./scripts/test.sh`
6. **Commit** with clear messages
## ⭐ Star History

If you find this project useful, please consider giving it a star on GitHub!
