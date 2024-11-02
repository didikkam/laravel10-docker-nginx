#!/bin/bash

# Start PHP-FPM
php-fpm &

# Start Nginx in the foreground
nginx -g "daemon off;"
