#!/usr/bin/env python3
"""
Example usage of Trident Scrum Framework
=========================================

Demonstrates the complete workflow from sprint planning through execution.
"""

import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from trident_scrum.core.sprint_trident import SprintTrident
from trident_scrum.core.feature_epic import FeatureEpic, Story, Task, Deliverable, Priority
from trident_scrum.core.execution_pipeline import ExecutionPipeline, Phase, ExitCriteria
from trident_scrum.core.metrics import VelocityTracker, QualityMetrics, DefinitionOfDone
from trident_scrum.core.feedback_loop import FeedbackLoop, MetricCollector, PatternAnalyzer, SystemAdjuster
from trident_scrum.epics import AnomalyDetectionEpic, PredictiveCacheEpic
from trident_scrum.pipelines import CIPipeline, Sprint1


def print_section(title):
    """Print a section header."""
    print(f"\n{'='*60}")
    print(f"  {title}")
    print('='*60)


def demo_sprint_creation():
    """Demonstrate creating and managing a sprint."""
    print_section("Sprint Creation and Management")
    
    # Create sprint
    sprint = SprintTrident(
        sprint_number=1,
        goal="Establish HTM foundation layers",
        capacity=40
    )
    
    print(f"Created Sprint {sprint.sprint_number}: {sprint.goal}")
    print(f"Capacity: {sprint.capacity} story points")
    
    # Start sprint
    sprint.start_sprint()
    print(f"Sprint status: {sprint.status}")
    
    # Simulate progress
    sprint.prong_alpha.update_progress(0.5)
    sprint.prong_beta.update_coverage(75.0)
    sprint.prong_beta.mark_passing(True)
    sprint.prong_gamma.capture_insight("HTM patterns working well")
    sprint.completed_points = 20
    
    # Show status
    status = sprint.get_status_summary()
    print(f"\nSprint Status:")
    print(f"  Velocity: {status['velocity']:.1f}%")
    print(f"  Build Progress: {status['build_progress']:.1f}%")
    print(f"  Test Coverage: {status['test_coverage']:.1f}%")
    print(f"  Tests Passing: {status['tests_passing']}")
    print(f"  Insights Captured: {status['insights_captured']}")


def demo_feature_epic():
    """Demonstrate creating a feature epic."""
    print_section("Feature Epic Management")
    
    # Create custom epic
    epic = FeatureEpic(
        name="Custom Integration Feature",
        description="Integrate HTM components with MQTT broker"
    )
    
    # Add user stories
    story = Story(
        value="As a developer, I need MQTT integration so that components can communicate",
        points=8,
        priority=Priority.HIGH
    )
    epic.add_story(story)
    
    # Add tasks
    epic.add_task(Task("Setup MQTT broker", hours=3))
    epic.add_task(Task("Create message encoder", hours=5))
    epic.add_task(Task("Write integration tests", hours=3))
    
    # Add deliverable
    epic.add_deliverable(Deliverable(
        artifact="mqtt_integration.py",
        repository="FIELD",
        acceptance_criteria=[
            "Connects to MQTT broker",
            "Sends and receives messages",
            "Handles reconnection"
        ]
    ))
    
    print(f"Epic: {epic.name}")
    print(f"Description: {epic.description}")
    print(f"Total Story Points: {epic.total_story_points()}")
    print(f"Number of Tasks: {len(epic.tasks)}")
    
    # Mark story complete
    story.mark_complete()
    summary = epic.get_summary()
    print(f"\nProgress: {summary['progress']:.1f}%")
    print(f"Completed Stories: {summary['completed_stories']}/{summary['total_stories']}")


def demo_execution_pipeline():
    """Demonstrate execution pipeline."""
    print_section("Execution Pipeline")
    
    pipeline = ExecutionPipeline()
    
    # Add phases
    phase1 = Phase(
        name="Foundation",
        tasks=["Setup environment", "Install dependencies", "Create base structure"],
        exit_criteria=ExitCriteria(tests_passing=True)
    )
    
    phase2 = Phase(
        name="Development",
        tasks=["Implement features", "Write tests", "Code review"],
        exit_criteria=ExitCriteria(coverage=80.0, features_complete=True)
    )
    
    pipeline.add_phase(phase1)
    pipeline.add_phase(phase2)
    
    print(f"Pipeline created with {len(pipeline.sequence)} phases")
    
    # Start pipeline
    pipeline.start_pipeline()
    print(f"Current phase: {pipeline.current_phase}")
    
    # Complete tasks in phase 1
    current = pipeline.sequence[pipeline.current_phase]
    for task in current.tasks:
        current.complete_task(task)
    
    # Update exit criteria
    current.exit_criteria.tests_passing = True
    
    print(f"Phase 1 progress: {current.get_progress():.1f}%")
    print(f"Can exit phase 1: {current.can_exit()}")
    
    # Advance
    if pipeline.advance_phase():
        print(f"Advanced to: {pipeline.current_phase}")


def demo_anomaly_detection():
    """Demonstrate anomaly detection epic."""
    print_section("Anomaly Detection Epic")
    
    from trident_scrum.epics.anomaly_detection_epic import AnomalyDetector
    
    # Create epic
    epic = AnomalyDetectionEpic()
    print(f"Epic: {epic.name}")
    print(f"Description: {epic.description}")
    print(f"Total Story Points: {epic.total_story_points()}")
    print(f"Acceptance Criteria: {len(epic.acceptance_criteria)}")
    
    # Create detector
    detector = AnomalyDetector(input_size=10, column_count=128)
    
    # Test with sample data
    print("\nTesting anomaly detection:")
    
    # Normal patterns
    normal_data = [0.5] * 10
    result = detector.detect(normal_data, learn=True)
    print(f"Normal data - Anomaly score: {result['anomaly_score']:.2f}, Is anomaly: {result['is_anomaly']}")
    
    # Train with a few more normal patterns
    for _ in range(5):
        detector.detect(normal_data, learn=True)
    
    # Anomalous pattern
    anomaly_data = [0.9] * 10
    result = detector.detect(anomaly_data, learn=False)
    print(f"Anomalous data - Anomaly score: {result['anomaly_score']:.2f}, Is anomaly: {result['is_anomaly']}")


def demo_predictive_cache():
    """Demonstrate predictive cache epic."""
    print_section("Predictive Cache Epic")
    
    from trident_scrum.epics.predictive_cache_epic import HTMCache
    
    # Create epic
    epic = PredictiveCacheEpic()
    print(f"Epic: {epic.name}")
    print(f"Total Story Points: {epic.total_story_points()}")
    
    # Create cache
    cache = HTMCache(capacity=100, prediction_window=5)
    
    print("\nTesting predictive cache:")
    
    # Simulate access pattern
    keys = ["user_1", "user_2", "user_3", "user_1", "user_2", "user_3"]
    
    for key in keys:
        value = cache.get(key)
        if value is None:
            # Simulate fetch
            cache.put(key, f"data_for_{key}")
            print(f"Cache miss: {key} (fetched)")
        else:
            print(f"Cache hit: {key}")
    
    # Get metrics
    metrics = cache.get_metrics()
    print(f"\nCache Metrics:")
    print(f"  Hit Ratio: {metrics['hit_ratio']:.2%}")
    print(f"  Cache Size: {metrics['cache_size']}/{metrics['capacity']}")
    
    # Get prefetch recommendations
    prefetch = cache.prefetch()
    print(f"  Prefetch recommendations: {prefetch}")


def demo_ci_pipeline():
    """Demonstrate CI/CD pipeline."""
    print_section("CI/CD Pipeline")
    
    pipeline = CIPipeline()
    
    print("Running CI/CD pipeline...")
    print("Stages: build → test → deploy → monitor")
    
    success = pipeline.run()
    
    if success:
        print("\n✅ Pipeline completed successfully!")
    else:
        print("\n❌ Pipeline failed!")
    
    # Show status
    status = pipeline.get_status()
    print(f"\nPipeline Status: {status['pipeline_status']}")
    
    for stage_name, stage_info in status['stages'].items():
        print(f"  {stage_name}: {stage_info['status']}")


def demo_feedback_loop():
    """Demonstrate feedback loop."""
    print_section("Feedback Loop")
    
    # Create feedback loop
    loop = FeedbackLoop()
    
    # Add collector
    collector = MetricCollector(
        name="performance_metrics",
        metric_type="performance"
    )
    loop.add_collector(collector)
    
    # Add analyzer
    analyzer = PatternAnalyzer(
        name="trend_analyzer",
        analyzer_type="trend"
    )
    loop.add_analyzer(analyzer)
    
    # Add adjuster
    adjuster = SystemAdjuster(
        name="performance_tuner",
        adjuster_type="performance"
    )
    loop.add_adjuster(adjuster)
    
    print(f"Feedback loop configured:")
    print(f"  Collectors: {len(loop.collectors)}")
    print(f"  Analyzers: {len(loop.analyzers)}")
    print(f"  Adjusters: {len(loop.adjusters)}")
    
    # Execute cycle
    print("\nExecuting feedback cycle...")
    result = loop.execute_cycle()
    
    print(f"Cycle {result['cycle']} completed:")
    print(f"  Metrics collected: {result['metrics_collected']}")
    print(f"  Patterns detected: {result['patterns_detected']}")
    print(f"  Adjustments applied: {result['adjustments_applied']}")


def main():
    """Run all demonstrations."""
    print("\n" + "="*60)
    print("  TRIDENT SCRUM FRAMEWORK - COMPLETE DEMONSTRATION")
    print("="*60)
    
    demo_sprint_creation()
    demo_feature_epic()
    demo_execution_pipeline()
    demo_anomaly_detection()
    demo_predictive_cache()
    demo_ci_pipeline()
    demo_feedback_loop()
    
    print("\n" + "="*60)
    print("  All demonstrations completed successfully! ✅")
    print("="*60 + "\n")


if __name__ == "__main__":
    main()
