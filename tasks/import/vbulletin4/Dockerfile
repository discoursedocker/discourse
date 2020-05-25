FROM discoursedocker/discourse:${DISCOURSE_DOCKER_VERSION:-latest}

RUN apt-get update && apt-get install -y --no-install-recommends \
        libmariadb-dev-compat \
        mariadb-server-10.3 \
        optipng

RUN echo "gem 'mysql2', require: false" >> Gemfile \
    && echo "gem 'php_serialize', require: false" >> Gemfile \
    && bundle config unset deployment \
    && bundle install --retry 3 --jobs 4 --verbose --without test development

RUN mkdir -p /tmp/attachments

COPY docker-cmd.sh docker-cmd.sh
RUN chmod +x docker-cmd.sh

CMD ["sh", "docker-cmd.sh"]