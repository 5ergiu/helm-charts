# Changelog

All notable changes to the Next.js Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-12-05

### Added
- Initial release of Next.js Helm chart
- Production-ready deployment configuration
- Support for Server-Side Rendering (SSR) and Static Site Generation (SSG)
- Horizontal Pod Autoscaler (HPA) with configurable CPU/Memory targets
- Comprehensive health checks (liveness, readiness, startup probes)
- Ingress controller support with TLS/SSL configuration
- Traefik middleware integration (rate limiting, headers, compression)
- Security hardening (non-root user, read-only filesystem, dropped capabilities)
- Separate public and server-side environment variable management
- Kubernetes Secrets for sensitive data
- Optional persistent storage for uploads/generated files
- Tmpfs volumes for cache and temporary files
- Pod Disruption Budget for high availability
- ServiceAccount with configurable annotations
- ConfigMap and Secret management
- Support for External Secrets Operator
- Init containers for build verification
- Prometheus metrics annotations
- Rolling update strategy with zero downtime
- Comprehensive documentation and examples
- Values schema validation (values.schema.json)
- Example values file (values.example.yaml)
- Professional NOTES.txt with deployment information
- Test files for chart validation

### Security
- Non-root user execution (UID 1000)
- Read-only root filesystem
- Security context with dropped capabilities
- Seccomp profile (RuntimeDefault)
- Pod security standards compliant

### Documentation
- Comprehensive README with installation instructions
- Configuration examples for common scenarios
- Docker image requirements and Dockerfile example
- Health check endpoint examples
- Security best practices
- Troubleshooting guide
- Local development setup guide
- Monitoring and observability setup

[0.1.0]: https://github.com/5ergiu/helm-charts/releases/tag/nextjs-0.1.0
