FROM nginx:1.27-alpine

ARG AUTH_MODE=vuln

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html
COPY htpasswd-vuln /etc/nginx/htpasswd-vuln
COPY htpasswd-secured /etc/nginx/htpasswd-secured

RUN if [ "$AUTH_MODE" = "secured" ]; then \
      cp /etc/nginx/htpasswd-secured /etc/nginx/.htpasswd; \
    else \
      cp /etc/nginx/htpasswd-vuln /etc/nginx/.htpasswd; \
    fi \
    && chmod 0644 /etc/nginx/.htpasswd

EXPOSE 80
