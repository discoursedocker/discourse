#!/bin/bash

ssl_domain_path="/etc/letsencrypt/live/${DISCOURSE_HOSTNAME}"

if [ ! -f $ssl_domain_path/privkey.pem ] || [ ! -f $ssl_domain_path/fullchain.pem ]; then
  echo "Letsencrypt certificates missing, starting generation..."
  domains=("${DISCOURSE_HOSTNAME}")
  rsa_key_size=4096
  data_path="./data/certbot"
  email="${LETSENCRYPT_EMAIL_ISSUER}" # Adding a valid address is strongly recommended
  staging=${LETSENCRYPT_STAGING_MODE} # Set to true if you're testing your setup to avoid hitting request limits

  echo "### Creating dummy certificate for $domains ..."
  mkdir -p "$ssl_domain_path"
  openssl req -x509 -nodes -newkey rsa:2048 -days 1\
      -keyout "$ssl_domain_path/privkey.pem" \
      -out "$ssl_domain_path/fullchain.pem" \
      -subj "/CN=${DISCOURSE_HOSTNAME}"

  # If LETSENCRYPT_ENABLED is false this step will be skipped and self-certificate will be used
  if [ "$LETSENCRYPT_ENABLED" == "true" ]; then
      echo "Letsencrypt enabled, requesting SSL certificates..."

      echo "### Starting nginx in background ..."
      nginx

      echo "### Deleting dummy certificate for $domains ..."
        rm -Rf /etc/letsencrypt/live/$domains && \
        rm -Rf /etc/letsencrypt/archive/$domains && \
        rm -Rf /etc/letsencrypt/renewal/$domains.conf

      echo "### Requesting Let's Encrypt certificate for $domains ..."
      #Join $domains to -d args
      domain_args=""
      for domain in "${domains[@]}"; do
        domain_args="$domain_args -d $domain"
      done

      # Select appropriate email arg
      case "$email" in
        "") email_arg="--register-unsafely-without-email" ;;
        *) email_arg="--email $email" ;;
      esac

      # Enable staging mode if needed
      if [ $staging != "false" ]; then staging_arg="--staging"; fi

      certbot certonly --webroot -w /var/www/certbot $staging_arg $email_arg $domain_args --rsa-key-size $rsa_key_size --agree-tos --force-renewal

      echo "### Stopping nginx in background ..."
      nginx -s stop
      sleep 5

  else
    echo "Letsencrypt disabled, skipping SSL certificates requests..."
  fi

else
    echo "Letsencrypt certificates exists, skipping generation..."
fi