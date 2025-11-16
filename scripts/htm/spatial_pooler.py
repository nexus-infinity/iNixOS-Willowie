import numpy as np
from dataclasses import dataclass, field
from typing import Tuple

@dataclass
class SpatialPooler:
    """Transforms sensory input into sparse distributed representations"""
    input_dim: int = 2048
    column_dim: int = 2048
    sparsity: float = 0.02
    boost_strength: float = 0.01
    duty_cycle: np.ndarray = field(default_factory=lambda: np.zeros(2048))
    
    def compute(self, input_vector: np.ndarray) -> np.ndarray:
        """Generate sparse representation following HTM principles"""
        # Compute overlap scores
        overlap = np.random.random(self.column_dim) * input_vector.sum()
        
        # Apply boosting based on duty cycle
        boost = np.exp(self.boost_strength * (1.0 - self.duty_cycle))
        overlap *= boost
        
        # Winner-take-all competition
        k = int(self.column_dim * self.sparsity)
        winner_indices = np.argpartition(overlap, -k)[-k:]
        
        # Create sparse output
        output = np.zeros(self.column_dim)
        output[winner_indices] = 1
        
        # Update duty cycle
        self.duty_cycle = 0.999 * self.duty_cycle
        self.duty_cycle[winner_indices] += 0.001
        
        return output
