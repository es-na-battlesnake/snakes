FROM ruby:3.1.2

EXPOSE 4567
CMD ["/usr/bin/supervisord"]

RUN apt-get update && apt-get install --no-install-suggests -y supervisor=4.2.2-2 && apt-get install pip jq -y
RUN mkdir -p /var/log/supervisor

RUN bundle config --global frozen 1 && bundle config set --local without 'dev'

COPY setup-go.sh setup-go.sh
RUN bash setup-go.sh

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

RUN pip install --no-cache-dir flask==2.2.2 pathfinding==1.0.1

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY . .
