# ES NA Battlesnakes ![Deploy](https://github.com/es-na-battlesnake/snakes/actions/workflows/deploy-branch.yml/badge.svg) ![CodeQL](https://github.com/es-na-battlesnake/snakes/actions/workflows/codeql-analysis.yml/badge.svg)

[Battlesnakes](https://play.battlesnake.com/) created by a small team of GitHub Enterprise Support Engineers as a learning and team-building exercise.

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

### Running Simulations

Use the continuous improvement script to run simulations locally:

```bash
# Run 20 simulations (default)
./script/continuous_improve

# Run 50 simulations with custom settings
./script/continuous_improve --runs 50 --mode wrapped

# View help
./script/continuous_improve --help
```

### Continuous Improvement

The repository includes automated tools for continuous snake improvement:

- **Automated Workflow**: Runs simulations every 6 hours via GitHub Actions
- **Local Testing**: `script/continuous_improve` for quick iteration
- **Performance Tracking**: Results stored and tracked via GitHub Issues

📚 **Documentation**:
- [Continuous Improvement Guide](docs/CONTINUOUS_IMPROVEMENT.md)
- [Ruby Snake Improvements](docs/RUBY_SNAKE_IMPROVEMENTS.md)

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
