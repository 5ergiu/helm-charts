# Next.js Dockerfile using the image example from the Next.js docs
# https://nextjs.org/docs/deployment
# https://github.com/vercel/next.js/blob/canary/examples/with-docker/Dockerfile.bun
#
# This is a DEMO Dockerfile that creates a fresh Next.js application.
# For your own projects, replace the nextjs-builder stage with your app code.
#
# This Dockerfile supports both development and production builds:
# - Build for development: docker build --target dev -t app:dev .
# - Build for production: docker build --target production -t app:production .

###############################
# Next.js App Builder: Create fresh Next.js application
###############################
FROM oven/bun:1.3.4-alpine AS nextjs-builder

WORKDIR /app

# Create a fresh Next.js application with TypeScript and App Router
# This installs Next.js 16.x (latest version)
RUN bunx create-next-app@latest . --typescript --tailwind --app --src-dir \
    --import-alias "@/*" --no-git --yes

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/app/api-reference/config/next-config-js/output
RUN sed -i '/const nextConfig: NextConfig = {/a\  output: "standalone",' next.config.ts

# Add enterprise-grade health check endpoint
COPY health-check-route.ts src/app/api/health/route.ts

RUN bun run build

###############################
# Development Stage: For local development with hot reload
###############################
FROM nextjs-builder AS dev

WORKDIR /app

# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=development

# Expose Next.js dev server port
EXPOSE 3000

# Start Next.js in development mode with hot reload
CMD ["bun", "run", "dev"]

###############################
# Production Stage: Optimized runtime image
###############################
FROM oven/bun:1.3.4-alpine AS production

WORKDIR /app

# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production \
    PORT=3000 \
    HOSTNAME="0.0.0.0"

COPY --from=nextjs-builder /app/public ./public
COPY --from=nextjs-builder --chown=bun:bun /app/.next/standalone ./
COPY --from=nextjs-builder --chown=bun:bun /app/.next/static ./.next/static

# Switch to non-root user
USER bun

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/api/health || exit 1

# Start the application
CMD ["bun", "server.js"]
