# Trident Scrum NixOS Development Workspace

## Overview

This branch provides a complete NixOS-based development environment for the Trident Scrum framework, which implements a three-pronged agile methodology inspired by Hierarchical Temporal Memory (HTM) principles from NuPIC Legacy.

## What's Included

### 1. Trident Scrum Framework (`trident_scrum/`)

A comprehensive Python framework for agile development with HTM-inspired components:

- **Core Framework**:
  - `SprintTrident`: Three-pronged sprint management (Build, Test, Learn)
  - `FeatureEpic`: User story and task organization
  - `ExecutionPipeline`: Sequential phase execution with exit criteria
  - `VelocityTracker`: Sprint velocity and capacity planning
  - `FeedbackLoop`: Continuous learning and system adaptation

- **Epic Implementations**:
  - `AnomalyDetectionEpic`: HTM-inspired real-time anomaly detection
  - `PredictiveCacheEpic`: Temporal sequence learning for optimized data access

- **CI/CD Integration**:
  - `CIPipeline`: Build, test, deploy, and monitor stages
  - Sprint Pipelines: Sprint 1, 2, 3 implementations

### 2. NixOS Workspace Module (`modules/services/trident-workspace.nix`)

A declarative NixOS service that sets up a complete development environment:

- **Languages & Runtimes**:
  - Python 3.11 with pip, virtualenv
  - Node.js 20 with npm, TypeScript
  - Go (latest stable)

- **Development Tools**:
  - Git and GitHub CLI (`gh`)
  - Docker and docker-compose
  - vim, neovim, tmux, zsh
  - NixOS development tools (nixpkgs-fmt, nix-tree)

- **Optional**: GitHub Copilot CLI integration

### 3. NixOS Configurations

Three NixOS system configurations in `flake.nix`:

1. **BearsiMac**: Original configuration
2. **willowie**: Consciousness system configuration
3. **trident-dev**: Development workspace configuration (NEW)

### 4. Development Shells

Two Nix development shells:

1. **default**: Basic shell for NixOS operations
2. **trident**: Full Trident Scrum development environment

## Installation Options

### Option 1: Full NixOS System (Recommended for dedicated machines)

Build and switch to the Trident development system:

```bash
# Clone repository
git clone https://github.com/nexus-infinity/iNixOS-Willowie.git
cd iNixOS-Willowie
git checkout copilot/setup-nixos-declarative-install

# Generate hardware configuration
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix

# Build the Trident development system
sudo nixos-rebuild switch --flake .#trident-dev
```

This will:
- Create a `developer` user with development tools
- Setup workspace at `/home/developer/workspace`
- Install Python, Node.js, Go, Docker, and dev tools
- Optionally install GitHub Copilot CLI
- Copy the Trident Scrum framework to the workspace

### Option 2: Development Shell (Recommended for existing NixOS systems)

Use Nix development shell without changing system configuration:

```bash
# Clone repository
git clone https://github.com/nexus-infinity/iNixOS-Willowie.git
cd iNixOS-Willowie
git checkout copilot/setup-nixos-declarative-install

# Enter Trident development shell
nix develop .#trident
```

This provides:
- All development tools (Python, Node.js, Go, GitHub CLI)
- No system-level changes
- Perfect for testing or temporary development

### Option 3: Add to Existing Configuration

Add the Trident workspace to your existing NixOS configuration:

```nix
{
  imports = [
    /path/to/iNixOS-Willowie/modules/services/trident-workspace.nix
  ];
  
  services.trident-workspace = {
    enable = true;
    userName = "your-username";
    workspaceDir = "/home/your-username/workspace";
    enableCopilot = true;  # Optional
    pythonVersion = "python311";
  };
}
```

Then rebuild:

```bash
sudo nixos-rebuild switch
```

## Quick Start

### Using the Framework

After installation, the Trident Scrum framework is available:

```bash
# Navigate to workspace
cd ~/workspace/trident_scrum  # Or wherever you installed it

# Run tests
python3 tests/test_sprint_trident.py

# Run complete demonstration
python3 examples/complete_demo.py

# Create virtual environment for development
python3 -m venv venv
source venv/bin/activate
pip install pytest pytest-cov
```

### Example: Creating a Sprint

```python
from trident_scrum import SprintTrident
from trident_scrum.epics import AnomalyDetectionEpic

# Create sprint
sprint = SprintTrident(
    sprint_number=1,
    goal="Establish HTM foundation layers",
    capacity=40
)

# Add epic
epic = AnomalyDetectionEpic()

# Start sprint
sprint.start_sprint()

# Track progress
sprint.prong_alpha.update_progress(0.75)  # 75% build complete
sprint.prong_beta.update_coverage(85.0)   # 85% test coverage
sprint.prong_gamma.capture_insight("HTM converging well")

# Check status
status = sprint.get_status_summary()
print(f"Velocity: {status['velocity']:.1f}%")
```

### Using GitHub Copilot CLI (if enabled)

After installation and setup:

```bash
# Install Copilot CLI (if not auto-installed)
npm install -g @githubnext/github-copilot-cli

# Authenticate
gh auth login

# Use Copilot
?? how to compress a directory  # Get command suggestions
git? what does rebase do        # Git-specific help
gh? create a pull request       # GitHub CLI help
```

## Architecture

### Sacred Geometry Integration

The Trident Scrum framework integrates with iNixOS-Willowie's sacred geometry architecture:

```
          Metatron Cube (ExecutionPipeline)
                    |
         +----------+----------+
         |          |          |
    Build      Test       Learn
   (Alpha)    (Beta)     (Gamma)
```

### HTM Principles

Based on Hierarchical Temporal Memory:

1. **Spatial Pooling**: Convert inputs to sparse distributed representations
2. **Temporal Memory**: Learn and predict temporal sequences
3. **Anomaly Detection**: Identify unexpected patterns
4. **Online Learning**: Continuously adapt to new data

### Three-Pronged Approach

**Prong Alpha (Build)**: Feature development pipeline
- Tracks features and implementation progress
- Manages build artifacts and deployments

**Prong Beta (Test)**: Validation layer
- Test suite management
- Coverage tracking
- Quality assurance

**Prong Gamma (Learn)**: Feedback integration
- Captures insights from each sprint
- Applies adaptations based on learning
- Tracks improvement metrics

## Project Structure

```
iNixOS-Willowie/
├── trident_scrum/              # Trident Scrum framework
│   ├── __init__.py
│   ├── core/                   # Core framework components
│   │   ├── sprint_trident.py
│   │   ├── feature_epic.py
│   │   ├── execution_pipeline.py
│   │   ├── metrics.py
│   │   └── feedback_loop.py
│   ├── epics/                  # Epic implementations
│   │   ├── anomaly_detection_epic.py
│   │   └── predictive_cache_epic.py
│   ├── pipelines/              # Pipeline implementations
│   │   ├── ci_pipeline.py
│   │   └── sprint_pipelines.py
│   ├── tests/                  # Test suite
│   │   └── test_sprint_trident.py
│   ├── examples/               # Usage examples
│   │   └── complete_demo.py
│   └── README.md
│
├── modules/services/
│   └── trident-workspace.nix   # NixOS workspace module
│
├── flake.nix                   # Updated with trident-dev config
└── TRIDENT_SCRUM_GUIDE.md     # This file
```

## Configuration Options

### Trident Workspace Service

```nix
services.trident-workspace = {
  # Enable the workspace
  enable = true;
  
  # Username for development
  userName = "developer";
  
  # Workspace directory path
  workspaceDir = "/home/developer/workspace";
  
  # Enable GitHub Copilot CLI
  enableCopilot = true;
  
  # Python version to use
  pythonVersion = "python311";  # or "python39", "python310", etc.
};
```

### System Requirements

- **NixOS**: 23.11 or later
- **RAM**: 4GB minimum, 8GB+ recommended
- **Disk**: 10GB free space minimum
- **Network**: Internet connection for package downloads

## Development Workflow

### 1. Sprint Planning

```python
from trident_scrum.pipelines import Sprint1

# Create sprint with pre-configured epics
sprint = Sprint1()

# Review epics
for epic in sprint.get_epics():
    print(f"{epic.name}: {epic.total_story_points()} points")
```

### 2. Development

```python
from trident_scrum.core.execution_pipeline import ExecutionPipeline

# Setup pipeline
pipeline = sprint.pipeline
pipeline.start_pipeline()

# Work through phases
while pipeline.current_phase:
    phase = pipeline.sequence[pipeline.current_phase]
    # Complete tasks...
    pipeline.advance_phase()
```

### 3. Testing

```bash
# Run framework tests
python3 -m pytest tests/

# Run with coverage
python3 -m pytest --cov=trident_scrum tests/

# Run specific test
python3 -m pytest tests/test_sprint_trident.py
```

### 4. CI/CD

```python
from trident_scrum.pipelines import CIPipeline

# Run CI/CD pipeline
pipeline = CIPipeline()
success = pipeline.run()

# Check results
if success:
    status = pipeline.get_status()
    # Deploy...
```

### 5. Learning & Adaptation

```python
from trident_scrum.core.feedback_loop import FeedbackLoop

# Setup feedback loop
loop = FeedbackLoop()
# Add collectors, analyzers, adjusters...

# Execute learning cycle
result = loop.execute_cycle()
```

## Testing

Run the complete test suite:

```bash
# Basic tests
cd trident_scrum
python3 tests/test_sprint_trident.py

# With pytest (if installed)
python3 -m pytest tests/ -v

# With coverage
python3 -m pytest --cov=trident_scrum --cov-report=html tests/
```

## Examples

See `trident_scrum/examples/complete_demo.py` for comprehensive examples of:
- Sprint creation and management
- Feature epic development
- Execution pipeline usage
- Anomaly detection
- Predictive caching
- CI/CD integration
- Feedback loops

Run the demo:

```bash
cd trident_scrum
python3 examples/complete_demo.py
```

## Troubleshooting

### Python Module Not Found

```bash
# Set PYTHONPATH
export PYTHONPATH=/path/to/iNixOS-Willowie:$PYTHONPATH

# Or use development shell
nix develop .#trident
```

### Copilot CLI Not Installing

```bash
# Manual installation
npm install -g @githubnext/github-copilot-cli

# Check installation
which github-copilot-cli

# Setup aliases manually
eval "$(github-copilot-cli alias -- "$0")"
```

### Permission Issues

```bash
# Fix workspace permissions
sudo chown -R $USER:users ~/workspace

# Fix trident_scrum permissions
chmod -R u+rw trident_scrum/
```

## Contributing

This is part of the iNixOS-Willowie project. Follow the repository's contribution guidelines:

1. Use the Trident Scrum framework for development
2. Follow sacred geometry architectural patterns
3. Write tests for new features
4. Update documentation

## References

- [NuPIC Legacy](https://github.com/numenta/nupic) - HTM implementation inspiration
- [Hierarchical Temporal Memory](https://numenta.com/resources/htm/) - Theoretical foundation
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Scrum Guide](https://scrumguides.org/)
- [GitHub Copilot CLI](https://githubnext.com/projects/copilot-cli/)

## Support

For issues or questions:
1. Check the framework README: `trident_scrum/README.md`
2. Run the examples: `python3 trident_scrum/examples/complete_demo.py`
3. Review test cases: `trident_scrum/tests/`
4. Consult the main repository documentation

---

**Status**: ✅ Implementation complete  
**Version**: 0.1.0  
**Branch**: `copilot/setup-nixos-declarative-install`  
**NixOS Version**: 23.11+  
**Framework**: Trident Scrum with HTM principles
