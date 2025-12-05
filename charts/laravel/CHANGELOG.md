# Changelog

All notable changes to the Laravel Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-12-04

### Added
- Initial release of Laravel Helm chart
- Production-ready deployment configuration for Laravel applications
- Web deployment with configurable replicas and auto-scaling
- Queue worker deployment with Laravel Horizon support
- Scheduler (cron) for Laravel scheduled tasks via CronJob
- Database migration job as Helm hook (runs before install/upgrade)
- Horizontal Pod Autoscaler (HPA) for web and worker deployments
- Comprehensive health checks (liveness, readiness, startup probes)
- Ingress controller support with TLS/SSL configuration
- Traefik middleware integration (rate limiting, security headers, compression)
- Security hardening (non-root user, read-only filesystem, dropped capabilities)
- Environment variable management via ConfigMap and Secret
- Support for Laravel Horizon dashboard and queue management
- Optional persistent storage for uploads and logs
- Tmpfs volumes for cache, sessions, views, and temporary files
- Pod Disruption Budget for high availability (web and workers)
- ServiceAccount with configurable annotations
- Support for External Secrets Operator
- Init containers for cache warming (config, route, view, storage link)
- Prometheus metrics annotations
- Rolling update strategy with zero downtime
- Comprehensive documentation with examples
- Values schema validation (values.schema.json)
- Example values file (values.example.yaml)
- Professional NOTES.txt with deployment information and useful commands
- Test files for chart validation

### Features
- **Web Deployment**: PHP-FPM/web server with auto-scaling (2-10 replicas)
- **Queue Workers**: Horizon or basic queue worker with auto-scaling
- **Scheduler**: Automated Laravel cron job execution every minute
- **Migrations**: Automatic database migrations via Helm hooks
- **Cache Warming**: Config, route, and view caching on deployment
- **Multi-component Architecture**: Separate deployments for web, workers, and scheduler

### Security
- Non-root user execution (UID 1000, configurable)
- Read-only root filesystem
- Security context with dropped capabilities
- Seccomp profile (RuntimeDefault)
- Pod security standards compliant
- Separate secrets management for sensitive data

### Configuration
- Configurable resource limits and requests for each component
- Flexible environment variable configuration
- Database connection support (MySQL, PostgreSQL, etc.)
- Redis integration for cache, session, and queue
- SMTP/email configuration
- AWS S3 integration support
- Broadcasting and session drivers
- Customizable health check endpoints

### Documentation
- Comprehensive README with installation instructions
- Configuration examples for production and local development
- Docker image requirements and best practices
- Health check endpoint setup guide
- Security best practices and checklist
- Troubleshooting guide
- Laravel-specific commands and examples
- Monitoring and observability setup

[0.1.0]: https://github.com/5ergiu/helm-charts/releases/tag/laravel-0.1.0
