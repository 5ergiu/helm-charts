# Laravel Helm Chart

A production-grade Helm chart for deploying Laravel applications on Kubernetes.

## 🗒️ Prerequisites

- Kubernetes 1.23+
- Helm 3.8+
- Traefik Ingress Controller (if using Ingress)
- PersistentVolume provisioner support in the underlying infrastructure

## 🚀 Installation Methods

You can use this Helm chart **without depending on the entire infrastructure project**. Choose the method that works best for you:

### Method 1: Direct from Git (Recommended for Getting Started)

Install directly from the Git repository URL:

```bash
# Install directly from GitHub Container Registry
helm install my-laravel-app \
  oci://ghcr.io/5ergiu/helm-charts/laravel \
  --version 0.1.0 \
  --namespace production \
  --create-namespace \
  --values values/production.yaml
```

### Method 2: Git Submodule (Best for Version Control)

Add the chart as a submodule in your Laravel application:

```bash
# In your Laravel app repository
cd your-laravel-app/

# Add chart as submodule
git submodule add https://github.com/5ergiu/helm-charts.git helm-chart

# Use specific chart directory
helm install my-app ./helm-chart/charts/laravel \
  --namespace production \
  --values values/production.yaml

# Update submodule to latest
git submodule update --remote helm-chart
```

### Method 3: Package and Host (Production-Ready)

Package the chart and host it in an OCI registry (GitHub, GitLab, Harbor, etc.):

```bash
# Package the chart
helm package ./charts/laravel
# Creates: laravel-0.1.0.tgz

# Push to OCI registry (GitHub Container Registry example)
helm registry login ghcr.io -u <username>
helm push laravel-0.1.0.tgz oci://ghcr.io/5ergiu/helm-charts

# Install from registry
helm install my-laravel-app \
  oci://ghcr.io/5ergiu/helm-charts/laravel \
  --version 0.1.0 \
  --namespace production \
  --values values/production.yaml
```

### Method 4: Local Copy (Simple)

Copy the chart directory to your project:

```bash
# Clone the repository
git clone https://github.com/5ergiu/helm-charts.git

# Copy chart to your Laravel app
cp -r helm-charts/charts/laravel your-laravel-app/helm/

# Use it
helm install my-app ./charts/laravel \
  --namespace production \
  --values values/production.yaml
```

## 📦 Quick Start Example

Using the **Git submodule** method (recommended for most use cases):

```bash
# 1. In your Laravel application repository
cd ~/projects/my-laravel-app

# 2. Add chart as submodule
git submodule add <INFRASTRUCTURE_REPO_URL> .helm-chart

# 3. Create values file
mkdir -p helm-values
cat > helm-values/production.yaml <<EOF
image:
  repository: ghcr.io/yourorg/my-laravel-app
  tag: "1.0.0"

ingress:
  hosts:
    - host: app.example.com
      paths:
        - path: /
          pathType: Prefix

env:
  APP_NAME: "MyApp"
  APP_ENV: production
  APP_DEBUG: "false"
  DB_HOST: mysql.databases.svc.cluster.local
  REDIS_HOST: redis.databases.svc.cluster.local

secrets:
  enabled: true
  data:
    APP_KEY: "base64:your-key-here"
    DB_PASSWORD: "your-password"
EOF

# 4. Deploy
helm install my-app .helm-chart/charts/laravel \
  --namespace production \
  --create-namespace \
  -f helm-values/production.yaml

# 5. Commit to your repo
git add .gitmodules .helm-chart helm-values/
git commit -m "Add Helm chart and production values"
```

## 🔄 Basic Usage

```bash
# Upgrade existing release
helm upgrade my-laravel-app ./charts/laravel \
  --namespace production \
  --values values/production.yaml

# Upgrade with image tag override
helm upgrade my-laravel-app ./charts/laravel \
  --namespace production \
  --values values/production.yaml \
  --set image.tag=v1.2.3

# Check release status
helm status my-laravel-app -n production

# View release history
helm history my-laravel-app -n production

# Uninstall
helm uninstall my-laravel-app -n production
```

## 🏗️ Recommended Setup for Production

For a production-ready setup:

**In your Laravel application repository:**
```
your-laravel-app/
├── .helm-chart/              # Git submodule pointing to infrastructure repo
├── helm-values/
│   ├── local.yaml           # Local development config
│   ├── staging.yaml         # Staging environment
│   └── production.yaml      # Production (secrets via CI/CD)
├── .github/workflows/
│   └── deploy.yml           # CI/CD deployment
└── ...
```

**GitHub Actions deployment example:**
```yaml
name: Deploy to Production

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: true  # Fetch chart submodule
      
      - name: Setup Helm
        uses: azure/setup-helm@v3
      
      - name: Deploy
        run: |
          helm upgrade --install my-app .helm-chart/charts/laravel \
            --namespace production \
            --create-namespace \
            -f helm-values/production.yaml \
            --set image.tag=${{ github.ref_name }} \
            --set secrets.data.APP_KEY="${{ secrets.APP_KEY }}" \
            --set secrets.data.DB_PASSWORD="${{ secrets.DB_PASSWORD }}"
```

**Benefits of this approach:**
- ✅ Chart version controlled via Git submodule
- ✅ Secrets managed by CI/CD (not in repo)
- ✅ Environment-specific configs in your app repo
- ✅ Easy to update chart: `git submodule update --remote`
- ✅ No dependency on entire infrastructure project

## 📁 Structure

```
charts/laravel/
├── Chart.yaml                    # Helm chart metadata
├── values.yaml                   # Default configuration template
├── values.example.yaml           # Example configuration
├── README.md                     # Complete chart documentation
│
└── templates/                    # Kubernetes resource templates
   ├── _helpers.tpl             # Template helper functions
   ├── web-deployment.yaml      # Web server deployment (PHP-FPM/Nginx)
   ├── worker-deployment.yaml   # Queue worker deployment
   ├── cronjob.yaml             # Scheduler (cron)
   ├── migration-job.yaml       # Database migration job (Helm hook)
   ├── service.yaml             # ClusterIP service
   ├── ingress.yaml             # Traefik ingress
   ├── middleware.yaml          # Traefik middlewares (rate limit, headers, etc.)
   ├── hpa.yaml                 # Horizontal Pod Autoscalers
   ├── pdb.yaml                 # Pod Disruption Budgets
   ├── configmap.yaml           # Non-sensitive configuration
   ├── secret.yaml              # Sensitive data
   ├── serviceaccount.yaml      # RBAC service account
   ├── pvc.yaml                 # Persistent storage
   ├── NOTES.txt                # Post-installation instructions
   └── tests/                   # Helm tests
       └── test-connection.yaml
```

## 🎯 Purpose

This Helm chart provides a **production-ready, reusable template** for deploying Laravel applications to Kubernetes. It's designed to:

1. **Standardize Deployments**: Consistent deployment process across all environments
2. **Security Hardened**: Pod Security Standards "Restricted" compliance
3. **High Availability**: Auto-scaling, pod disruption budgets, health checks

## ⭐ Features

- 🚀 **Production Ready**: Built following Kubernetes and Helm best practices
- 🔄 **Complete Laravel Support**: Web, Queue Workers, and Scheduler (Cron)
- 📈 **Auto-scaling**: HorizontalPodAutoscaler for both web and worker components
- 🛡️ **High Availability**: Pod Disruption Budgets and anti-affinity rules
- 🔒 **Security**: Non-root containers, read-only root filesystem support, security contexts
- 🌐 **Ingress**: Full Traefik integration with middleware support
- ⚡ **Performance**: Configurable resource limits, probes, and caching
- 📦 **Persistence**: PVC support for storage/logs
- 🔧 **Flexibility**: Highly configurable via values.yaml

## 🔒 Security

- ✅ **Read-only Root Filesystem**: With tmpfs volumes for writable paths
- ✅ **Non-root User**: Runs as UID 1000
- ✅ **Dropped Capabilities**: All capabilities dropped
- ✅ **Seccomp Profile**: RuntimeDefault
- ✅ **No Privilege Escalation**: `allowPrivilegeEscalation: false`
- ✅ **Secrets Management**: Separate from configuration
- ✅ **Network Policies**: (optional) Limit pod-to-pod traffic

## 🏗️ Architecture

### Components

#### Web Application
- **Deployment**: PHP-FPM/Laravel web application
- **Service**: ClusterIP service exposing port 80
- **HPA**: Auto-scaling based on CPU/Memory utilization
- **PDB**: Ensures minimum availability during disruptions
- **Probes**: Liveness, Readiness, and Startup probes

#### Queue Workers
- **Deployment**: Laravel Horizon or queue workers processing background jobs
- **HPA**: Scales based on CPU/memory workload
- **PDB**: Ensures worker availability
- **Horizon**: Recommended - provides dashboard, metrics, and auto-balancing
- **Configurable**: Custom commands and arguments

#### Scheduler
- **CronJob**: Runs `php artisan schedule:run` every minute
- **Configurable**: Custom schedule and resource limits

#### Migration Job
- **Helm Hook**: Runs on pre-install and pre-upgrade
- **Automatic Execution**: Migrations run before new pods start
- **Retry Logic**: Configurable backoff limit
- **TTL**: Automatic cleanup after completion
- **Failure Handling**: Deployment blocked if migrations fail

#### Additional Resources
- **ConfigMap**: Non-sensitive environment variables
- **Secret**: Sensitive credentials and keys
- **PVC**: Persistent storage for uploads and logs
- **ServiceAccount**: RBAC support
- **Ingress**: HTTP/HTTPS routing with TLS
- **Traefik Middlewares**: Rate limiting, security headers, compression, IP whitelisting

### Writable Filesystem Strategy

This chart implements read-only root filesystem for security, with tmpfs volumes for writable paths:

```yaml
tmpfsVolumes:
  - name: cache
    mountPath: /app/storage/framework/cache
    sizeLimit: 256Mi
  - name: sessions
    mountPath: /app/storage/framework/sessions
    sizeLimit: 128Mi
  - name: views
    mountPath: /app/storage/framework/views
    sizeLimit: 128Mi
  - name: tmp
    mountPath: /tmp
    sizeLimit: 512Mi
```

**Important**: tmpfs volumes are memory-based and **data is lost** on pod restart. For persistent data:
- Use PVC for uploads, exports, logs
- Store sessions in Redis/database
- Use external storage (S3) for user files

## 📝 Configuration

The following table lists the key configurable parameters and their default values.

### Global Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Docker image repository | `your-registry/laravel-app` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Web Application

| Parameter | Description | Default |
|-----------|-------------|---------|
| `web.enabled` | Enable web component | `true` |
| `web.replicaCount` | Number of replicas | `2` |
| `web.autoscaling.enabled` | Enable HPA | `true` |
| `web.autoscaling.minReplicas` | Minimum replicas | `2` |
| `web.autoscaling.maxReplicas` | Maximum replicas | `10` |
| `web.resources.requests.cpu` | CPU request | `100m` |
| `web.resources.requests.memory` | Memory request | `256Mi` |

### Queue Workers

| Parameter | Description | Default |
|-----------|-------------|---------|
| `worker.enabled` | Enable worker component | `true` |
| `worker.replicaCount` | Number of worker replicas | `2` |
| `worker.command` | Worker command | `["php", "artisan", "queue:work"]` |
| `worker.autoscaling.enabled` | Enable worker HPA | `true` |

### Scheduler

| Parameter | Description | Default |
|-----------|-------------|---------|
| `scheduler.enabled` | Enable scheduler CronJob | `true` |
| `scheduler.schedule` | Cron schedule | `* * * * *` |
| `scheduler.command` | Command to run | `["php", "artisan", "schedule:run"]` |

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.className` | Ingress class | `traefik` |
| `ingress.hosts[0].host` | Hostname | `app.example.com` |

### Middleware

| Parameter | Description | Default |
|-----------|-------------|---------|
| `middleware.enabled` | Enable Traefik middleware | `true` |
| `middleware.rateLimit.enabled` | Enable rate limiting | `true` |
| `middleware.headers.enabled` | Enable security headers | `true` |
| `middleware.compress.enabled` | Enable compression | `true` |

### Laravel Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `laravel.env.APP_NAME` | Application name | `Laravel` |
| `laravel.env.APP_ENV` | Environment | `production` |
| `laravel.env.APP_DEBUG` | Debug mode | `false` |
| `laravel.secrets.APP_KEY` | Application key | `""` |
| `laravel.secrets.DB_PASSWORD` | Database password | `""` |

For a complete list of parameters, see `values.yaml`.

## 🔧 Configuration Examples

### Local Development Environment

```yaml
# values/local.yaml
image:
  repository: localhost:5000/laravel-app
  tag: latest
  pullPolicy: Always

ingress:
  enabled: true
  hosts:
    - host: app.local
      paths:
        - path: /
          pathType: Prefix

env:
  APP_ENV: local
  APP_DEBUG: "true"
  DB_HOST: mariadb.databases.svc.cluster.local
  CACHE_DRIVER: redis
  SESSION_DRIVER: redis
  QUEUE_CONNECTION: redis
  REDIS_HOST: redis.databases.svc.cluster.local

web:
  replicaCount: 1
  resources:
    requests:
      cpu: 50m
      memory: 128Mi

worker:
  replicaCount: 1

autoscaling:
  web:
    enabled: false
  worker:
    enabled: false
```

### Production Environment

```yaml
# values/production.yaml
image:
  repository: your-registry.io/laravel-app
  tag: "1.0.0"
  pullPolicy: IfNotPresent

ingress:
  enabled: true
  className: traefik
  hosts:
    - host: app.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: app-tls
      hosts:
        - app.example.com

env:
  APP_ENV: production
  APP_DEBUG: "false"
  APP_URL: "https://app.example.com"
  DB_HOST: mysql.databases.svc.cluster.local
  DB_PORT: "3306"
  DB_DATABASE: laravel_prod
  CACHE_DRIVER: redis
  SESSION_DRIVER: redis
  QUEUE_CONNECTION: redis
  REDIS_HOST: redis.databases.svc.cluster.local

secrets:
  enabled: true
  data:
    APP_KEY: "base64:your-production-key"
    DB_PASSWORD: "secure-password"
    REDIS_PASSWORD: "redis-password"

web:
  replicaCount: 3
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 1Gi

worker:
  replicaCount: 2
  command:
    - "php"
    - "artisan"
    - "horizon"
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi

autoscaling:
  web:
    enabled: true
    minReplicas: 3
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70
  worker:
    enabled: true
    minReplicas: 2
    maxReplicas: 8
    targetCPUUtilizationPercentage: 75

pdb:
  web:
    enabled: true
    minAvailable: 2
  worker:
    enabled: true
    minAvailable: 1

middleware:
  rateLimit:
    enabled: true
    average: 100
    burst: 50
  securityHeaders:
    enabled: true
  compression:
    enabled: true

persistence:
  enabled: true
  storageClass: "fast-ssd"
  size: 20Gi
  accessMode: ReadWriteMany
```

### Laravel Queue Management

```yaml
# Recommended: Use Laravel Horizon for queue management
worker:
  enabled: true
  replicaCount: 2
  command:
    - "php"
    - "artisan"
    - "horizon"
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi

# Horizon configuration in config/horizon.php handles:
# - Multiple queues (default, emails, notifications, etc.)
# - Queue priorities
# - Worker balancing
# - Auto-scaling
# - Failed job management
# - Monitoring dashboard at /horizon
```

**Note**: Laravel Horizon is the recommended way to manage queues. It provides:
- Beautiful dashboard at `/horizon`
- Automatic load balancing across queues
- Real-time monitoring
- Failed job management
- Queue metrics and insights

Alternatively, for simple use cases without Horizon:
```yaml
# Basic queue worker (without Horizon)
worker:
  enabled: true
  replicaCount: 2
  command:
    - "php"
    - "artisan"
    - "queue:work"
    - "--tries=3"
    - "--max-jobs=1000"
    - "--timeout=60"
```

## 🔄 Deployment Workflow

### Initial Deployment

1. **Build and push Docker image**:
   ```bash
   docker build -t your-registry.io/laravel-app:1.0.0 .
   docker push your-registry.io/laravel-app:1.0.0
   ```

2. **Create values file** for your environment

3. **Deploy with Helm**:
   ```bash
   helm install my-app ./charts/laravel \
     --namespace production \
     --create-namespace \
     --values values/production.yaml
   ```

4. **Verify deployment**:
   ```bash
   kubectl get pods -n production
   kubectl get ingress -n production
   helm status my-app -n production
   ```

### Upgrading

```bash
# Standard upgrade
helm upgrade my-app ./charts/laravel \
  --namespace production \
  --values values/production.yaml

# Upgrade with new image version
helm upgrade my-app ./charts/laravel \
  --namespace production \
  --values values/production.yaml \
  --set image.tag=1.0.1

# Dry run to preview changes
helm upgrade my-app ./charts/laravel \
  --namespace production \
  --values values/production.yaml \
  --dry-run --debug
```

### Rollback

```bash
# View release history
helm history my-app -n production

# Rollback to previous version
helm rollback my-app -n production

# Rollback to specific revision
helm rollback my-app 3 -n production

# Verify rollback
kubectl get pods -n production -w
```

## 🛠️ Common Operations

### Running Migrations

Migrations automatically run via Helm hooks (pre-install, pre-upgrade). To run manually:

```bash
# Get a web pod
POD=$(kubectl get pods -n production -l app.kubernetes.io/component=web -o jsonpath='{.items[0].metadata.name}')

# Run migrations
kubectl exec -it $POD -n production -- php artisan migrate --force

# Check migration status
kubectl exec -it $POD -n production -- php artisan migrate:status

# Rollback migrations
kubectl exec -it $POD -n production -- php artisan migrate:rollback --force
```

### Cache Management

```bash
# Clear all caches
kubectl exec -it $POD -n production -- php artisan cache:clear
kubectl exec -it $POD -n production -- php artisan config:clear
kubectl exec -it $POD -n production -- php artisan route:clear
kubectl exec -it $POD -n production -- php artisan view:clear

# Optimize application
kubectl exec -it $POD -n production -- php artisan optimize
```

### Queue Management (Horizon)

```bash
# Restart Horizon (graceful restart of all workers)
kubectl exec -it $POD -n production -- php artisan horizon:terminate
# Kubernetes will automatically restart the pod

# Or force restart the worker deployment
kubectl rollout restart deployment/my-app-worker -n production

# Pause Horizon (stop processing jobs)
kubectl exec -it $POD -n production -- php artisan horizon:pause

# Resume Horizon
kubectl exec -it $POD -n production -- php artisan horizon:continue

# Check Horizon status
kubectl exec -it $POD -n production -- php artisan horizon:status

# View failed jobs (via Horizon dashboard or artisan)
kubectl exec -it $POD -n production -- php artisan horizon:failed

# Retry failed job
kubectl exec -it $POD -n production -- php artisan queue:retry <job-id>

# Retry all failed jobs
kubectl exec -it $POD -n production -- php artisan queue:retry all

# Clear failed jobs
kubectl exec -it $POD -n production -- php artisan horizon:clear
```

**Horizon Dashboard**: Access at `https://your-app.com/horizon` (ensure route is protected in production)

### Viewing Logs

```bash
# Web server logs
kubectl logs -f -n production -l app.kubernetes.io/component=web

# Worker logs
kubectl logs -f -n production -l app.kubernetes.io/component=worker

# Scheduler logs (recent jobs)
kubectl logs -n production -l app.kubernetes.io/component=scheduler --tail=50

# Migration job logs
kubectl logs -n production -l app.kubernetes.io/component=migration
```

### Scaling

```bash
# Manual scaling (when HPA is disabled)
kubectl scale deployment my-app-web -n production --replicas=5
kubectl scale deployment my-app-worker -n production --replicas=3

# Check HPA status
kubectl get hpa -n production

# View HPA details
kubectl describe hpa my-app-web -n production
```

## 🔐 Security Considerations

### Secrets Management

**Never commit secrets to version control!** Use one of these approaches:

1. **External Secrets Operator** (Recommended for production):
   ```yaml
   secrets:
     enabled: false
     existingSecret: my-app-secrets  # Managed by External Secrets
   ```

2. **Sealed Secrets**:
   ```bash
   kubectl create secret generic my-app-secrets \
     --from-literal=APP_KEY=base64:xxx \
     --from-literal=DB_PASSWORD=xxx \
     --dry-run=client -o yaml | \
     kubeseal -o yaml > sealed-secret.yaml
   ```

3. **Manual Secret Creation**:
   ```bash
   kubectl create secret generic my-app-secrets \
     --from-literal=APP_KEY="base64:your-key" \
     --from-literal=DB_PASSWORD="secure-password" \
     -n production
   ```

### Image Security

```bash
# Scan images for vulnerabilities
docker scan your-registry.io/laravel-app:1.0.0

# Use specific digest for immutability
image:
  repository: your-registry.io/laravel-app
  tag: "1.0.0"
  # Or use digest:
  # digest: sha256:abc123...
```

### Network Policies

Limit pod-to-pod communication:

```yaml
networkPolicy:
  enabled: true
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
      - namespaceSelector:
          matchLabels:
            name: kube-system  # Allow Traefik
  egress:
    - to:
      - namespaceSelector:
          matchLabels:
            name: databases  # Allow database access
    - to:
      - podSelector: {}  # Allow internal pod communication
```

### Security Checklist

- [ ] `APP_DEBUG` is `false` in production
- [ ] `APP_KEY` is generated and secured
- [ ] Database credentials are in Kubernetes secrets
- [ ] TLS/HTTPS enabled on ingress
- [ ] Rate limiting configured
- [ ] Security headers enabled
- [ ] Read-only root filesystem enabled
- [ ] Running as non-root user (UID 1000)
- [ ] All capabilities dropped
- [ ] Resource limits set to prevent resource exhaustion
- [ ] Network policies configured
- [ ] Container registry is private and secured
- [ ] Regular security scanning of images

## 🎓 Best Practices

### Deployment

1. **Use specific image tags** instead of `latest` in production
2. **Tag with semantic versioning**: `v1.2.3` format
3. **Test in lower environments** before production
4. **Use Helm's `--dry-run`** to preview changes
5. **Enable HPA** for both web and worker components
6. **Configure PDB** to ensure high availability (min 2 replicas)
7. **Set resource requests and limits** based on actual usage

### Configuration

8. **Separate secrets from config**: Use Kubernetes secrets, not ConfigMaps
9. **Use ConfigMaps** for environment-specific non-sensitive configuration
10. **Environment parity**: Keep dev/staging/prod configurations similar
11. **Externalize all config**: No hardcoded values in images

### Operations

12. **Monitor your application**: CPU, memory, response times, error rates
13. **Set up alerts**: For high error rates, resource exhaustion, pod failures
14. **Regular backups**: Of persistent volumes and databases
15. **Log aggregation**: Send logs to centralized logging system
16. **Health checks**: Configure appropriate liveness/readiness probes
17. **Graceful shutdown**: Ensure proper cleanup on pod termination

### Performance

18. **Enable OPcache**: For PHP performance
19. **Use Redis**: For cache and sessions
20. **Queue long-running tasks**: Don't block HTTP requests
21. **Use Laravel Horizon**: For queue management and monitoring
22. **Database connection pooling**: Configure appropriate pool sizes
23. **CDN for static assets**: Offload static file serving

### Maintenance

24. **Keep dependencies updated**: Regularly update Laravel and packages
25. **Update base images**: Apply security patches
26. **Review resource usage**: Adjust limits based on metrics
27. **Clean up old releases**: `helm delete` unused releases
28. **Prune old images**: Remove unused container images
29. **Monitor Horizon metrics**: Check queue wait times and throughput
30. **Failed job cleanup**: Regularly review and clear old failed jobs

## 🎯 Production Readiness Checklist

Before going to production, verify:

**Application**:
- [ ] All tests passing
- [ ] Database migrations tested
- [ ] Seed data prepared (if needed)
- [ ] Error tracking configured (Sentry, etc.)
- [ ] Logging configured and tested

**Infrastructure**:
- [ ] Resource limits appropriate
- [ ] HPA configured and tested
- [ ] PDB configured (minAvailable: 2)
- [ ] Health probes responding correctly
- [ ] Ingress/TLS working
- [ ] DNS configured

**Security**:
- [ ] Secrets externalized
- [ ] Security headers enabled
- [ ] Rate limiting configured
- [ ] Image vulnerabilities scanned
- [ ] RBAC configured

**Monitoring**:
- [ ] Metrics collection enabled
- [ ] Alerts configured
- [ ] Logs aggregated
- [ ] Dashboard created

**Backups**:
- [ ] Database backup strategy
- [ ] PVC backup if needed
- [ ] Backup restore tested

**Documentation**:
- [ ] Deployment process documented
- [ ] Rollback procedure documented
- [ ] On-call runbook created

## 📊 Monitoring and Observability

1. **Application Health**
   - HTTP probe status
   - Response times
   - Error rates

2. **Resource Usage**
   - CPU and memory utilization
   - Disk I/O (if using PVC)
   - Network traffic

3. **Scaling Metrics**
   - HPA current/desired replicas
   - Pod ready/not-ready counts
   - Queue depth (for workers)

4. **Business Metrics**
   - User requests
   - Database queries
   - Cache hit rates
   - Queue job processing times

## 🆘 Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n production

# Describe pod for events
kubectl describe pod <pod-name> -n production

# Check logs
kubectl logs <pod-name> -n production

# Check previous pod logs (if pod is crashlooping)
kubectl logs <pod-name> -n production --previous
```

**Common causes**:
- Image pull errors: Check `imagePullSecrets` and registry credentials
- `CrashLoopBackOff`: Check application logs for PHP errors
- `Pending`: Check resource requests vs. node capacity
- `Init:Error`: Migration job failed, check migration logs

### Database Connection Issues

```bash
# Test database connectivity from pod
kubectl exec -it $POD -n production -- php artisan tinker
# In tinker: DB::connection()->getPdo();

# Check database service
kubectl get svc -n databases

# Verify environment variables
kubectl exec -it $POD -n production -- env | grep DB_
```

**Common causes**:
- Incorrect `DB_HOST` (should be FQDN: `service.namespace.svc.cluster.local`)
- Wrong credentials in secrets
- Database not ready (check database pod status)
- Network policies blocking connection

### Migration Job Failed

```bash
# View migration job status
kubectl get jobs -n production

# Check migration job logs
kubectl logs -n production -l app.kubernetes.io/component=migration

# Describe job for events
kubectl describe job my-app-migration -n production

# Delete failed job to retry on next upgrade
kubectl delete job my-app-migration -n production
```

**Common causes**:
- Database connection timeout
- Schema conflicts
- Missing database permissions
- Timeout (increase job timeout in values)

### Permission Denied Errors

```bash
# Check file permissions in pod
kubectl exec -it $POD -n production -- ls -la /app/storage

# Verify security context
kubectl get pod $POD -n production -o yaml | grep -A 10 securityContext
```

**Solution**: Ensure your Docker image has correct ownership:
```dockerfile
RUN chown -R 1000:1000 /app/storage /app/bootstrap/cache
USER 1000
```

### Application Error 500

```bash
# Check Laravel logs
kubectl exec -it $POD -n production -- tail -f storage/logs/laravel.log

# Check if APP_KEY is set
kubectl exec -it $POD -n production -- env | grep APP_KEY

# Clear and recache config
kubectl exec -it $POD -n production -- php artisan config:clear
kubectl exec -it $POD -n production -- php artisan config:cache
```

### Queue Workers Not Processing Jobs

```bash
# Check worker pod status
kubectl get pods -n production -l app.kubernetes.io/component=worker

# View worker logs (Horizon logs)
kubectl logs -f -n production -l app.kubernetes.io/component=worker

# Check Horizon status
kubectl exec -it $POD -n production -- php artisan horizon:status

# Check if Horizon is paused
kubectl exec -it $POD -n production -- php artisan horizon:continue

# Check Redis connection
kubectl exec -it $POD -n production -- php artisan tinker
# In tinker: Redis::connection()->ping();

# Restart Horizon gracefully
kubectl exec -it $POD -n production -- php artisan horizon:terminate

# Or force restart worker deployment
kubectl rollout restart deployment/my-app-worker -n production

# Check queue sizes
kubectl exec -it $POD -n production -- php artisan queue:monitor redis:default,redis:notifications --max=1000
```

**Common Horizon issues**:
- Horizon paused: Run `horizon:continue`
- Memory leaks: Horizon restarts automatically after max memory limit
- Stuck jobs: Check logs for exceptions, retry failed jobs
- Config cache: Clear config cache after horizon.php changes

### High Memory Usage / OOM Kills

```bash
# Check resource usage
kubectl top pods -n production

# View pod events for OOM kills
kubectl get events -n production --field-selector involvedObject.name=$POD

# Check memory limits
kubectl get pod $POD -n production -o yaml | grep -A 5 resources
```

**Solution**: Increase memory limits in values:
```yaml
web:
  resources:
    limits:
      memory: 1Gi  # Increase as needed
```

### Ingress Not Working

```bash
# Check ingress resource
kubectl get ingress -n production
kubectl describe ingress my-app -n production

# Check Traefik controller
kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik

# Test service directly
kubectl port-forward -n production svc/my-app 8080:80
# Then access: http://localhost:8080
```

### Storage/PVC Issues

```bash
# Check PVC status
kubectl get pvc -n production

# Describe PVC
kubectl describe pvc my-app-storage -n production

# Check if PV is bound
kubectl get pv
```

## ❓ Frequently Asked Questions

### How do I generate an APP_KEY?

```bash
# Generate locally
php artisan key:generate --show

# Or in a pod
kubectl run temp-laravel --rm -it --image=your-registry.io/laravel-app:1.0.0 -- php artisan key:generate --show
```

### How do I run database seeders?

```bash
# Run all seeders
kubectl exec -it $POD -n production -- php artisan db:seed --force

# Run specific seeder
kubectl exec -it $POD -n production -- php artisan db:seed --class=UserSeeder --force
```

### How do I access the application shell (tinker)?

```bash
kubectl exec -it $POD -n production -- php artisan tinker
```

### How do I run one-off commands?

```bash
# Using kubectl exec
kubectl exec -it $POD -n production -- php artisan your:command

# Using a Job
kubectl run my-command --rm -it \
  --image=your-registry.io/laravel-app:1.0.0 \
  --restart=Never \
  -n production \
  -- php artisan your:command
```

### How do I enable maintenance mode?

```bash
# Enable maintenance mode
kubectl exec -it $POD -n production -- php artisan down --message="Upgrading" --retry=60

# Disable maintenance mode
kubectl exec -it $POD -n production -- php artisan up
```

### How do I change the number of replicas?

For temporary changes:
```bash
kubectl scale deployment my-app-web -n production --replicas=5
```

For permanent changes, update `values.yaml`:
```yaml
web:
  replicaCount: 5
```

Then upgrade:
```bash
helm upgrade my-app ./charts/laravel -f values/production.yaml -n production
```

### Why are my pods restarting?

Check:
```bash
# View pod events
kubectl describe pod $POD -n production

# Check if OOM killed
kubectl get events -n production | grep OOM

# Check liveness probe failures
kubectl logs $POD -n production --previous
```

### How do I update environment variables?

1. Update `values.yaml`:
   ```yaml
   env:
     NEW_VAR: "new_value"
   ```

2. Upgrade release:
   ```bash
   helm upgrade my-app ./charts/laravel -f values/production.yaml -n production
   ```

3. Pods will automatically restart with new environment variables.

### How do I use a different storage class?

```yaml
persistence:
  enabled: true
  storageClass: "fast-ssd"  # Your storage class name
  size: 20Gi
```

### Can I use this chart with nginx-ingress instead of Traefik?

Yes, update the ingress class:
```yaml
ingress:
  className: nginx
  annotations:
    nginx.ingress.kubernetes.io/rate-limit: "100"
```

Note: Traefik-specific middlewares won't work with nginx-ingress.

### How do I debug migration failures?

```bash
# Check migration job logs
kubectl logs -n production -l app.kubernetes.io/component=migration

# Get migration job details
kubectl describe job my-app-migration -n production

# Delete failed job to retry
kubectl delete job my-app-migration -n production

# Then upgrade again
helm upgrade my-app ./charts/laravel -f values/production.yaml -n production
```

### How do I connect to Redis from the application?

The chart expects Redis to be available. Configure the connection:
```yaml
env:
  REDIS_HOST: redis.databases.svc.cluster.local
  REDIS_PORT: "6379"
  REDIS_PASSWORD: ""  # Or use secrets
  CACHE_DRIVER: redis
  SESSION_DRIVER: redis
  QUEUE_CONNECTION: redis
```

### How do I handle file uploads with read-only filesystem?

Options:
1. **Use PVC** (persistent volume):
   ```yaml
   persistence:
     enabled: true
     size: 10Gi
     mountPath: /app/storage/app/public
   ```

2. **Use S3/Object Storage**:
   ```yaml
   env:
     FILESYSTEM_DISK: s3
     AWS_BUCKET: your-bucket
     AWS_ACCESS_KEY_ID: your-key
   ```

3. **Both**: PVC for temporary files, S3 for permanent storage

### How do I configure Laravel Horizon for multiple queues?

In your `config/horizon.php`, configure supervisors and queues:

```php
'environments' => [
    'production' => [
        'supervisor-1' => [
            'connection' => 'redis',
            'queue' => ['default'],
            'balance' => 'auto',
            'processes' => 3,
            'tries' => 3,
            'timeout' => 60,
        ],
        'supervisor-2' => [
            'connection' => 'redis',
            'queue' => ['emails', 'notifications'],
            'balance' => 'auto',
            'processes' => 2,
            'tries' => 3,
        ],
    ],
],
```

Horizon automatically manages workers across all defined queues. Kubernetes HPA scales the entire Horizon deployment based on resource usage.

### How do I access the Horizon dashboard?

The dashboard is at `/horizon`. Protect it in production:

```php
// app/Providers/HorizonServiceProvider.php
protected function gate()
{
    Gate::define('viewHorizon', function ($user) {
        return in_array($user->email, [
            'admin@example.com',
        ]);
    });
}
```

Or use middleware in `config/horizon.php`:
```php
'middleware' => ['web', 'auth', 'admin'],
```

### How do I see what changed between releases?

```bash
# View release history
helm history my-app -n production

# Compare revisions
helm get values my-app -n production --revision 1 > rev1.yaml
helm get values my-app -n production --revision 2 > rev2.yaml
diff rev1.yaml rev2.yaml
```
