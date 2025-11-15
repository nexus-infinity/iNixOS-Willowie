"""
Sprint Trident - Three-pronged Sprint Approach
===============================================

Implements Build, Test, and Learn streams that run in parallel
during sprint execution.
"""

from typing import List, Dict, Any, Optional
from dataclasses import dataclass, field
from datetime import datetime


class BuildPipeline:
    """Feature development stream."""
    
    def __init__(self):
        self.features: List[Any] = []
        self.status: str = "initialized"
        self.progress: float = 0.0
    
    def add_feature(self, feature: Any) -> None:
        """Add a feature to the build pipeline."""
        self.features.append(feature)
    
    def update_progress(self, progress: float) -> None:
        """Update build progress (0.0 to 1.0)."""
        self.progress = min(1.0, max(0.0, progress))
        if self.progress >= 1.0:
            self.status = "completed"
        elif self.progress > 0.0:
            self.status = "in_progress"


class TestHarness:
    """Validation layer stream."""
    
    def __init__(self):
        self.test_suites: List[str] = []
        self.coverage: float = 0.0
        self.passing: bool = False
    
    def add_test_suite(self, suite_name: str) -> None:
        """Add a test suite to the harness."""
        self.test_suites.append(suite_name)
    
    def update_coverage(self, coverage: float) -> None:
        """Update test coverage percentage."""
        self.coverage = min(100.0, max(0.0, coverage))
    
    def mark_passing(self, passing: bool) -> None:
        """Mark tests as passing or failing."""
        self.passing = passing


class LearningLoop:
    """Feedback integration stream."""
    
    def __init__(self):
        self.insights: List[str] = []
        self.adaptations: List[str] = []
        self.metrics: Dict[str, float] = {}
    
    def capture_insight(self, insight: str) -> None:
        """Capture a learning insight."""
        self.insights.append(insight)
    
    def apply_adaptation(self, adaptation: str) -> None:
        """Apply an adaptation based on learning."""
        self.adaptations.append(adaptation)
    
    def track_metric(self, name: str, value: float) -> None:
        """Track a learning metric."""
        self.metrics[name] = value


@dataclass
class SprintTrident:
    """
    Three-pronged approach: Build, Test, Learn
    
    This class orchestrates parallel streams of work during a sprint,
    ensuring continuous integration of build, validation, and learning.
    """
    
    sprint_number: int
    goal: str
    capacity: int  # story points
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    
    # Three prongs
    prong_alpha: BuildPipeline = field(default_factory=BuildPipeline)
    prong_beta: TestHarness = field(default_factory=TestHarness)
    prong_gamma: LearningLoop = field(default_factory=LearningLoop)
    
    # Sprint state
    status: str = "planning"
    completed_points: int = 0
    
    def __post_init__(self):
        """Initialize sprint with current datetime if not provided."""
        if self.start_date is None:
            self.start_date = datetime.now()
    
    def start_sprint(self) -> None:
        """Begin sprint execution."""
        self.status = "active"
        self.start_date = datetime.now()
    
    def complete_sprint(self) -> None:
        """Complete sprint and capture final state."""
        self.status = "completed"
        self.end_date = datetime.now()
        
        # Capture final learning insights
        self.prong_gamma.capture_insight(
            f"Sprint {self.sprint_number} completed {self.completed_points}/{self.capacity} points"
        )
    
    def get_velocity(self) -> float:
        """Calculate sprint velocity."""
        if self.capacity == 0:
            return 0.0
        return (self.completed_points / self.capacity) * 100.0
    
    def get_status_summary(self) -> Dict[str, Any]:
        """Get comprehensive sprint status."""
        return {
            'sprint_number': self.sprint_number,
            'goal': self.goal,
            'status': self.status,
            'velocity': self.get_velocity(),
            'build_progress': self.prong_alpha.progress * 100,
            'test_coverage': self.prong_beta.coverage,
            'tests_passing': self.prong_beta.passing,
            'insights_captured': len(self.prong_gamma.insights),
            'adaptations_applied': len(self.prong_gamma.adaptations),
        }
