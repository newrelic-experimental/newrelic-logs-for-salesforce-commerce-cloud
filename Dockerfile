FROM node:current-alpine
USER root

RUN apk add --no-cache --update git \
  && git clone https://github.com/newrelic-forks/cctail.git cctail

WORKDIR cctail
RUN npm install

FROM fluent/fluentd:edge
USER root

RUN apk add --no-cache --update --virtual .build-deps \
  sudo build-base ruby-dev \
  && apk add --update nodejs supervisor \
  && sudo gem install fluent-plugin-newrelic fluent-plugin-grok-parser \
  && sudo gem sources --clear-all \
  && apk del .build-deps \
  && rm -rf /home/fluent/.gem/ruby/2.5.0/cache/*.gem

COPY entrypoint.sh /bin/
COPY fluent.conf /fluentd/etc/
COPY supervisord.conf /etc/supervisord.conf
COPY --from=0 cctail cctail

# Mapped at runtime (for security purposes)
# COPY log.conf.json .
