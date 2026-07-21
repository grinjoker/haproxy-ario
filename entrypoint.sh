#!/bin/sh
set -e

# Create certs directory
mkdir -p /etc/haproxy/certs

# 1. اگر اس‌اس‌ال اصلی در زمان ساخت (GitHub Secrets) درون ایمیج قرار گرفته است
if [ -f "/etc/haproxy/certs/stream.pem" ]; then
    echo "SSL certificate found inside image (Pre-built via GitHub Secrets)."
    chmod 600 /etc/haproxy/certs/stream.pem

# 2. اگر از طریق متغیر محیطی ارسال شده بود
elif [ -n "$SSL_PEM_BASE64" ]; then
    echo "Decoding SSL certificate from SSL_PEM_BASE64..."
    echo "$SSL_PEM_BASE64" | base64 -d > /etc/haproxy/certs/stream.pem
    chmod 600 /etc/haproxy/certs/stream.pem

# 3. اگر هیچ‌کدام نبود، گواهی موقت بگذار
else
    echo "WARNING: SSL certificate not found! Creating a temporary self-signed certificate..."
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
