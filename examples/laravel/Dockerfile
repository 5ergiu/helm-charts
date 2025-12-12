# Laravel Dockerfile using ServersideUp PHP images
# https://serversideup.net/open-source/docker-php/
# https://github.com/serversideup/docker-php
#
# This is a DEMO Dockerfile that creates a fresh Laravel application.
# For your own projects, replace the laravel-builder stage with your app code.
#
# This Dockerfile supports both development and production builds:
# - Build for production: docker build --target production -t app:prod .
# - Build for development: docker build --target development -t app:dev .

###############################
# Laravel App Builder: Create fresh Laravel application
###############################
FROM composer:2.9 AS laravel-builder

WORKDIR /app

# Create a fresh Laravel application
# This installs Laravel 12.x (latest version)
RUN composer create-project laravel/laravel . --no-interaction --prefer-dist

###############################
# Bun Builder: Build frontend assets (production only)
###############################
FROM oven/bun:1 AS bun-builder

WORKDIR /app

# Copy package files from Laravel installation
COPY --from=laravel-builder /app/package*.json ./

# Install JS dependencies
RUN bun install

# Copy source files needed for build
COPY --from=laravel-builder /app/resources/ resources/
COPY --from=laravel-builder /app/public/ public/
COPY --from=laravel-builder /app/vite.config.js* ./

# Build production assets (Vite will output to public/build)
RUN bun run build

###############################
# Development Stage: For local development with hot reload
###############################
FROM serversideup/php:8.5-fpm-nginx-alpine AS development

# Switch to root to install development tools
USER root

# Install Xdebug and other development extensions
RUN install-php-extensions xdebug pcov

# Switch back to www-data
USER www-data

WORKDIR /var/www/html

# Copy fresh Laravel application with dev dependencies
COPY --chown=www-data:www-data --from=laravel-builder /app ./

# Install dependencies
RUN composer install --no-interaction --prefer-dist

# Configure development-specific PHP settings via ENV
# When using hostPath volume mounts in Kubernetes, OPcache is disabled for hot reload
ENV PHP_OPCACHE_ENABLE=0 \
    PHP_DISPLAY_ERRORS=On \
    PHP_DISPLAY_STARTUP_ERRORS=On \
    PHP_ERROR_REPORTING=E_ALL \
    LOG_OUTPUT_LEVEL=info \
    SHOW_WELCOME_MESSAGE=true

# Expose Nginx, SSL, and Vite dev server ports
# Port 8080: Nginx (HTTP)
# Port 8443: Nginx (HTTPS)
EXPOSE 8080 8443

# Development uses default entrypoint (S6 overlay manages PHP-FPM + Nginx)
# NOTE: When using hostPath volume mounts in Kubernetes:
#   - Your local code changes will be immediately reflected (hot reload)
#   - Run Vite dev server as a sidecar container for frontend HMR
#   - The Laravel app and Bun sidecar share the same hostPath volume mount

###############################
# Production Stage: Optimized runtime image
###############################
FROM serversideup/php:8.5-fpm-nginx-alpine AS production

WORKDIR /var/www/html

# Copy built application from laravel-builder stage
# The serversideup/php image runs as www-data by default
COPY --chown=www-data:www-data --from=laravel-builder /app ./

# Copy built assets from bun-builder
COPY --from=bun-builder /app/public/build ./public/build

# Install dependencies
RUN composer install \
    --no-interaction \
    --no-progress \
    --no-scripts \
    --prefer-dist \
    --optimize-autoloader

# Configure production-specific PHP settings via ENV (can be overridden by Helm)
ENV PHP_OPCACHE_ENABLE=1 \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS=0 \
    PHP_DISPLAY_ERRORS=Off \
    PHP_DISPLAY_STARTUP_ERRORS=Off \
    LOG_OUTPUT_LEVEL=warn \
    SHOW_WELCOME_MESSAGE=false

# The base image already:
# - Exposes ports 8080 (HTTP) and 8443 (HTTPS)
# - Runs as www-data (non-root user, UID 1000, GID 1000)
# - Has health checks configured at $HEALTHCHECK_PATH (default: /healthcheck)
# - Manages PHP-FPM and Nginx via S6 overlay
# - Has proper permissions on /var/www
# - Provides environment-based configuration

# All runtime configuration is done via environment variables
# Set these in your Helm values.yaml and they will be passed to the container
# See: https://github.com/serversideup/docker-php/blob/main/docs/content/docs/8.reference/1.environment-variable-specification.md
