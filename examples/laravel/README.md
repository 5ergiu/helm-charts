# 🎨 Laravel Demo Application

This is a demonstration Docker image that creates a fresh Laravel 12.x application using the [ServersideUp PHP](https://serversideup.net/open-source/docker-php/) base images. This image is designed to showcase the capabilities of the Laravel Helm chart in this repository.

## 📦 Image Repository

**GitHub Container Registry:** `ghcr.io/5ergiu/laravel`

## ✨ Features

- 🚀 Fresh Laravel 12.x installation
- ⚡ PHP 8.5 with FPM and Nginx
- 🏗️ Multi-stage build for development and production
- 🎯 Vite-powered frontend with Bun
- ☸️ Optimized for Kubernetes deployment
- 💚 Health check endpoints built-in
- 🔒 Non-root user execution (UID 1000)

## 🐳 Docker Image Variants

This Dockerfile creates two build targets:

### 🛠️ Development (`dev` tag)
- 🐛 Includes Xdebug and pcov for debugging
- 🔥 OPcache disabled for hot reload
- 📢 Verbose error reporting
- 🏠 Designed for local Kubernetes development with hostPath volumes
- ⚡ Includes Vite dev server support via sidecar container

**Build command:**
```bash
docker build --target development -t ghcr.io/5ergiu/laravel:dev .
```

### 🚀 Production (`latest` tag)
- ⚡ Optimized for performance
- 🎯 OPcache enabled with no timestamp validation
- 🏭 Production-ready PHP-FPM configuration
- 🔇 Minimal error reporting
- 📦 Built frontend assets included

**Build command:**
```bash
docker build --target production -t ghcr.io/5ergiu/laravel:latest .
```

## 🏗️ Architecture

The Dockerfile uses a multi-stage build process:

1. **laravel-builder**: Creates a fresh Laravel application using Composer
2. **deps-builder**: Installs dependencies and configures for Kubernetes
3. **development**: Development-ready image with debugging tools
4. **production**: Optimized runtime image with compiled assets

### 🔒 Kubernetes-Optimized Configuration

This image is specifically configured for production Kubernetes environments with enhanced security:

**Read-Only Filesystem Support:**
- Custom static `nginx.conf` with all temp paths pointing to `/tmp`
- No template processing required at runtime
- Pre-configured for port 8080 (non-privileged)
- All configuration baked into the image

**Disabled Default Entrypoint Scripts:**
- The ServersideUp PHP image's default entrypoint scripts are disabled via `DISABLE_DEFAULT_CONFIG=true`
- Default scripts require writable filesystem for nginx template processing
- Custom entrypoint scripts in `entrypoint.d/` provide minimal runtime initialization
- Only essential container info display script is included

**Security Benefits:**
- ✅ Compatible with `readOnlyRootFilesystem: true`
- ✅ Works with restrictive Pod Security Standards
- ✅ No runtime file modifications needed
- ✅ Tmpfs volumes only for application cache/sessions

## ☸️ Deployment with Helm

This image is designed to work with the Laravel Helm chart located in `../../charts/laravel`.

### 🏠 Local Development Deployment

**Zero External Dependencies!** Uses SQLite and file-based drivers - no MySQL or Redis needed.

```bash
# 1. Install Traefik (if not already installed)
helm install traefik traefik/traefik -n traefik --create-namespace

# 2. Add to /etc/hosts
echo "127.0.0.1 laravel.local" | sudo tee -a /etc/hosts

# 3. Copy and configure secrets
cp secrets.local.yaml.example secrets.local.yaml
# Generate APP_KEY: docker run --rm ghcr.io/5ergiu/laravel:latest php artisan key:generate --show
# Edit secrets.local.yaml with your APP_KEY

# 4. Deploy with local development values (includes Bun sidecar for Vite HMR)
helm install myapp-dev ../../charts/laravel \
  -f values.local.yaml \
  -f secrets.local.yaml \
  -n development \
  --create-namespace

# 5. Port forward for Vite HMR
kubectl port-forward -n development svc/myapp-dev-laravel 5173:5173
```

**⚠️ For Hot Reload:**
1. Update `web.podSecurityContext.runAsUser/fsGroup` in [values.local.yaml](values.local.yaml) (run: `id -u && id -g`)
2. Update `extraVolumes[0].hostPath.path` to your Laravel project directory
3. Access http://laravel.local and edit code for instant updates!

### 🌍 Production Deployment

Deploy to production Kubernetes:

```bash
# Update values.prod.yaml with your domain, secrets, and configuration

# Deploy Laravel with production values
helm install myapp ../../charts/laravel \
  -f values.prod.yaml \
  -n production \
  --create-namespace
```

## ⚙️ Configuration

### 🧪 CI Configuration ([values.ci.yaml](values.ci.yaml))

Key features:
- 1️⃣ Single replica for fast testing
- 🚫 Disabled autoscaling and health probes
- 📦 Minimal resources for CI runners
- ⚡ In-memory SQLite for speed
- 🎯 Array cache/session drivers
- 💨 Sync queue for instant processing
- 📉 No external dependencies

### 🔬 Test Configuration ([values.test.yaml](values.test.yaml))

Key features:
- 1️⃣ Single replica for local testing
- 🏠 HTTP-only ingress (no TLS)
- 📉 Minimal resources for laptop/desktop
- 🐛 Debug logging enabled
- 💾 SQLite with file-based drivers
- 🎯 Suitable for Kind/K3d/Minikube
- 🚫 No external dependencies

### 🛠️ Local Development Configuration ([values.local.yaml](values.local.yaml))

Key features:
- 1️⃣ Single replica for faster iteration
- 🔥 Hot reload via hostPath volume mounts
- ⚡ Bun sidecar for Vite HMR
- 🚫 Disabled health probes for faster startup
- 🐛 Debug mode enabled
- 🔓 OPcache disabled
- 💾 SQLite + file-based drivers
- 🚫 No external dependencies

### 🚀 Production Configuration ([values.prod.yaml](values.prod.yaml))

Key features:
- 3️⃣ 3 replicas with horizontal pod autoscaling
- 🔄 Rolling updates with zero downtime
- 🛡️ Pod Disruption Budget for high availability
- ⚡ OPcache enabled with maximum performance
- 🔐 TLS/HTTPS via Traefik with Let's Encrypt
- 🚦 Rate limiting and security headers
- 💾 Cached routes, views, and config
- 🏭 Production-grade PHP-FPM settings
- 🗄️ PostgreSQL/MySQL + Redis recommended

## 🔧 Environment Variables

The image supports configuration via environment variables. See the [ServersideUp PHP documentation](https://github.com/serversideup/docker-php/blob/main/docs/content/docs/8.reference/1.environment-variable-specification.md) for a complete list.

### 🔑 Key Environment Variables

**🐘 PHP Runtime:**
- `PHP_MEMORY_LIMIT`: Memory limit per process (default: `256M`)
- `PHP_MAX_EXECUTION_TIME`: Maximum execution time (default: `99`)
- `PHP_OPCACHE_ENABLE`: Enable OPcache (`0` for dev, `1` for prod)
- `PHP_DISPLAY_ERRORS`: Display errors (`On` for dev, `Off` for prod)

**⚙️ PHP-FPM:**
- `PHP_FPM_PM_CONTROL`: Process manager control (`ondemand` for dev, `dynamic` for prod)
- `PHP_FPM_PM_MAX_CHILDREN`: Maximum child processes

## 🧩 Components

### 🌐 Web Application
The main web server running PHP-FPM and Nginx, serving the Laravel application.

### 👷 Queue Workers
Background job processing using Laravel Horizon for queue management and monitoring.

### ⏰ Scheduler
Laravel's task scheduler running via Kubernetes CronJob (every minute).

### 🗄️ Migration Job
Runs database migrations automatically before deployment using Helm hooks.

## 🔒 Security

- 👤 Runs as non-root user (`www-data`, UID 1000)
- 📖 Read-only root filesystem (with tmpfs mounts for writable directories)
- 🚫 No privileged escalation
- 🛡️ All capabilities dropped
- 🔐 Seccomp profile enabled

## 🔧 Technical Implementation Details

### Custom Nginx Configuration

The image includes a pre-configured `nginx.conf` (located in `nginx/nginx.conf`) that is copied during the build process. This approach differs from the ServersideUp PHP image defaults:

**Why Custom Configuration?**
- The default ServersideUp image uses template files (`.template`) that are processed at container startup
- Template processing requires writing to `/etc/nginx/`, which conflicts with `readOnlyRootFilesystem: true`
- Our custom config is static and requires no runtime modifications

**Division of Responsibilities (Traefik + Nginx):**

This setup uses Traefik as the edge load balancer and Nginx solely as a FastCGI proxy to PHP-FPM. Since Traefik doesn't support FastCGI protocol directly, Nginx acts as the bridge.

*Traefik Handles (via Middlewares):*
- ✅ Security headers (HSTS, X-Frame-Options, X-Content-Type-Options, CSP, etc.)
- ✅ Response compression (gzip)
- ✅ Rate limiting
- ✅ Real IP detection (X-Forwarded-For parsing)
- ✅ TLS termination
- ✅ HTTP to HTTPS redirects

*Nginx Handles (Minimal Config):*
- ✅ FastCGI proxy to PHP-FPM (port 9000)
- ✅ Laravel routing and static file serving
- ✅ Read-only filesystem compatibility (temp paths to `/tmp`)

**Key Configuration Points:**
- Listens on port 8080 (non-privileged port)
- All temporary paths point to `/tmp` (mounted as tmpfs)
- Error logs to `/dev/stderr`, access logs disabled (use Traefik logs)
- No duplicate security headers (handled by Traefik)
- No gzip compression (handled by Traefik)
- Minimal configuration (~100 lines vs 180+ lines with duplicates)

### Entrypoint Script Customization

**Default Behavior (Disabled):**
The ServersideUp PHP image includes several entrypoint scripts that:
- Process nginx/PHP configuration templates using `envsubst`
- Require write access to `/etc/nginx/` and other system directories
- Are designed for traditional deployment models

**Our Approach:**
- Set `DISABLE_DEFAULT_CONFIG=true` to disable built-in entrypoint scripts
- Provide minimal custom scripts in `entrypoint.d/`:
  - `10-container-info.sh`: Display container runtime information
- All configuration is baked into the image during build

**Files in the Build:**
```dockerfile
# Copy custom entrypoint scripts
COPY --chmod=755 ./entrypoint.d/ /etc/entrypoint.d/

# Copy custom nginx configuration
COPY --chmod=644 ./nginx/nginx.conf /etc/nginx/nginx.conf
```

All other PHP and application configuration is handled via environment variables as documented in the [ServersideUp PHP Environment Variables Reference](https://github.com/serversideup/docker-php/blob/main/docs/content/docs/8.reference/1.environment-variable-specification.md).

## 📚 Resources

- **📖 Laravel Documentation:** https://laravel.com/docs
- **🐳 ServersideUp PHP Images:** https://serversideup.net/open-source/docker-php/
- **💻 ServersideUp PHP GitHub:** https://github.com/serversideup/docker-php
- **⎈ Helm Chart:** `../../charts/laravel`

## 📄 License

This demo application follows Laravel's license. The ServersideUp PHP images are licensed under the GPL-3.0 license.
