# Next.js Dockerfile using official Node.js Alpine images
# https://nextjs.org/docs/deployment
# https://github.com/vercel/next.js/tree/canary/examples/with-docker
#
# This is a DEMO Dockerfile that creates a fresh Next.js application.
# For your own projects, replace the nextjs-builder stage with your app code.
#
# This Dockerfile supports both development and production builds:
# - Build for production: docker build --target production -t app:prod .
# - Build for development: docker build --target development -t app:dev .

###############################
# Next.js App Builder: Create fresh Next.js application
###############################
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies for creating Next.js app
RUN apk add --no-cache libc6-compat

# Create a fresh Next.js application with TypeScript and App Router
# This installs Next.js 16.x (latest version)
RUN npx create-next-app@latest . --typescript --tailwind --app --src-dir \
    --import-alias "@/*" --no-git --yes

# Install dependencies
RUN npm ci

# Set environment to production for optimal build
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Build Next.js application
# This creates an optimized production build with standalone output
RUN npm run build

###############################
# Development Stage: For local development with hot reload
###############################
FROM node:20-alpine AS development

WORKDIR /app

# Install dependencies for better compatibility
RUN apk add --no-cache libc6-compat

# Copy fresh Next.js application
COPY --from=builder /app .

# Install all dependencies (including devDependencies)
RUN npm install

# Set development environment
ENV NODE_ENV=development
ENV NEXT_TELEMETRY_DISABLED=1

# Expose Next.js dev server port
EXPOSE 3000

# Start Next.js in development mode with hot reload
CMD ["npm", "run", "dev"]

###############################
# Production Stage: Optimized runtime image
###############################
FROM node:20-alpine AS production

WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache libc6-compat

# Create non-root user for running the application
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Set environment variables
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Copy fresh Next.js application
COPY --from=builder /app .

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start the application
CMD ["node", "server.js"]
