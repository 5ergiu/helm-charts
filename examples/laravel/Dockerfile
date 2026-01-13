# Laravel Dockerfile using ServersideUp PHP images
# https://serversideup.net/open-source/docker-php/
# https://github.com/serversideup/docker-php
#
# This is a DEMO Dockerfile that creates a fresh Laravel application.
# For your own projects, replace the laravel-builder stage with your app code.
#
# This Dockerfile supports both development and production builds with web (FPM) and CLI variants:
# - Build for CLI (workers): docker build --target cli -t app:cli .
# - Build for development web (FPM): docker build --target dev -t app:dev .
# - Build for production web (FPM): docker build --target production -t app:production .

###############################
# Laravel App Builder: Create fresh Laravel application
###############################
FROM composer:2.9 AS laravel-builder

WORKDIR /app

# Create a fresh Laravel application
# This installs Laravel 12.x (latest version)
RUN composer create-project laravel/laravel . --no-interaction --prefer-dist

###############################
# CLI Stage: Optimized PHP-CLI image for workers
###############################
FROM serversideup/php:8.5-cli-alpine AS cli

# The base image provides:
# - PHP-CLI for running console commands
# - Environment-based configuration
# - Proper permissions on /var/www
#
# All runtime configuration is done via environment variables
# See: https://github.com/serversideup/docker-php/blob/main/docs/content/docs/8.reference/1.environment-variable-specification.md

# Copy custom entrypoint scripts
COPY --chmod=755 ./entrypoint.d/ /etc/entrypoint.d/

WORKDIR /var/www/html

# Copy fresh Laravel application
COPY --chown=www-data:www-data --from=laravel-builder /app ./

# Install Laravel Horizon for queue management
RUN composer require laravel/horizon --no-interaction --prefer-dist

# Install and configure Horizon
RUN php artisan horizon:install

###############################
# Dependencies Builder Stage: For development and production
###############################
FROM serversideup/php:8.5-fpm-alpine AS deps-builder

# The base image provides:
# - PHP-FPM on port 9000
# - Has health checks configured at $HEALTHCHECK_PATH (default: /healthcheck)
# - Environment-based configuration
# - Proper permissions on /var/www
#
# All runtime configuration is done via environment variables
# See: https://github.com/serversideup/docker-php/blob/main/docs/content/docs/8.reference/1.environment-variable-specification.md

# Copy custom entrypoint scripts
COPY --chmod=755 ./entrypoint.d/ /etc/entrypoint.d/

WORKDIR /var/www/html

# Copy Laravel application
COPY --chown=www-data:www-data --from=laravel-builder /app ./

###############################
# Development Web Stage: For local development with PHP-FPM
###############################
FROM deps-builder AS dev

# Switch to root to install extensions
USER root

# Install extensions
RUN install-php-extensions xdebug pcov

# Switch back to www-data
USER www-data

WORKDIR /var/www/html

# Copy Laravel application
COPY --chown=www-data:www-data --from=deps-builder /var/www/html ./

###############################
# Production Web Stage: Optimized runtime image with PHP-FPM
###############################
FROM deps-builder AS production

WORKDIR /var/www/html

# Copy Laravel application
COPY --chown=www-data:www-data --from=deps-builder /var/www/html ./
