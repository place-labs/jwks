FROM crystallang/crystal:1.0.0-alpine
WORKDIR /app

COPY shard.yml /app
COPY shard.override.yml /app
RUN shards install

COPY spec /app/spec
COPY src /app/src

RUN crystal tool format --check
RUN crystal lib/ameba/bin/ameba.cr

ENTRYPOINT ["crystal", "spec", "--error-on-warnings", "--error-trace", "-v"]