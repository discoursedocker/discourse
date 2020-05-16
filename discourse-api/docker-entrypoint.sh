#!/bin/bash

function main {
    sh ${DISCOURSE_OPT_PATH}/scripts/copy-env.sh
    if [ "$1" == "sidekiq" ]; then
        bundle exec sidekiq -q critical -q default -q low -v
    elif [ "$1" == "server" ]; then
        
        # Installing Plugins
        cd ${DISCOURSE_WWW_PATH}/plugins
        discourse_plugins_list=($(echo $DISCOURSE_PLUGINS | tr "," "\n"))
        for plugin in "${discourse_plugins_list[@]}"; do
            git clone --single-branch --depth 1 $plugin
        done
        cd -

        # Starting DB migrations
        bundle exec rake db:migrate

        # If persisted assets path is empty...
        if [ -z "$(ls -A ${DISCOURSE_WWW_PATH}/public/assets)" ]; then
        echo "Assets path is empty. 'assets:precomplie' required"
        bundle exec rake assets:precompile
        else
            echo "Assets path has content. 'assets:precomplie' skipped"
        fi

        # Running server
        bundle exec rails server -b 0.0.0.0
    else
        exec "$@"
    fi 
}

set -ex
main $@ | ts