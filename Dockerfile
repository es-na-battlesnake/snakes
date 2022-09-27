FROM ghcr.io/es-na-battlesnake/code-snake:latest
EXPOSE 4567
CMD ["/usr/bin/supervisord"]

RUN apt-get update && apt-get install --no-install-suggests -y supervisor=4.2.2-2 && apt-get install --no-install-recommends python3-pip=20.3.4-4+deb11u1 jq=1.6-2.1 -y && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/log/supervisor

RUN bundle config --global frozen 1 && bundle config set --local without 'dev'

COPY setup-go.sh setup-go.sh
RUN bash setup-go.sh

WORKDIR /usr/src/app
