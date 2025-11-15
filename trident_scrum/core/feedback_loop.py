"""
Feedback Loop - Continuous Learning and Adaptation
===================================================

Implements feedback loop for continuous improvement based on
HTM-inspired pattern recognition and system adjustment.
"""

from typing import List, Dict, Any, Callable, Optional
from dataclasses import dataclass, field
from datetime import datetime


@dataclass
class MetricCollector:
    """Collects metrics from the system."""
    
    name: str
    metric_type: str  # 'performance', 'quality', 'velocity', etc.
    collection_fn: Optional[Callable] = None
    collected_data: List[Dict[str, Any]] = field(default_factory=list)
    
    def collect(self) -> Dict[str, Any]:
        """Collect current metrics."""
        if self.collection_fn:
            data = self.collection_fn()
        else:
            data = {}
        
        data_point = {
            'timestamp': datetime.now().isoformat(),
            'data': data,
        }
        self.collected_data.append(data_point)
        return data_point
    
    def get_recent_data(self, count: int = 10) -> List[Dict[str, Any]]:
        """Get most recent collected data points."""
        return self.collected_data[-count:]


@dataclass
class PatternAnalyzer:
    """Analyzes patterns in collected metrics."""
    
    name: str
    analyzer_type: str  # 'trend', 'anomaly', 'correlation', etc.
    analysis_fn: Optional[Callable] = None
    detected_patterns: List[str] = field(default_factory=list)
    
    def analyze(self, metrics: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Analyze metrics for patterns.
        
        Args:
            metrics: List of collected metric data points
        
        Returns:
            dict: Analysis results including detected patterns
        """
        if self.analysis_fn:
            result = self.analysis_fn(metrics)
        else:
            result = self._default_analysis(metrics)
        
        if result.get('patterns'):
            self.detected_patterns.extend(result['patterns'])
        
        return result
    
    def _default_analysis(self, metrics: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Default analysis implementation."""
        return {
            'metric_count': len(metrics),
            'patterns': [],
            'summary': 'Default analysis completed',
        }


@dataclass
class SystemAdjuster:
    """Makes adjustments to the system based on analysis."""
    
    name: str
    adjuster_type: str  # 'performance', 'resource', 'behavior', etc.
    adjustment_fn: Optional[Callable] = None
    applied_adjustments: List[Dict[str, Any]] = field(default_factory=list)
    
    def adjust(self, patterns: Dict[str, Any]) -> Dict[str, Any]:
        """
        Apply adjustments based on detected patterns.
        
        Args:
            patterns: Detected patterns from analysis
        
        Returns:
            dict: Adjustment results
        """
        if self.adjustment_fn:
            result = self.adjustment_fn(patterns)
        else:
            result = self._default_adjustment(patterns)
        
        adjustment_record = {
            'timestamp': datetime.now().isoformat(),
            'patterns': patterns,
            'result': result,
        }
        self.applied_adjustments.append(adjustment_record)
        return result
    
    def _default_adjustment(self, patterns: Dict[str, Any]) -> Dict[str, Any]:
        """Default adjustment implementation."""
        return {
            'status': 'acknowledged',
            'action': 'No automatic adjustment configured',
        }


class FeedbackLoop:
    """
    Implements continuous feedback loop for system improvement.
    
    Inspired by HTM principles, this loop:
    1. Collects metrics from the system
    2. Analyzes patterns in the data
    3. Makes adjustments based on learned patterns
    4. Repeats continuously
    """
    
    def __init__(self):
        self.collectors: List[MetricCollector] = []
        self.analyzers: List[PatternAnalyzer] = []
        self.adjusters: List[SystemAdjuster] = []
        self.cycle_count: int = 0
        self.cycle_history: List[Dict[str, Any]] = []
    
    def add_collector(self, collector: MetricCollector) -> None:
        """Add a metric collector to the loop."""
        self.collectors.append(collector)
    
    def add_analyzer(self, analyzer: PatternAnalyzer) -> None:
        """Add a pattern analyzer to the loop."""
        self.analyzers.append(analyzer)
    
    def add_adjuster(self, adjuster: SystemAdjuster) -> None:
        """Add a system adjuster to the loop."""
        self.adjusters.append(adjuster)
    
    def collect(self) -> List[Dict[str, Any]]:
        """Collect metrics from all collectors."""
        return [collector.collect() for collector in self.collectors]
    
    def analyze(self, metrics: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Analyze collected metrics using all analyzers."""
        return [
            {
                'analyzer': analyzer.name,
                'result': analyzer.analyze(metrics)
            }
            for analyzer in self.analyzers
        ]
    
    def adjust(self, patterns: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Apply adjustments based on analyzed patterns."""
        adjustments = []
        for adjuster in self.adjusters:
            for pattern_set in patterns:
                result = adjuster.adjust(pattern_set['result'])
                adjustments.append({
                    'adjuster': adjuster.name,
                    'result': result
                })
        return adjustments
    
    def execute_cycle(self) -> Dict[str, Any]:
        """
        Execute one complete feedback cycle.
        
        Returns:
            dict: Results from collect, analyze, and adjust phases
        """
        self.cycle_count += 1
        
        # Collect metrics
        metrics = self.collect()
        
        # Analyze patterns
        patterns = self.analyze(metrics)
        
        # Apply adjustments
        adjustments = self.adjust(patterns)
        
        cycle_result = {
            'cycle': self.cycle_count,
            'timestamp': datetime.now().isoformat(),
            'metrics_collected': len(metrics),
            'patterns_detected': sum(len(p['result'].get('patterns', [])) for p in patterns),
            'adjustments_applied': len(adjustments),
            'details': {
                'metrics': metrics,
                'patterns': patterns,
                'adjustments': adjustments,
            }
        }
        
        self.cycle_history.append(cycle_result)
        return cycle_result
    
    def get_status(self) -> Dict[str, Any]:
        """Get comprehensive feedback loop status."""
        return {
            'cycles_executed': self.cycle_count,
            'collectors': len(self.collectors),
            'analyzers': len(self.analyzers),
            'adjusters': len(self.adjusters),
            'recent_cycles': self.cycle_history[-5:],
        }
