user www-data;

events {
  worker_connections 768;
}

http {
  include mime.types;

  # Including migration redirections
  include /etc/nginx/snippets/includes/301-redirects-global.map;

  # Additional MIME types that you'd like nginx to handle go in here
  types {
      text/csv csv;
  }

  upstream discourse {
    server ${DISCOURSE_API_HOST};
  }

  # proxy_cache_path /var/nginx/cache keys_zone=one:10m max_size=200m;

  # attempt to preserve the proto, must be in http context
  map $http_x_forwarded_proto $thescheme {
    default $scheme;
    https https;
  }

  log_format log_discourse '[$time_local] "$http_host" $remote_addr "$request" "$http_user_agent" "$sent_http_x_discourse_route" $status $bytes_sent "$http_referer" $upstream_response_time $request_time "$sent_http_x_discourse_username"';

  server {

      listen 80;
      server_name ${DISCOURSE_HOSTNAME}; 

      location /.well-known/acme-challenge/ {
          root /var/www/certbot;
      }

      location / {
          return 301 https://$host$request_uri;
      }

  }

  server {

    listen 443 ssl;
    server_name ${DISCOURSE_HOSTNAME};

    ssl_certificate /etc/letsencrypt/live/${DISCOURSE_HOSTNAME}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DISCOURSE_HOSTNAME}/privkey.pem;

    include /etc/nginx/snippets/includes/options-ssl-nginx.conf;
    ssl_dhparam /etc/nginx/snippets/includes/ssl-dhparams.pem;

    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_comp_level 5;
    gzip_types application/json text/css application/x-javascript application/javascript image/svg+xml;

    server_tokens off;

    sendfile on;

    keepalive_timeout 65;

    # maximum file upload size (keep up to date when changing the corresponding site setting)
    client_max_body_size 10m;

    # path to discourse's public directory
    set $public /usr/share/nginx/html;

    # without weak etags we get zero benefit from etags on dynamically compressed content
    # further more etags are based on the file in nginx not sha of data
    # use dates, it solves the problem fine even cross server
    etag off;

    # processing rewrite map file
    if ($new_uri != "") {
      rewrite ^(.*)$ $new_uri permanent;
    }

    # prevent direct download of backups
    location ^~ /backups/ {
      internal;
    }

    # bypass rails stack with a cheap 204 for favicon.ico requests
    location /favicon.ico {
      return 204;
      access_log off;
      log_not_found off;
    }

    location / {
      set_real_ip_from  10.0.0.0/8;
      set_real_ip_from  172.16.0.0/12;
      set_real_ip_from  192.168.0.0/16;
      real_ip_header X-Forwarded-For;
      root $public;
      add_header ETag "";

      # auth_basic on;
      # auth_basic_user_file /etc/nginx/htpasswd;

      location ~* assets/.*\.(eot|ttf|woff|woff2|ico)$ {
        expires 1y;
        add_header Cache-Control public,immutable;
        add_header Access-Control-Allow-Origin *;
      }

      location = /srv/status {
        access_log off;
        log_not_found off;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $thescheme;
        proxy_pass http://discourse;
        break;
      }

      location ~ ^/assets/(?<asset_path>.+)$ {
        expires 1y;
        # asset pipeline enables this
        # brotli_static on;
        gzip_static on;
        add_header Cache-Control public,immutable;
        # HOOK in asset location (used for extensibility)
        # TODO I don't think this break is needed, it just breaks out of rewrite
        break;
      }

      location ~ ^/plugins/ {
        expires 1y;
        add_header Cache-Control public,immutable;
      }

      # cache emojis
      location ~ /images/emoji/ {
        expires 1y;
        add_header Cache-Control public,immutable;
      }

      location ~ ^/uploads/ {

        # NOTE: it is really annoying that we can't just define headers
        # at the top level and inherit.
        #
        # proxy_set_header DOES NOT inherit, by design, we must repeat it,
        # otherwise headers are not set correctly
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $thescheme;
        proxy_set_header X-Sendfile-Type X-Accel-Redirect;
        proxy_set_header X-Accel-Mapping $public/=/downloads/;
        expires 1y;
        add_header Cache-Control public,immutable;

        ## optional upload anti-hotlinking rules
        #valid_referers none blocked mysite.com *.mysite.com;
        #if ($invalid_referer) { return 403; }

        # custom CSS
        location ~ /stylesheet-cache/ {
            try_files $uri =404;
        }
        # this allows us to bypass rails
        location ~* \.(gif|png|jpg|jpeg|bmp|tif|tiff|svg|ico|webp)$ {
            try_files $uri =404;
        }
        # thumbnails & optimized images
        location ~ /_?optimized/ {
            try_files $uri =404;
        }

        proxy_pass http://discourse;
        break;
      }

      location ~ ^/admin/backups/ {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $thescheme;
        proxy_set_header X-Sendfile-Type X-Accel-Redirect;
        proxy_set_header X-Accel-Mapping $public/=/downloads/;
        proxy_pass http://discourse;
        break;
      }

      # This big block is needed so we can selectively enable
      # acceleration for backups and avatars
      # see note about repetition above
      location ~ ^/(letter_avatar/|user_avatar|highlight-js|stylesheets|favicon/proxied) {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $thescheme;

        # if Set-Cookie is in the response nothing gets cached
        # this is double bad cause we are not passing last modified in
        proxy_ignore_headers "Set-Cookie";
        proxy_hide_header "Set-Cookie";

        # note x-accel-redirect can not be used with proxy_cache
        #proxy_cache one;
        #proxy_cache_valid 200 301 302 7d;
        #proxy_cache_valid any 1m;
        proxy_pass http://discourse;
        break;
      }

      location /letter_avatar_proxy/ {
        # Don't send any client headers to the avatars service
        proxy_method GET;
        proxy_pass_request_headers off;
        proxy_pass_request_body off;

        # Don't let cookies interrupt caching, and don't pass them to the
        # client
        proxy_ignore_headers "Set-Cookie";
        proxy_hide_header "Set-Cookie";

        #proxy_cache one;
        #proxy_cache_key $uri;
        #proxy_cache_valid 200 7d;
        #proxy_cache_valid 404 1m;
        proxy_set_header Connection "";

        proxy_pass https://avatars.discourse.org/;
        break;
      }

      # we need buffering off for message bus
      location /message-bus/ {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $thescheme;
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_pass http://discourse;
        break;
      }

      # this means every file in public is tried first
      try_files $uri @discourse;
    }

    location /downloads/ {
      internal;
      alias $public/;
    }

    location @discourse {
      add_header Referrer-Policy 'no-referrer-when-downgrade';
      proxy_set_header Host $http_host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $thescheme;
      proxy_pass http://discourse;
    }

  }
}
