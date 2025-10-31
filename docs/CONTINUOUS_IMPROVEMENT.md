# Continuous Simulation and Improvement

This directory contains tools and documentation for continuously running simulations and improving the Ruby Battlesnake.

## Overview

The continuous improvement system provides:
- Automated simulations via GitHub Actions (scheduled and on-demand)
- Local simulation and analysis tools
- Performance tracking and recommendations
- Structured approach to iterative improvements

## Quick Start

### Local Simulations

Run simulations locally to test improvements:

```bash
# Run 20 simulations with default settings
./script/continuous_improve

# Run 50 simulations with custom settings
./script/continuous_improve --runs 50 --mode wrapped

# Analyze existing results
./script/continuous_improve --analyze-only

# Verbose output
./script/continuous_improve --runs 10 -v
```

### GitHub Actions Workflow

The `continuous-simulation.yml` workflow:
- Runs automatically every 6 hours
- Can be triggered manually with custom parameters
- Creates/updates a tracking issue with results
- Stores simulation logs as artifacts

To trigger manually:
1. Go to Actions tab in GitHub
2. Select "Continuous Snake Simulation and Improvement"
3. Click "Run workflow"
4. Customize runs and mode if desired

## Improvement Process

### 1. Run Simulations

```bash
./script/continuous_improve --runs 30
```

This will:
- Build and start the snakes
- Run 30 simulation games
- Analyze the results
- Provide recommendations

### 2. Analyze Results

Check the output for:
- Win rate (target: >45%)
- Common failure patterns
- Specific scenarios where the snake struggles

Results are saved in `simulation_results/`:
- `sim_TIMESTAMP.log` - Full simulation output
- `analysis_TIMESTAMP.txt` - Summary and recommendations

### 3. Identify Issues

Review simulation logs to find:
- Collision patterns
- Food-seeking failures
- Edge case bugs
- Suboptimal move choices

### 4. Make Improvements

Edit `snakes/ruby/djdefi/app/move.rb` to:
- Adjust scoring weights
- Improve collision detection
- Enhance food-seeking logic
- Fix edge cases

Key areas to tune:
- `@score_multiplier` hash (lines 323-386)
- Health threshold behavior (line 14)
- Directional scoring logic (lines 484-514)

### 5. Test Changes

```bash
# Run unit tests
script/test djdefi

# Run quick simulation test
./script/continuous_improve --runs 10
```

### 6. Validate Improvements

```bash
# Run full simulation suite
./script/continuous_improve --runs 50
```

Compare win rates before and after changes.

### 7. Commit and Deploy

If improvements are validated:
```bash
git add snakes/ruby/djdefi/app/move.rb
git commit -m "Improve Ruby snake: [description of changes]"
git push
```

## Performance Metrics

### Target Metrics
- Win rate vs Pathy snake: >45%
- Draw rate: <10%
- Average survival turns: Monitor trend

### Current Performance
Check the latest tracking issue labeled `snake-improvement` for:
- Recent simulation results
- Win rate trends
- Known issues

## Common Improvements

### Low Win Rate (<30%)
**Symptoms**: Frequent early collisions, poor survival

**Actions**:
1. Review collision avoidance weights
2. Check edge detection logic
3. Verify body tracking
4. Test wrapped mode edge cases

### Medium Win Rate (30-45%)
**Symptoms**: Survives but doesn't win often

**Actions**:
1. Improve food-seeking strategy
2. Adjust health threshold
3. Optimize endgame behavior
4. Fine-tune scoring weights

### High Win Rate (>45%)
**Symptoms**: Consistent performance

**Actions**:
1. Monitor for regressions
2. Test against new opponents
3. Look for edge case improvements
4. Optimize performance/speed

## Scoring System

The Ruby snake uses a scoring system to evaluate moves. Key multipliers:

### Critical (High Impact)
- `shared_longer_snake`: -50 to -80 (avoid larger snakes)
- `other_snake_body`: -30 to -130 (avoid collisions)
- `my_tail`: +6 to +76 (chase tail when safe)
- `hazard`: -15 to -550 (avoid hazards)

### Important (Medium Impact)
- `food`: +15 to +55 (seek food)
- `empty`: +8 to +55 (prefer open space)
- `my_tail_neighbor`: +12 to +20 (enable tail chasing)

### Situational (Low Impact)
- `edge`: -4 to 0 (board edges)
- `corner`: -1 (avoid corners)
- `head_neighbor`: 0 (neutral)

## Troubleshooting

### Docker Build Fails
```bash
# Rebuild base image
docker build -f Dockerfile.base -t battlesnake-base .
```

### Simulations Don't Start
```bash
# Check Docker
docker ps
docker logs code-snek

# Verify endpoints
curl http://localhost:4567/
```

### Low/No Wins
1. Check simulation logs for patterns
2. Run with `--verbose` flag
3. Review recent code changes
4. Compare with known-good version

## Files

- `script/continuous_improve` - Local simulation and analysis script
- `.github/workflows/continuous-simulation.yml` - Automated workflow
- `simulation_results/` - Local simulation logs (gitignored)
- `snakes/ruby/djdefi/app/move.rb` - Ruby snake logic

## Resources

- [Battlesnake Documentation](https://docs.battlesnake.com/)
- [Battlesnake CLI](https://github.com/BattlesnakeOfficial/rules)
- [Repository README](../README.md)
- [Simulation Workflow](../.github/workflows/simulate-games.yml)
