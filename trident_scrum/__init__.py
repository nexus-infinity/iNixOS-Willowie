"""
Trident Scrum Framework
========================

A three-pronged agile approach: Build, Test, Learn

This framework integrates with the iNixOS-Willowie sacred geometry architecture,
providing object-oriented sequential planning inspired by HTM (Hierarchical Temporal Memory)
principles from NuPIC Legacy.

Core Components:
- SprintTrident: Three-pronged sprint approach
- FeatureEpic: User story and task management
- ExecutionPipeline: Sequential phase execution
- CI/CD Integration: Continuous feedback loops
"""

__version__ = "0.1.0"
__author__ = "Nexus Infinity"

from .core.sprint_trident import SprintTrident, BuildPipeline, TestHarness, LearningLoop
from .core.feature_epic import FeatureEpic, Story, Task, Deliverable
from .core.execution_pipeline import ExecutionPipeline, Phase, ExitCriteria
from .core.metrics import VelocityTracker, QualityMetrics, DefinitionOfDone
from .core.feedback_loop import FeedbackLoop, MetricCollector, PatternAnalyzer, SystemAdjuster

__all__ = [
    'SprintTrident',
    'BuildPipeline',
    'TestHarness',
    'LearningLoop',
    'FeatureEpic',
    'Story',
    'Task',
    'Deliverable',
    'ExecutionPipeline',
    'Phase',
    'ExitCriteria',
    'VelocityTracker',
    'QualityMetrics',
    'DefinitionOfDone',
    'FeedbackLoop',
    'MetricCollector',
    'PatternAnalyzer',
    'SystemAdjuster',
]
