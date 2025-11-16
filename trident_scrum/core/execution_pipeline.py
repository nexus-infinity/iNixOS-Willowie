"""
Execution Pipeline - Sequential Phase Management
=================================================

Manages ordered execution of development phases with exit criteria.
"""

from typing import List, Dict, Any, Optional
from dataclasses import dataclass, field
from collections import OrderedDict


@dataclass
class ExitCriteria:
    """Exit criteria for a phase."""
    
    coverage: Optional[float] = None
    tests_passing: Optional[bool] = None
    features_complete: Optional[bool] = None
    integrated: Optional[bool] = None
    performance_targets_met: Optional[bool] = None
    custom_criteria: Dict[str, bool] = field(default_factory=dict)
    
    def is_met(self) -> bool:
        """Check if all defined criteria are met."""
        criteria_checks = []
        
        if self.coverage is not None:
            criteria_checks.append(self.coverage >= 80.0)  # Default threshold
        
        if self.tests_passing is not None:
            criteria_checks.append(self.tests_passing)
        
        if self.features_complete is not None:
            criteria_checks.append(self.features_complete)
        
        if self.integrated is not None:
            criteria_checks.append(self.integrated)
        
        if self.performance_targets_met is not None:
            criteria_checks.append(self.performance_targets_met)
        
        criteria_checks.extend(self.custom_criteria.values())
        
        return all(criteria_checks) if criteria_checks else False
    
    def get_status(self) -> Dict[str, Any]:
        """Get detailed status of criteria."""
        return {
            'coverage': self.coverage,
            'tests_passing': self.tests_passing,
            'features_complete': self.features_complete,
            'integrated': self.integrated,
            'performance_targets_met': self.performance_targets_met,
            'custom_criteria': self.custom_criteria,
            'is_met': self.is_met(),
        }


@dataclass
class Phase:
    """Development phase with tasks and exit criteria."""
    
    name: str
    tasks: List[str]
    exit_criteria: ExitCriteria
    status: str = "pending"
    completed_tasks: List[str] = field(default_factory=list)
    
    def start(self) -> None:
        """Start phase execution."""
        self.status = "in_progress"
    
    def complete_task(self, task: str) -> None:
        """Mark a task as complete."""
        if task in self.tasks and task not in self.completed_tasks:
            self.completed_tasks.append(task)
    
    def can_exit(self) -> bool:
        """Check if phase can exit based on criteria."""
        return self.exit_criteria.is_met()
    
    def complete(self) -> None:
        """Complete phase if exit criteria are met."""
        if self.can_exit():
            self.status = "completed"
        else:
            raise ValueError(f"Phase {self.name} exit criteria not met")
    
    def get_progress(self) -> float:
        """Calculate phase progress percentage."""
        if not self.tasks:
            return 0.0
        return (len(self.completed_tasks) / len(self.tasks)) * 100.0


class ExecutionPipeline:
    """
    Sequential execution pipeline for development phases.
    
    Ensures proper ordering and validation of development workflow
    aligned with Trident Scrum methodology.
    """
    
    def __init__(self):
        self.sequence: OrderedDict[str, Phase] = OrderedDict()
        self.current_phase: Optional[str] = None
    
    def add_phase(self, phase: Phase) -> None:
        """Add phase to pipeline."""
        self.sequence[phase.name] = phase
    
    def start_pipeline(self) -> None:
        """Start pipeline execution from first phase."""
        if self.sequence:
            first_phase_name = next(iter(self.sequence))
            self.current_phase = first_phase_name
            self.sequence[first_phase_name].start()
    
    def advance_phase(self) -> bool:
        """
        Advance to next phase if current phase is complete.
        
        Returns:
            bool: True if advanced, False if cannot advance
        """
        if not self.current_phase:
            return False
        
        current = self.sequence[self.current_phase]
        
        if not current.can_exit():
            return False
        
        current.complete()
        
        # Move to next phase
        phase_names = list(self.sequence.keys())
        current_index = phase_names.index(self.current_phase)
        
        if current_index + 1 < len(phase_names):
            next_phase_name = phase_names[current_index + 1]
            self.current_phase = next_phase_name
            self.sequence[next_phase_name].start()
            return True
        else:
            # Pipeline complete
            self.current_phase = None
            return False
    
    def get_overall_progress(self) -> float:
        """Calculate overall pipeline progress."""
        if not self.sequence:
            return 0.0
        
        total_phases = len(self.sequence)
        completed_phases = sum(1 for p in self.sequence.values() if p.status == "completed")
        
        return (completed_phases / total_phases) * 100.0
    
    def get_status(self) -> Dict[str, Any]:
        """Get comprehensive pipeline status."""
        return {
            'total_phases': len(self.sequence),
            'current_phase': self.current_phase,
            'completed_phases': sum(1 for p in self.sequence.values() if p.status == "completed"),
            'overall_progress': self.get_overall_progress(),
            'phases': {
                name: {
                    'status': phase.status,
                    'progress': phase.get_progress(),
                    'can_exit': phase.can_exit(),
                }
                for name, phase in self.sequence.items()
            }
        }
