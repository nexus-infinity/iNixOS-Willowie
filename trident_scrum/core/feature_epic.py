"""
Feature Epic - User Story and Task Management
==============================================

Manages epics, user stories, tasks, and deliverables.
"""

from typing import List, Optional
from dataclasses import dataclass, field
from enum import Enum


class Priority(Enum):
    """Story priority levels."""
    LOW = 1
    MEDIUM = 2
    HIGH = 3
    CRITICAL = 4


@dataclass
class Story:
    """User story with acceptance criteria."""
    
    value: str
    points: int
    priority: Priority = Priority.MEDIUM
    status: str = "backlog"
    acceptance_criteria: List[str] = field(default_factory=list)
    
    def mark_complete(self) -> None:
        """Mark story as complete."""
        self.status = "completed"
    
    def is_complete(self) -> bool:
        """Check if story is complete."""
        return self.status == "completed"


@dataclass
class Task:
    """Development task."""
    
    description: str
    hours: int
    assignee: Optional[str] = None
    status: str = "todo"
    
    def start(self, assignee: Optional[str] = None) -> None:
        """Start working on task."""
        self.status = "in_progress"
        if assignee:
            self.assignee = assignee
    
    def complete(self) -> None:
        """Mark task as complete."""
        self.status = "done"


@dataclass
class Deliverable:
    """Sprint deliverable with acceptance criteria."""
    
    artifact: str
    repository: str
    acceptance_criteria: List[str]
    status: str = "pending"
    
    def verify(self) -> bool:
        """Verify deliverable meets acceptance criteria."""
        # In real implementation, this would run actual verification
        return self.status == "verified"
    
    def mark_verified(self) -> None:
        """Mark deliverable as verified."""
        self.status = "verified"


class FeatureEpic:
    """
    Feature epic with user stories, tasks, and deliverables.
    
    Organizes work into coherent feature sets aligned with
    the sacred geometry architecture of iNixOS-Willowie.
    """
    
    def __init__(self, name: str, description: str = ""):
        self.name = name
        self.description = description
        self.user_stories: List[Story] = []
        self.tasks: List[Task] = []
        self.acceptance_criteria: List[str] = []
        self.definition_of_done: List[str] = []
        self.deliverables: List[Deliverable] = []
    
    def add_story(self, story: Story) -> None:
        """Add user story to epic."""
        self.user_stories.append(story)
    
    def add_task(self, task: Task) -> None:
        """Add task to epic."""
        self.tasks.append(task)
    
    def add_deliverable(self, deliverable: Deliverable) -> None:
        """Add deliverable to epic."""
        self.deliverables.append(deliverable)
    
    def total_story_points(self) -> int:
        """Calculate total story points."""
        return sum(story.points for story in self.user_stories)
    
    def completed_story_points(self) -> int:
        """Calculate completed story points."""
        return sum(story.points for story in self.user_stories if story.is_complete())
    
    def progress_percentage(self) -> float:
        """Calculate progress as percentage."""
        total = self.total_story_points()
        if total == 0:
            return 0.0
        return (self.completed_story_points() / total) * 100.0
    
    def get_summary(self) -> dict:
        """Get epic summary."""
        return {
            'name': self.name,
            'description': self.description,
            'total_stories': len(self.user_stories),
            'completed_stories': sum(1 for s in self.user_stories if s.is_complete()),
            'total_points': self.total_story_points(),
            'completed_points': self.completed_story_points(),
            'progress': self.progress_percentage(),
            'total_tasks': len(self.tasks),
            'completed_tasks': sum(1 for t in self.tasks if t.status == "done"),
            'deliverables': len(self.deliverables),
            'verified_deliverables': sum(1 for d in self.deliverables if d.status == "verified"),
        }
