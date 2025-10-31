# Ruby Snake Improvement Log

This document tracks improvements made to the Ruby Battlesnake (`snakes/ruby/djdefi/`).

## Improvement History

### 2025-10-31: Initial Improvements

**Goal**: Improve food seeking and collision avoidance

**Changes**:

1. **Health Threshold**: 99 → 70
   - Snake now seeks food more proactively
   - Better balance between aggression and survival

2. **Food Scoring (Wrapped Mode)**:
   - `food`: 55 → 65
   - `food_adjacent`: 20 → 25
   - Added dynamic health-based boost (up to +70 when health <70)

3. **Food Scoring (Standard Mode)**:
   - `food`: 15 → 25
   - `food_adjacent`: 2 → 5
   - Same dynamic boost as wrapped mode

4. **Collision Avoidance (Wrapped Mode)**:
   - `other_snake_body`: -30 → -60
   - `other_snake_head_neighbor`: 0 → -10
   - `snake_body_neighbor`: -20 → -25
   - `shared_longer_snake`: -80 → -100
   - `shared_same_length_snake`: -75 → -85

5. **Collision Avoidance (Standard Mode)**:
   - `other_snake_body`: -130 → -150
   - `other_snake_head_neighbor`: 0 → -5
   - `snake_body_neighbor`: -10 → -15
   - `shared_longer_snake`: -50 → -70
   - `shared_same_length_snake`: -5 → -10

6. **Edge and Corner Handling**:
   - `corner`: -1 → -5 (wrapped), -1 → -8 (standard)
   - `edge`: 0 → 0 (wrapped), -4 → -6 (standard)
   - `edge_adjacent`: 0 → -2 (wrapped), -1 → -3 (standard)

7. **Aggressive Behavior**:
   - `shared_shorter_snake`: 45 → 50 (wrapped), 5 → 10 (standard)
   - `shorter_snake_heads`: 4 → 5 (wrapped), 0 → 2 (standard)

8. **Dynamic Multipliers**:
   - Added health-based food scoring boost
   - Top direction multiplier now scales: 15 → (15-45) based on health

**Expected Impact**:
- Improved win rate through better food management
- Reduced early-game deaths from starvation
- Better collision avoidance with larger opponents
- More aggressive when appropriate

**Testing**:
- Unit tests: ✅ All passing
- Simulation tests: Pending

---

## Performance Metrics

Track performance here after running simulations:

### Baseline (Before Improvements)
- Win rate: TBD
- Average survival turns: TBD
- Common failure modes: TBD

### After 2025-10-31 Improvements
- Win rate: TBD (run `script/continuous_improve --runs 50`)
- Average survival turns: TBD
- Improvements observed: TBD

---

## Future Improvement Ideas

### High Priority
- [ ] Implement flood fill algorithm to avoid dead ends
- [ ] Add space awareness (estimate available space in each direction)
- [ ] Improve endgame strategy (1v1 scenarios)
- [ ] Better prediction of opponent moves

### Medium Priority
- [ ] Optimize for specific maps (hz_islands_bridges)
- [ ] Dynamic strategy based on game phase (early/mid/late)
- [ ] Better handling of multiple nearby snakes
- [ ] Improve hazard zone navigation

### Low Priority
- [ ] Performance optimization (reduce computation time)
- [ ] More sophisticated scoring algorithm
- [ ] Machine learning-based move selection
- [ ] Multi-turn planning

---

## Testing Checklist

Before committing improvements:
- [ ] Run unit tests: `script/test djdefi`
- [ ] Run quick simulation: `script/continuous_improve --runs 10`
- [ ] Review move logic manually
- [ ] Check for edge cases
- [ ] Run full simulation: `script/continuous_improve --runs 50`
- [ ] Compare win rate to baseline
- [ ] Document changes in this file

---

## Scoring Reference

Quick reference for score multipliers (subject to change):

### Critical Cells (High Impact)
- **Hazards**: -550 (wrapped), -20 (standard)
- **Other Snake Bodies**: -60 (wrapped), -150 (standard)
- **Shared Longer Snake**: -100 (wrapped), -70 (standard)
- **My Tail**: +8 (wrapped), +80 (standard)

### Important Cells (Medium Impact)
- **Food**: +65 (wrapped), +25 (standard) + dynamic boost
- **Empty**: +55 (wrapped), +10 (standard)
- **My Tail Neighbor**: +25 (wrapped), +15 (standard)
- **Food Adjacent**: +25 (wrapped), +5 (standard)

### Situational Cells (Context-Dependent)
- **Shared Shorter Snake**: +50 (wrapped), +10 (standard)
- **Corners**: -5 (wrapped), -8 (standard)
- **Edges**: 0 (wrapped), -6 (standard)

---

## Resources

- [Battlesnake Docs](https://docs.battlesnake.com/)
- [Continuous Improvement Guide](./CONTINUOUS_IMPROVEMENT.md)
- [Simulation Script](../script/continuous_improve)
- [Automated Workflow](../.github/workflows/continuous-simulation.yml)
