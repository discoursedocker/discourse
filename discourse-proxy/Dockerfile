ARG DISCOURSE_DOCKER_VERSION
FROM discoursedocker/discourse:${DISCOURSE_DOCKER_VERSION:-latest} as discourse
FROM nginx:1.17.10
COPY --from=discourse /home/discourse/discourse/public /usr/share/nginx/html

RUN apt update && apt install -y certbot python-certbot-nginx curl moreutils

RUN mkdir -p /var/nginx/cache
COPY nginx.conf.tpl /etc/nginx/nginx.conf.tpl

RUN mkdir -p /etc/nginx/snippets/includes
COPY maps/301-redirects-global.map /etc/nginx/snippets/includes/301-redirects-global.map

RUN curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "/etc/nginx/snippets/includes/options-ssl-nginx.conf" \
  && curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "/etc/nginx/snippets/includes/ssl-dhparams.pem"

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

COPY scripts/ssl-init.sh /ssl-init.sh
RUN chmod +x /ssl-init.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
