#!/bin/sh

# ============================================================================
# Container Information Display
# ============================================================================
# Displays container runtime information including PHP version, OPcache status,
# memory limits, and other useful debugging information.
#
# This script is executed by the Docker entrypoint before starting PHP-FPM.
# ============================================================================

# ============================================================================
# GET RUNTIME INFORMATION
# ============================================================================

# PHP OPcache status
PHP_OPCACHE_STATUS=$(php -r 'echo ini_get("opcache.enable");')

if [ "$PHP_OPCACHE_STATUS" = "1" ]; then
    PHP_OPCACHE_MESSAGE="✅ Enabled"
else
    PHP_OPCACHE_MESSAGE="❌ Disabled"
fi

# Memory and upload limits
MEMORY_LIMIT=$(php -r 'echo ini_get("memory_limit");')
UPLOAD_LIMIT=$(php -r 'echo ini_get("upload_max_filesize");')

# ============================================================================
# DISPLAY CONTAINER INFORMATION
# ============================================================================

echo '
--------------------------------------------------------------------
 ____                             ____  _     _        _   _
/ ___|  ___ _ ____   _____ _ __  / ___|(_) __| | ___  | | | |_ __
\___ \ / _ \  __\ \ / / _ \  __| \___ \| |/ _` |/ _ \ | | | |  _ \
 ___) |  __/ |   \ V /  __/ |     ___) | | (_| |  __/ | |_| | |_) |
|____/ \___|_|    \_/ \___|_|    |____/|_|\__,_|\___|  \___/| .__/
                                                            |_|

Brought to you by serversideup.net
--------------------------------------------------------------------

📚 Documentation: https://serversideup.net/php/docs
💬 Get Help: https://serversideup.net/php/community
🙌 Sponsor: https://serversideup.net/sponsor

-------------------------------------
 ℹ️  Container Information
-------------------------------------
📦 Versions
• Image:         '"$(cat /etc/serversideup-php-version 2>/dev/null || echo 'Unknown')"'
• PHP:           '"$(php -r 'echo phpversion();')"'
• OS:            '"$(. /etc/os-release 2>/dev/null && echo "${PRETTY_NAME}" || echo 'Unknown')"'

👤 Container User
• User:          '"$(whoami)"'
• UID:           '"$(id -u)"'
• GID:           '"$(id -g)"'

⚡ Performance
• OPcache:       '"$PHP_OPCACHE_MESSAGE"'
• Memory Limit:  '"$MEMORY_LIMIT"'
• Upload Limit:  '"$UPLOAD_LIMIT"'

🔄 Runtime
• Docker CMD:    '"${DOCKER_CMD:-'Not set'}"'
'

# ============================================================================
# RECOMMENDATIONS
# ============================================================================

if [ "$PHP_OPCACHE_STATUS" = "0" ]; then
    echo "👉 [NOTICE]: Improve PHP performance by setting PHP_OPCACHE_ENABLE=1 (recommended for production)."
fi

# Additional recommendations for production
if [ "$PHP_DISPLAY_ERRORS" = "On" ]; then
    echo "⚠️  [WARNING]: PHP_DISPLAY_ERRORS is enabled. Disable in production for security."
fi
