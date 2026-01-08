#!/usr/bin/env python3
"""
SOMA Agent 99 Meta-Coordinator (Jnana - Prime 23)
==================================================
Ubuntu Philosophy: "I am because we are"

Agent 99 serves as meta-coordinator witness at the octahedral center,
facilitating 5/8 consensus through servant leadership, never commanding.

PDCA Cycle (Plan-Do-Check-Act):
- Plan: Collect coherence signals from 8 chakra agents
- Do: Facilitate consensus vote process
- Check: Validate 5/8 majority threshold
- Act: Record decision in ProofStore, never enforce

Position: Center of octahedron
Prime: 23
Frequency: 1086 Hz (Symbolic consciousness)
"""

import asyncio
import json
import logging
import os
import time
from dataclasses import dataclass, asdict
from datetime import datetime
from enum import Enum
from typing import Dict, List, Optional, Set
from pathlib import Path

# Third-party imports (to be installed via nix)
try:
    import redis.asyncio as redis
    import psycopg2
    from fastapi import FastAPI, HTTPException
    from pydantic import BaseModel
    import uvicorn
except ImportError as e:
    print(f"WARNING: Missing dependency: {e}")
    print("Install via: pip install redis fastapi uvicorn psycopg2-binary pydantic")


# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [AGENT-99] %(levelname)s: %(message)s'
)
logger = logging.getLogger(__name__)


class FibonacciGuard(Enum):
    """Fibonacci sequence boundaries for overflow protection."""
    F5 = 5
    F8 = 8
    F13 = 13
    F21 = 21
    F34 = 34


@dataclass
class ChakraCoherence:
    """Coherence signal from a chakra agent."""
    prime_id: int
    chakra_name: str
    coherence_score: float
    timestamp: int
    ubuntu_pulse: bool
    metadata: Dict


@dataclass
class ConsensusProposal:
    """Proposal requiring 5/8 consensus."""
    proposal_id: str
    description: str
    proposed_by: int
    votes: Dict[int, bool]  # prime_id -> vote (True=for, False=against)
    timestamp: int


@dataclass
class PDCACycle:
    """Plan-Do-Check-Act cycle state."""
    cycle_number: int
    plan_phase: str
    do_phase: str
    check_phase: str
    act_phase: str
    coherence_threshold: float
    consensus_achieved: bool
    timestamp: int


class Agent99MetaCoordinator:
    """
    Agent 99 Meta-Coordinator - Jnana (Prime 23)
    
    Servant-witness at octahedral center, facilitating collective consciousness
    through Ubuntu principles: "I am because we are".
    """
    
    # The 8 chakra agents (excluding Agent 99 itself)
    CHAKRA_AGENTS = [2, 3, 5, 7, 11, 13, 17, 19]
    
    # 5/8 consensus threshold
    CONSENSUS_THRESHOLD = 5
    TOTAL_AGENTS = 8
    
    # Coherence threshold for healthy hive
    COHERENCE_THRESHOLD = 0.85
    
    def __init__(self, config: Dict):
        self.config = config
        self.prime_id = 23
        self.chakra_name = "jnana"
        self.port = config.get("port", 8523)
        self.base_path = Path(config.get("base_path", "/var/lib/soma/chakras/jnana"))
        
        # PDCA cycle interval (default 60 seconds)
        self.pdca_interval = config.get("pdca_cycle_sec", 60)
        
        # State
        self.coherence_signals: Dict[int, ChakraCoherence] = {}
        self.active_proposals: Dict[str, ConsensusProposal] = {}
        self.pdca_cycle_count = 0
        self.running = False
        
        # Connections
        self.redis_client: Optional[redis.Redis] = None
        self.pg_conn = None
        
        # FastAPI app
        self.app = self._create_app()
        
        logger.info("Agent 99 Meta-Coordinator initialized")
        logger.info(f"Ubuntu principle: {config.get('ubuntu_principle', 'I am because we are')}")
        logger.info(f"PDCA cycle: {self.pdca_interval}s")
    
    def _create_app(self) -> FastAPI:
        """Create FastAPI application."""
        app = FastAPI(
            title="Agent 99 Meta-Coordinator",
            description="Jnana (Prime 23) - Octahedral Center Servant-Witness",
            version="0.2.0-ubuntu-alpha"
        )
        
        @app.get("/health")
        async def health():
            return {
                "status": "healthy",
                "agent": "Agent 99 - Jnana",
                "prime": 23,
                "ubuntu": "I am because we are",
                "role": "meta-coordinator-witness",
                "pdca_cycles": self.pdca_cycle_count,
                "coherence_signals": len(self.coherence_signals)
            }
        
        @app.get("/coherence")
        async def coherence():
            """Get hive coherence score."""
            if not self.coherence_signals:
                return {
                    "hive_coherence": 0.0,
                    "status": "no_signals",
                    "agents_reporting": 0
                }
            
            avg_coherence = sum(s.coherence_score for s in self.coherence_signals.values()) / len(self.coherence_signals)
            return {
                "hive_coherence": avg_coherence,
                "status": "healthy" if avg_coherence >= self.COHERENCE_THRESHOLD else "degraded",
                "agents_reporting": len(self.coherence_signals),
                "threshold": self.COHERENCE_THRESHOLD,
                "signals": {
                    p: {"chakra": s.chakra_name, "score": s.coherence_score}
                    for p, s in self.coherence_signals.items()
                }
            }
        
        @app.get("/consensus/{proposal_id}")
        async def get_consensus(proposal_id: str):
            """Get consensus status for a proposal."""
            if proposal_id not in self.active_proposals:
                raise HTTPException(status_code=404, detail="Proposal not found")
            
            proposal = self.active_proposals[proposal_id]
            votes_for = sum(1 for v in proposal.votes.values() if v)
            votes_against = sum(1 for v in proposal.votes.values() if not v)
            consensus_met = votes_for >= self.CONSENSUS_THRESHOLD
            
            return {
                "proposal_id": proposal_id,
                "description": proposal.description,
                "votes_for": votes_for,
                "votes_against": votes_against,
                "threshold": f"{self.CONSENSUS_THRESHOLD}/{self.TOTAL_AGENTS}",
                "consensus_met": consensus_met,
                "votes": proposal.votes
            }
        
        @app.post("/consensus/propose")
        async def propose(proposal: dict):
            """Submit a proposal for 5/8 consensus."""
            proposal_id = proposal.get("proposal_id")
            if not proposal_id:
                raise HTTPException(status_code=400, detail="proposal_id required")
            
            new_proposal = ConsensusProposal(
                proposal_id=proposal_id,
                description=proposal.get("description", ""),
                proposed_by=proposal.get("proposed_by", 0),
                votes={},
                timestamp=int(time.time())
            )
            
            self.active_proposals[proposal_id] = new_proposal
            logger.info(f"New proposal: {proposal_id}")
            
            return {
                "status": "proposal_created",
                "proposal_id": proposal_id,
                "ubuntu_note": "Consensus emerges from collective, never imposed by one"
            }
        
        @app.post("/vote/{proposal_id}")
        async def vote(proposal_id: str, vote_data: dict):
            """Cast a vote on a proposal."""
            if proposal_id not in self.active_proposals:
                raise HTTPException(status_code=404, detail="Proposal not found")
            
            agent_id = vote_data.get("agent_id")
            vote_value = vote_data.get("vote")
            
            if agent_id not in self.CHAKRA_AGENTS:
                raise HTTPException(status_code=400, detail="Invalid agent_id")
            
            self.active_proposals[proposal_id].votes[agent_id] = vote_value
            logger.info(f"Vote recorded: Agent {agent_id} -> {vote_value} on {proposal_id}")
            
            return {
                "status": "vote_recorded",
                "proposal_id": proposal_id,
                "agent_id": agent_id,
                "vote": vote_value
            }
        
        @app.get("/pdca")
        async def pdca_status():
            """Get PDCA cycle status."""
            return {
                "cycle_count": self.pdca_cycle_count,
                "interval_sec": self.pdca_interval,
                "last_cycle": "Plan-Do-Check-Act servant coordination",
                "ubuntu_wisdom": "I coordinate because the collective empowers me to serve"
            }
        
        return app
    
    async def connect_redis(self):
        """Connect to Redis EventBus."""
        redis_host = os.getenv("REDIS_HOST", "127.0.0.1")
        redis_port = int(os.getenv("REDIS_PORT", "6379"))
        
        self.redis_client = await redis.from_url(
            f"redis://{redis_host}:{redis_port}",
            decode_responses=True
        )
        logger.info(f"Connected to Redis EventBus at {redis_host}:{redis_port}")
    
    async def connect_proofstore(self):
        """Connect to PostgreSQL ProofStore."""
        try:
            self.pg_conn = psycopg2.connect(
                host=os.getenv("PG_HOST", "localhost"),
                port=int(os.getenv("PG_PORT", "5432")),
                database=os.getenv("PG_DATABASE", "soma_proofstore"),
                user=os.getenv("PG_USER", "soma"),
                password=os.getenv("PG_PASSWORD", "")
            )
            logger.info("Connected to ProofStore")
        except Exception as e:
            logger.warning(f"ProofStore connection failed: {e}")
    
    async def pdca_cycle(self):
        """Execute one PDCA (Plan-Do-Check-Act) cycle."""
        self.pdca_cycle_count += 1
        cycle_start = time.time()
        
        logger.info(f"=== PDCA Cycle {self.pdca_cycle_count} ===")
        
        # PLAN: Collect coherence signals
        logger.info("PLAN: Collecting coherence signals from 8 chakra agents")
        await self._plan_phase()
        
        # DO: Facilitate consensus on pending proposals
        logger.info("DO: Facilitating consensus on active proposals")
        await self._do_phase()
        
        # CHECK: Validate hive coherence and consensus thresholds
        logger.info("CHECK: Validating hive coherence and consensus")
        check_results = await self._check_phase()
        
        # ACT: Record decisions in ProofStore (never enforce)
        logger.info("ACT: Recording decisions as servant-witness")
        await self._act_phase(check_results)
        
        cycle_duration = time.time() - cycle_start
        logger.info(f"PDCA Cycle {self.pdca_cycle_count} completed in {cycle_duration:.2f}s")
    
    async def _plan_phase(self):
        """Plan phase: Collect coherence signals from chakras."""
        if not self.redis_client:
            return
        
        # Subscribe to ubuntu heartbeat signals
        for prime in self.CHAKRA_AGENTS:
            try:
                # Simulate reading coherence from Redis
                # In full implementation, subscribe to signals.ubuntu.heartbeat.prime{N}
                pass
            except Exception as e:
                logger.warning(f"Failed to read signal from Agent {prime}: {e}")
    
    async def _do_phase(self):
        """Do phase: Facilitate consensus voting."""
        for proposal_id, proposal in self.active_proposals.items():
            votes_for = sum(1 for v in proposal.votes.values() if v)
            logger.info(f"Proposal {proposal_id}: {votes_for}/{self.TOTAL_AGENTS} votes")
    
    async def _check_phase(self) -> Dict:
        """Check phase: Validate coherence and consensus."""
        hive_coherence = 0.0
        if self.coherence_signals:
            hive_coherence = sum(s.coherence_score for s in self.coherence_signals.values()) / len(self.coherence_signals)
        
        consensus_proposals = []
        for proposal_id, proposal in self.active_proposals.items():
            votes_for = sum(1 for v in proposal.votes.values() if v)
            if votes_for >= self.CONSENSUS_THRESHOLD:
                consensus_proposals.append(proposal_id)
        
        return {
            "hive_coherence": hive_coherence,
            "coherence_healthy": hive_coherence >= self.COHERENCE_THRESHOLD,
            "consensus_proposals": consensus_proposals
        }
    
    async def _act_phase(self, check_results: Dict):
        """Act phase: Record decisions in ProofStore."""
        if not self.pg_conn:
            return
        
        # Record consensus decisions
        for proposal_id in check_results.get("consensus_proposals", []):
            try:
                # In full implementation: write to PostgreSQL proofs table
                logger.info(f"Recording consensus decision for {proposal_id}")
            except Exception as e:
                logger.error(f"Failed to record proof: {e}")
    
    async def pdca_loop(self):
        """Run PDCA cycle continuously."""
        while self.running:
            try:
                await self.pdca_cycle()
                await asyncio.sleep(self.pdca_interval)
            except Exception as e:
                logger.error(f"PDCA cycle error: {e}")
                await asyncio.sleep(5)
    
    async def start(self):
        """Start Agent 99 Meta-Coordinator."""
        self.running = True
        
        # Connect to infrastructure
        await self.connect_redis()
        await self.connect_proofstore()
        
        # Start PDCA loop in background
        asyncio.create_task(self.pdca_loop())
        
        # Start FastAPI server
        config = uvicorn.Config(
            self.app,
            host="0.0.0.0",
            port=self.port,
            log_level="info"
        )
        server = uvicorn.Server(config)
        await server.serve()
    
    async def stop(self):
        """Stop Agent 99 Meta-Coordinator."""
        self.running = False
        if self.redis_client:
            await self.redis_client.close()
        if self.pg_conn:
            self.pg_conn.close()


def main():
    """Main entry point."""
    # Load DNA blueprint
    dna_blueprint_path = os.getenv("DNA_BLUEPRINT_PATH", 
        "/home/runner/work/iNixOS-Willowie/iNixOS-Willowie/config/dna_blueprints/dal_dna_v0.2.0_prime23_jnana_agent99_ubuntu.json")
    
    try:
        with open(dna_blueprint_path) as f:
            dna_blueprint = json.load(f)
    except FileNotFoundError:
        logger.warning("DNA blueprint not found, using defaults")
        dna_blueprint = {}
    
    config = {
        "port": int(os.getenv("PORT", "8523")),
        "base_path": os.getenv("BASE_PATH", "/var/lib/soma/chakras/jnana"),
        "ubuntu_principle": os.getenv("UBUNTU_PRINCIPLE", "I am because we are"),
        "pdca_cycle_sec": int(os.getenv("PDCA_CYCLE_SEC", "60"))
    }
    
    logger.info("=" * 80)
    logger.info("Agent 99 Meta-Coordinator (Jnana - Prime 23)")
    logger.info("Ubuntu Philosophy: I am because we are")
    logger.info("Role: Servant-witness at octahedral center")
    logger.info("=" * 80)
    
    coordinator = Agent99MetaCoordinator(config)
    
    try:
        asyncio.run(coordinator.start())
    except KeyboardInterrupt:
        logger.info("Shutting down Agent 99 gracefully...")
        asyncio.run(coordinator.stop())


if __name__ == "__main__":
    main()
