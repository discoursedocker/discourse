#!/bin/bash
set -ex
sh ${DISCOURSE_OPT_PATH}/scripts/copy-env.sh
echo $@
if [ $1 == "sidekiq" ]; then
    bundle exec sidekiq -q critical -q default -q low -v
elif [ $1 == "server" ]; then
    bundle exec rake db:migrate
    #If persisted assets path is empty...
    if [ -z "$(ls -A ${DISCOURSE_WWW_PATH}/public/assets)" ]; then
    echo "Assets path is empty. 'assets:precomplie' required"
    bundle exec rake assets:precompile
    else
        echo "Assets path has content. 'assets:precomplie' skipped"
    fi
    bundle exec rails server -b 0.0.0.0
else
    exec "$@"
fi