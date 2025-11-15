# Trident Scrum Framework

A three-pronged agile development framework inspired by Hierarchical Temporal Memory (HTM) principles from NuPIC Legacy. Designed for the iNixOS-Willowie sacred geometry architecture.

## Overview

Trident Scrum provides an object-oriented approach to sprint planning and execution with three parallel streams:

- **Prong Alpha (Build)**: Feature development pipeline
- **Prong Beta (Test)**: Validation and testing harness
- **Prong Gamma (Learn)**: Feedback integration and continuous learning

## Features

### Core Framework
- **SprintTrident**: Three-pronged sprint management
- **FeatureEpic**: User story and task organization
- **ExecutionPipeline**: Sequential phase execution with exit criteria
- **VelocityTracker**: Sprint velocity and capacity planning
- **FeedbackLoop**: Continuous learning and system adaptation

### Epic Implementations
- **Anomaly Detection**: HTM-inspired real-time anomaly detection for FIELD repository
- **Predictive Cache**: Temporal sequence learning for optimized data access

### CI/CD Integration
- **CIPipeline**: Build, test, deploy, and monitor stages
- **Sprint Pipelines**: Sprint 1, 2, 3 implementations with clear goals and deliverables

## Installation

### NixOS Integration

Add to your `flake.nix` or configuration:

```nix
{
  # Import the trident workspace module
  imports = [
    ./modules/services/trident-workspace.nix
  ];
  
  # Enable the workspace
  services.trident-workspace = {
    enable = true;
    userName = "developer";
    workspaceDir = "/home/developer/workspace";
    enableCopilot = true;
    pythonVersion = "python311";
  };
}
```

Then rebuild your NixOS system:

```bash
sudo nixos-rebuild switch --flake .#yourConfiguration
```

### Manual Installation

```bash
# Clone the repository
cd /path/to/workspace
cp -r /path/to/iNixOS-Willowie/trident_scrum .

# Create Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install pytest pytest-cov dataclasses-json pyyaml
```

## Quick Start

### Example: Creating a Sprint

```python
from trident_scrum import SprintTrident
from trident_scrum.epics import AnomalyDetectionEpic, PredictiveCacheEpic

# Create sprint
sprint = SprintTrident(
    sprint_number=1,
    goal="Establish HTM foundation layers",
    capacity=40  # story points
)

# Add epics
anomaly_epic = AnomalyDetectionEpic()
cache_epic = PredictiveCacheEpic()

# Start sprint
sprint.start_sprint()

# Update progress
sprint.prong_alpha.update_progress(0.5)  # 50% build complete
sprint.prong_beta.update_coverage(75.0)  # 75% test coverage
sprint.prong_gamma.capture_insight("HTM patterns emerging in data")

# Check status
status = sprint.get_status_summary()
print(f"Sprint velocity: {status['velocity']:.1f}%")
```

### Example: Using Anomaly Detection

```python
from trident_scrum.epics.anomaly_detection_epic import AnomalyDetector

# Create detector
detector = AnomalyDetector(input_size=100, column_count=2048)

# Detect anomalies in data stream
for data_point in data_stream:
    result = detector.detect(data_point, learn=True)
    
    if result['is_anomaly']:
        print(f"Anomaly detected! Score: {result['anomaly_score']:.2f}")
        print(f"Confidence: {result['confidence']:.2f}")
```

### Example: Using Predictive Cache

```python
from trident_scrum.epics.predictive_cache_epic import HTMCache

# Create cache
cache = HTMCache(capacity=1000, prediction_window=10)

# Use cache
value = cache.get("user_profile_123")
if value is None:
    value = fetch_from_database("user_profile_123")
    cache.put("user_profile_123", value)

# Get prefetch recommendations
to_prefetch = cache.prefetch()
for key in to_prefetch:
    asyncio.create_task(prefetch_data(key))

# Monitor performance
metrics = cache.get_metrics()
print(f"Cache hit ratio: {metrics['hit_ratio']:.2%}")
```

### Example: Execution Pipeline

```python
from trident_scrum.core.execution_pipeline import ExecutionPipeline, Phase, ExitCriteria

# Create pipeline
pipeline = ExecutionPipeline()

# Add phases
pipeline.add_phase(Phase(
    name="Foundation",
    tasks=["Setup HTM core", "Create encoders", "Establish tests"],
    exit_criteria=ExitCriteria(coverage=80.0, tests_passing=True)
))

pipeline.add_phase(Phase(
    name="Development",
    tasks=["Implement features", "Integration testing"],
    exit_criteria=ExitCriteria(features_complete=True, integrated=True)
))

# Execute pipeline
pipeline.start_pipeline()

# Mark tasks complete
current_phase = pipeline.sequence[pipeline.current_phase]
current_phase.complete_task("Setup HTM core")

# Advance when ready
if pipeline.advance_phase():
    print("Advanced to next phase!")
```

### Example: CI/CD Pipeline

```python
from trident_scrum.pipelines import CIPipeline

# Create and run pipeline
pipeline = CIPipeline()
success = pipeline.run()

if success:
    print("Pipeline completed successfully!")
    status = pipeline.get_status()
    print(f"All stages: {status['stages'].keys()}")
else:
    print("Pipeline failed")
```

## Architecture

### Sacred Geometry Integration

Trident Scrum aligns with the iNixOS-Willowie sacred geometry architecture:

- **Metatron Cube**: Central coordination (ExecutionPipeline)
- **Chakra System**: Feature organization (Epics)
- **Hexagonal Hive**: Distributed execution (FeedbackLoop)
- **Frequency Bridge**: Continuous integration (CIPipeline)

### HTM Principles

Inspired by Hierarchical Temporal Memory:

1. **Spatial Pooling**: Convert inputs to sparse distributed representations
2. **Temporal Memory**: Learn and predict temporal sequences
3. **Anomaly Detection**: Identify unexpected patterns
4. **Online Learning**: Continuously adapt to new data

## Project Structure

```
trident_scrum/
├── __init__.py                 # Main module
├── core/                       # Core framework
│   ├── sprint_trident.py      # Sprint management
│   ├── feature_epic.py        # Epic and story management
│   ├── execution_pipeline.py  # Phase execution
│   ├── metrics.py             # Velocity and quality tracking
│   └── feedback_loop.py       # Continuous learning
├── epics/                      # Epic implementations
│   ├── anomaly_detection_epic.py
│   └── predictive_cache_epic.py
├── pipelines/                  # Pipeline implementations
│   ├── ci_pipeline.py         # CI/CD stages
│   └── sprint_pipelines.py    # Sprint 1, 2, 3
└── tests/                      # Test suite
    └── (test files)
```

## Testing

Run the test suite:

```bash
# Activate virtual environment
source venv/bin/activate

# Run all tests
python -m pytest tests/

# Run with coverage
python -m pytest --cov=trident_scrum tests/

# Run specific test file
python -m pytest tests/test_sprint_trident.py
```

## Development

### Adding a New Epic

1. Create epic class inheriting from `FeatureEpic`
2. Define user stories with acceptance criteria
3. Define tasks with time estimates
4. Define deliverables with verification criteria
5. Add to `epics/__init__.py`

Example:

```python
from trident_scrum.core.feature_epic import FeatureEpic, Story, Task, Deliverable

class MyNewEpic(FeatureEpic):
    def __init__(self):
        super().__init__(
            name="My New Feature",
            description="Description of the feature"
        )
        
        # Add user stories
        self.add_story(Story(
            value="As a user, I need...",
            points=5
        ))
        
        # Add tasks
        self.add_task(Task("Implement X", hours=8))
        
        # Add deliverables
        self.add_deliverable(Deliverable(
            artifact="my_feature.py",
            repository="MyRepo",
            acceptance_criteria=["Criterion 1", "Criterion 2"]
        ))
```

### Code Style

- Follow PEP 8 for Python code
- Use type hints for function signatures
- Document classes and methods with docstrings
- Keep modules focused and single-purpose
- Write tests for new features

## GitHub Copilot CLI Integration

When the Trident workspace is enabled with Copilot support:

```bash
# Get command suggestions
?? how to compress a directory

# Explain a command
git? what does git rebase -i do

# GitHub-specific help
gh? how to create a pull request
```

## Contributing

This framework is part of the iNixOS-Willowie project. Follow the repository's contribution guidelines and sacred geometry principles.

## License

Part of iNixOS-Willowie project. See repository license for details.

## References

- [NuPIC Legacy](https://github.com/numenta/nupic) - HTM implementation inspiration
- [Hierarchical Temporal Memory](https://numenta.com/resources/htm/) - Theoretical foundation
- [iNixOS-Willowie](https://github.com/nexus-infinity/iNixOS-Willowie) - Host repository
- [Scrum Guide](https://scrumguides.org/) - Agile methodology basis

---

**Status**: ✅ Framework implemented and ready for use  
**Version**: 0.1.0  
**Target**: NixOS-based development environments  
**Integration**: Sacred geometry architecture aligned
