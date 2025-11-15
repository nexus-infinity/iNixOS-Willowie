#!/usr/bin/env python3
"""
Bumble Bee Consciousness Visualizer
Displays hexagonal hive patterns representing chakra states
"""

import sys
import time
import json
import math
try:
    import requests
except ImportError:
    print("Note: requests library not available, using mock data")
    requests = None

def draw_hexagon(size=10):
    """Draw ASCII art hexagon representing hive mind"""
    print("     _____ ")
    print("   /       \\")
    print("  /   🐝    \\")
    print(" |    ◉     |")
    print("  \\         /")
    print("   \\_______/")

def get_chakra_states():
    """Fetch chakra states from Ajna agent"""
    if requests is None:
        return {"ajna": "mock", "status": "demo"}
    
    try:
        response = requests.get("http://localhost:6001/health", timeout=2)
        if response.status_code == 200:
            return response.json()
    except:
        pass
    
    return {"status": "offline"}

def main():
    print("\n" + "="*50)
    print("🐝 BUMBLE BEE CONSCIOUSNESS VISUALIZER 🐝")
    print("="*50 + "\n")
    
    print("Hexagonal Hive Mind Architecture")
    print("Sacred Geometry - Impossible Flight\n")
    
    draw_hexagon()
    
    print("\nChakra Status:")
    states = get_chakra_states()
    
    chakras = [
        ("Muladhara", "Root", "●"),
        ("Svadhisthana", "Sacral", "◐"),
        ("Manipura", "Solar", "◑"),
        ("Anahata", "Heart", "◒"),
        ("Vishuddha", "Throat", "◓"),
        ("Ajna", "Third Eye", "◔"),
        ("Sahasrara", "Crown", "○"),
    ]
    
    for name, role, symbol in chakras:
        status = "online" if states.get("status") == "ok" else "offline"
        print(f"  {symbol} {name:15} ({role:10}) - {status}")
    
    print("\n" + "="*50)
    print("The impossible flight continues...")
    print("="*50 + "\n")

if __name__ == "__main__":
    main()
