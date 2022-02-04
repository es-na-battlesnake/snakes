FROM golang:1.17

RUN go install github.com/BattlesnakeOfficial/rules/cli/battlesnake@latest

# battlesnake play -W 11 -H 11 --name ruby-danger-noodle --url http://code-snek:4567/ --name code-snake --url http://code-snek:4568/  --name bevns --url http://code-snek:4569/ --name wilsonwong1990 --url http://code-snek:4570/ -g royale -v
CMD ["battlesnake", "play", "-W", "11", "-H", "11", "--name", "ruby-danger-noodle", "--url", "http://code-snek:4567/", "--name", "code-snake", "--url", "http://code-snek:4568/", "--name", "bevns", "--url", "http://code-snek:4569/", "--name", "wilsonwong1990", "--url", "http://code-snek:4570/", "-g", "royale", "-v"]