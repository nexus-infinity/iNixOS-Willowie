#!/usr/bin/env python3
"""
SOMA Train Station Orchestrator
================================
🚂 Train Station at SOMA center (852 Hz)

Central orchestrator for the SOMA octahedron architecture.
Routes requests to appropriate vertices using the Triadic Handshake protocol.

Position: CENTER of octahedron
Frequency: 852 Hz (Crown Base - Spiritual Order)
Function: Orchestration hub, not a service endpoint
"""

import json
import logging
import time
from dataclasses import dataclass
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Dict, Optional, List, Any
import http.server
import socketserver
from urllib.parse import urlparse, parse_qs


# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [TRAIN-STATION] %(levelname)s: %(message)s'
)
logger = logging.getLogger(__name__)


class RequestType(Enum):
    """Types of requests that can be routed by Train Station."""
    BUILD = "build"
    COMPILE = "compile"
    DEPLOY = "deploy"
    ROLLBACK = "rollback"
    COMPUTE = "compute"
    ML_TRAINING = "ml_training"
    API_CALL = "api_call"
    WEBHOOK = "webhook"
    STORE = "store"
    ARCHIVE = "archive"
    MONITOR = "monitor"
    HEALTH_CHECK = "health_check"
    UNKNOWN = "unknown"


class Vertex(Enum):
    """SOMA octahedron vertices with frequencies."""
    TOP_963 = ("monitoring", 963, "Crown")
    NORTH_639 = ("communication", 639, "Throat")
    EAST_528 = ("transformation", 528, "Heart")
    SOUTH_741 = ("compute", 741, "Third Eye")
    WEST_417 = ("transmutation", 417, "Sacral")
    BOTTOM_174 = ("storage", 174, "Sub-Root")
    
    def __init__(self, name: str, frequency: int, chakra: str):
        self.vertex_name = name
        self.frequency = frequency
        self.chakra = chakra


@dataclass
class Request:
    """Represents a request passing through Train Station."""
    id: str
    type: RequestType
    payload: Dict[str, Any]
    source: str
    timestamp: str
    
    def to_dict(self) -> Dict:
        """Convert to dictionary for JSON serialization."""
        return {
            "id": self.id,
            "type": self.type.value,
            "payload": self.payload,
            "source": self.source,
            "timestamp": self.timestamp
        }


@dataclass
class RoutingResult:
    """Result of routing a request through Train Station."""
    success: bool
    vertex: Optional[Vertex]
    message: str
    request_id: str
    
    def to_dict(self) -> Dict:
        """Convert to dictionary for JSON serialization."""
        return {
            "success": self.success,
            "vertex": self.vertex.vertex_name if self.vertex else None,
            "frequency": self.vertex.frequency if self.vertex else None,
            "chakra": self.vertex.chakra if self.vertex else None,
            "message": self.message,
            "request_id": self.request_id
        }


class TrainStationOrchestrator:
    """
    🚂 Train Station at SOMA center (852 Hz)
    Orchestrates all vertex traffic and DOJO bridge
    """
    
    # Routing map: request type → vertex
    ROUTING_MAP = {
        RequestType.BUILD: Vertex.EAST_528,
        RequestType.COMPILE: Vertex.EAST_528,
        RequestType.DEPLOY: Vertex.WEST_417,
        RequestType.ROLLBACK: Vertex.WEST_417,
        RequestType.COMPUTE: Vertex.SOUTH_741,
        RequestType.ML_TRAINING: Vertex.SOUTH_741,
        RequestType.API_CALL: Vertex.NORTH_639,
        RequestType.WEBHOOK: Vertex.NORTH_639,
        RequestType.STORE: Vertex.BOTTOM_174,
        RequestType.ARCHIVE: Vertex.BOTTOM_174,
        RequestType.MONITOR: Vertex.TOP_963,
        RequestType.HEALTH_CHECK: Vertex.TOP_963,
    }
    
    def __init__(self, log_path: Path = Path("/var/log/SOMA/train-station.log")):
        self.frequency = 852
        self.position = "center"
        self.symbol = "🚂"
        self.log_path = log_path
        self.request_count = 0
        self.vertex_counts = {vertex: 0 for vertex in Vertex}
        
        # Ensure log directory exists
        self.log_path.parent.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"Train Station Orchestrator initialized")
        logger.info(f"Position: {self.position}")
        logger.info(f"Frequency: {self.frequency} Hz (Crown Base)")
        logger.info(f"Symbol: {self.symbol}")
        logger.info(f"Log path: {self.log_path}")
    
    def capture(self, request: Request) -> Request:
        """
        Step 1 of Triadic Handshake: CAPTURE
        Receive request from DOJO or internal source.
        """
        logger.info(f"CAPTURE: Request {request.id} from {request.source}")
        logger.info(f"  Type: {request.type.value}")
        self.request_count += 1
        
        # Log to file
        self._log_to_file({
            "phase": "capture",
            "request_id": request.id,
            "type": request.type.value,
            "source": request.source,
            "timestamp": request.timestamp
        })
        
        return request
    
    def validate(self, request: Request) -> bool:
        """
        Step 2 of Triadic Handshake: VALIDATE
        Check geometric coherence, permissions, dependencies.
        """
        logger.info(f"VALIDATE: Request {request.id}")
        
        # Basic validation: check if request type is known
        if request.type == RequestType.UNKNOWN:
            logger.warning(f"  Unknown request type, validation failed")
            self._log_to_file({
                "phase": "validate",
                "request_id": request.id,
                "success": False,
                "reason": "unknown_request_type"
            })
            return False
        
        # Check if we have a routing rule for this request type
        if request.type not in self.ROUTING_MAP:
            logger.warning(f"  No routing rule for type {request.type.value}")
            self._log_to_file({
                "phase": "validate",
                "request_id": request.id,
                "success": False,
                "reason": "no_routing_rule"
            })
            return False
        
        logger.info(f"  Validation passed")
        self._log_to_file({
            "phase": "validate",
            "request_id": request.id,
            "success": True
        })
        return True
    
    def route(self, request: Request) -> RoutingResult:
        """
        Step 3 of Triadic Handshake: ROUTE
        Forward to appropriate vertex based on request type.
        """
        vertex = self.ROUTING_MAP.get(request.type)
        
        if not vertex:
            logger.error(f"ROUTE: No vertex found for {request.type.value}")
            return RoutingResult(
                success=False,
                vertex=None,
                message=f"No routing rule for request type: {request.type.value}",
                request_id=request.id
            )
        
        logger.info(f"ROUTE: Request {request.id} → {vertex.vertex_name}")
        logger.info(f"  Vertex: {vertex.vertex_name} ({vertex.frequency} Hz - {vertex.chakra})")
        
        # Update vertex routing counter
        self.vertex_counts[vertex] += 1
        
        # Log to file
        self._log_to_file({
            "phase": "route",
            "request_id": request.id,
            "vertex": vertex.vertex_name,
            "frequency": vertex.frequency,
            "chakra": vertex.chakra
        })
        
        return RoutingResult(
            success=True,
            vertex=vertex,
            message=f"Routed to {vertex.vertex_name} vertex",
            request_id=request.id
        )
    
    def route_request(self, request: Request) -> RoutingResult:
        """
        Complete Triadic Handshake: Capture → Validate → Route
        """
        # Step 1: Capture
        captured = self.capture(request)
        
        # Step 2: Validate
        if not self.validate(captured):
            return RoutingResult(
                success=False,
                vertex=None,
                message="Validation failed",
                request_id=request.id
            )
        
        # Step 3: Route
        return self.route(captured)
    
    def get_status(self) -> Dict[str, Any]:
        """Get Train Station status and statistics."""
        return {
            "train_station": {
                "position": self.position,
                "frequency": self.frequency,
                "symbol": self.symbol,
                "status": "active"
            },
            "statistics": {
                "total_requests": self.request_count,
                "vertex_routing": {
                    vertex.vertex_name: count 
                    for vertex, count in self.vertex_counts.items()
                }
            },
            "octahedron": {
                "vertices": 6,
                "faces": 8,
                "edges": 12,
                "geometry": "octahedron"
            },
            "timestamp": datetime.now().isoformat()
        }
    
    def _log_to_file(self, data: Dict) -> None:
        """Log structured data to file."""
        try:
            with open(self.log_path, 'a') as f:
                log_entry = {
                    "timestamp": datetime.now().isoformat(),
                    "data": data
                }
                f.write(json.dumps(log_entry) + "\n")
        except Exception as e:
            logger.error(f"Failed to write to log file: {e}")


class TrainStationHTTPHandler(http.server.SimpleHTTPRequestHandler):
    """HTTP handler for Train Station API."""
    
    orchestrator: Optional[TrainStationOrchestrator] = None
    
    def do_GET(self):
        """Handle GET requests."""
        parsed_path = urlparse(self.path)
        
        if parsed_path.path == '/health':
            self._handle_health()
        elif parsed_path.path == '/status':
            self._handle_status()
        else:
            self._send_response(404, {"error": "Not found"})
    
    def do_POST(self):
        """Handle POST requests."""
        parsed_path = urlparse(self.path)
        
        if parsed_path.path == '/route':
            self._handle_route()
        else:
            self._send_response(404, {"error": "Not found"})
    
    def _handle_health(self):
        """Health check endpoint."""
        response = {
            "status": "healthy",
            "service": "train-station",
            "frequency": "852 Hz",
            "position": "center"
        }
        self._send_response(200, response)
    
    def _handle_status(self):
        """Status endpoint."""
        if self.orchestrator:
            status = self.orchestrator.get_status()
            self._send_response(200, status)
        else:
            self._send_response(500, {"error": "Orchestrator not initialized"})
    
    def _handle_route(self):
        """Route request endpoint."""
        try:
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            # Parse request
            request_type_str = data.get('type', 'unknown')
            try:
                request_type = RequestType(request_type_str)
            except ValueError:
                request_type = RequestType.UNKNOWN
            
            request = Request(
                id=data.get('id', f"req-{int(time.time())}"),
                type=request_type,
                payload=data.get('payload', {}),
                source=data.get('source', 'unknown'),
                timestamp=datetime.now().isoformat()
            )
            
            # Route through orchestrator
            if self.orchestrator:
                result = self.orchestrator.route_request(request)
                self._send_response(200, result.to_dict())
            else:
                self._send_response(500, {"error": "Orchestrator not initialized"})
        
        except Exception as e:
            logger.error(f"Error handling route request: {e}")
            self._send_response(500, {"error": str(e)})
    
    def _send_response(self, status_code: int, data: Dict):
        """Send JSON response."""
        self.send_response(status_code)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(data, indent=2).encode('utf-8'))
    
    def log_message(self, format, *args):
        """Override to use our logger."""
        logger.info(f"HTTP: {format % args}")


def main():
    """Main entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="SOMA Train Station Orchestrator (852 Hz)"
    )
    parser.add_argument(
        "--port",
        type=int,
        default=8520,
        help="HTTP port to listen on (default: 8520, inspired by 852 Hz)"
    )
    parser.add_argument(
        "--log-path",
        type=Path,
        default=Path("/var/log/SOMA/train-station.log"),
        help="Path to log file"
    )
    
    args = parser.parse_args()
    
    # Create orchestrator
    orchestrator = TrainStationOrchestrator(log_path=args.log_path)
    TrainStationHTTPHandler.orchestrator = orchestrator
    
    # Start HTTP server
    logger.info(f"Starting Train Station HTTP server on port {args.port}")
    logger.info(f"Endpoints:")
    logger.info(f"  GET  /health  - Health check")
    logger.info(f"  GET  /status  - Status and statistics")
    logger.info(f"  POST /route   - Route request")
    
    try:
        with socketserver.TCPServer(("", args.port), TrainStationHTTPHandler) as httpd:
            logger.info(f"🚂 Train Station listening on port {args.port}")
            httpd.serve_forever()
    except KeyboardInterrupt:
        logger.info("Train Station shutting down")
    except Exception as e:
        logger.error(f"Train Station error: {e}")
        raise


if __name__ == "__main__":
    main()
