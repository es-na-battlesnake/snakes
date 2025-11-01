# Simulation Analysis Report

This document provides analysis of simulation runs from the continuous improvement workflow.

## How to Use

1. **Trigger a workflow run**: Go to Actions → "Continuous Snake Simulation and Improvement" → Run workflow
2. **Download the logs**: After completion, download the simulation results artifact
3. **Analyze**: Use the analysis tools in this repository or review the tracking issue

## Expected Performance

Based on the improvements made to the Ruby snake:

### Baseline (Pre-Improvements)
- Health threshold: 99 (rarely seeks food proactively)
- Basic collision avoidance
- No dynamic scoring
- **Expected win rate**: ~20-30% (estimated)

### After Improvements (Current)
- Health threshold: 70 (seeks food earlier)
- Enhanced collision avoidance (2x stronger penalties)
- Dynamic health-based food scoring (+70 boost when critical)
- Better corner/edge handling
- **Target win rate**: >45%

## Key Improvements Impact

| Improvement | Expected Impact |
|-------------|----------------|
| Lower health threshold (99→70) | +10-15% win rate (less starvation) |
| Dynamic food scoring | +5-10% win rate (better food management) |
| Enhanced collision avoidance | +5-10% win rate (fewer crashes) |
| Corner/edge penalties | +3-5% win rate (better positioning) |
| **Total Expected** | **+23-40% improvement** |

## Running Simulations Manually

### Option 1: GitHub Actions (Recommended)
```
1. Go to repository Actions tab
2. Select "Continuous Snake Simulation and Improvement"
3. Click "Run workflow"
4. Set parameters:
   - runs: 50 (default)
   - mode: wrapped (default)
5. View results in tracking issue
```

### Option 2: Local with Docker
```bash
# Build image
docker build . -t code-snek

# Run simulations
./script/continuous_improve --runs 20

# Quick test
./script/quick_sim 10 wrapped
```

### Option 3: Using existing simulate-games workflow
```
# Automatically runs on PRs that modify snake code
# Check the PR for simulation results comment
```

## Interpreting Results

### Win Rate Ranges

| Win Rate | Assessment | Action |
|----------|-----------|--------|
| >60% | Excellent | Monitor for consistency |
| 45-60% | Good | Continue incremental improvements |
| 30-45% | Fair | Review specific failure patterns |
| <30% | Poor | Major review needed |

### Common Failure Patterns

1. **Starvation** - Increase food-seeking priority
2. **Collisions** - Strengthen avoidance penalties
3. **Trapped in corners** - Increase corner/edge penalties
4. **Lost to larger snakes** - Improve head-to-head logic

## Simulation Settings

Default settings match competition environment:
- **Mode**: wrapped (board edges wrap)
- **Map**: hz_islands_bridges (strategic map with obstacles)
- **Size**: 11x11
- **Opponents**: pathy (Go snake with pathfinding)

## Tracking

All automated simulation results are posted to the tracking issue:
- **Label**: `snake-improvement`
- **Updates**: Every 6 hours (automated)
- **Artifacts**: 30-day retention

## Recent Changes Log

### 2025-10-31
- Added error handling to prevent HTML responses
- Fixed port exposure for both snakes (4567, 8081)
- Improved health threshold (99→70)
- Enhanced collision avoidance
- Added dynamic food scoring

## Next Steps

1. ✅ Monitor first automated run results
2. ⏳ Validate win rate improvement
3. ⏳ Identify any edge cases from logs
4. ⏳ Iterate on scoring based on data
