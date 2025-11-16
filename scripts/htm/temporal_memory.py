import numpy as np
from typing import Tuple

class TemporalMemory:
    """Learns sequences and makes predictions"""
    
    def __init__(self):
        self.columns = 2048
        self.cells_per_column = 32
        self.cell_state = np.zeros((self.columns, self.cells_per_column))
        self.predictive_state = np.zeros((self.columns, self.cells_per_column))
        self.segments = {}  # Dendritic segments
        
    def process(self, active_columns: np.ndarray) -> Tuple[np.ndarray, float]:
        """Process one timestep of HTM algorithm"""
        # Phase 1: Activate cells
        new_active_cells = self.activate_cells(active_columns)
        
        # Phase 2: Calculate predictions
        new_predictive_cells = self.calculate_predictions(new_active_cells)
        
        # Phase 3: Calculate anomaly
        anomaly_score = self.calculate_anomaly(active_columns)
        
        # Update states
        self.cell_state = new_active_cells
        self.predictive_state = new_predictive_cells
        
        return new_predictive_cells, anomaly_score
        
    def activate_cells(self, active_columns: np.ndarray) -> np.ndarray:
        """Activate cells based on current input and predictions"""
        new_state = np.zeros((self.columns, self.cells_per_column))
        
        for col_idx in np.where(active_columns)[0]:
            if self.predictive_state[col_idx].any():
                # Use predicted cells
                new_state[col_idx] = self.predictive_state[col_idx]
            else:
                # Burst all cells in column
                new_state[col_idx, :] = 1
                
        return new_state
        
    def calculate_predictions(self, active_cells: np.ndarray) -> np.ndarray:
        """Calculate predictive state for next timestep"""
        predictions = np.zeros((self.columns, self.cells_per_column))
        
        # Simplified prediction logic
        active_cols = np.any(active_cells, axis=1)
        shift = np.roll(active_cols, 1)
        predictions[:, 0] = shift
        
        return predictions
        
    def calculate_anomaly(self, active_columns: np.ndarray) -> float:
        """Calculate anomaly score based on prediction accuracy"""
        predicted_columns = np.any(self.predictive_state, axis=1)
        
        # Anomaly is fraction of unpredicted active columns
        unpredicted = active_columns & ~predicted_columns
        if active_columns.sum() > 0:
            return unpredicted.sum() / active_columns.sum()
        return 0.0
