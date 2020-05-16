#!/bin/bash
function main {

    envsubst '${DISCOURSE_API_HOST},${DISCOURSE_HOSTNAME}' < /etc/nginx/nginx.conf.tpl > /etc/nginx/nginx.conf

    bash /ssl-init.sh

    nginx -g 'daemon off;'

}

set -ex
main $@ | ts