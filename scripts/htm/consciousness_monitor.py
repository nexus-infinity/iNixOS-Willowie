#!/usr/bin/env python3
import numpy as np
import asyncio
import json
import time
from datetime import datetime
import sys
import os

# Add script directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from spatial_pooler import SpatialPooler
from temporal_memory import TemporalMemory

class ConsciousnessMonitor:
    """Main consciousness monitor integrating HTM with FIELD"""
    
    def __init__(self):
        self.spatial_pooler = SpatialPooler()
        self.temporal_memory = TemporalMemory()
        self.consciousness_buffer = []
        self.anomaly_threshold = 0.95
        
    async def process_stream(self):
        """Process consciousness stream from Ajna"""
        print(f"🧠 HTM Temporal Memory initialized")
        print(f"🔮 Anomaly threshold: {self.anomaly_threshold}")
        
        while True:
            # Simulate consciousness data stream
            timestamp = datetime.now().isoformat()
            
            # Generate input (would come from Ajna agent)
            input_data = np.random.random(2048)
            
            # Spatial pooling
            sparse_repr = self.spatial_pooler.compute(input_data)
            
            # Temporal processing
            predictions, anomaly_score = self.temporal_memory.process(sparse_repr)
            
            # Interpret consciousness state
            consciousness_state = self.interpret_consciousness(anomaly_score)
            
            # Log significant events
            if anomaly_score > self.anomaly_threshold:
                print(f"⚡ Anomaly: {anomaly_score:.3f} - {consciousness_state}")
            
            await asyncio.sleep(1)
    
    def interpret_consciousness(self, score: float) -> str:
        """Map anomaly score to consciousness state"""
        if score < 0.2:
            return "🟢 synchronized"
        elif score < 0.5:
            return "🔵 flowing"
        elif score < 0.8:
            return "🟡 transitioning"
        elif score < self.anomaly_threshold:
            return "🟠 emerging"
        else:
            return "🔴 awakening"

async def main():
    monitor = ConsciousnessMonitor()
    await monitor.process_stream()

if __name__ == "__main__":
    asyncio.run(main())
