#!/usr/bin/env python3
"""
Advanced Performance Analysis for Elite Battlesnake Training

This script provides deep analysis of game performance, identifies patterns
in wins/losses, and generates actionable recommendations for achieving 
90%+ win rates.

Features:
- Game state pattern analysis
- Decision tree visualization 
- Failure mode classification
- Strategic recommendation engine
- Performance trend tracking
- Opponent behavior modeling
"""

import json
import os
import sys
import argparse
from pathlib import Path
from collections import defaultdict, Counter
from datetime import datetime
import statistics

class ElitePerformanceAnalyzer:
    def __init__(self, training_data_dir="/tmp/battlesnake_training_data"):
        self.data_dir = Path(training_data_dir)
        self.games_dir = self.data_dir / "games"
        self.analysis_dir = self.data_dir / "analysis"
        self.patterns_dir = self.data_dir / "patterns"
        
        # Create directories if they don't exist
        for directory in [self.games_dir, self.analysis_dir, self.patterns_dir]:
            directory.mkdir(parents=True, exist_ok=True)
    
    def analyze_all_cycles(self):
        """Analyze all training cycles and generate comprehensive report"""
        print("🧠 Elite Performance Analysis Starting...")
        
        # Load all cycle analysis files
        cycle_data = []
        for analysis_file in self.analysis_dir.glob("cycle_*_patterns.json"):
            try:
                with open(analysis_file, 'r') as f:
                    data = json.load(f)
                    cycle_data.append(data)
            except Exception as e:
                print(f"⚠️  Warning: Could not load {analysis_file}: {e}")
        
        if not cycle_data:
            print("❌ No cycle data found for analysis")
            return
        
        # Sort by cycle ID
        cycle_data.sort(key=lambda x: int(x.get('cycle_id', 0)))
        
        # Analyze trends
        performance_trends = self.analyze_performance_trends(cycle_data)
        failure_patterns = self.analyze_failure_patterns(cycle_data)
        strategic_insights = self.generate_strategic_insights(cycle_data)
        
        # Generate comprehensive report
        report = self.generate_elite_report(performance_trends, failure_patterns, strategic_insights)
        
        # Save report
        report_file = self.analysis_dir / f"elite_analysis_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
        with open(report_file, 'w') as f:
            f.write(report)
        
        print(f"✅ Elite analysis complete: {report_file}")
        return report
    
    def analyze_performance_trends(self, cycle_data):
        """Analyze performance trends across training cycles"""
        trends = {
            'competitive_rates': [],
            'win_rates': [],
            'failure_rates': [],
            'improvement_velocity': [],
            'consistency_score': 0
        }
        
        for cycle in cycle_data:
            stats = cycle.get('game_statistics', {})
            failure_analysis = cycle.get('failure_analysis', {})
            
            competitive_rate = float(stats.get('competitive_rate', 0))
            win_rate = float(stats.get('win_rate', 0))
            early_failure_rate = float(failure_analysis.get('early_failure_rate', 0))
            
            trends['competitive_rates'].append(competitive_rate)
            trends['win_rates'].append(win_rate)
            trends['failure_rates'].append(early_failure_rate)
        
        # Calculate improvement velocity
        if len(trends['competitive_rates']) > 1:
            for i in range(1, len(trends['competitive_rates'])):
                improvement = trends['competitive_rates'][i] - trends['competitive_rates'][i-1]
                trends['improvement_velocity'].append(improvement)
        
        # Calculate consistency score
        if trends['competitive_rates']:
            std_dev = statistics.stdev(trends['competitive_rates']) if len(trends['competitive_rates']) > 1 else 0
            mean_rate = statistics.mean(trends['competitive_rates'])
            trends['consistency_score'] = max(0, 100 - (std_dev / max(mean_rate, 1) * 100))
        
        return trends
    
    def analyze_failure_patterns(self, cycle_data):
        """Analyze patterns in losses to identify improvement areas"""
        patterns = {
            'primary_failure_modes': Counter(),
            'failure_trend': [],
            'critical_weaknesses': [],
            'improvement_priorities': []
        }
        
        for cycle in cycle_data:
            failure_analysis = cycle.get('failure_analysis', {})
            
            # Count failure types
            early_failures = failure_analysis.get('early_failures', 0)
            starvation_deaths = failure_analysis.get('starvation_deaths', 0)
            collision_deaths = failure_analysis.get('collision_deaths', 0)
            
            if early_failures > 0:
                patterns['primary_failure_modes']['early_game_survival'] += early_failures
            if starvation_deaths > 0:
                patterns['primary_failure_modes']['food_seeking'] += starvation_deaths
            if collision_deaths > 0:
                patterns['primary_failure_modes']['collision_avoidance'] += collision_deaths
            
            total_failures = early_failures + starvation_deaths + collision_deaths
            patterns['failure_trend'].append(total_failures)
        
        # Identify critical weaknesses
        total_games = sum(cycle.get('game_statistics', {}).get('total_games', 0) for cycle in cycle_data)
        if total_games > 0:
            for failure_mode, count in patterns['primary_failure_modes'].items():
                failure_rate = (count / total_games) * 100
                if failure_rate > 20:
                    patterns['critical_weaknesses'].append({
                        'type': failure_mode,
                        'rate': failure_rate,
                        'priority': 'CRITICAL' if failure_rate > 30 else 'HIGH'
                    })
        
        return patterns
    
    def generate_strategic_insights(self, cycle_data):
        """Generate strategic insights for reaching 90% win rate"""
        insights = {
            'current_level': 'UNKNOWN',
            'next_milestone': 60,
            'specific_recommendations': [],
            'estimated_cycles_to_goal': 'UNKNOWN',
            'confidence_level': 'LOW'
        }
        
        if not cycle_data:
            return insights
        
        # Get latest performance
        latest_cycle = cycle_data[-1]
        latest_competitive_rate = float(latest_cycle.get('game_statistics', {}).get('competitive_rate', 0))
        
        # Determine current performance level
        if latest_competitive_rate >= 90:
            insights['current_level'] = 'ELITE'
            insights['next_milestone'] = 95
        elif latest_competitive_rate >= 75:
            insights['current_level'] = 'EXCELLENT'
            insights['next_milestone'] = 90
        elif latest_competitive_rate >= 60:
            insights['current_level'] = 'GOOD'
            insights['next_milestone'] = 75
        elif latest_competitive_rate >= 40:
            insights['current_level'] = 'FAIR'
            insights['next_milestone'] = 60
        else:
            insights['current_level'] = 'NEEDS_IMPROVEMENT'
            insights['next_milestone'] = 40
        
        # Generate specific recommendations based on level
        insights['specific_recommendations'] = self.get_level_specific_recommendations(
            insights['current_level'], latest_competitive_rate
        )
        
        # Estimate cycles to goal based on improvement velocity
        if len(cycle_data) >= 3:
            recent_rates = [float(c.get('game_statistics', {}).get('competitive_rate', 0)) for c in cycle_data[-3:]]
            if len(recent_rates) >= 2:
                avg_improvement = sum(recent_rates[i] - recent_rates[i-1] for i in range(1, len(recent_rates))) / (len(recent_rates) - 1)
                if avg_improvement > 0:
                    cycles_needed = max(1, int((90 - latest_competitive_rate) / avg_improvement))
                    insights['estimated_cycles_to_goal'] = cycles_needed
                    insights['confidence_level'] = 'HIGH' if avg_improvement > 2 else 'MEDIUM'
        
        return insights
    
    def get_level_specific_recommendations(self, level, current_rate):
        """Get specific recommendations based on current performance level"""
        recommendations = []
        
        if level == 'NEEDS_IMPROVEMENT':
            recommendations = [
                "🚨 CRITICAL: Fix basic survival - snake is losing majority of games",
                "🔧 Improve collision detection and wall avoidance algorithms",
                "🎯 Implement conservative health management (85+ threshold)",
                "📊 Add comprehensive safety checks before each move",
                "🧪 Focus on 100% reliable basic gameplay first"
            ]
        elif level == 'FAIR':
            recommendations = [
                "🎯 Enhance food seeking with smarter A* pathfinding",
                "🤖 Implement enemy movement prediction and avoidance",
                "🏗️  Add space control algorithms to avoid getting trapped", 
                "⚖️  Balance aggressive and defensive strategies",
                "📈 Optimize decision-making for mid-game scenarios"
            ]
        elif level == 'GOOD':
            recommendations = [
                "🧠 Implement advanced opponent modeling",
                "🏆 Add dynamic strategy switching based on game state",
                "🎮 Enhance endgame strategies for long-term victories",
                "📊 Fine-tune health thresholds for different scenarios",
                "🎯 Add sophisticated territory control algorithms"
            ]
        elif level == 'EXCELLENT':
            recommendations = [
                "💎 Perfect marginal gains - optimize edge case handling",
                "🎯 Implement machine learning for opponent adaptation",
                "⚡ Add ultra-fast response optimizations",
                "🧪 Test against multiple opponent types",
                "📊 Fine-tune all parameters for maximum win rate"
            ]
        else:  # ELITE
            recommendations = [
                "🏆 Maintain elite performance consistency",
                "🔬 Analyze remaining losses for perfect play",
                "🎯 Test against tournament-level opponents", 
                "📊 Document elite strategies for other snakes",
                "🚀 Push beyond 95% win rate if possible"
            ]
        
        return recommendations
    
    def generate_elite_report(self, trends, patterns, insights):
        """Generate comprehensive elite analysis report"""
        current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        report = f"""# 🧠 Elite Battlesnake Performance Analysis Report

*Generated: {current_time}*

## 📊 Performance Summary

**Current Level:** {insights['current_level']}
**Latest Competitive Rate:** {trends['competitive_rates'][-1] if trends['competitive_rates'] else 'N/A'}%
**Next Milestone:** {insights['next_milestone']}%
**Estimated Cycles to 90% Goal:** {insights['estimated_cycles_to_goal']}

## 📈 Performance Trends

### Competitive Rate Progression
"""
        
        if trends['competitive_rates']:
            for i, rate in enumerate(trends['competitive_rates']):
                report += f"- Cycle {i+1}: {rate}%\n"
            
            report += f"\n**Average Rate:** {statistics.mean(trends['competitive_rates']):.1f}%\n"
            report += f"**Consistency Score:** {trends['consistency_score']:.1f}/100\n"
            
            if trends['improvement_velocity']:
                avg_improvement = statistics.mean(trends['improvement_velocity'])
                report += f"**Average Improvement per Cycle:** {avg_improvement:+.1f}%\n"
        
        report += f"""
## 🚨 Failure Pattern Analysis

### Primary Failure Modes
"""
        
        for failure_mode, count in patterns['primary_failure_modes'].items():
            report += f"- **{failure_mode.replace('_', ' ').title()}:** {count} occurrences\n"
        
        if patterns['critical_weaknesses']:
            report += "\n### Critical Weaknesses to Address\n"
            for weakness in patterns['critical_weaknesses']:
                report += f"- **{weakness['type'].replace('_', ' ').title()}:** {weakness['rate']:.1f}% failure rate - {weakness['priority']} priority\n"
        
        report += f"""
## 🎯 Strategic Recommendations

### Immediate Actions for {insights['current_level']} Level
"""
        
        for i, recommendation in enumerate(insights['specific_recommendations'], 1):
            report += f"{i}. {recommendation}\n"
        
        report += f"""
## 🚀 Path to Elite Performance (90%+ Win Rate)

### Performance Roadmap
"""
        
        current_rate = trends['competitive_rates'][-1] if trends['competitive_rates'] else 0
        
        milestones = [
            (40, "FAIR", "Basic survival mastery"),
            (60, "GOOD", "Strategic gameplay"),
            (75, "EXCELLENT", "Advanced AI techniques"),
            (90, "ELITE", "Tournament-ready performance")
        ]
        
        for rate, level, description in milestones:
            if current_rate < rate:
                status = "🎯 NEXT TARGET"
            elif current_rate >= rate:
                status = "✅ ACHIEVED"
            else:
                status = "⏳ FUTURE GOAL"
            
            report += f"- **{rate}%+ ({level}):** {description} - {status}\n"
        
        report += f"""
## 📋 Implementation Priority

### Phase 1: Foundation (Current → {min(60, insights['next_milestone'])}%)
- Fix all basic survival issues
- Implement robust safety systems
- Ensure 100% game completion

### Phase 2: Enhancement ({min(60, insights['next_milestone'])}% → 75%)
- Add sophisticated opponent prediction
- Implement territory control
- Optimize food seeking strategies

### Phase 3: Mastery (75% → 90%)
- Perfect endgame strategies
- Add dynamic adaptation
- Fine-tune all parameters

### Phase 4: Elite (90%+)
- Achieve tournament-level performance
- Maintain consistency
- Push theoretical limits

## 🔧 Technical Recommendations

### Code Improvements
- Implement elite strategies module ✅
- Add multi-objective decision making ✅
- Create advanced opponent modeling ✅
- Build sophisticated space control algorithms ✅

### Testing Strategy
- Run 100+ game cycles per improvement
- Test against multiple opponents
- Validate across different map types
- Monitor performance consistency

## 📊 Data Insights

### Key Metrics to Track
1. **Competitive Rate:** Primary success metric
2. **Consistency Score:** Performance stability
3. **Failure Mode Distribution:** Improvement priorities
4. **Improvement Velocity:** Progress rate

### Success Indicators
- Consistent 90%+ competitive rate over 100+ games
- Less than 5% early game failures  
- Robust performance across all map types
- Positive win rate against elite opponents

---

*Next Analysis: Run after completing additional training cycles*
*Goal: Achieve and maintain 90%+ competitive rate*
"""
        
        return report

def main():
    parser = argparse.ArgumentParser(description="Elite Battlesnake Performance Analysis")
    parser.add_argument("--data-dir", default="/tmp/battlesnake_training_data", 
                       help="Training data directory")
    parser.add_argument("--output", help="Output file for report")
    
    args = parser.parse_args()
    
    analyzer = ElitePerformanceAnalyzer(args.data_dir)
    report = analyzer.analyze_all_cycles()
    
    if report:
        if args.output:
            with open(args.output, 'w') as f:
                f.write(report)
            print(f"📊 Report saved to: {args.output}")
        else:
            print("\n" + "="*60)
            print(report)
    else:
        print("❌ No analysis could be performed")

if __name__ == "__main__":
    main()