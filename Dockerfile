FROM ghcr.io/es-na-battlesnake/code-snake:latest
WORKDIR /usr/src/app
# Copy possibly changed files
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports for multiple snake services
EXPOSE 4567 8081 8082 8083 8084 8085

COPY . .
