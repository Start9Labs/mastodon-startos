# FROM arm32v7/postgres:12-alpine
FROM ruby:2.6-alpine3.13

# 70 is the standard uid/gid for "postgres" in Alpine
# https://git.alpinelinux.org/aports/tree/main/postgresql/postgresql.pre-install?h=3.12-stable
RUN set -eux; \
    addgroup -g 70 -S postgres; \
    adduser -u 70 -S -D -G postgres -H -h /var/lib/postgresql -s /bin/sh postgres; \
    mkdir -p /var/lib/postgresql; \
    chown -R postgres:postgres /var/lib/postgresql

RUN apk add --no-cache postgresql sudo && \
    rm -f /var/cache/apk/*

RUN mkdir -p /run/postgresql \
    && chmod 777 /run \
    && chown postgres:postgres /run/postgresql

ADD ./pg-migrate/docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
