# Next.js Helm Chart

High-performance Next.js application deployment with SSR/SSG support, image optimization, and CDN integration.

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational) ![Type: application](https://img.shields.io/badge/Type-application-informational) ![AppVersion: v16.x.0](https://img.shields.io/badge/AppVersion-v16.x-informational)

## 🚀 Installation

### Install from OCI Registry

```bash
# Install the chart
helm install my-nextjs-app \
  oci://ghcr.io/5ergiu/helm-charts/nextjs \
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
helm install my-nextjs-app ./charts/nextjs \
  --namespace production \
  --create-namespace \
  --values values.yaml
```

## 🗑️ Uninstall

```bash
# Uninstall release
helm uninstall my-nextjs-app -n production

# Optionally delete namespace
kubectl delete namespace production

# Note: PVCs are not deleted automatically for data safety
# Delete PVCs manually if needed:
kubectl delete pvc -n production -l app.kubernetes.io/instance=my-nextjs-app
```

## 🔄 Upgrade & Rollback

```bash
# Upgrade with new values
helm upgrade my-nextjs-app oci://ghcr.io/5ergiu/helm-charts/nextjs \
  --version 0.1.0 \
  --namespace production \
  --values values.yaml

# View release history
helm history my-nextjs-app -n production

# Rollback to previous version
helm rollback my-nextjs-app -n production
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
cosign verify --key cosign.pub ghcr.io/5ergiu/helm-charts/nextjs:0.1.0
```

For more details on chart verification, see [COSIGN.md](../../COSIGN.md).

## 📦 Quick Start

```yaml
# values.yaml
image:
  repository: ghcr.io/yourorg/nextjs-app
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

nextjs:
  publicEnv:
    NEXT_PUBLIC_APP_NAME: "My App"
    NEXT_PUBLIC_API_URL: "https://api.myapp.example.com"

  env:
    NODE_ENV: "production"
    # Add any custom environment variables as needed
    # External services (database, Redis, etc.) are optional

  secrets:
    # Only add secrets if you need external services
    # DATABASE_PASSWORD: "your-secure-password"  # Optional
    # REDIS_PASSWORD: "your-redis-password"      # Optional
    NEXTAUTH_SECRET: "your-nextauth-secret"     # If using NextAuth.js
```

Then install:

```bash
helm install myapp ./charts/nextjs -f values.yaml -n production --create-namespace
```

## ✨ Features

### 🎯 Core Features

- **Production-Ready Deployment** - Optimized for production workloads with security best practices
- **SSR/SSG Support** - Full support for Server-Side Rendering and Static Site Generation
- **Auto-Scaling** - Horizontal Pod Autoscaler (HPA) based on CPU/Memory
- **Health Checks** - Comprehensive liveness, readiness, and startup probes
- **Security Hardened** - Non-root user, read-only filesystem, dropped capabilities
- **Resource Management** - Configurable resource requests and limits

### 🌐 Networking

- **Ingress Controller Support** - Traefik, NGINX, or any Kubernetes ingress
- **TLS/SSL** - Automatic HTTPS with cert-manager integration
- **Rate Limiting** - Built-in rate limiting via Traefik middleware
- **Security Headers** - HSTS, XSS protection, content-type nosniff
- **Compression** - Automatic response compression

### 🔧 Configuration

- **Environment Variables** - Separate public and server-side environment variables
- **Secrets Management** - Kubernetes secrets for sensitive data
- **External Secrets** - Support for External Secrets Operator
- **ConfigMap/Secret** - Automatic configuration injection

### 📊 Observability

- **Prometheus Metrics** - Pod annotations for Prometheus scraping
- **Structured Logging** - JSON logging to stdout/stderr
- **Pod Disruption Budget** - High availability configuration
- **Rolling Updates** - Zero-downtime deployments

### 💾 Storage

- **Persistent Volumes** - Optional PVC for user uploads or generated files
- **Tmpfs Volumes** - In-memory volumes for cache and temporary files
- **Read-Only Filesystem** - Enhanced security with tmpfs for writable paths

## 📋 Prerequisites

- **Kubernetes 1.24+**
- **Helm 3.8+**
- **Ingress controller** (Traefik, NGINX, etc.) for external access
- **cert-manager** (optional, for automatic TLS certificates)

**Note:** Next.js runs standalone without external dependencies. Database, cache, and other services are optional and only needed if your application requires them.

## ⚙️ Configuration

### Image Configuration

```yaml
image:
  repository: ghcr.io/yourorg/nextjs-app
  pullPolicy: Always

imagePullSecrets:
  - name: ghcr-secret
```

### Application Settings

```yaml
app:
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
    targetPort: 3000
```

### Auto-Scaling

```yaml
app:
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
      # Sticky sessions for Next.js apps
      sticky:
        cookieName: nextjs_sticky
        secure: true
        httpOnly: true
        sameSite: lax
      # Service weight (for A/B testing or canary)
      weight: 100

  # TLS configuration
  tls:
    # Option A: Use existing secret
    secretName: nextjs-tls

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
- Sticky sessions for stateful Next.js apps
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

  # IP Whitelist - Restrict access by IP
  ipWhiteList:
    enabled: false
    sourceRange:
      - 10.0.0.0/8
      - 172.16.0.0/12

  # Middleware Chain - Combine multiple middlewares
  chain:
    enabled: false
    middlewares:
      - headers
      - ratelimit
      - compress
```

**Available Middlewares:**
- ✅ **Rate Limiting** - Protect against DDoS and abuse
- ✅ **Security Headers** - HSTS, CSP, XSS protection, CORS
- ✅ **Compression** - Gzip compression for better performance
- ✅ **Redirect Scheme** - HTTP to HTTPS redirection
- ✅ **Strip Prefix** - Path manipulation for API versioning
- ✅ **Retry** - Automatic retry on transient failures
- ✅ **Circuit Breaker** - Prevent cascading failures
- ✅ **In-Flight Requests** - Limit concurrent connections
- ✅ **IP Whitelist** - IP-based access control
- ✅ **Middleware Chain** - Compose multiple middlewares

See [values.yaml](values.yaml) for all available configuration options.

### Environment Variables

Next.js distinguishes between public (browser-accessible) and server-side environment variables:

```yaml
nextjs:
  # Public environment variables (exposed to browser)
  # These must start with NEXT_PUBLIC_
  publicEnv:
    NEXT_PUBLIC_APP_NAME: "My App"
    NEXT_PUBLIC_APP_URL: "https://myapp.example.com"
    NEXT_PUBLIC_API_URL: "https://api.myapp.example.com"
    NEXT_PUBLIC_GOOGLE_ANALYTICS: "G-XXXXXXXXXX"
  
  # Server-side environment variables (not exposed to browser)
  env:
    NODE_ENV: "production"
    PORT: "3000"
    # Add external service URLs only if your application needs them
    # DATABASE_URL: "postgresql://user@postgres:5432/myapp"  # Optional
    # REDIS_URL: "redis://redis:6379"                        # Optional
    # SMTP_HOST: "smtp.sendgrid.net"                         # Optional
    # SMTP_PORT: "587"                                       # Optional

  # Sensitive data (stored in Kubernetes Secret)
  # Only add secrets for services your application actually uses
  secrets:
    # DATABASE_PASSWORD: "your-password"           # Optional - only if using database
    # REDIS_PASSWORD: "your-redis-password"        # Optional - only if using Redis
    # API_SECRET_KEY: "your-api-secret"            # Optional - for your API
    NEXTAUTH_SECRET: "your-nextauth-secret"        # If using NextAuth.js
    # NEXTAUTH_URL: "https://myapp.example.com"    # If using NextAuth.js
    # GITHUB_CLIENT_ID: "your-github-oauth-id"     # If using GitHub OAuth
    # GITHUB_CLIENT_SECRET: "your-github-oauth-secret"  # If using GitHub OAuth
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
      mountPath: /app/public/uploads
      subPath: uploads
```

### Security Context

```yaml
app:
  podSecurityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  
  securityContext:
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL
    readOnlyRootFilesystem: true
```

## 🏗️ Building Your Docker Image

This repository includes a complete demo Dockerfile that creates a fresh Next.js 16.x installation. You can use it to test the Helm chart immediately or as a template for your own projects.

### Using with Your Own Next.js Project

The demo Dockerfile is designed as a template. To use it with your own project:

**Option 1: Modify the builder stage**
**Option 2: Copy the pattern into your project**

### Dockerfile Features

The demo Dockerfile (`examples/nextjs-app/Dockerfile`) includes:

- ✅ **Fresh Next.js 16.x installation** (for demo/testing)
- ✅ **Multi-stage build** (builder, development, production)
- ✅ **TypeScript, Tailwind CSS, App Router, src/ directory**
- ✅ **Development stage** with hot module replacement
- ✅ **Production stage** with standalone output (minimal size)
- ✅ **Non-root user** (nextjs:nodejs, UID 1001)
- ✅ **Health check endpoint**
- ✅ **Alpine Linux base** (smaller images)
- ✅ **Security best practices**

### Required: next.config.js

Your Next.js project must use standalone output mode:

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Required for standalone output
  output: 'standalone',

  // Enable compression
  compress: true,

  // Optimize for production
  poweredByHeader: false,
  generateEtags: true,

  // Image optimization
  images: {
    domains: ['yourdomain.com'],
    formats: ['image/webp', 'image/avif'],
  },
}

module.exports = nextConfig
```

## 🩺 Health Check Endpoint

Create a health check API route for Kubernetes probes:

### App Router (Next.js 13+)

```typescript
// app/api/health/route.ts
export async function GET() {
  return Response.json({ status: 'ok', timestamp: new Date().toISOString() })
}
```

### Pages Router (Next.js 12 and below)

```typescript
// pages/api/health.ts
import type { NextApiRequest, NextApiResponse } from 'next'

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() })
}
```

## 🧪 Testing

Test your deployment:

```bash
# Check pod status
kubectl get pods -n production -l app.kubernetes.io/name=nextjs

# View logs
kubectl logs -n production -l app.kubernetes.io/name=nextjs -f

# Port forward for local testing
kubectl port-forward -n production svc/my-nextjs-app-app 3000:80

# Test health endpoint
curl http://localhost:3000/api/health
```

## 📊 Monitoring

### Prometheus Integration

The chart includes Prometheus annotations by default:

```yaml
app:
  podAnnotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9090"
```

### Grafana Dashboards

Import Next.js and Kubernetes dashboards:
- **Kubernetes Pods** - Dashboard ID: 6417
- **Node.js Application** - Dashboard ID: 11159

## 💻 Local Development with Kubernetes

This chart supports full local development using Kubernetes (Docker Desktop, Minikube, or Kind) with hot reload and all production features.

### Quick Start (Local Development)

**Zero External Dependencies!** Next.js runs standalone - no database or cache needed for local development.

**See the [examples/nextjs](../../examples/nextjs) directory for complete deployment guides including:**
- **values.local.yaml** - Full local development configuration
- **values.test.yaml** - Local testing with Kind/K3d/Minikube
- **values.ci.yaml** - CI/CD optimized configuration
- **README.md** - Detailed setup instructions and deployment guide

**Quick Local Setup:**
```bash
# 1. Install Traefik (if not already installed)
helm install traefik traefik/traefik -n traefik --create-namespace

# 2. Add to /etc/hosts
echo "127.0.0.1 nextjs.local" | sudo tee -a /etc/hosts

# 3. (Optional) Copy and configure secrets - only if you need external services
cd examples/nextjs
cp secrets.local.yaml.example secrets.local.yaml
# Edit secrets.local.yaml with your credentials (if needed)

# 4. Deploy with local development values
helm install myapp-dev ../../charts/nextjs \
  -f values.local.yaml \
  -n development \
  --create-namespace

# 5. Access the application
open http://nextjs.local
```

**Access your application:**
- **Next.js App**: http://nextjs.local

For production deployment with PostgreSQL/Redis, see [examples/nextjs/values.prod.yaml](../../examples/nextjs/values.prod.yaml).

### Development Configuration

The local development values files provide optimized settings for different scenarios:

**values.local.yaml** - Full local development:
```yaml
global:
  environment: development

image:
  tag: "dev"  # Development build target

web:
  replicaCount: 1  # Single replica

  # Minimal resources
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 256Mi

  # Faster startup - no probes
  livenessProbe:
    enabled: false
  readinessProbe:
    enabled: false
  startupProbe:
    enabled: false

nextjs:
  env:
    NODE_ENV: "development"
    # Add any custom environment variables as needed
    # External services (database, Redis) are optional

# HTTP only (no TLS)
ingressRoute:
  enabled: true
  entryPoints:
    - web
  routes:
    - match: "Host(`nextjs.local`)"
  tls: {}

# No middlewares in dev for simplicity
middleware:
  enabled: false
```

For production deployment with external services, see [examples/nextjs/values.prod.yaml](../../examples/nextjs/values.prod.yaml).

### Customizing for Your User ID

To avoid permission issues with volume mounts, match your host user:

```bash
# Get your user and group IDs
id -u  # e.g., 1000
id -g  # e.g., 1000

# Update values.dev.yaml or use --set
helm upgrade myapp-dev ./charts/nextjs \
  -f charts/nextjs/values.dev.yaml \
  -n development \
  --set app.podSecurityContext.runAsUser=$(id -u) \
  --set app.podSecurityContext.fsGroup=$(id -g)
```

### Hot Reload in Development

The development Docker image (`--target development`) includes:

- ✅ **Hot Module Replacement (HMR)** - Code changes reload instantly
- ✅ **Development Dependencies** - All dev packages installed
- ✅ **Source Maps** - Full debugging support
- ✅ **Error Overlay** - Detailed error messages in browser
- ✅ **Fast Refresh** - React component hot reload

To enable hot reload with your own code:

**Option 1: Mount your code (fastest for development)**
```yaml
# In values-local.yaml
extraVolumes:
  - name: code
    hostPath:
      path: /path/to/your/nextjs/app
      type: Directory

extraVolumeMounts:
  - name: code
    mountPath: /app
```

**Option 2: Rebuild image on changes**
```bash
# Use skaffold or tilt for automatic rebuilds
# Or manually rebuild:
docker build --target development -t ghcr.io/5ergiu/nextjs:dev .
kubectl rollout restart deployment/myapp-dev-nextjs-app -n development
```

### Viewing Logs

```bash
# All pods
kubectl logs -n development -l app.kubernetes.io/name=nextjs -f

# Specific pod
kubectl logs -n development <pod-name> -f

# Previous crashed container
kubectl logs -n development <pod-name> --previous
```

### Debugging

```bash
# Exec into pod
kubectl exec -n development -it <pod-name> -- sh

# Check environment variables
kubectl exec -n development <pod-name> -- env | grep NEXT

# Check file permissions
kubectl exec -n development <pod-name> -- ls -la /app

# Test database connection
kubectl exec -n development <pod-name> -- node -e "console.log(process.env.DATABASE_URL)"
```

### Clean Up Local Environment

```bash
# Uninstall application
helm uninstall myapp-dev -n development

# Remove dependencies
helm uninstall postgres -n development
helm uninstall redis -n development
kubectl delete deployment mailpit -n development
kubectl delete service mailpit -n development

# Delete namespace
kubectl delete namespace development

# Remove from /etc/hosts
sudo sed -i '' '/nextjs.local/d' /etc/hosts
```

### Switching Between Development and Production

**Deploy Development:**
```bash
helm install myapp ./charts/nextjs -f charts/nextjs/values.dev.yaml -n development --create-namespace
```

**Deploy Production:**
```bash
helm install myapp ./charts/nextjs -f charts/nextjs/values.prod.yaml -n production --create-namespace
```

**Both Simultaneously (different namespaces):**
```bash
# Development
helm install myapp-dev ./charts/nextjs -f charts/nextjs/values.dev.yaml -n development --create-namespace

# Production
helm install myapp-prod ./charts/nextjs -f charts/nextjs/values.prod.yaml -n production --create-namespace
```

## 🏗️ Production Deployment

### Prerequisites

Before deploying to production, ensure you have:

- Kubernetes cluster (EKS, GKE, AKS, or self-hosted)
- Traefik or NGINX ingress controller
- cert-manager for automatic TLS certificates
- Container registry (ghcr.io, ECR, GCR, ACR)

**Optional (only if your application needs them):**
- PostgreSQL/MySQL database (or managed service like AWS RDS, Google Cloud SQL)
- Redis for caching/sessions (or managed service like AWS ElastiCache, Upstash)

### Deploy to Production

```bash
# Update values.prod.yaml with your settings
# Then deploy:
helm install myapp ./charts/nextjs \
  -f charts/nextjs/values.prod.yaml \
  -n production \
  --create-namespace

# Or from OCI registry:
helm install myapp \
  oci://ghcr.io/5ergiu/helm-charts/nextjs \
  --version 0.1.0 \
  -f values.prod.yaml \
  -n production \
  --create-namespace
```

### Production Configuration

The `values.prod.yaml` file provides optimized settings for production:

```yaml
global:
  environment: production

image:
  repository: ghcr.io/5ergiu/nextjs
  tag: latest

imagePullSecrets:
  - name: ghcr-secret

app:
  replicaCount: 3  # High availability

  # Production resources
  resources:
    limits:
      cpu: 2000m
      memory: 1Gi
    requests:
      cpu: 200m
      memory: 512Mi

  # Auto-scaling
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 20
    targetCPUUtilizationPercentage: 70

  # High availability
  pdb:
    enabled: true
    minAvailable: 2

# Production routing with TLS
ingressRoute:
  enabled: true
  entryPoints:
    - websecure
  routes:
    - match: "Host(`app.example.com`)"
  tls:
    certResolver: letsencrypt-prod

# Production middleware
middleware:
  enabled: true
  rateLimit:
    enabled: true
    average: 100
    burst: 200
  headers:
    enabled: true
    forceSTSHeader: true
  compress:
    enabled: true

# Production environment
nextjs:
  env:
    NODE_ENV: "production"
    LOG_LEVEL: "warn"
    # Add external service URLs only if your application needs them
    # DATABASE_URL: "postgresql://user@postgres.databases.svc.cluster.local:5432/nextjs"
    # REDIS_URL: "redis://redis.databases.svc.cluster.local:6379"

  secrets:
    # Only add secrets for services your application actually uses
    # DATABASE_PASSWORD: ""  # Set via sealed secrets (if using database)
    NEXTAUTH_SECRET: ""      # Generate: openssl rand -base64 32 (if using NextAuth.js)
```

### Secrets Management

**Option 1: Kubernetes Secrets (Basic)**
```bash
# Create secret manually (only include secrets your application needs)
kubectl create secret generic nextjs-secrets \
  -n production \
  --from-literal=NEXTAUTH_SECRET='your-secret'
  # --from-literal=DATABASE_PASSWORD='your-password'  # Optional
  # --from-literal=REDIS_PASSWORD='your-redis-password'  # Optional

# Reference in values.yaml
nextjs:
  secrets:
    NEXTAUTH_SECRET: "your-secret"
    # DATABASE_PASSWORD: "your-password"  # Optional
    # REDIS_PASSWORD: "your-redis-password"  # Optional
```

**Option 2: Sealed Secrets (Recommended)**
```bash
# Install sealed-secrets controller
helm install sealed-secrets sealed-secrets/sealed-secrets -n kube-system

# Create sealed secret (example with NextAuth secret)
echo -n 'your-nextauth-secret' | kubectl create secret generic nextjs-secrets \
  --dry-run=client \
  --from-file=NEXTAUTH_SECRET=/dev/stdin \
  -o yaml | \
  kubeseal -o yaml > sealed-secret.yaml

# Apply sealed secret
kubectl apply -f sealed-secret.yaml -n production

# For database password (optional):
# echo -n 'your-db-password' | kubectl create secret generic nextjs-db-secrets \
#   --dry-run=client \
#   --from-file=DATABASE_PASSWORD=/dev/stdin \
#   -o yaml | \
#   kubeseal -o yaml > sealed-db-secret.yaml
```

**Option 3: External Secrets Operator**
```yaml
# Enable in values.yaml
externalSecrets:
  enabled: true
  backendType: secretsManager  # or vault, gcpSecretsManager
  region: us-east-1
  data:
    # Only add secrets your application needs
    - key: prod/nextjs/nextauth-secret
      name: NEXTAUTH_SECRET
    # - key: prod/nextjs/db-password      # Optional
    #   name: DATABASE_PASSWORD
    # - key: prod/nextjs/redis-password   # Optional
    #   name: REDIS_PASSWORD
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

### Health Check Failures

```bash
# Exec into pod
kubectl exec -n production -it <pod-name> -- sh

# Test health endpoint
wget -O- http://localhost:3000/api/health

# Check environment variables
env | grep NEXT
```

### Permission Issues

```bash
# Check security context
kubectl get pod -n production <pod-name> -o jsonpath='{.spec.securityContext}'

# Check file permissions
kubectl exec -n production -it <pod-name> -- ls -la /app
```

### HPA Not Scaling

```bash
# Check metrics server
kubectl top nodes
kubectl top pods -n production

# Check HPA status
kubectl get hpa -n production
kubectl describe hpa -n production <hpa-name>

# View HPA events
kubectl get events -n production --field-selector involvedObject.kind=HorizontalPodAutoscaler
```

## 📜 License

This chart is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.

## 🔗 Links

- **Chart Repository**: https://github.com/5ergiu/helm-charts
- **Next.js Documentation**: https://nextjs.org/docs
- **Artifact Hub**: https://artifacthub.io/packages/helm/5ergiu/nextjs
- **Issues**: https://github.com/5ergiu/helm-charts/issues

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.

---

**Made with ❤️ for the Next.js community**
