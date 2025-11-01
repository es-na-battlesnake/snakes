# Agentic Workflows for Snake Improvement

This document describes the agentic workflow system for autonomous Battlesnake improvement.

## Overview

The agentic workflow system provides a natural language-based approach to continuous improvement, mimicking the concepts from GitHub's experimental Agentic Workflows (gh-aw) framework.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  Agentic Workflow Engine                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐      ┌──────────────┐      ┌───────────┐ │
│  │   Analyze    │─────▶│  Recommend   │─────▶│  Validate │ │
│  │ Performance  │      │ Improvements │      │  Changes  │ │
│  └──────────────┘      └──────────────┘      └───────────┘ │
│         │                      │                     │      │
│         └──────────────────────┴─────────────────────┘      │
│                           │                                  │
│                  ┌────────▼────────┐                        │
│                  │  Decide & Act   │                        │
│                  └─────────────────┘                        │
│                           │                                  │
│              ┌────────────┼────────────┐                    │
│              │            │            │                     │
│         ┌────▼───┐   ┌───▼────┐  ┌───▼─────┐              │
│         │ Merge  │   │Iterate │  │ Revert  │              │
│         └────────┘   └────────┘  └─────────┘              │
└─────────────────────────────────────────────────────────────┘
```

## Workflow Definition

Agentic workflows are defined in `.github/workflows-agentic/` using a natural language format:

```yaml
name: "Improve Snake Performance"

goal: |
  Continuously improve the Ruby Battlesnake's win rate through iterative analysis,
  code modifications, and validation testing.

tasks:
  - id: analyze_performance
    description: "Analyze simulation results to identify performance bottlenecks"
    inputs: [simulation_results, historical_performance]
    outputs: [performance_analysis, improvement_recommendations]
    success_criteria:
      - "Identifies at least 3 specific improvement opportunities"
```

## Tasks

### Task 1: Analyze Performance

**Goal**: Identify performance bottlenecks and improvement opportunities

**Process**:
1. Run baseline simulations (20 games)
2. Measure current win rate
3. Compare against historical performance
4. Identify weakness patterns

**Outputs**:
- Baseline win rate
- Performance metrics
- Identified bottlenecks

### Task 2: Generate Recommendations

**Goal**: Propose specific code improvements based on analysis

**Process**:
1. Analyze performance gaps
2. Generate targeted recommendations
3. Estimate expected impact
4. Prioritize by impact potential

**Outputs**:
- Prioritized improvement list
- Expected impact estimates
- Implementation guidance

### Task 3: Validate Changes

**Goal**: Test proposed improvements through simulation

**Process**:
1. Apply recommended changes
2. Run validation simulations (30+ games)
3. Measure actual impact
4. Compare to baseline

**Outputs**:
- Validation results
- Actual vs expected impact
- Performance delta

### Task 4: Decide & Act

**Goal**: Make data-driven decisions on next actions

**Process**:
1. Evaluate validation results
2. Check success criteria
3. Determine action: merge, iterate, or revert
4. Report outcome

**Decisions**:
- **Merge**: Target achieved, changes improve performance
- **Iterate**: Partial improvement, continue with next priority
- **Revert**: Regression detected, revert changes

## Iteration Strategy

The workflow uses an iterative improvement cycle:

```
  Analyze ──▶ Recommend ──▶ Validate ──▶ Decide
      ▲                                    │
      │                                    │
      └────────── Continue if needed ◀────┘
```

**Convergence Criteria**:
- Win rate reaches target (>45%)
- Improvement delta < 2% (diminishing returns)
- Maximum iterations reached (5 cycles)

## Safety Constraints

All improvements must satisfy:

1. ✅ **Unit tests pass**: All existing tests must pass
2. ✅ **Code coverage maintained**: Coverage must not decrease
3. ✅ **Security scan passes**: CodeQL finds no new vulnerabilities
4. ✅ **No major regression**: Win rate must not drop >5%

## Reporting

Results are reported through:

### GitHub Issues
- **Label**: `agentic-improvement`
- **Frequency**: Per iteration
- **Content**: Analysis, recommendations, decisions

### PR Comments
- **Trigger**: When validation completes
- **Content**: Performance metrics, test results

### Workflow Summary
- **Frequency**: Every run
- **Content**: Task outcomes, metrics, decisions

## Example Workflow Run

```
1. ANALYZE PERFORMANCE
   ├─ Run 20 baseline simulations
   ├─ Measure: Win rate = 35%
   └─ Gap to target (45%): 10%

2. GENERATE RECOMMENDATIONS
   ├─ Priority 1: Food seeking (+5-10%)
   ├─ Priority 2: Collision avoidance (+3-7%)
   └─ Priority 3: Space control (+2-5%)

3. VALIDATE (if changes made)
   ├─ Run 30 validation simulations  
   ├─ Measure: Win rate = 42%
   └─ Improvement: +7% ✅

4. DECIDE
   ├─ Decision: Continue (42% < 45%)
   ├─ Action: Iterate with next priority
   └─ Create tracking issue #123
```

## Manual Triggering

Trigger the agentic workflow manually:

```bash
# Via GitHub UI
1. Go to Actions tab
2. Select "Agentic Snake Improvement"
3. Click "Run workflow"
4. Set parameters:
   - max_iterations: 3
   - target_win_rate: 45

# Via GitHub CLI
gh workflow run agentic-improvement.yml \
  -f max_iterations=3 \
  -f target_win_rate=45
```

## Monitoring Progress

Track improvement cycles through:

1. **GitHub Issues**: Label `agentic-improvement`
2. **Workflow Runs**: Actions tab
3. **Metrics Dashboard**: Check simulation artifacts
4. **Git History**: Review automated commits

## Configuration

Customize the agentic behavior:

```yaml
# .github/workflows-agentic/improve-snake.yml

iteration:
  max_cycles: 5                    # Maximum improvement iterations
  convergence_criteria:
    - metric: "win_rate"
      threshold: 0.45              # Target win rate (45%)
      direction: "above"
    - metric: "improvement_delta"
      threshold: 0.02              # Stop if improvement < 2%
      direction: "below"
```

## Best Practices

### 1. Set Realistic Targets
- Start with achievable goals (40-50%)
- Increase gradually as improvements compound

### 2. Monitor Iterations
- Review recommendations before automated changes
- Validate unexpected patterns manually

### 3. Use Safety Constraints
- Always run full test suite
- Check for regressions
- Monitor code quality metrics

### 4. Track History
- Maintain improvement log
- Document successful strategies
- Learn from failed experiments

## Integration with Existing Infrastructure

The agentic workflow integrates with:

- ✅ **Simulation workflows**: Uses same simulation infrastructure
- ✅ **Telemetry system**: Leverages comprehensive metrics
- ✅ **Testing tools**: Runs validation through existing tools
- ✅ **Documentation**: Updates improvement tracking logs

## Limitations

Current implementation:
- ❌ No autonomous code modification (requires manual implementation)
- ❌ No LLM-powered analysis (uses rule-based recommendations)
- ❌ No automatic PR creation (requires manual review)
- ✅ Provides framework for future autonomous capabilities

## Future Enhancements

Potential improvements:
1. **LLM Integration**: Add GPT-4 for code analysis and generation
2. **Automated PRs**: Auto-create PRs with proposed changes
3. **A/B Testing**: Run parallel experiments
4. **Multi-objective**: Optimize for multiple metrics simultaneously
5. **Transfer Learning**: Apply learnings across different snakes

## Troubleshooting

### Workflow Not Triggering
- Check schedule configuration
- Verify workflow is enabled
- Review GitHub Actions permissions

### Simulations Failing
- Check snake startup logs
- Verify battlesnake CLI installation
- Review port availability

### Recommendations Not Actionable
- Increase simulation sample size
- Check analysis logic
- Review historical performance data

## Support

For questions or issues:
- **Documentation**: `docs/CONTINUOUS_IMPROVEMENT.md`
- **Issue Tracker**: Label `agentic-improvement`
- **Workflow Logs**: Actions tab → Recent runs

---

**Last Updated**: 2025-10-31
**Status**: Active and operational
**Maintainer**: Automated workflow system
