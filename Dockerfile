FROM ghcr.io/cyber-dojo/sinatra-base:c58736f@sha256:35f8f0ad8bf53b955398392891ca64949787d414edb53789be8a628d76f6d217
LABEL maintainer=jon@jaggersoft.com

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

WORKDIR /app
COPY source .

# Install the js/scss compilation gems declared in the Gemfile.
# libstdc++, libgcc and gmp are persistent runtime libs that mini_racer's V8
# extension links against (see `ldd mini_racer_extension.so`); they must outlive
# the throwaway build-base toolchain that compiles the native extensions.
# The base image sets force_ruby_platform=true; override it to false so
# mini_racer pulls the precompiled libv8-node musl binary instead of building
# V8 from source.
RUN apk add --no-cache libstdc++ libgcc gmp \
  && apk add --update --upgrade --virtual build-dependencies build-base \
  && bundle config set force_ruby_platform false \
  && bundle install \
  && gem clean \
  && apk del build-dependencies build-base \
  && rm -vrf /usr/local/bundle/cache/* \
             /var/cache/apk/* \
             /tmp/* \
             /var/tmp/*

USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD /app/config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/app/config/up.sh" ]
