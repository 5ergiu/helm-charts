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
# Dependencies Builder: Install dependencies
###############################
FROM serversideup/php:8.5-fpm-nginx-alpine AS deps-builder

# The base image provides:
# - PHP-FPM on port 9000
# - Has health checks configured at $HEALTHCHECK_PATH (default: /healthcheck)
# - www-data user (UID 1000, GID 1000)
# - Environment-based configuration
# - Proper permissions on /var/www
#
# All runtime configuration is done via environment variables
# See: https://github.com/serversideup/docker-php/blob/main/docs/content/docs/8.reference/1.environment-variable-specification.md

# Switch to root to install extensions
USER root

# Install required PHP extensions
RUN install-php-extensions pcntl

# Copy custom entrypoint scripts
COPY --chmod=755 ./entrypoint.d/ /etc/entrypoint.d/

# Copy custom nginx configuration
COPY --chmod=644 ./nginx/nginx.conf /etc/nginx/nginx.conf

# Switch back to www-data
USER www-data

WORKDIR /app

# Copy fresh Laravel application
COPY --chown=www-data:www-data --from=laravel-builder /app ./

# Install Laravel Horizon for queue management
RUN composer require laravel/horizon --no-interaction --prefer-dist

# Install and configure Horizon
RUN php artisan horizon:install

###############################
# Development Stage: For local development with hot reload
###############################
FROM deps-builder AS development

# Switch to root to install extensions
USER root

# Install extensions
RUN install-php-extensions xdebug pcov

# Switch back to www-data
USER www-data

WORKDIR /var/www/html

# Copy fresh Laravel application
COPY --chown=www-data:www-data --from=deps-builder /app ./

# Configure development-specific PHP settings via ENV
ENV DISABLE_DEFAULT_CONFIG=true \
    PHP_OPCACHE_ENABLE=0 \
    PHP_DISPLAY_ERRORS=On \
    PHP_DISPLAY_STARTUP_ERRORS=On \
    PHP_ERROR_REPORTING=E_ALL \
    LOG_OUTPUT_LEVEL=info \
    SHOW_WELCOME_MESSAGE=true

###############################
# Production Stage: Optimized runtime image
###############################
FROM deps-builder AS production

WORKDIR /var/www/html

# Copy fresh Laravel application
COPY --chown=www-data:www-data --from=deps-builder /app /var/www/html

# Configure production-specific PHP settings via ENV (can be overridden by Helm)
ENV DISABLE_DEFAULT_CONFIG=true \
    PHP_OPCACHE_ENABLE=1 \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS=0 \
    PHP_DISPLAY_ERRORS=Off \
    PHP_DISPLAY_STARTUP_ERRORS=Off \
    LOG_OUTPUT_LEVEL=warn \
    SHOW_WELCOME_MESSAGE=false
