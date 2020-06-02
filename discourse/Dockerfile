FROM ruby:2.6.5

ENV DISCOURSE_VERSION=v2.4.5 \
    DISCOURSE_OPT_PATH=/opt/discourse \
    DISCOURSE_WWW_PATH=/home/discourse/discourse \
    PG_MAJOR=10 \
    NODE_MAJOR=10 \
    RAILS_ENV=production \
    DEBIAN_VERSION=buster \
    BUILD_DEPS="\
      autoconf \
      advancecomp \
      libbz2-dev \
      libfreetype6-dev \
      libjpeg-dev \
      libjpeg-turbo-progs \
      libtiff-dev \
      pkg-config"

RUN curl http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add - \
 && echo "deb http://apt.postgresql.org/pub/repos/apt/ ${DEBIAN_VERSION}-pgdg main" | \
        tee /etc/apt/sources.list.d/postgres.list \
 && apt-get update && apt-get install -y --no-install-recommends \
      ${BUILD_DEPS} \
      brotli \
      ghostscript \
      gsfonts \
      jpegoptim \
      libxml2 \
      optipng \
      jhead \
      postgresql-client-${PG_MAJOR} \
      postgresql-contrib-${PG_MAJOR} libpq-dev libreadline-dev \
      pngquant \
      gifsicle \
      moreutils

RUN curl --silent --location https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - \
 && apt-get update && apt-get install -y --no-install-recommends \
      nodejs \
 && npm install svgo uglify-js -g

RUN mkdir -p ${DISCOURSE_WWW_PATH}

WORKDIR ${DISCOURSE_WWW_PATH}

RUN git clone --branch ${DISCOURSE_VERSION} --single-branch --depth 1 https://github.com/discourse/discourse.git ${DISCOURSE_WWW_PATH}

RUN gem install bundler --force \
 && bundle install --deployment --retry 3 --jobs 4 --verbose --without test development

RUN mkdir -p ${DISCOURSE_WWW_PATH}/plugins

RUN sed -i 's/daemonize true/daemonize false/g' ./config/puma.rb

COPY scripts ${DISCOURSE_OPT_PATH}/scripts
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["server"]
