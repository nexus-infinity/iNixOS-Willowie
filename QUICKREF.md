# Trident Scrum Quick Reference

## Installation

### Option 1: Full System
```bash
git clone https://github.com/nexus-infinity/iNixOS-Willowie.git
cd iNixOS-Willowie
git checkout copilot/setup-nixos-declarative-install
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
sudo nixos-rebuild switch --flake .#trident-dev
```

### Option 2: Development Shell
```bash
git clone https://github.com/nexus-infinity/iNixOS-Willowie.git
cd iNixOS-Willowie
git checkout copilot/setup-nixos-declarative-install
nix develop .#trident
```

## Quick Start

```bash
# Run tests
cd trident_scrum
python3 tests/test_sprint_trident.py

# Run demo
python3 examples/complete_demo.py

# Setup virtual environment
python3 -m venv venv
source venv/bin/activate
pip install pytest pytest-cov
```

## Basic Usage

### Create a Sprint
```python
from trident_scrum import SprintTrident

sprint = SprintTrident(
    sprint_number=1,
    goal="Your sprint goal",
    capacity=40  # story points
)

sprint.start_sprint()
sprint.prong_alpha.update_progress(0.5)  # Build 50% done
sprint.prong_beta.update_coverage(80.0)  # 80% test coverage
```

### Use Anomaly Detection
```python
from trident_scrum.epics.anomaly_detection_epic import AnomalyDetector

detector = AnomalyDetector(input_size=100)
result = detector.detect(data, learn=True)

if result['is_anomaly']:
    print(f"Anomaly! Score: {result['anomaly_score']}")
```

### Use Predictive Cache
```python
from trident_scrum.epics.predictive_cache_epic import HTMCache

cache = HTMCache(capacity=1000)
value = cache.get(key)
if value is None:
    value = fetch_data(key)
    cache.put(key, value)
```

### Run CI/CD Pipeline
```python
from trident_scrum.pipelines import CIPipeline

pipeline = CIPipeline()
success = pipeline.run()
```

## GitHub Copilot CLI

```bash
# Install
npm install -g @githubnext/github-copilot-cli

# Use
?? how to compress files
git? what does rebase do
gh? create a pull request
```

## Framework Structure

```
trident_scrum/
├── core/           # Core framework
│   ├── sprint_trident.py
│   ├── feature_epic.py
│   ├── execution_pipeline.py
│   ├── metrics.py
│   └── feedback_loop.py
├── epics/          # Epic implementations
│   ├── anomaly_detection_epic.py
│   └── predictive_cache_epic.py
├── pipelines/      # CI/CD pipelines
│   ├── ci_pipeline.py
│   └── sprint_pipelines.py
├── tests/          # Test suite
├── examples/       # Usage examples
└── README.md       # Full documentation
```

## Configuration Options

```nix
services.trident-workspace = {
  enable = true;
  userName = "developer";
  workspaceDir = "/home/developer/workspace";
  enableCopilot = true;
  pythonVersion = "python311";
};
```

## Testing

```bash
# Run all tests
python3 -m pytest tests/

# With coverage
python3 -m pytest --cov=trident_scrum tests/

# Specific test
python3 tests/test_sprint_trident.py
```

## Documentation

- **Full Guide**: `TRIDENT_SCRUM_GUIDE.md`
- **Framework README**: `trident_scrum/README.md`
- **Examples**: `trident_scrum/examples/complete_demo.py`
- **Tests**: `trident_scrum/tests/`

## Key Concepts

### Three Prongs
1. **Alpha (Build)**: Feature development
2. **Beta (Test)**: Validation and testing
3. **Gamma (Learn)**: Feedback and adaptation

### HTM Principles
- Spatial Pooling: Sparse distributed representations
- Temporal Memory: Sequential pattern learning
- Anomaly Detection: Unexpected pattern identification
- Online Learning: Continuous adaptation

## Support

For help:
1. Read `TRIDENT_SCRUM_GUIDE.md`
2. Run examples: `python3 examples/complete_demo.py`
3. Check tests: `python3 tests/test_sprint_trident.py`
4. Review code in `trident_scrum/`

---

**Version**: 0.1.0  
**Branch**: copilot/setup-nixos-declarative-install  
**Status**: ✅ Ready for use
