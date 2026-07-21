FROM alpine:3.19

# Install HAProxy, Nginx, Git, OpenSSL and ca-certificates
RUN apk add --no-cache haproxy nginx git openssl ca-certificates

# Clone the 2048 game static files
RUN rm -rf /usr/share/nginx/html/* && \
    git clone https://github.com/gabrielecirulli/2048.git /usr/share/nginx/html

# Copy configurations
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh

# Make entrypoint executable
RUN chmod +x /entrypoint.sh

# Expose ports
EXPOSE 80
EXPOSE 443
EXPOSE 8404

ENTRYPOINT ["/entrypoint.sh"]
