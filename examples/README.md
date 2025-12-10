# Example Applications

This directory contains example Dockerfiles for Laravel and Next.js applications. These are demo/template Dockerfiles that create fresh application installations during the build process, allowing you to test the Helm charts immediately without needing an existing project.

## 📁 Directory Structure

```
examples/
├── laravel-app/
│   └── Dockerfile          # Multi-stage Laravel Dockerfile
└── nextjs-app/
    └── Dockerfile          # Multi-stage Next.js Dockerfile
```

## 🚀 Quick Start - Build Demo Images

You can build and test these images immediately without any Laravel/Next.js project:

### Laravel

```bash
cd examples/laravel-app

# Build development image (with Xdebug, hot reload, Node.js)
docker build --target development -t ghcr.io/5ergiu/laravel:dev .

# Build production image (optimized with OPcache JIT)
docker build --target production -t ghcr.io/5ergiu/laravel:v0.1.0 .

# Test locally
docker run -p 8080:8080 ghcr.io/5ergiu/laravel:dev
# Visit: http://localhost:8080
```

### Next.js

```bash
cd examples/nextjs-app

# Build development image (with hot reload)
docker build --target development -t ghcr.io/5ergiu/nextjs:dev .

# Build production image (standalone optimized)
docker build --target production -t ghcr.io/5ergiu/nextjs:v0.1.0 .

# Test locally
docker run -p 3000:3000 ghcr.io/5ergiu/nextjs:dev
# Visit: http://localhost:3000
```

## 📦 Push to GitHub Container Registry

These are public images, so you can push to GitHub Container Registry (ghcr.io) for free:

```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u your-github-username --password-stdin

# Tag images (replace with your GitHub username)
docker tag ghcr.io/5ergiu/laravel:dev ghcr.io/your-github-username/laravel:dev
docker tag ghcr.io/5ergiu/laravel:v0.1.0 ghcr.io/your-github-username/laravel:v0.1.0
docker tag ghcr.io/5ergiu/nextjs:dev ghcr.io/your-github-username/nextjs:dev
docker tag ghcr.io/5ergiu/nextjs:v0.1.0 ghcr.io/your-github-username/nextjs:v0.1.0

# Push to registry
docker push ghcr.io/your-github-username/laravel:dev
docker push ghcr.io/your-github-username/laravel:v0.1.0
docker push ghcr.io/your-github-username/nextjs:dev
docker push ghcr.io/your-github-username/nextjs:v0.1.0
```

After pushing, make sure to:
1. Go to GitHub → Packages → Your package → Package settings
2. Change visibility to "Public" (for free hosting)
3. Link the package to your repository

## 📋 Using with Your Own Project

These Dockerfiles are designed as templates. You can adapt them for your own projects:

### Option 1: Modify the Builder Stage

Replace the `laravel-builder` or `nextjs-builder` stage with your actual application code:

**Laravel:**
```dockerfile
# Replace this stage:
FROM composer:2.9 AS laravel-builder
WORKDIR /app
RUN composer create-project laravel/laravel . --no-interaction --prefer-dist

# With:
FROM composer:2.9 AS laravel-builder
WORKDIR /app
COPY . .
```

**Next.js:**
```dockerfile
# Replace this stage:
FROM node:20-alpine AS nextjs-builder
WORKDIR /app
RUN npx create-next-app@latest . --typescript --tailwind --app --src-dir --import-alias "@/*" --no-git --yes

# With:
FROM node:20-alpine AS nextjs-builder
WORKDIR /app
COPY . .
```

### Option 2: Use as Reference

Copy the Dockerfile patterns (multi-stage builds, security practices, optimization techniques) into your own project structure.

## 🎯 What These Dockerfiles Include

### Laravel Dockerfile Features:
- ✅ Fresh Laravel 11.x installation (for demo/testing)
- ✅ Multi-stage build (builder, development, production)
- ✅ ServersideUp PHP 8.5 with FPM + Nginx
- ✅ Node.js asset compilation (Vite)
- ✅ Development stage with Xdebug, hot reload
- ✅ Production stage with OPcache JIT optimization
- ✅ Non-root user (www-data)
- ✅ Production-ready with best practices

### Next.js Dockerfile Features:
- ✅ Fresh Next.js 15.x installation (for demo/testing)
- ✅ Multi-stage build (builder, development, production)
- ✅ TypeScript, Tailwind CSS, App Router, src/ directory
- ✅ Development stage with hot module replacement
- ✅ Production stage with standalone output (minimal size)
- ✅ Non-root user (nextjs:nodejs)
- ✅ Health check endpoint
- ✅ Alpine Linux base (smaller images)

## 📚 Documentation

For comprehensive documentation on deploying these applications with Kubernetes:

- **Laravel**: See [charts/laravel/README.md](../charts/laravel/README.md)
- **Next.js**: See [charts/nextjs/README.md](../charts/nextjs/README.md)

Each Helm chart README includes:
- Local Kubernetes development setup
- Production deployment guide
- Configuration options
- Troubleshooting tips
