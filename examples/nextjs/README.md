# ⚡ Next.js Demo Application

This is a demonstration Docker image that creates a fresh Next.js 16.x application with TypeScript, Tailwind CSS, and the App Router. This image is designed to showcase the capabilities of the Next.js Helm chart in this repository.

## 📦 Image Repository

**GitHub Container Registry:** `ghcr.io/5ergiu/nextjs`

## ✨ Features

- 🚀 Fresh Next.js 16.x installation with TypeScript
- 🎨 Tailwind CSS for styling
- 🛤️ App Router architecture
- 📦 Standalone output mode for minimal Docker images
- 🏗️ Multi-stage build for development and production
- ⚡ Optimized with Bun runtime
- 💚 Health check endpoints built-in
- 🔒 Non-root user execution (UID 1001)

## 🐳 Docker Image Variants

This Dockerfile creates two build targets:

### 🛠️ Development (`dev` tag)
- 🔥 Hot reload with Bun dev server
- 🐛 Development mode enabled
- 📢 Verbose logging
- 🚫 Telemetry disabled
- 📁 Full source code included

**Build command:**
```bash
docker build --target development -t ghcr.io/5ergiu/nextjs:dev .
```

### 🚀 Production (`latest` tag)
- ⚡ Optimized standalone build
- 📦 Only production dependencies
- 🪶 Minimal image size using output traces
- 🎯 Static assets pre-built
- 🏭 Production-ready configuration

**Build command:**
```bash
docker build --target production -t ghcr.io/5ergiu/nextjs:latest .
```

## 🏗️ Architecture

The Dockerfile uses a multi-stage build process:

1. **nextjs-builder**: Creates a fresh Next.js application with Bun and builds it with standalone output
2. **development**: Development-ready image with hot reload support
3. **production**: Minimal runtime image with only standalone output and static assets

## ☸️ Deployment with Helm

This image is designed to work with the Next.js Helm chart located in `../../charts/nextjs`.

### 🏠 Local Development Deployment

Deploy to your local Kubernetes cluster:

```bash
# Install Traefik (if not already installed)
helm install traefik traefik/traefik -n traefik --create-namespace

# Install optional dependencies
helm install postgres bitnami/postgresql -n development --create-namespace
helm install redis bitnami/redis -n development --create-namespace

# Add to /etc/hosts
echo "127.0.0.1 nextjs.local" | sudo tee -a /etc/hosts

# Deploy Next.js with development values
helm install myapp-dev ../../charts/nextjs \
  -f values.dev.yaml \
  -n development \
  --create-namespace

# Access the application
open http://nextjs.local
```

### 🌍 Production Deployment

Deploy to production Kubernetes:

```bash
# Update values.prod.yaml with your domain, secrets, and configuration

# Deploy Next.js with production values
helm install myapp ../../charts/nextjs \
  -f values.prod.yaml \
  -n production \
  --create-namespace
```

## ⚙️ Configuration

### 🛠️ Development Configuration ([values.dev.yaml](values.dev.yaml))

Key features:
- 1️⃣ Single replica for faster iteration
- 🔌 LoadBalancer service for local access
- 🚫 Disabled health probes for faster startup
- 🐛 Development mode enabled
- 📢 Debug logging
- 🏠 Local service dependencies (PostgreSQL, Redis, Mailpit)
- 📉 Minimal resource requests

### 🚀 Production Configuration ([values.prod.yaml](values.prod.yaml))

Key features:
- 3️⃣ 3 replicas with horizontal pod autoscaling
- 🔄 Rolling updates with zero downtime
- 🛡️ Pod Disruption Budget for high availability
- 🔐 TLS/HTTPS via Traefik with Let's Encrypt
- 🚦 Rate limiting and security headers
- 🏭 Production environment variables
- ⚡ Optimized resource allocation
- 💾 Persistent storage for uploads

## 🔧 Environment Variables

The image supports configuration via environment variables.

### �� Build-time Variables (Public)

These are embedded during the build and exposed to the browser:

- `NEXT_PUBLIC_APP_NAME`: Application name
- `NEXT_PUBLIC_APP_URL`: Public application URL
- `NEXT_PUBLIC_API_URL`: Public API endpoint
- `NEXT_PUBLIC_ENABLE_ANALYTICS`: Enable analytics features

### 🔐 Runtime Variables (Server-side Only)

These are NOT exposed to the browser:

**⚡ Next.js Configuration:**
- `NODE_ENV`: Environment (`development` or `production`)
- `PORT`: Server port (default: `3000`)
- `HOSTNAME`: Server hostname (default: `0.0.0.0`)
- `NEXT_TELEMETRY_DISABLED`: Disable telemetry collection

**🗄️ Database:**
- `DATABASE_URL`: PostgreSQL connection string
- `DATABASE_PASSWORD`: Database password (secret)

**💾 Cache:**
- `REDIS_URL`: Redis connection string
- `REDIS_PASSWORD`: Redis password (secret)

**📧 Email/SMTP:**
- `SMTP_HOST`: SMTP server hostname
- `SMTP_PORT`: SMTP server port
- `SMTP_USER`: SMTP username (secret)
- `SMTP_PASSWORD`: SMTP password (secret)
- `SMTP_FROM`: From email address

**☁️ Storage:**
- `AWS_REGION`: AWS region
- `AWS_S3_BUCKET`: S3 bucket name
- `AWS_ACCESS_KEY_ID`: AWS access key (secret)
- `AWS_SECRET_ACCESS_KEY`: AWS secret key (secret)

**🔑 Authentication:**
- `NEXTAUTH_SECRET`: NextAuth.js secret (secret)
- `NEXTAUTH_URL`: NextAuth.js callback URL

## 💚 Health Checks

The image includes a health check endpoint at `/api/health` that provides comprehensive application monitoring:

### 📊 Health Check Response

```json
{
  "status": "healthy",
  "timestamp": "2025-12-15T10:30:45.123Z",
  "uptime": 3600,
  "memory": {
    "rss": 128,
    "heapTotal": 64,
    "heapUsed": 32,
    "external": 8
  },
  "environment": "production"
}
```

### 🔍 Endpoint Details

- **GET** `/api/health` - Returns detailed health information
  - **200 OK** when healthy
  - **503 Service Unavailable** when unhealthy
- **HEAD** `/api/health` - Lightweight health check (200 OK)

### 📈 Metrics Included

- **Status** - `healthy` or `unhealthy`
- **Uptime** - Application uptime in seconds
- **Memory Usage** - RSS, heap total, heap used, and external memory in MB
- **Timestamp** - ISO 8601 formatted timestamp
- **Environment** - Current NODE_ENV

### ☸️ Kubernetes Probes

The health check is designed for Kubernetes probes and is automatically configured in the Helm chart:

```yaml
startupProbe:
  httpGet:
    path: /api/health
    port: 3000
  periodSeconds: 5
  failureThreshold: 30

livenessProbe:
  httpGet:
    path: /api/health
    port: 3000
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /api/health
    port: 3000
  periodSeconds: 5
```

### 🧪 Testing

```bash
# GET request with full details
curl http://localhost:3000/api/health

# HEAD request (lightweight)
curl -I http://localhost:3000/api/health
```

## 📦 Standalone Output Mode

This image uses Next.js standalone output mode, which:

- 🎯 Automatically traces and includes only necessary files
- 🪶 Significantly reduces image size
- 📦 Includes only production dependencies
- ⚡ Optimizes startup time

The standalone mode is configured in `next.config.ts`:

```typescript
const nextConfig: NextConfig = {
  output: "standalone",
}
```

## 🎯 Architecture Choices

### 🥟 Bun Runtime
This image uses Bun instead of Node.js for:
- ⚡ Faster startup times
- 💾 Lower memory usage
- 📘 Built-in TypeScript support
- 🚀 Better performance

### 🛤️ App Router
The demo uses Next.js App Router (not Pages Router) for:
- 🎨 Server Components by default
- 📊 Improved data fetching patterns
- 📘 Better TypeScript support
- ⚛️ Modern React features (Suspense, etc.)

### 🎨 Tailwind CSS
Includes Tailwind CSS for:
- 🎯 Utility-first styling
- 🪶 Small bundle size
- ⚡ Built-in optimization
- 🎨 Easy customization

## 🔒 Security

- 👤 Runs as non-root user (`nextjs`, UID 1001)
- 📖 Read-only root filesystem (with tmpfs mounts for cache directories)
- 🚫 No privileged escalation
- 🛡️ All capabilities dropped
- 🔐 Seccomp profile enabled

## 💾 Persistent Storage

For applications that need persistent storage (user uploads, generated files, etc.):

1. Enable persistence in your values file:
```yaml
persistence:
  enabled: true
  size: 10Gi
  mounts:
    - name: storage
      mountPath: /app/public/uploads
      subPath: uploads
```

2. Access files in your application from `/app/public/uploads`

## 🎯 Common Use Cases

### 🖼️ Image Optimization
Next.js Image component works out of the box. For custom image optimization with S3:

```yaml
nextjs:
  env:
    AWS_REGION: "us-east-1"
    AWS_S3_BUCKET: "my-images"
  secrets:
    AWS_ACCESS_KEY_ID: "your-key-id"
    AWS_SECRET_ACCESS_KEY: "your-secret-key"
```

### 🔌 API Routes
API routes are included in the standalone output and work normally at `/api/*`.

### 📁 Static Assets
Static assets in `/public` are automatically included in the production build.

### 🔄 ISR (Incremental Static Regeneration)
ISR works with the standalone output. Configure revalidation in your pages/routes as needed.

## 📚 Resources

- **📖 Next.js Documentation:** https://nextjs.org/docs
- **🚀 Next.js Deployment Guide:** https://nextjs.org/docs/deployment
- **🥟 Bun Documentation:** https://bun.sh/docs
- **⎈ Helm Chart:** `../../charts/nextjs`

## 📄 License

This demo application follows Next.js's license (MIT).
