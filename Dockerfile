FROM ghcr.io/es-na-battlesnake/code-snake:latest
WORKDIR /usr/src/app

# Update certificates and configure bundle for SSL issues
RUN apt-get update && apt-get install -y ca-certificates && update-ca-certificates
RUN bundle config set --global silence_root_warning 1
RUN bundle config set --global disable_platform_warnings true

# Copy possibly changed files
COPY Gemfile Gemfile.lock ./
RUN bundle config unset frozen && \
    bundle config set --global ssl_verify_mode 0 && \
    bundle install --retry 3
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports for multiple snake services
EXPOSE 4567 8081 8082 8083 8084 8085

COPY . .
