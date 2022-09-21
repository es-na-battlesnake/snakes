# ES NA Battlesnakes

[Battlesnakes](https://play.battlesnake.com/) created by a [small team](https://play.battlesnake.com/t/es-na/) of GitHub Enterprise Support Engineers as a learning and team-building exercise. 

## Adding snakes

1. Add snake directory within `snakes`
2. Make new program config in `supervisord.conf` choosing a new port. Currently we have snakes in two languages (Ruby and Go)
     - Ruby snakes run on ports 4567+
     - Go snakes run on 8080+

## Running snakes

### Codespaces

1. Run `script/server` to launch all snakes
2. [Make port public](https://docs.github.com/en/codespaces/developing-in-codespaces/forwarding-ports-in-your-codespace#sharing-a-port) as needed to access from outside

### Docker

1. `docker build -t battlesnake .`
2. `docker run -p 4567:4567 -d battlesnake`

## Testing snakes

Beyond language and snake-specific testing, we also run simulated games to get quick feedback on how snakes are performing.

[Testing isntructions here]

## Infrastructure

Development environment:
- [GitHub Codespaces](https://github.com/features/codespaces)
- [GitHub Copilot](https://copilot.github.com/)

Deployment environment:
- [Azure Container Instances](https://github.com/es-na-battlesnake/snakes/blob/main/.github/workflows/docker-image.yml#L31)
- Azure Traffic Manager
- Azure Log Analytics

CI/CD:
- [GitHub Actions](https://github.com/es-na-battlesnake/snakes/tree/main/.github/workflows)
