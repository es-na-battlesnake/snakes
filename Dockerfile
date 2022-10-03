FROM ghcr.io/es-na-battlesnake/code-snake:latest
CMD ["/usr/bin/supervisord"]
WORKDIR /usr/src/app
COPY . .
