# ES NA Battlesnakes ![Deploy](https://github.com/es-na-battlesnake/snakes/actions/workflows/deploy-branch.yml/badge.svg) ![CodeQL](https://github.com/es-na-battlesnake/snakes/actions/workflows/codeql-analysis.yml/badge.svg)

[Battlesnakes](https://play.battlesnake.com/) created by a small team of GitHub Enterprise Support Engineers as a learning and team-building exercise.

## Adding snakes

1. Add snake directory within `snakes`
2. Make new program config in `supervisord.conf` choosing a new port. Currently we have snakes in two languages (Ruby and Go)
     - Ruby snakes run on ports 4567+
     - Go snakes run on 8080+
3. For Python-based snakes, add the snake directory within `snakes/python`
     - Python snakes run on ports 8082+

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

## Deployment 🚀

To deploy a change to this repository, follow the general process laid out below:

1. Create a new branch and pull request with your changes
1. Observe CI to ensure it is passing
1. Get an approval from from the required codeowners
1. Run `.deploy` on your pull request to deploy your changes to production
1. If you branch deployment completes successfully, merge your pull request!

To roll back a deployment to the last `main` version, run `.deploy main`.

## AI-based Python Snake

### Features

* AI-based navigation logic using A* and Dijkstra pathfinding algorithms
* Handles HTTP requests for snake actions
* Includes tests for AI-based navigation logic and pathfinding algorithms

### Adding the AI-based Python Snake

1. Add the AI-based Python snake directory within `snakes/python/ai-snake`
2. Implement AI-based navigation logic in `snakes/python/ai-snake/src/logic.py`
3. Update `snakes/python/ai-snake/src/main.py` to handle HTTP requests for the new AI-based snake
4. Add tests for the new AI-based snake in `snakes/python/ai-snake/src/tests.py`
5. Update `README.md` with instructions for adding and running the new AI-based snake

### Running the AI-based Python Snake

1. Run `script/server` to launch all snakes
2. [Make port public](https://docs.github.com/en/codespaces/developing-in-codespaces/forwarding-ports-in-your-codespace#sharing-a-port) as needed to access from outside
