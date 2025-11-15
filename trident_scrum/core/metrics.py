"""
Metrics and KPIs - Sprint Velocity and Quality Tracking
========================================================

Tracks velocity, quality metrics, and definition of done.
"""

from typing import List, Dict, Any
from dataclasses import dataclass, field


class VelocityTracker:
    """
    Tracks sprint velocity and calculates rolling averages.
    
    Helps predict capacity for future sprints based on historical data.
    """
    
    def __init__(self, window_size: int = 3):
        self.sprint_velocities: List[int] = []
        self.rolling_average: float = 0.0
        self.window_size = window_size
    
    def calculate_velocity(self, sprint) -> int:
        """
        Calculate velocity for a sprint.
        
        Args:
            sprint: Sprint object with completed_stories attribute
        
        Returns:
            int: Total completed story points
        """
        if hasattr(sprint, 'completed_stories'):
            completed_points = sum(story.points for story in sprint.completed_stories)
        else:
            completed_points = getattr(sprint, 'completed_points', 0)
        
        self.sprint_velocities.append(completed_points)
        self._update_rolling_average()
        return completed_points
    
    def _update_rolling_average(self) -> None:
        """Update rolling average based on recent sprints."""
        if not self.sprint_velocities:
            self.rolling_average = 0.0
            return
        
        recent_velocities = self.sprint_velocities[-self.window_size:]
        self.rolling_average = sum(recent_velocities) / len(recent_velocities)
    
    def get_trend(self) -> str:
        """Determine velocity trend (improving, declining, stable)."""
        if len(self.sprint_velocities) < 2:
            return "insufficient_data"
        
        recent = self.sprint_velocities[-1]
        previous = self.sprint_velocities[-2]
        
        if recent > previous * 1.1:
            return "improving"
        elif recent < previous * 0.9:
            return "declining"
        else:
            return "stable"
    
    def get_metrics(self) -> Dict[str, Any]:
        """Get velocity metrics summary."""
        return {
            'total_sprints': len(self.sprint_velocities),
            'latest_velocity': self.sprint_velocities[-1] if self.sprint_velocities else 0,
            'rolling_average': self.rolling_average,
            'trend': self.get_trend(),
            'all_velocities': self.sprint_velocities,
        }


@dataclass
class Metric:
    """Quality metric with target value."""
    
    target: str
    current_value: Any = None
    description: str = ""
    
    def is_met(self) -> bool:
        """Check if metric meets target."""
        # Simple implementation - can be enhanced based on metric type
        return self.current_value is not None


class QualityMetrics:
    """
    Tracks quality metrics for the project.
    
    Includes defect density, code coverage, technical debt,
    and customer satisfaction.
    """
    
    def __init__(self):
        self.metrics: Dict[str, Metric] = {
            "defect_density": Metric(target="< 0.1 per KLOC", description="Defects per 1000 lines of code"),
            "code_coverage": Metric(target="> 80%", description="Test coverage percentage"),
            "technical_debt": Metric(target="< 5% of sprint capacity", description="Technical debt ratio"),
            "customer_satisfaction": Metric(target="> 4.5/5", description="Customer satisfaction score"),
        }
    
    def update_metric(self, name: str, value: Any) -> None:
        """Update metric value."""
        if name in self.metrics:
            self.metrics[name].current_value = value
    
    def get_metrics_summary(self) -> Dict[str, Any]:
        """Get summary of all metrics."""
        return {
            name: {
                'target': metric.target,
                'current': metric.current_value,
                'description': metric.description,
                'is_met': metric.is_met(),
            }
            for name, metric in self.metrics.items()
        }
    
    def add_custom_metric(self, name: str, target: str, description: str = "") -> None:
        """Add a custom quality metric."""
        self.metrics[name] = Metric(target=target, description=description)


class DefinitionOfDone:
    """
    Definition of done checklist for stories and sprints.
    
    Ensures consistent quality standards across all deliverables.
    """
    
    def __init__(self):
        self.criteria: Dict[str, str] = {
            "code_complete": "All code peer-reviewed and merged",
            "tests_passing": "Unit, integration, and performance tests green",
            "documented": "API docs and usage examples provided",
            "deployed": "Running in test environment",
            "monitored": "Metrics and alerts configured",
            "learned": "Retrospective insights captured",
        }
        self.completed_criteria: Dict[str, bool] = {
            key: False for key in self.criteria.keys()
        }
    
    def mark_complete(self, criterion: str) -> None:
        """Mark a criterion as complete."""
        if criterion in self.completed_criteria:
            self.completed_criteria[criterion] = True
    
    def is_done(self) -> bool:
        """Check if all criteria are met."""
        return all(self.completed_criteria.values())
    
    def get_progress(self) -> float:
        """Get completion percentage."""
        if not self.completed_criteria:
            return 0.0
        completed = sum(1 for v in self.completed_criteria.values() if v)
        return (completed / len(self.completed_criteria)) * 100.0
    
    def get_status(self) -> Dict[str, Any]:
        """Get detailed status of all criteria."""
        return {
            'is_done': self.is_done(),
            'progress': self.get_progress(),
            'criteria': {
                criterion: {
                    'description': self.criteria[criterion],
                    'completed': self.completed_criteria[criterion],
                }
                for criterion in self.criteria.keys()
            }
        }
    
    def add_custom_criterion(self, key: str, description: str) -> None:
        """Add a custom criterion to the definition of done."""
        self.criteria[key] = description
        self.completed_criteria[key] = False
