FROM ruby:2.6-alpine3.13

ENV BIND=0.0.0.0 \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_ENV=production \
    NODE_ENV=production \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/mastodon/bin

# 70 is the standard uid/gid for "postgres" in Alpine
# https://git.alpinelinux.org/aports/tree/main/postgresql/postgresql.pre-install?h=3.12-stable
RUN set -eux; \
    addgroup -g 70 -S postgres; \
    adduser -u 70 -S -D -G postgres -H -h /var/lib/postgresql -s /bin/sh postgres; \
    mkdir -p /var/lib/postgresql; \
    chown -R postgres:postgres /var/lib/postgresql

# Install dependencies
RUN apk add --no-cache \
    ca-certificates \
    curl \
    ffmpeg \
    file \
    git \
    icu-libs \
    imagemagick \
    libidn \
    libxml2 \
    libxslt \
    libpq \
    libstdc++ \
    openssl \
    protobuf \
    su-exec \
    tzdata \
    yaml \
    readline \
    gcompat\
    bash \
    nginx \
    postgresql \
    redis \
    privoxy \
    sudo \
    nodejs \
    gnu-libiconv

ADD ./mastodon /mastodon
WORKDIR /mastodon

RUN apk add --no-cache -t build-dependencies \
    build-base \
    icu-dev \
    libidn-dev \
    libtool \
    libxml2-dev \
    libxslt-dev \
    postgresql-dev \
    protobuf-dev \
    python3 \
    tar \
    ncurses \
    coreutils \
    python2 \
    grep \
    util-linux \
    binutils \
    findutils \
    npm \
    gnu-libiconv-dev \
    && npm i -g yarn \
    && cd /mastodon \
    && cp ./priv-config /etc/privoxy/config \
    && bundle config build.nokogiri --use-system-libraries \
    && bundle install -j$(getconf _NPROCESSORS_ONLN) --deployment --clean --no-cache --without 'test development' \
    && yarn install --prod --pure-lockfile --ignore-engines --network-timeout 100000 \
    && OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder bundle exec rails assets:precompile \
    && npm -g --force cache clean && yarn cache clean \
    && npm uninstall -g yarn \
    && apk del build-dependencies \
    && rm -rf /var/cache/apk/* /tmp/src

ARG PLATFORM
RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${PLATFORM} && chmod +x /usr/local/bin/yq

RUN mkdir -p /run/nginx \
    && mkdir -p /run/postgresql \
    && chmod 777 /run \
    && chown postgres:postgres /run/postgresql
ADD ./nginx.conf /etc/nginx/conf.d/default.conf
ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh
ADD ./reset_first_user.sh /usr/local/bin/reset_first_user.sh
RUN chmod a+x /usr/local/bin/reset_first_user.sh
ADD ./check-federation.sh /usr/local/bin/check-federation.sh
RUN chmod a+x /usr/local/bin/check-federation.sh

EXPOSE 80 3000 4000
