#!/bin/sh
set -e

# Create certs directory
mkdir -p /etc/haproxy/certs

# Decode SSL certificate if provided
if [ -n "$SSL_PEM_BASE64" ]; then
    echo "Decoding SSL certificate from SSL_PEM_BASE64..."
    echo "$SSL_PEM_BASE64" | base64 -d > /etc/haproxy/certs/stream.pem
    chmod 600 /etc/haproxy/certs/stream.pem
else
    echo "WARNING: SSL_PEM_BASE64 environment variable is not set!"
    # Create a dummy self-signed certificate so HAProxy doesn't crash on startup
    echo "Creating a temporary self-signed certificate..."
    openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" \
        -keyout /tmp/temp.key -out /tmp/temp.crt
    cat /tmp/temp.crt /tmp/temp.key > /etc/haproxy/certs/stream.pem
    rm /tmp/temp.key /tmp/temp.crt
fi

# Start Nginx in background
echo "Starting Nginx..."
nginx

# Start HAProxy in foreground
echo "Starting HAProxy..."
exec haproxy -f /usr/local/etc/haproxy/haproxy.cfg
