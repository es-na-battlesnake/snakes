# Simulation Results and Telemetry

This document shows the expected feedback and telemetry from simulation runs.

## Example Workflow Output

### During Simulation Run

```
🎮 Starting 10 simulation games...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🐍 Game 1 of 10
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
{"winner":"ruby-danger-noodle","turns":42}
✅ Ruby snake wins! (Turn 42)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🐍 Game 2 of 10
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
{"winner":"pathy","turns":38}
❌ Pathy snake wins (Turn 38)

[... continues for all 10 games ...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 SIMULATION SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Ruby (ruby-danger-noodle): 6 wins
Pathy (Go snake):          3 wins
Draws:                     1

🎯 Ruby Win Rate: 60.0%
✅ Ruby snake performing well!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### PR Comment Format

When simulations run on PRs, results are posted as a formatted comment:

## 🎮 Simulation Results

**Mode**: Wrapped | **Map**: hz_islands_bridges | **Games**: 10

### 📊 Summary
| Snake | Wins | Win Rate |
|-------|------|----------|
| 🔴 Ruby (ruby-danger-noodle) | 6 | 60.0% |
| 🔵 Pathy (Go snake) | 3 | 30.0% |
| 🤝 Draws | 1 | 10.0% |

### 🎯 Performance Assessment
✅ **Ruby snake performing well!**

### 📝 Detailed Results
```
{"winner":"ruby-danger-noodle","turns":42}
{"winner":"pathy","turns":38}
{"winner":"ruby-danger-noodle","turns":45}
{"winner":"ruby-danger-noodle","turns":39}
{"winner":"draw","turns":50}
{"winner":"ruby-danger-noodle","turns":44}
{"winner":"pathy","turns":41}
{"winner":"ruby-danger-noodle","turns":43}
{"winner":"pathy","turns":37}
{"winner":"ruby-danger-noodle","turns":46}
```

---
*Simulation completed via GitHub Actions*

## Continuous Simulation Tracking

For the scheduled continuous simulation workflow, results are posted to a GitHub Issue with label `snake-improvement`.

### Example Issue Update

## Simulation Run - 2025-10-31T05:47:53.347Z

## Simulation Results

```
Mode: wrapped
Runs: 50

Last 10 results:
{"winner":"ruby-danger-noodle","turns":42}
{"winner":"ruby-danger-noodle","turns":45}
{"winner":"pathy","turns":38}
{"winner":"ruby-danger-noodle","turns":39}
{"winner":"ruby-danger-noodle","turns":44}
{"winner":"pathy","turns":41}
{"winner":"ruby-danger-noodle","turns":43}
{"winner":"draw","turns":50}
{"winner":"ruby-danger-noodle","turns":46}
{"winner":"pathy","turns":37}
```

### Performance Metrics
- Ruby snake wins: 28 / 50 (56.0%)
- Pathy snake wins: 19 / 50 (38.0%)
- Draws: 3 / 50 (6.0%)

[View full workflow run](https://github.com/es-na-battlesnake/snakes/actions/runs/...)

---
✅ Win rate is acceptable.

## Telemetry Collected

### Metrics Tracked
1. **Win Rate**: Percentage of games won by Ruby snake
2. **Game Duration**: Number of turns per game
3. **Outcome Distribution**: Wins, losses, draws
4. **Performance Trend**: Tracked over time via issue history

### Artifacts Stored
All simulation runs store the following artifacts (30-day retention):
- `simulation_results.log` - Raw results for all games
- `analysis.md` - Summary analysis
- `/tmp/ruby-snake.log` - Ruby snake debug logs
- `/tmp/go-snake.log` - Go snake debug logs

### Accessing Telemetry

**Via GitHub Actions UI**:
1. Go to Actions tab
2. Select workflow run
3. View "Simulate games" or "Run simulations" step output
4. Download artifacts for detailed logs

**Via GitHub Issue**:
1. Navigate to Issues
2. Filter by label: `snake-improvement`
3. View historical performance data

**Via API** (for automated analysis):
```bash
# Get latest simulation results
gh run list --workflow=continuous-simulation.yml --limit 1

# Download artifacts
gh run download <run-id>
```

## Performance Baselines

### Target Metrics
- **Win Rate**: >45% (vs pathy snake)
- **Consistency**: <10% variance across runs
- **Game Duration**: Average 40-50 turns

### Current Performance (After Improvements)
Based on Ruby snake improvements in this PR:
- Health threshold: 99 → 70 (seeks food earlier)
- Food scoring: +67-145% increase
- Collision avoidance: 2x stronger
- **Expected win rate**: 45-60%

### Historical Tracking
Results are accumulated in the tracking issue, allowing trend analysis:
- Compare win rates over time
- Identify performance regressions
- Validate improvement iterations

## Interpreting Results

### Win Rate Ranges
| Win Rate | Status | Action |
|----------|--------|--------|
| ≥60% | 🎉 Excellent | Monitor for consistency |
| 45-59% | ✅ Good | Target achieved |
| 30-44% | ⚠️  Fair | Review specific failure patterns |
| <30% | ❌ Poor | Major review needed |

### Common Patterns
- **High draw rate** (>15%): May indicate conservative play
- **Short games** (<30 turns): Likely collision deaths
- **Long games** (>60 turns): Good survival, check endgame strategy

## Next Steps

1. **Monitor First Run**: Wait for automated workflow or trigger manually
2. **Review Telemetry**: Check win rate and patterns
3. **Iterate**: Use data to guide further improvements
4. **Track Trends**: Compare across multiple runs
