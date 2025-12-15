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

# Install Laravel Horizon for queue management
RUN composer require laravel/horizon --no-interaction --prefer-dist

# Install and configure Horizon
RUN php artisan horizon:install

###############################
# Development Stage: For local development with hot reload
###############################
FROM serversideup/php:8.5-fpm-nginx-alpine AS development

# Switch to root to install development tools
USER root

# Install Xdebug and other development extensions
RUN install-php-extensions xdebug pcov

# Install Bun for hot module replacement (HMR) / Vite dev server
COPY --from=oven/bun:alpine /usr/local/bin/bun /usr/local/bin/bun

# Switch back to www-data
USER www-data

WORKDIR /var/www/html

# Copy fresh Laravel application
COPY --chown=www-data:www-data --from=laravel-builder /app ./

# Configure development-specific PHP settings via ENV
ENV PHP_OPCACHE_ENABLE=0 \
    PHP_DISPLAY_ERRORS=On \
    PHP_DISPLAY_STARTUP_ERRORS=On \
    PHP_ERROR_REPORTING=E_ALL \
    LOG_OUTPUT_LEVEL=info \
    SHOW_WELCOME_MESSAGE=true

# Expose Nginx, SSL, and Vite dev server ports
EXPOSE 8080 8443 5173

# Development uses default entrypoint (S6 overlay manages PHP-FPM + Nginx)
# Vite dev server should be run separately: bun run dev (or via docker-compose)

###############################
# Production Stage: Optimized runtime image
###############################
FROM serversideup/php:8.5-fpm-nginx-alpine AS production

WORKDIR /var/www/html

# Copy fresh Laravel application
COPY --chown=www-data:www-data --from=laravel-builder /app /var/www/html

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
