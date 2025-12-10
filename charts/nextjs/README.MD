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
    DATABASE_URL: "postgresql://user@postgres:5432/myapp"
  
  secrets:
    DATABASE_PASSWORD: "your-secure-password"
    NEXTAUTH_SECRET: "your-nextauth-secret"
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

## ⚙️ Configuration

### Image Configuration

```yaml
image:
  repository: ghcr.io/yourorg/nextjs-app
  pullPolicy: IfNotPresent
  tag: "1.0.0"

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
    DATABASE_URL: "postgresql://user@postgres:5432/myapp"
    REDIS_URL: "redis://redis:6379"
    SMTP_HOST: "smtp.sendgrid.net"
    SMTP_PORT: "587"
  
  # Sensitive data (stored in Kubernetes Secret)
  secrets:
    DATABASE_PASSWORD: "your-password"
    REDIS_PASSWORD: "your-redis-password"
    API_SECRET_KEY: "your-api-secret"
    NEXTAUTH_SECRET: "your-nextauth-secret"
    NEXTAUTH_URL: "https://myapp.example.com"
    GITHUB_CLIENT_ID: "your-github-oauth-id"
    GITHUB_CLIENT_SECRET: "your-github-oauth-secret"
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

## 🏗️ Docker Image Requirements

Your Next.js Docker image should follow these guidelines:

### Dockerfile Example

```dockerfile
# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Build Next.js app
RUN npm run build

# Production stage
FROM node:20-alpine AS runner

WORKDIR /app

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy built app
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]
```

### next.config.js

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

## 🚀 Local Development

For local Kubernetes development (minikube, k3d, kind):

### 1. Adjust Security Context

```yaml
app:
  podSecurityContext:
    runAsUser: 1000  # Your host user ID (run: id -u)
    fsGroup: 1000    # Your host group ID (run: id -g)
```

### 2. Use NodePort Service (Optional)

```yaml
app:
  service:
    type: NodePort
    port: 80
    targetPort: 3000
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

### 4. Test Locally

```bash
# Install chart
helm install myapp ./charts/nextjs -f values-local.yaml

# Get NodePort
kubectl get svc myapp-nextjs-app

# Access application
# If using minikube: minikube service myapp-nextjs-app
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
