# Laravel Helm Chart

Laravel application deployment with web/worker deployments, queue management, cron jobs, and auto-scaling.

![Dynamic YAML Badge](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2F5ergiu%2Fhelm-charts%2Fmain%2Fcharts%2Flaravel%2FChart.yaml&query=version&label=Version)
![Dynamic YAML Badge](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2F5ergiu%2Fhelm-charts%2Fmain%2Fcharts%2Flaravel%2FChart.yaml&query=type&label=Type&color=green)
![Dynamic YAML Badge](https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2F5ergiu%2Fhelm-charts%2Fmain%2Fcharts%2Flaravel%2FChart.yaml&query=appVersion&label=AppVersion&color=red)

## 🚀 Installation

### Install from OCI Registry

```bash
# Install the chart
helm install my-laravel-app \
  oci://ghcr.io/5ergiu/helm-charts/laravel \
  --version 0.1.0 \
  --namespace production \
  --create-namespace \
  --values values.yaml
```

### Install from Local Chart

```bash
# Clone repository
git clone https://github.com/5ergiu/helm-charts.git
cd helm-charts

# Install
helm install my-laravel-app ./charts/laravel \
  --namespace production \
  --create-namespace \
  --values values.yaml
```

## 🗑️ Uninstall

```bash
# Uninstall release
helm uninstall my-laravel-app -n production

# Optionally delete namespace
kubectl delete namespace production

# Note: PVCs are not deleted automatically for data safety
# Delete PVCs manually if needed:
kubectl delete pvc -n production -l app.kubernetes.io/instance=my-laravel-app
```

## 🔄 Upgrade & Rollback

```bash
# Upgrade with new values
helm upgrade my-laravel-app oci://ghcr.io/5ergiu/helm-charts/laravel \
  --version 0.1.0 \
  --namespace production \
  --values values.yaml

# View release history
helm history my-laravel-app -n production

# Rollback to previous version
helm rollback my-laravel-app -n production
```

## 🔐 Chart Signature Verification

This Helm chart is **cryptographically signed with Cosign** to ensure authenticity and prevent tampering.

### Public Key

```
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEWI1U5hBthE0x/1h5c7BQXI8d+EY4
6LnKJrAYwJ5rPLm8Ao5JC+J5x1g4nNvN8Lh9Y5hqnR8t1K5rP8vH9W5q1A==
-----END PUBLIC KEY-----
```

### Verify Before Installation

```bash
# Save the public key
cat > cosign.pub <<EOF
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEWI1U5hBthE0x/1h5c7BQXI8d+EY4
6LnKJrAYwJ5rPLm8Ao5JC+J5x1g4nNvN8Lh9Y5hqnR8t1K5rP8vH9W5q1A==
-----END PUBLIC KEY-----
EOF

# Verify chart signature
cosign verify --key cosign.pub ghcr.io/5ergiu/helm-charts/laravel:0.1.0
```

For more details on chart verification, see [COSIGN.md](../../COSIGN.md).

## 📦 Quick Start

```yaml
# values.yaml
image:
  repository: ghcr.io/yourorg/laravel-app
  tag: "1.0.0"

ingress:
  enabled: true
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: myapp-tls
      hosts:
        - myapp.example.com

laravel:
  env:
    APP_NAME: "My Laravel App"
    APP_ENV: "production"
    APP_DEBUG: "false"
    APP_URL: "https://myapp.example.com"
    # PostgreSQL recommended (or use "mysql" if preferred)
    DB_CONNECTION: "pgsql"
    DB_PORT: "5432"  # Use 3306 for MySQL
    DB_DATABASE: "laravel"
    # Redis recommended for production caching and queues
    CACHE_DRIVER: "redis"
    QUEUE_CONNECTION: "redis"
    SESSION_DRIVER: "redis"

  secrets:
    APP_KEY: "base64:your-secure-app-key-here"
    # Database credentials (managed PostgreSQL/MySQL recommended)
    DB_HOST: "postgres.databases.svc.cluster.local"  # Or your managed DB endpoint
    DB_USERNAME: "laravel"
    DB_PASSWORD: "your-secure-password"
    # Redis credentials (managed Redis recommended)
    REDIS_HOST: "redis.databases.svc.cluster.local"  # Or your managed Redis endpoint
    REDIS_PASSWORD: "your-redis-password"
```

Then install:

```bash
helm install myapp ./charts/laravel -f values.yaml -n production --create-namespace
```

## ✨ Features

### 🎯 Core Features

- **Production-Ready Deployment** - Optimized for Laravel applications with security best practices
- **Multi-Component Architecture** - Separate deployments for web, workers, scheduler, and migrations
- **Auto-Scaling** - Horizontal Pod Autoscaler (HPA) based on CPU/Memory for web and workers
- **Automated Migrations** - Database migrations run automatically via Helm hooks
- **Health Checks** - Comprehensive liveness, readiness, and startup probes
- **Security Hardened** - Non-root user, read-only filesystem, dropped capabilities
- **Resource Management** - Configurable resource requests and limits per component

### 🌐 Networking

- **Ingress Controller Support** - Traefik, NGINX, or any Kubernetes ingress
- **TLS/SSL** - Automatic HTTPS with cert-manager integration
- **Rate Limiting** - Built-in rate limiting via Traefik middleware
- **Security Headers** - HSTS, XSS protection, content-type nosniff
- **Compression** - Automatic response compression

### 🔧 Configuration

- **Environment Variables** - ConfigMap for application configuration
- **Secrets Management** - Kubernetes secrets for sensitive data (DB passwords, API keys)
- **External Secrets** - Support for External Secrets Operator
- **Cache Warming** - Automatic config, route, and view caching on deployment

### 📊 Observability

- **Prometheus Metrics** - Pod annotations for Prometheus scraping
- **Structured Logging** - Application logs to stdout/stderr
- **Pod Disruption Budget** - High availability configuration for web and workers
- **Rolling Updates** - Zero-downtime deployments

### 💾 Storage

- **Persistent Volumes** - Optional PVC for storage/app and logs
- **Tmpfs Volumes** - In-memory volumes for cache, sessions, views, and tmp
- **Read-Only Filesystem** - Enhanced security with tmpfs for writable paths


## 💻 Local Development with Kubernetes

This chart supports full local development using Kubernetes (Docker Desktop, Minikube, or Kind) with hot reload, debugging, and all production features.

### Quick Start (Local Development)

**Zero External Dependencies!** Uses SQLite and file-based drivers - no PostgreSQL or Redis needed for local development.

**See the [examples/laravel](../../examples/laravel) directory for complete deployment guides including:**
- **values.local.yaml** - Full development with Vite HMR and hot reload
- **values.test.yaml** - Local testing with Kind/K3d/Minikube
- **values.ci.yaml** - CI/CD optimized configuration
- **README.md** - Detailed setup instructions and deployment guide

**Quick Local Setup:**
```bash
# 1. Install Traefik (if not already installed)
helm install traefik traefik/traefik -n traefik --create-namespace

# 2. Add to /etc/hosts
echo "127.0.0.1 laravel.local" | sudo tee -a /etc/hosts

# 3. Copy and configure secrets
cd examples/laravel
cp secrets.yaml.example secrets.yaml
# Generate APP_KEY: docker run --rm ghcr.io/5ergiu/images/laravel:latest php artisan key:generate --show
# Edit secrets.yaml with your APP_KEY

# 4. Deploy with local development values (includes Bun sidecar for Vite HMR)
helm install myapp-dev ../../charts/laravel \
  -f values.local.yaml \
  -f secrets.yaml \
  -n development \
  --create-namespace

# 5. (Optional) Port forward for Vite HMR
kubectl port-forward -n development svc/myapp-dev-laravel 5173:5173
```

**Access your application:**
- **Laravel App**: http://laravel.local

For hot reload with hostPath volumes, see the detailed guide in [examples/laravel/README.md](../../examples/laravel/README.md).

**7. Development workflow:**
```bash
# View logs
kubectl logs -f deployment/myapp-dev-laravel-web -n development

# Run Artisan commands
kubectl exec -it deployment/myapp-dev-laravel-web -n development -- php artisan migrate
kubectl exec -it deployment/myapp-dev-laravel-web -n development -- php artisan tinker

# Restart pods to pick up new code (if not using volume mounts)
kubectl rollout restart deployment/myapp-dev-laravel-web -n development

# Port-forward for debugging
kubectl port-forward service/myapp-dev-laravel-web 8080:80 -n development

# View all resources
kubectl get all -n development
```

### Hot Reload Setup (Advanced)

For true hot reload without rebuilding images, use volume mounts:

**1. Create a hostPath PersistentVolume:**
```yaml
# local-pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: laravel-code
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /path/to/your/laravel/app
    type: Directory
  storageClassName: local-path
```

**2. Update values.dev.yaml:**
```yaml
persistence:
  enabled: true
  storageClass: "local-path"
  mounts:
    - name: code
      mountPath: /var/www/html
      subPath: ""
```

**3. Disable OPcache for immediate code changes:**
```yaml
php:
  opcache:
    enable: "0"  # See changes immediately
```

Now code changes on your host are immediately reflected in the pod!

### Debugging with Xdebug

The development image includes Xdebug. To enable:

**1. Add to values.dev.yaml:**
```yaml
extraEnv:
  - name: XDEBUG_MODE
    value: "debug,coverage"
  - name: XDEBUG_CONFIG
    value: "client_host=host.docker.internal client_port=9003"
```

**2. Configure your IDE:**
- **VS Code**: Install PHP Debug extension, set breakpoints
- **PHPStorm**: Go to Settings → PHP → Servers, add server with name matching hostname

**3. Start debugging:**
```bash
# Apply changes
helm upgrade myapp-dev ./charts/laravel -f charts/laravel/values.dev.yaml -n development

# Trigger Xdebug
curl http://laravel.local?XDEBUG_TRIGGER=1
```

### Local vs Production Differences

| Feature | Local (values.dev.yaml) | Production (values.prod.yaml) |
|---------|-------------------------|-------------------------------|
| **Image Target** | `development` | `production` |
| **Replicas** | 1 | 3+ with autoscaling |
| **OPcache** | Disabled | Enabled |
| **Error Display** | On | Off |
| **Probes** | Disabled | Enabled |
| **TLS** | Disabled | Enabled with cert-manager |
| **Rate Limiting** | Disabled | Enabled |
| **Log Level** | debug | warning |
| **Service Type** | LoadBalancer/NodePort | ClusterIP |
| **Resources** | Minimal | Production-sized |

### Troubleshooting Local Development

**Pod won't start:**
```bash
kubectl describe pod -l app.kubernetes.io/name=laravel -n development
kubectl logs -l app.kubernetes.io/name=laravel -n development --tail=100
```

**Permission issues with volumes:**
- Default values use UID 82:82 (Alpine's www-data)
- For hostPath volumes, override with: `--set web.podSecurityContext.runAsUser=$(id -u) --set web.podSecurityContext.fsGroup=$(id -g)`

**Can't access laravel.local:**
- Verify /etc/hosts entry: `cat /etc/hosts | grep laravel.local`
- Check service: `kubectl get svc -n development`
- Check ingress: `kubectl get ingress -n development`

**Database connection fails:**
- Verify MySQL is running: `kubectl get pods -n development`
- Check credentials match between MySQL install and values.dev.yaml
- Test connection: `kubectl exec -it deployment/myapp-dev-laravel-web -n development -- php artisan db:show`

**Changes not reflected:**
- If using image: rebuild and `kubectl rollout restart deployment/myapp-dev-laravel-web -n development`
- If using volume mounts: check OPcache is disabled (`PHP_OPCACHE_ENABLE=0`)
- Clear Laravel caches: `kubectl exec -it deployment/myapp-dev-laravel-web -n development -- php artisan optimize:clear`

## 📋 Prerequisites

- **Kubernetes 1.24+**
- **Helm 3.8+**
- **Ingress controller** (Traefik, NGINX, etc.) for external access
- **cert-manager** (optional, for automatic TLS certificates)
- **MySQL/PostgreSQL** database server
- **Redis** server (for cache, sessions, and queues)

## 🏗️ Architecture

This chart uses a **sidecar pattern** with separate nginx and PHP-FPM containers for optimal security and flexibility:

### Container Architecture

```
┌─────────────────────────────────────────────────────────┐
│                         Pod                              │
│                                                          │
│  ┌──────────────┐            ┌──────────────────────┐  │
│  │    Nginx     │  FastCGI   │      PHP-FPM         │  │
│  │  (Sidecar)   │ ─────────> │  (Laravel App)       │  │
│  │   Port 8080  │            │     Port 9000        │  │
│  └──────────────┘            └──────────────────────┘  │
│         ▲                                                │
│         │                                                │
│    HTTP Request                                          │
└─────────────────────────────────────────────────────────┘
         ▲
         │
    ┌────┴────┐
    │ Traefik │
    └─────────┘
```

**Benefits of Sidecar Pattern:**
- ✅ **Separation of Concerns**: nginx and PHP-FPM run independently
- ✅ **Better Resource Management**: Each container has dedicated resources
- ✅ **Flexibility**: Easy to swap nginx versions or configuration without rebuilding app image
- ✅ **Standard Kubernetes Pattern**: Follows cloud-native best practices
- ✅ **Security**: Both containers maintain read-only root filesystems

### Request Flow

1. **Traefik** → Routes to Service port 80
2. **Service** → Forwards to nginx sidecar on port 8080
3. **Nginx sidecar** → Acts as reverse proxy, forwards PHP requests via FastCGI to localhost:9000
4. **PHP-FPM container** → Processes PHP requests and serves the Laravel application

### Nginx Sidecar Configuration

The nginx sidecar is configured via a ConfigMap that's automatically generated from your values:

```yaml
nginx:
  enabled: true
  image:
    repository: nginx
    tag: 1.27-alpine
    pullPolicy: IfNotPresent

  port: 8080
  # Note: clientMaxBodySize should match Traefik's buffering.maxRequestBodyBytes
  # Traefik enforces the limit, nginx just needs to not reject valid requests
  clientMaxBodySize: 100M
  keepaliveTimeout: 65
  fastcgiReadTimeout: 120s

  resources:
    limits:
      cpu: 500m
      memory: 128Mi
    requests:
      cpu: 50m
      memory: 64Mi
```

**Important:** Request body size limits are enforced by Traefik's buffering middleware, but nginx's `clientMaxBodySize` must be set to match or exceed Traefik's limit. Otherwise, nginx will reject requests with its default 1MB limit before they reach PHP-FPM.

## 🔒 Security & Read-Only Filesystem

This chart is designed for **maximum security** with `readOnlyRootFilesystem: true` enabled by default for both containers:

### Image Requirements

Your Laravel Docker image should use PHP-FPM only (no built-in web server):

**Use PHP-FPM Base Images:**
```dockerfile
FROM serversideup/php:8.5-fpm-alpine AS production
# Your application code here
```

**The chart handles nginx separately** via the sidecar pattern, so your image only needs PHP-FPM.

### Reference Implementation

See the complete working example in [`examples/laravel/`](../../examples/laravel/):
- [`Dockerfile`](../../examples/laravel/Dockerfile) - PHP-FPM only image configuration
- [`templates/configmap.yaml`](templates/configmap.yaml) - Nginx configuration template for the sidecar
- [`entrypoint.d/`](../../examples/laravel/entrypoint.d/) - Custom minimal entrypoint scripts
- [`README.md`](../../examples/laravel/README.md) - Full technical details and explanation

### Alternative: Disable Read-Only Filesystem

If you need to disable the read-only filesystem constraint:

```yaml
web:
  securityContext:
    readOnlyRootFilesystem: false  # Not recommended for production

nginx:
  securityContext:
    readOnlyRootFilesystem: false

worker:
  securityContext:
    readOnlyRootFilesystem: false

scheduler:
  securityContext:
    readOnlyRootFilesystem: false

migration:
  securityContext:
    readOnlyRootFilesystem: false
```

⚠️ **Warning:** Disabling read-only filesystem reduces security posture and may not comply with strict Pod Security Standards.

## ⚙️ Configuration

### Image Configuration

```yaml
image:
  repository: ghcr.io/yourorg/laravel-app
  pullPolicy: Always

imagePullSecrets:
  - name: ghcr-secret
```

### Web Application Settings

```yaml
web:
  enabled: true
  replicaCount: 3
  
  resources:
    limits:
      cpu: 2000m
      memory: 1Gi
    requests:
      cpu: 200m
      memory: 512Mi
  
  service:
    type: ClusterIP
    port: 80
    targetPort: 8080
  
  livenessProbe:
    enabled: true
    httpGet:
      path: /healthcheck  # Nginx proxies to PHP-FPM
      port: 8080
    initialDelaySeconds: 30

  readinessProbe:
    enabled: true
    httpGet:
      path: /healthcheck  # Nginx proxies to PHP-FPM
      port: 8080
    initialDelaySeconds: 10
```

### Auto-Scaling (Web & Workers)

```yaml
web:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 80
    behavior:
      scaleDown:
        stabilizationWindowSeconds: 300
      scaleUp:
        stabilizationWindowSeconds: 0

worker:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 80
```

### Queue Workers Configuration

The chart supports both basic queue workers and Laravel Horizon. You can run both simultaneously or choose one.

#### Option 1: Laravel Horizon (Recommended for Production)

Horizon provides a beautiful dashboard and advanced queue management features. Requires Redis.

```yaml
horizon:
  enabled: true
  replicaCount: 2

  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 250m
      memory: 512Mi

  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10

# Optionally disable basic worker if using only Horizon
worker:
  enabled: false
```

#### Option 2: Basic Queue Worker

Use the basic `queue:work` command for simpler setups or when Redis is not available.

```yaml
worker:
  enabled: true
  replicaCount: 2
  command: ["php", "artisan", "queue:work"]
  args:
    - "--verbose"
    - "--tries=3"
    - "--max-time=3600"

  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 256Mi
```

#### Running Both Worker Types

You can run both Horizon and basic workers simultaneously for specialized queue configurations:

```yaml
# Horizon for high-priority queues
horizon:
  enabled: true
  replicaCount: 3

# Basic workers for low-priority or specific queues
worker:
  enabled: true
  replicaCount: 1
  command: ["php", "artisan", "queue:work"]
  args:
    - "--queue=low-priority"
```

### Scheduler (Laravel Cron)

```yaml
scheduler:
  enabled: true
  schedule: "* * * * *"  # Every minute
  command: ["php", "artisan", "schedule:run"]
  
  resources:
    limits:
      cpu: 200m
      memory: 256Mi
    requests:
      cpu: 50m
      memory: 128Mi
```

### Database Migrations

```yaml
migration:
  enabled: true
  command: ["php", "artisan", "migrate", "--force"]
  backoffLimit: 3
  ttlSecondsAfterFinished: 300
  
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 256Mi
```

### Ingress & TLS

#### Option 1: Kubernetes Ingress (Legacy)

```yaml
ingress:
  enabled: true  # Set to false if using IngressRoute
  className: traefik
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: app.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: app-tls
      hosts:
        - app.example.com
```

#### Option 2: Traefik IngressRoute (Recommended)

Modern CRD-based routing with advanced Traefik features:

```yaml
# Disable standard Ingress
ingress:
  enabled: false

# Enable IngressRoute (default)
ingressRoute:
  enabled: true

  # Entry points (web, websecure, etc.)
  entryPoints:
    - websecure

  # Global middlewares applied to all routes
  # Use shorthand names (template will prepend fullname automatically)
  # Or use "namespace/middleware-name" for cross-namespace references
  middlewares:
    - headers
    - compress
    - ratelimit

  # Route configuration
  routes:
    - match: "Host(`app.example.com`)"
      kind: Rule
      priority: 10
      # Per-route middlewares (optional)
      middlewares: []
      # Sticky sessions for stateful apps
      sticky:
        cookieName: laravel_sticky
        secure: true
        httpOnly: true
        sameSite: lax
      # Service weight (for A/B testing or canary)
      weight: 100

  # TLS configuration
  tls:
    # Option A: Use existing secret
    secretName: laravel-tls

    # Option B: Use cert-resolver for automatic certificates
    # certResolver: letsencrypt-prod
    # domains:
    #   - main: app.example.com
    #     sans:
    #       - www.app.example.com

    # TLS options (optional)
    # options:
    #   name: tls-options
    #   namespace: default
```

**IngressRoute Benefits:**
- Native Traefik integration with advanced features
- Sticky sessions for stateful applications
- Fine-grained routing control with priorities
- Service weights for canary deployments
- Better middleware composition
- TCP/UDP routing support

### Traefik Middlewares

The chart includes comprehensive middleware support for security, performance, and reliability:

```yaml
middleware:
  enabled: true

  # Rate Limiting - Protect against abuse
  rateLimit:
    enabled: true
    average: 100  # Average requests per period
    burst: 200    # Burst capacity
    period: 1s
    # Advanced IP strategy
    sourceCriterion:
      ipStrategy:
        depth: 1  # For X-Forwarded-For header
        excludedIPs: []
      # requestHeaderName: X-Forwarded-For
      # requestHost: true

  # Security Headers - OWASP best practices
  headers:
    enabled: true
    browserXssFilter: true
    contentTypeNosniff: true
    forceSTSHeader: true
    stsSeconds: 31536000
    stsIncludeSubdomains: true
    stsPreload: true
    customFrameOptionsValue: "SAMEORIGIN"
    # Additional headers
    contentSecurityPolicy: "default-src 'self'"
    referrerPolicy: "strict-origin-when-cross-origin"
    permissionsPolicy: "geolocation=(self), microphone=()"
    # CORS support
    accessControlAllowOriginList:
      - "https://example.com"
    accessControlAllowMethods:
      - GET
      - POST
      - PUT
    accessControlAllowHeaders:
      - Content-Type
      - Authorization
    customResponseHeaders:
      X-Powered-By: ""  # Hide server info
      Server: ""

  # Response Compression - Improve performance
  compress:
    enabled: true
    excludedContentTypes:
      - text/event-stream
    minResponseBodyBytes: 1024

  # HTTP to HTTPS Redirect
  redirectScheme:
    enabled: true
    scheme: https
    permanent: true
    # port: "443"

  # Strip Prefix - Remove path prefix before forwarding
  stripPrefix:
    enabled: false
    prefixes:
      - /api/v1
    forceSlash: false

  # Retry - Automatic retry on failures
  retry:
    enabled: false
    attempts: 3
    initialInterval: 100ms

  # Circuit Breaker - Prevent cascading failures
  circuitBreaker:
    enabled: false
    expression: "NetworkErrorRatio() > 0.30"
    checkPeriod: 10s
    fallbackDuration: 10s
    recoveryDuration: 10s

  # In-Flight Requests - Limit concurrent requests
  inFlightReq:
    enabled: false
    amount: 100
    sourceCriterion:
      ipStrategy:
        depth: 1

  # IP Whitelist - Restrict access by IP
  ipWhiteList:
    enabled: false
    sourceRange:
      - 10.0.0.0/8
      - 172.16.0.0/12
    ipStrategy:
      depth: 1
      excludedIPs: []

  # Middleware Chain - Combine multiple middlewares
  chain:
    enabled: false
    middlewares:
      - headers
      - ratelimit
      - compress

  # Buffering - Request/response body size limits
  buffering:
    enabled: true
    # Maximum request body size (100MB default)
    maxRequestBodyBytes: 104857600  # 100MB in bytes
    # Memory buffer for request body (1MB default, rest goes to disk)
    memRequestBodyBytes: 1048576    # 1MB in bytes
    # Maximum response body size (optional)
    # maxResponseBodyBytes: 0  # 0 = unlimited
    # Memory buffer for response body (optional)
    # memResponseBodyBytes: 1048576
```

**Available Middlewares:**
- ✅ **Rate Limiting** - Protect against DDoS and abuse
- ✅ **Security Headers** - HSTS, CSP, XSS protection, CORS
- ✅ **Compression** - Gzip compression for better performance
- ✅ **Buffering** - Request/response body size limits
- ✅ **Redirect Scheme** - HTTP to HTTPS redirection
- ✅ **Strip Prefix** - Path manipulation for API versioning
- ✅ **Retry** - Automatic retry on transient failures
- ✅ **Circuit Breaker** - Prevent cascading failures
- ✅ **In-Flight Requests** - Limit concurrent connections
- ✅ **IP Whitelist** - IP-based access control
- ✅ **Middleware Chain** - Compose multiple middlewares

### Environment Variables

All application and PHP configuration is provided via environment variables in the ConfigMap. The chart supports both Laravel and PHP (ServersideUp image) environment variables, matching the structure in values.yaml:

```yaml
laravel:
  env:
    APP_NAME: "Laravel"
    APP_ENV: "production"
    APP_DEBUG: "false"
    APP_URL: "https://app.example.com"
    LOG_CHANNEL: "stderr"
    LOG_LEVEL: "info"
    DB_CONNECTION: "mysql"
    DB_HOST: "mysql"
    DB_PORT: "3306"
    DB_DATABASE: "laravel"
    BROADCAST_DRIVER: "redis"
    CACHE_DRIVER: "redis"
    FILESYSTEM_DISK: "local"
    QUEUE_CONNECTION: "redis"
    SESSION_DRIVER: "redis"
    SESSION_LIFETIME: "120"
    MAIL_MAILER: "smtp"
    MAIL_HOST: "mailpit"
    MAIL_PORT: "1025"
    MAIL_FROM_ADDRESS: "noreply@example.com"
    MAIL_FROM_NAME: "Laravel App"
  secrets:
    APP_KEY: "base64:your-generated-app-key"
    DB_USERNAME: "laravel"
    DB_PASSWORD: "your-secure-password"
    REDIS_URL: "rediss://default:your-redis-password@redis:6379"
    AWS_ACCESS_KEY_ID: "your-aws-key"
    AWS_SECRET_ACCESS_KEY: "your-aws-secret"
    MAIL_USERNAME: "your-smtp-user"
    MAIL_PASSWORD: "your-smtp-password"

php:
  env:
    APP_BASE_DIR: "/var/www/html"
    HEALTHCHECK_PATH: "/healthcheck"
    PHP_DATE_TIMEZONE: "UTC"
    PHP_DISPLAY_ERRORS: "Off"
    PHP_DISPLAY_STARTUP_ERRORS: "Off"
    PHP_ERROR_LOG: "/dev/stderr"
    PHP_ERROR_REPORTING: "22527"
    PHP_MAX_EXECUTION_TIME: "99"
    PHP_MAX_INPUT_TIME: "-1"
    PHP_MAX_INPUT_VARS: "1000"
    PHP_MEMORY_LIMIT: "256M"
    PHP_OPEN_BASEDIR: ""
    PHP_POST_MAX_SIZE: "100M"
    PHP_REALPATH_CACHE_TTL: "120"
    PHP_SESSION_COOKIE_SECURE: "1"
    PHP_UPLOAD_MAX_FILE_SIZE: "100M"
    PHP_ZEND_MULTIBYTE: "Off"
    PHP_ZEND_DETECT_UNICODE: ""
    PHP_OPCACHE_ENABLE: "1"
    PHP_OPCACHE_ENABLE_FILE_OVERRIDE: "0"
    PHP_OPCACHE_FORCE_RESTART_TIMEOUT: "180"
    PHP_OPCACHE_INTERNED_STRINGS_BUFFER: "8"
    PHP_OPCACHE_JIT: "off"
    PHP_OPCACHE_JIT_BUFFER_SIZE: "0"
    PHP_OPCACHE_MAX_ACCELERATED_FILES: "10000"
    PHP_OPCACHE_MEMORY_CONSUMPTION: "128"
    PHP_OPCACHE_REVALIDATE_FREQ: "2"
    PHP_OPCACHE_SAVE_COMMENTS: "1"
    PHP_OPCACHE_VALIDATE_TIMESTAMPS: "0"
    PHP_FPM_POOL_NAME: "www"
    PHP_FPM_PM_CONTROL: "dynamic"
    PHP_FPM_PM_MAX_CHILDREN: "20"
    PHP_FPM_PM_START_SERVERS: "2"
    PHP_FPM_PM_MIN_SPARE_SERVERS: "1"
    PHP_FPM_PM_MAX_SPARE_SERVERS: "3"
    PHP_FPM_PM_MAX_REQUESTS: "0"
    PHP_FPM_PM_STATUS_PATH: ""
    PHP_FPM_PROCESS_CONTROL_TIMEOUT: "10"
    COMPOSER_ALLOW_SUPERUSER: "1"
    COMPOSER_HOME: "/composer"
    COMPOSER_MAX_PARALLEL_HTTP: "24"
```

All PHP configuration options are set as environment variables under `php.env`. For a full list, see [ServersideUp PHP Environment Variables Reference](https://github.com/serversideup/docker-php/blob/main/docs/content/docs/8.reference/1.environment-variable-specification.md).

#### Performance Tuning Guidelines

**Small Applications (< 1000 RPM):**
```yaml
php:
  memoryLimit: "256M"
  opcache:
    memoryConsumption: "128"
  fpm:
    pmMaxChildren: "20"
```

**Medium Applications (1000-10000 RPM):**
```yaml
php:
  memoryLimit: "512M"
  opcache:
    memoryConsumption: "256"
    maxAcceleratedFiles: "20000"
  fpm:
    pmMaxChildren: "50"
    pmMaxRequests: "1000"
```

**Large Applications (> 10000 RPM):**
```yaml
php:
  memoryLimit: "1G"
  opcache:
    memoryConsumption: "512"
    maxAcceleratedFiles: "50000"
    jit: "tracing"
    jitBufferSize: "200"
  fpm:
    pmControl: "static"
    pmMaxChildren: "100"
    pmMaxRequests: "500"
```

**Calculate FPM Workers:**
```
Available RAM = Total Container Memory - OPcache Memory - System Overhead (100MB)
Max Workers = Available RAM / Average PHP Process Memory (typically 30-50MB)

Example with 2GB container:
Available RAM = 2048MB - 256MB (opcache) - 100MB = 1692MB
Max Workers = 1692MB / 40MB = 42 workers
```

### Persistent Storage

```yaml
persistence:
  enabled: true
  storageClass: "fast-ssd"
  accessMode: ReadWriteOnce
  size: 20Gi
  mounts:
    - name: storage
      mountPath: /var/www/html/storage/app
      subPath: app
    - name: storage
      mountPath: /var/www/html/storage/logs
      subPath: logs
```

### Security Context

The chart uses **UID 82 and GID 82** by default (Alpine's `www-data` user), which matches the serversideup/php Docker images:

```yaml
web:
  podSecurityContext:
    runAsNonRoot: true
    runAsUser: 82    # Alpine www-data user
    fsGroup: 82      # Alpine www-data group
    seccompProfile:
      type: RuntimeDefault

  securityContext:
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL
    readOnlyRootFilesystem: true
```

**For local development with hostPath volumes**, you need to match your host user:

```bash
helm install my-app ./charts/laravel \
  -f examples/laravel/values.local.yaml \
  --set web.podSecurityContext.runAsUser=$(id -u) \
  --set web.podSecurityContext.fsGroup=$(id -g) \
  --set worker.podSecurityContext.runAsUser=$(id -u) \
  --set worker.podSecurityContext.fsGroup=$(id -g)
```

### Init Containers (Cache Warming)

```yaml
initContainers:
  cacheConfig:
    enabled: true
    command: ["php", "artisan", "config:cache"]
  
  cacheRoute:
    enabled: true
    command: ["php", "artisan", "route:cache"]
  
  cacheView:
    enabled: true
    command: ["php", "artisan", "view:cache"]
  
  storageLink:
    enabled: true
    command: ["php", "artisan", "storage:link"]
```

See [values.yaml](values.yaml) for all available configuration options.

## 🧪 Testing

### Testing the Chart Locally

To run the full test suite:

```bash
./scripts/test.sh charts/laravel
```

**⚠️ Managing Secrets for Testing:**

The chart uses `ci/values.test.yaml` for testing, grabbing secrets from the local file:

1. Copy the example file:
   ```bash
   cp charts/laravel/ci/secrets.yaml.example charts/laravel/ci/secrets.yaml
   ```

2. Add your real credentials to `secrets.yaml` (this file is gitignored):
   ```yaml
   laravel:
     secrets:
       REDIS_URL: "rediss://default:your-actual-password@redis.example.com:6379"
   ```

3. The test script automatically loads both `values.test.yaml` and `secrets.yaml`

### Testing Your Deployment

Test your deployment:

```bash
# Check pod status
kubectl get pods -n production -l app.kubernetes.io/name=laravel

# View web logs
kubectl logs -n production -l app.kubernetes.io/component=web -f

# View worker logs
kubectl logs -n production -l app.kubernetes.io/component=worker -f

# Port forward for local testing
kubectl port-forward -n production svc/my-laravel-app-web 8080:80

# Exec into pod
kubectl exec -n production -it deployment/my-laravel-app-web -- bash

# Run artisan commands
kubectl exec -n production -it deployment/my-laravel-app-web -- php artisan tinker
```

## 📊 Monitoring

### Prometheus Integration

The chart includes Prometheus annotations by default:

```yaml
web:
  podAnnotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9090"
```

### Grafana Dashboards

Import recommended dashboards:
- **Kubernetes Pods** - Dashboard ID: 6417
- **PHP-FPM** - Dashboard ID: 12628

### Key Metrics to Monitor

- **Web pods**: Request rate, response time, error rate, CPU/Memory usage
- **Workers**: Queue size, job processing rate, failed jobs, CPU/Memory usage
- **Database**: Query time, connections, deadlocks
- **Cache**: Hit rate, memory usage
- **HPA**: Current replicas, desired replicas, scaling events

## 🚀 Local Development

For local Kubernetes development (minikube, k3d, kind):

### 1. Adjust Security Context

```yaml
web:
  podSecurityContext:
    runAsUser: 1000  # Your host user ID (run: id -u)
    fsGroup: 1000    # Your host group ID (run: id -g)

worker:
  podSecurityContext:
    runAsUser: 1000
    fsGroup: 1000
```

### 2. Use NodePort Service (Optional)

```yaml
web:
  service:
    type: NodePort
    port: 80
    targetPort: 8080
```

### 3. Disable TLS for Local

```yaml
ingress:
  enabled: true
  hosts:
    - host: app.local
      paths:
        - path: /
          pathType: Prefix
  tls: []  # Disable TLS
```

### 4. Local Database & Redis

```yaml
laravel:
  env:
    APP_ENV: "local"
    APP_DEBUG: "true"
    DB_HOST: "mysql.default.svc.cluster.local"
  secrets:
    REDIS_URL: "rediss://default:password@redis.default.svc.cluster.local:6379"
```

### 5. Test Locally

```bash
# Install chart with local values
helm install myapp ./charts/laravel -f values-local.yaml

# Get NodePort
kubectl get svc my-laravel-app-web

# Access application
# Access application
# If using minikube: minikube service my-laravel-app-web
# If using k3d/kind: http://localhost:<nodeport>
```

## 🔧 Troubleshooting

### Pods Not Starting

```bash
# Check pod events
kubectl describe pod -n production <pod-name>

# Check logs
kubectl logs -n production <pod-name>

# Check if image can be pulled
kubectl get events -n production --sort-by='.lastTimestamp'
```

**Common causes**: 
- Image pull errors (check imagePullSecrets)
- CrashLoopBackOff (check logs for Laravel errors)
- Resource limits too low
- Migration failures blocking deployment

### Database Connection Issues

```bash
# Get a web pod
POD=$(kubectl get pods -n production -l app.kubernetes.io/component=web -o jsonpath='{.items[0].metadata.name}')

# Test database connection
kubectl exec -it $POD -n production -- php artisan tinker
# Then run: DB::connection()->getPdo();

# Verify database environment variables
kubectl exec -it $POD -n production -- env | grep DB_

# Check database service
kubectl get svc -n production | grep mysql
```

### Migration Job Failed

```bash
# Check migration job logs
kubectl logs -n production -l app.kubernetes.io/component=migration

# Check job status
kubectl get jobs -n production -l app.kubernetes.io/component=migration

# Delete failed job to retry on next upgrade
kubectl delete job -n production -l app.kubernetes.io/component=migration

# Trigger upgrade again
helm upgrade my-laravel-app ./charts/laravel -f values.yaml -n production
```

### Queue Workers Not Processing Jobs

```bash
# Check worker pod status
kubectl get pods -n production -l app.kubernetes.io/component=worker

# View worker logs
kubectl logs -f -n production -l app.kubernetes.io/component=worker

# Check Horizon status
kubectl exec -it $POD -n production -- php artisan horizon:status

# Restart Horizon
kubectl exec -it $POD -n production -- php artisan horizon:terminate

# Check Redis connection
kubectl exec -it $POD -n production -- redis-cli -h redis ping
```

### Health Check Failures

```bash
# Exec into pod
kubectl exec -n production -it <pod-name> -- bash

# Test health endpoint locally
curl http://localhost:8080/healthcheck

# Verify environment
env | grep APP_
```

### Permission Issues

```bash
# Check security context
kubectl get pod -n production <pod-name> -o jsonpath='{.spec.securityContext}'

# Check file permissions inside pod
kubectl exec -n production -it <pod-name> -- ls -la /var/www/html/storage

# Check writable directories
kubectl exec -n production -it <pod-name> -- ls -la /var/www/html/storage/framework/cache
```

### HPA Not Scaling

```bash
# Check if metrics server is installed
kubectl top nodes
kubectl top pods -n production

# If not installed, install metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Check HPA status
kubectl get hpa -n production
kubectl describe hpa -n production my-laravel-app-web

# View HPA events
kubectl get events -n production --field-selector involvedObject.kind=HorizontalPodAutoscaler
```

### Scheduler Not Running

```bash
# Check CronJob
kubectl get cronjobs -n production

# View recent jobs
kubectl get jobs -n production -l app.kubernetes.io/component=scheduler

# Check logs of latest job
kubectl logs -n production -l app.kubernetes.io/component=scheduler --tail=100

# Manually trigger scheduler
kubectl create job --from=cronjob/my-laravel-app-scheduler manual-run -n production
```

## 🛠️ Common Laravel Operations

### Database Migrations

Migrations run automatically via Helm hooks. To run manually:

```bash
# Get web pod
POD=$(kubectl get pods -n production -l app.kubernetes.io/component=web -o jsonpath='{.items[0].metadata.name}')

# Run migrations
kubectl exec -it $POD -n production -- php artisan migrate --force

# Rollback migration
kubectl exec -it $POD -n production -- php artisan migrate:rollback

# Check migration status
kubectl exec -it $POD -n production -- php artisan migrate:status
```

### Laravel Horizon (Queue Management)

These commands should be run against Horizon pods when using the Horizon deployment:

```bash
# Get a Horizon pod
POD=$(kubectl get pods -n production -l app.kubernetes.io/component=horizon -o jsonpath='{.items[0].metadata.name}')

# Check Horizon status
kubectl exec -it $POD -n production -- php artisan horizon:status

# Restart Horizon gracefully
kubectl exec -it $POD -n production -- php artisan horizon:terminate

# Pause queue processing
kubectl exec -it $POD -n production -- php artisan horizon:pause

# Resume queue processing
kubectl exec -it $POD -n production -- php artisan horizon:continue

# Retry all failed jobs
kubectl exec -it $POD -n production -- php artisan queue:retry all

# Clear failed jobs
kubectl exec -it $POD -n production -- php artisan horizon:clear

# View Horizon logs
kubectl logs -n production -l app.kubernetes.io/component=horizon -f
```

### Cache Management

```bash
# Clear all caches
kubectl exec -it $POD -n production -- php artisan cache:clear
kubectl exec -it $POD -n production -- php artisan config:clear
kubectl exec -it $POD -n production -- php artisan route:clear
kubectl exec -it $POD -n production -- php artisan view:clear

# Warm caches
kubectl exec -it $POD -n production -- php artisan config:cache
kubectl exec -it $POD -n production -- php artisan route:cache
kubectl exec -it $POD -n production -- php artisan view:cache

# Optimize
kubectl exec -it $POD -n production -- php artisan optimize
```

### Artisan Commands

```bash
# Run any artisan command
kubectl exec -it $POD -n production -- php artisan <command>

# Laravel Tinker (interactive shell)
kubectl exec -it $POD -n production -- php artisan tinker

# List all artisan commands
kubectl exec -it $POD -n production -- php artisan list

# View routes
kubectl exec -it $POD -n production -- php artisan route:list
```

### Scaling

```bash
# Manual scaling (when HPA disabled)
kubectl scale deployment my-laravel-app-web -n production --replicas=5
kubectl scale deployment my-laravel-app-worker -n production --replicas=3

# Check HPA status
kubectl get hpa -n production

# View current replicas
kubectl get deployments -n production
```
