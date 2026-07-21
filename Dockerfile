FROM alpine:3.19

RUN apk add --no-cache haproxy nginx git openssl ca-certificates

RUN rm -rf /usr/share/nginx/html/* && \
    git clone https://github.com/gabrielecirulli/2048.git /usr/share/nginx/html

COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh

# Inject SSL during build if provided
ARG SSL_PEM_BASE64
RUN mkdir -p /etc/haproxy/certs && \
    if [ -n "$SSL_PEM_BASE64" ]; then \
        echo "$SSL_PEM_BASE64" | base64 -d > /etc/haproxy/certs/stream.pem && \
        chmod 600 /etc/haproxy/certs/stream.pem ; \
    fi

RUN chmod +x /entrypoint.sh

EXPOSE 80
EXPOSE 443
EXPOSE 8404

ENTRYPOINT ["/entrypoint.sh"]
