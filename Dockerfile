FROM ruby:3.1.2

EXPOSE 4567
CMD ["/usr/bin/supervisord"]

RUN apt-get update && apt-get install --no-install-suggests -y supervisor && apt-get install pip -y && apt-get install jq -y
RUN mkdir -p /var/log/supervisor

RUN bundle config --global frozen 1 && bundle config set --local without 'dev'

COPY setup-go.sh setup-go.sh
RUN bash setup-go.sh

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

RUN pip install flask pathfinding

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY . .
