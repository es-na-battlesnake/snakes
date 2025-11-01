# GitHub Agentic Workflows for Battlesnake Continuous Improvement

This directory contains agentic workflow definitions that enable autonomous improvement of the Ruby Battlesnake through natural language task descriptions.

## Overview

GitHub Agentic Workflows (gh-aw) allows you to define complex, multi-step workflows in natural language. An AI agent interprets these workflows, executes the tasks, and makes autonomous decisions based on results.

## Workflow Files

### 1. `improve-ruby-snake.yml`
**Purpose**: Continuous automated improvement cycle

**What it does**:
- Runs baseline simulations to measure current performance
- Analyzes results to identify improvement opportunities
- Proposes specific code modifications
- Applies changes to the Ruby snake
- Validates improvements through testing and simulation
- Iterates until target win rate is achieved or max iterations reached

**Triggers**:
- Scheduled: Every 6 hours
- Manual: Via workflow_dispatch with custom parameters

**Key Features**:
- Natural language task definitions
- Autonomous code modification
- Feedback-driven iteration
- Performance tracking
- Automatic rollback if changes don't improve win rate

### 2. `debug-failures.yml`
**Purpose**: Automated bug fixing from simulation failures

**What it does**:
- Extracts failure details from GitHub issues
- Reproduces bugs locally with test cases
- Analyzes root cause of failures
- Implements fixes with proper error handling
- Verifies fixes through testing and simulation
- Reports back on issues automatically

**Triggers**:
- When issues are labeled with specific tags
- Manual: Via workflow_dispatch with issue number

**Key Features**:
- Automated bug reproduction
- Root cause analysis
- Defensive programming patterns
- Comprehensive verification
- Issue tracking integration

### 3. `experiment-strategies.yml`
**Purpose**: A/B testing of different strategic approaches

**What it does**:
- Defines multiple strategy variants (conservative, aggressive, adaptive, etc.)
- Runs controlled experiments with consistent conditions
- Analyzes results statistically
- Identifies best practices from top performers
- Implements winning strategies in production code

**Triggers**:
- Manual: Via workflow_dispatch with strategy focus area

**Key Features**:
- Scientific approach to strategy optimization
- Reproducible experiments
- Statistical significance testing
- Best-of-breed synthesis
- Evidence-based improvements

## How to Use

### Prerequisites

1. **Install GitHub CLI** (if not already installed):
   ```bash
   brew install gh  # macOS
   # or
   sudo apt install gh  # Linux
   ```

2. **Install gh-aw extension**:
   ```bash
   gh extension install githubnext/gh-aw
   ```

3. **Authenticate**:
   ```bash
   gh auth login
   ```

### Running Workflows

**Enable agentic workflows for this repository**:
```bash
gh aw init
```

**List available workflows**:
```bash
gh aw list
```

**Run the improvement workflow**:
```bash
# With defaults (50% target win rate, 5 max iterations)
gh aw run improve-ruby-snake

# With custom parameters
gh aw run improve-ruby-snake --input target_win_rate=60 --input max_iterations=10
```

**Run the debug workflow**:
```bash
gh aw run debug-failures --input issue_number=123
```

**Run the experimentation workflow**:
```bash
# Test all strategy areas
gh aw run experiment-strategies --input strategy_focus=all

# Focus on specific area
gh aw run experiment-strategies --input strategy_focus=food-seeking
```

**Check workflow status**:
```bash
gh aw status
```

**View workflow logs**:
```bash
gh aw logs <run-id>
```

## Integration with Existing Infrastructure

These agentic workflows build on top of the existing simulation and telemetry infrastructure:

- **Simulations**: Uses the same `simulate-games` workflow and scripts
- **Testing**: Runs `script/test djdefi` for validation
- **Telemetry**: Leverages existing metrics and tracking
- **Issues**: Posts results to tracking issues (label: `snake-improvement`)
- **Artifacts**: Stores experiment data in `experiments/` and `debug_data/`

## Workflow Architecture

```
┌─────────────────────────────────────────────┐
│  Agentic Workflow (Natural Language)        │
│  - Task definitions                         │
│  - Decision logic                           │
│  - Iteration conditions                     │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│  AI Agent (gh-aw runtime)                   │
│  - Interprets tasks                         │
│  - Executes code modifications              │
│  - Makes autonomous decisions               │
│  - Manages iteration loops                  │
└──────────────┬──────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────┐
│  Existing Infrastructure                     │
│  - Simulation workflows                     │
│  - Test suite                               │
│  - Telemetry system                         │
│  - Snake code (move.rb, app.rb)             │
└─────────────────────────────────────────────┘
```

## Safety and Controls

The agentic workflows include several safety mechanisms:

1. **Validation gates**: All changes must pass tests before being committed
2. **Performance checks**: Changes must improve win rate by at least 5%
3. **Rollback capability**: Failed improvements are automatically reverted
4. **Iteration limits**: Max iterations prevent infinite loops
5. **Human approval**: Critical changes can require manual review

## Example Use Cases

### Continuous Improvement
```bash
# Let the agent autonomously improve the snake over multiple iterations
gh aw run improve-ruby-snake --input target_win_rate=55 --input max_iterations=10
```

The agent will:
1. Run simulations
2. Identify weaknesses
3. Modify code
4. Test changes
5. Repeat until 55% win rate achieved (or 10 iterations)

### Bug Fixing
```bash
# Automatically debug and fix a simulation failure
gh aw run debug-failures --input issue_number=42
```

The agent will:
1. Extract failure details from issue #42
2. Reproduce the bug
3. Find root cause
4. Implement fix
5. Verify and close issue

### Strategy Optimization
```bash
# Experiment with different food-seeking strategies
gh aw run experiment-strategies --input strategy_focus=food-seeking
```

The agent will:
1. Create 4 variants (conservative, moderate, aggressive, adaptive)
2. Run 50 games for each
3. Analyze results statistically
4. Apply the winning strategy

## Monitoring and Observability

**View active workflows**:
```bash
gh aw list --status running
```

**Check recent completions**:
```bash
gh aw list --status completed --limit 10
```

**Get detailed run information**:
```bash
gh aw describe <run-id>
```

**Access artifacts**:
- Experiment data: `experiments/`
- Debug data: `debug_data/`
- Simulation results: `simulation_results/`

## Customization

You can modify the workflow files to:
- Adjust iteration limits
- Change target metrics
- Add new strategy variants
- Modify decision logic
- Add custom validation steps

Just edit the `.yml` files in this directory - the natural language format makes it easy to understand and modify.

## Troubleshooting

**Workflow fails to start**:
- Ensure `gh aw init` was run
- Check authentication: `gh auth status`
- Verify extension is installed: `gh extension list`

**Agent makes unexpected changes**:
- Review workflow logs: `gh aw logs <run-id>`
- Check validation gates in workflow definition
- Adjust decision criteria in task descriptions

**Simulations fail during workflow**:
- Check that snake endpoints are accessible
- Verify battlesnake CLI is installed
- Review snake logs in artifacts

## Best Practices

1. **Start with small iterations**: Use lower max_iterations first
2. **Monitor initial runs**: Watch the first few runs closely
3. **Review changes**: Check commits made by the agent
4. **Use experiments**: Test risky changes via experiment workflow first
5. **Track metrics**: Monitor win rate trends over time

## Future Enhancements

Potential additions to the agentic workflow system:
- Multi-snake comparison workflows
- Automated tournament participation
- Opponent adaptation (learning from specific opponents)
- Real-time strategy switching
- Collaborative improvement across snake variants

## Documentation

- [gh-aw Documentation](https://githubnext.github.io/gh-aw/)
- [Agentic Workflow Concepts](https://githubnext.github.io/gh-aw/start-here/concepts/)
- [Task Definition Guide](https://githubnext.github.io/gh-aw/reference/tasks/)

## Support

For issues with the agentic workflows:
1. Check logs: `gh aw logs <run-id>`
2. Review workflow definitions in this directory
3. Consult gh-aw documentation
4. Open an issue with `agentic-workflow` label
