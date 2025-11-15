"""
Tests for Sprint Trident core functionality.
"""

import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from trident_scrum.core.sprint_trident import SprintTrident, BuildPipeline, TestHarness, LearningLoop


def test_build_pipeline_initialization():
    """Test BuildPipeline initialization."""
    pipeline = BuildPipeline()
    assert pipeline.status == "initialized"
    assert pipeline.progress == 0.0
    assert len(pipeline.features) == 0


def test_build_pipeline_progress():
    """Test BuildPipeline progress tracking."""
    pipeline = BuildPipeline()
    pipeline.update_progress(0.5)
    assert pipeline.progress == 0.5
    assert pipeline.status == "in_progress"
    
    pipeline.update_progress(1.0)
    assert pipeline.progress == 1.0
    assert pipeline.status == "completed"


def test_test_harness():
    """Test TestHarness functionality."""
    harness = TestHarness()
    harness.add_test_suite("unit_tests")
    harness.add_test_suite("integration_tests")
    assert len(harness.test_suites) == 2
    
    harness.update_coverage(85.0)
    assert harness.coverage == 85.0
    
    harness.mark_passing(True)
    assert harness.passing is True


def test_learning_loop():
    """Test LearningLoop functionality."""
    loop = LearningLoop()
    loop.capture_insight("Test insight")
    assert len(loop.insights) == 1
    
    loop.apply_adaptation("Test adaptation")
    assert len(loop.adaptations) == 1
    
    loop.track_metric("velocity", 42.0)
    assert loop.metrics["velocity"] == 42.0


def test_sprint_trident_initialization():
    """Test SprintTrident initialization."""
    sprint = SprintTrident(
        sprint_number=1,
        goal="Test goal",
        capacity=40
    )
    
    assert sprint.sprint_number == 1
    assert sprint.goal == "Test goal"
    assert sprint.capacity == 40
    assert sprint.status == "planning"
    assert sprint.start_date is not None


def test_sprint_lifecycle():
    """Test sprint lifecycle."""
    sprint = SprintTrident(
        sprint_number=1,
        goal="Test sprint",
        capacity=40
    )
    
    # Start sprint
    sprint.start_sprint()
    assert sprint.status == "active"
    
    # Update progress
    sprint.completed_points = 30
    sprint.prong_alpha.update_progress(0.75)
    sprint.prong_beta.update_coverage(80.0)
    sprint.prong_beta.mark_passing(True)
    
    # Check velocity
    velocity = sprint.get_velocity()
    assert velocity == 75.0  # 30/40 * 100
    
    # Complete sprint
    sprint.complete_sprint()
    assert sprint.status == "completed"
    assert sprint.end_date is not None


def test_sprint_status_summary():
    """Test sprint status summary."""
    sprint = SprintTrident(
        sprint_number=1,
        goal="Test sprint",
        capacity=40
    )
    
    sprint.start_sprint()
    sprint.completed_points = 20
    sprint.prong_alpha.update_progress(0.5)
    sprint.prong_beta.update_coverage(75.0)
    sprint.prong_beta.mark_passing(True)
    sprint.prong_gamma.capture_insight("Test insight")
    
    summary = sprint.get_status_summary()
    
    assert summary['sprint_number'] == 1
    assert summary['goal'] == "Test sprint"
    assert summary['status'] == "active"
    assert summary['velocity'] == 50.0
    assert summary['build_progress'] == 50.0
    assert summary['test_coverage'] == 75.0
    assert summary['tests_passing'] is True
    assert summary['insights_captured'] == 1


if __name__ == "__main__":
    # Run tests manually if pytest not available
    print("Running Sprint Trident tests...")
    
    test_build_pipeline_initialization()
    print("✓ BuildPipeline initialization")
    
    test_build_pipeline_progress()
    print("✓ BuildPipeline progress")
    
    test_test_harness()
    print("✓ TestHarness")
    
    test_learning_loop()
    print("✓ LearningLoop")
    
    test_sprint_trident_initialization()
    print("✓ SprintTrident initialization")
    
    test_sprint_lifecycle()
    print("✓ Sprint lifecycle")
    
    test_sprint_status_summary()
    print("✓ Sprint status summary")
    
    print("\nAll tests passed! ✅")
