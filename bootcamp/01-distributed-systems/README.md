# Module 1: Distributed Systems Fundamentals

Welcome to the foundational module on distributed systems! This module covers the essential concepts and patterns that underpin every component in your BigQuery-equivalent data warehouse.

## 🎯 Learning Objectives

By the end of this module, you will:
- Understand the CAP theorem and its implications for distributed data systems
- Master consensus algorithms and their role in maintaining consistency
- Implement fault tolerance patterns for high availability
- Design systems that handle network partitions gracefully
- Apply distributed systems principles to data warehouse architecture

## 📚 Module Overview

### Duration: 1 Week (20 hours)
- **Theory & Reading**: 6 hours
- **Hands-on Labs**: 10 hours  
- **Project Implementation**: 4 hours

### Prerequisites
- Basic understanding of computer networks
- Familiarity with database ACID properties
- Programming experience (Python preferred)

## 🧠 Core Concepts

### 1. The CAP Theorem

**Consistency, Availability, Partition Tolerance - Pick Two**

```
    Consistency (C)
         /\
        /  \
       /    \
      /      \
     /        \
    /          \
   /            \
  /              \
 /                \
/                  \
Partition           Availability
Tolerance (P)            (A)
```

**In Practice:**
- **CP Systems**: Traditional RDBMS, Apache HBase
- **AP Systems**: Amazon DynamoDB, Apache Cassandra  
- **CA Systems**: Single-node databases (not truly distributed)

**Relevance to Data Warehouses:**
- **MinIO**: AP system - prioritizes availability over strong consistency
- **Iceberg**: Achieves consistency through serializable isolation
- **Trino**: CP system for query coordination, AP for data access

### 2. Consensus Algorithms

**Raft Consensus Algorithm**

Key concepts:
- **Leader Election**: One node coordinates all changes
- **Log Replication**: Changes are replicated to followers
- **Safety**: At most one leader per term

```python
# Simplified Raft state machine
class RaftNode:
    def __init__(self, node_id):
        self.node_id = node_id
        self.state = "follower"  # follower, candidate, leader
        self.current_term = 0
        self.voted_for = None
        self.log = []
        self.commit_index = 0
    
    def start_election(self):
        """Convert to candidate and request votes"""
        self.state = "candidate"
        self.current_term += 1
        self.voted_for = self.node_id
        # Send RequestVote RPCs to all other nodes
        
    def handle_append_entries(self, term, leader_id, entries):
        """Handle log replication from leader"""
        if term >= self.current_term:
            self.current_term = term
            self.state = "follower"
            # Append entries to log
            return True
        return False
```

**Applications in Data Systems:**
- **Apache Kafka**: Uses Raft-like algorithm for broker coordination
- **etcd/Consul**: Metadata storage for Kubernetes and service discovery
- **Apache Iceberg**: Table metadata versioning follows consensus principles

### 3. Fault Tolerance Patterns

**Circuit Breaker Pattern**
```python
import time
from enum import Enum

class CircuitState(Enum):
    CLOSED = "closed"
    OPEN = "open" 
    HALF_OPEN = "half_open"

class CircuitBreaker:
    def __init__(self, failure_threshold=5, timeout=60):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.failure_count = 0
        self.last_failure_time = None
        self.state = CircuitState.CLOSED
    
    def call(self, func, *args, **kwargs):
        if self.state == CircuitState.OPEN:
            if time.time() - self.last_failure_time > self.timeout:
                self.state = CircuitState.HALF_OPEN
            else:
                raise Exception("Circuit breaker is OPEN")
        
        try:
            result = func(*args, **kwargs)
            if self.state == CircuitState.HALF_OPEN:
                self.state = CircuitState.CLOSED
                self.failure_count = 0
            return result
        except Exception as e:
            self.failure_count += 1
            self.last_failure_time = time.time()
            
            if self.failure_count >= self.failure_threshold:
                self.state = CircuitState.OPEN
            
            raise e
```

**Retry with Exponential Backoff**
```python
import random
import time

def retry_with_backoff(func, max_retries=3, base_delay=1):
    """Retry function with exponential backoff and jitter"""
    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise e
            
            # Exponential backoff with jitter
            delay = base_delay * (2 ** attempt) + random.uniform(0, 1)
            time.sleep(delay)
```

### 4. Data Consistency Models

**Consistency Levels in Distributed Systems:**

1. **Strong Consistency**: All nodes see the same data simultaneously
2. **Eventual Consistency**: System will become consistent over time
3. **Causal Consistency**: Causally related operations are seen in order
4. **Session Consistency**: Within a client session, reads reflect writes

**Implementation Example:**
```python
class DistributedCache:
    def __init__(self, consistency_level="eventual"):
        self.consistency_level = consistency_level
        self.local_cache = {}
        self.version_vector = {}
    
    def read(self, key):
        if self.consistency_level == "strong":
            # Read from majority of nodes
            return self.strong_read(key)
        else:
            # Read from local cache
            return self.local_cache.get(key)
    
    def write(self, key, value):
        if self.consistency_level == "strong":
            # Write to majority of nodes before returning
            return self.strong_write(key, value)
        else:
            # Write locally, propagate asynchronously
            self.local_cache[key] = value
            self.async_propagate(key, value)
```

## 🛠 Hands-on Labs

### Lab 1: CAP Theorem Simulation

**Objective**: Build a simple distributed key-value store to demonstrate CAP theorem trade-offs.

**Setup**:
```bash
# Create lab directory
mkdir -p 01-distributed-systems/labs/cap-theorem
cd 01-distributed-systems/labs/cap-theorem

# Create virtual environment
python3 -m venv lab-env
source lab-env/bin/activate
pip install flask requests
```

**Implementation**:
```python
# node.py - Simple distributed node
from flask import Flask, request, jsonify
import requests
import threading
import time

class DistributedNode:
    def __init__(self, node_id, port, peers=None):
        self.node_id = node_id
        self.port = port
        self.peers = peers or []
        self.data = {}
        self.app = Flask(__name__)
        self.setup_routes()
        
    def setup_routes(self):
        @self.app.route('/get/<key>')
        def get_key(key):
            return jsonify({
                'node_id': self.node_id,
                'key': key,
                'value': self.data.get(key),
                'timestamp': time.time()
            })
        
        @self.app.route('/set/<key>/<value>')
        def set_key(key, value):
            # Strong consistency - replicate to all nodes
            if request.args.get('consistency') == 'strong':
                return self.strong_set(key, value)
            else:
                # Eventual consistency - set locally
                self.data[key] = value
                self.async_replicate(key, value)
                return jsonify({
                    'status': 'success',
                    'node_id': self.node_id,
                    'consistency': 'eventual'
                })
        
        @self.app.route('/replicate/<key>/<value>')
        def replicate(key, value):
            self.data[key] = value
            return jsonify({'status': 'replicated'})
            
    def strong_set(self, key, value):
        """Replicate to majority before returning"""
        self.data[key] = value
        success_count = 1  # self
        
        for peer in self.peers:
            try:
                response = requests.get(
                    f"http://localhost:{peer}/replicate/{key}/{value}",
                    timeout=1
                )
                if response.status_code == 200:
                    success_count += 1
            except requests.RequestException:
                pass  # Node unavailable
        
        if success_count > len(self.peers) // 2:
            return jsonify({
                'status': 'success',
                'node_id': self.node_id,
                'consistency': 'strong',
                'replicas': success_count
            })
        else:
            # Rollback if majority not reached
            del self.data[key]
            return jsonify({
                'status': 'failed',
                'reason': 'insufficient_replicas'
            }), 500
    
    def async_replicate(self, key, value):
        """Asynchronously replicate to peers"""
        def replicate_to_peer(peer):
            try:
                requests.get(
                    f"http://localhost:{peer}/replicate/{key}/{value}",
                    timeout=1
                )
            except requests.RequestException:
                pass  # Handle failure gracefully
        
        for peer in self.peers:
            threading.Thread(
                target=replicate_to_peer,
                args=(peer,)
            ).start()
    
    def run(self):
        self.app.run(port=self.port, debug=False)

if __name__ == "__main__":
    import sys
    node_id = sys.argv[1]
    port = int(sys.argv[2])
    peers = [int(p) for p in sys.argv[3:]]
    
    node = DistributedNode(node_id, port, peers)
    node.run()
```

**Testing Script**:
```python
# test_cap.py
import requests
import time
import subprocess
import threading

def start_nodes():
    """Start 3 nodes in separate processes"""
    nodes = [
        ("node1", 5001, [5002, 5003]),
        ("node2", 5002, [5001, 5003]),
        ("node3", 5003, [5001, 5002])
    ]
    
    processes = []
    for node_id, port, peers in nodes:
        cmd = ["python", "node.py", node_id, str(port)] + [str(p) for p in peers]
        proc = subprocess.Popen(cmd)
        processes.append(proc)
        time.sleep(1)  # Allow startup
    
    return processes

def test_consistency():
    """Test different consistency levels"""
    
    # Test eventual consistency
    print("Testing Eventual Consistency...")
    response = requests.get("http://localhost:5001/set/key1/value1")
    print(f"Set response: {response.json()}")
    
    # Immediately read from different nodes
    for port in [5001, 5002, 5003]:
        try:
            response = requests.get(f"http://localhost:{port}/get/key1")
            print(f"Node {port}: {response.json()}")
        except requests.RequestException as e:
            print(f"Node {port}: Connection failed")
    
    print("\nTesting Strong Consistency...")
    response = requests.get("http://localhost:5001/set/key2/value2?consistency=strong")
    print(f"Set response: {response.json()}")
    
    # Read should be consistent across nodes
    for port in [5001, 5002, 5003]:
        try:
            response = requests.get(f"http://localhost:{port}/get/key2")
            print(f"Node {port}: {response.json()}")
        except requests.RequestException as e:
            print(f"Node {port}: Connection failed")

def test_partition_tolerance():
    """Simulate network partition"""
    print("\nSimulating Network Partition...")
    print("Stop node 3 to simulate partition")
    # In real test, you would kill the process or block network
    
if __name__ == "__main__":
    processes = start_nodes()
    time.sleep(3)  # Allow all nodes to start
    
    try:
        test_consistency()
        test_partition_tolerance()
    finally:
        # Cleanup
        for proc in processes:
            proc.terminate()
```

**Run the Lab**:
```bash
# Terminal 1: Start the test
python test_cap.py

# Observe the behavior differences between consistency levels
# Try stopping nodes to see partition tolerance in action
```

### Lab 2: Consensus Algorithm Implementation

**Objective**: Implement a simplified Raft consensus algorithm.

```python
# raft_node.py
import random
import time
import threading
from dataclasses import dataclass
from typing import List, Optional
from enum import Enum

class NodeState(Enum):
    FOLLOWER = "follower"
    CANDIDATE = "candidate"
    LEADER = "leader"

@dataclass
class LogEntry:
    term: int
    index: int
    command: str
    committed: bool = False

class RaftNode:
    def __init__(self, node_id: str, peers: List[str]):
        self.node_id = node_id
        self.peers = peers
        self.state = NodeState.FOLLOWER
        
        # Persistent state
        self.current_term = 0
        self.voted_for: Optional[str] = None
        self.log: List[LogEntry] = []
        
        # Volatile state
        self.commit_index = 0
        self.last_applied = 0
        
        # Leader state
        self.next_index = {}
        self.match_index = {}
        
        # Timing
        self.last_heartbeat = time.time()
        self.election_timeout = random.uniform(150, 300) / 1000  # 150-300ms
        self.heartbeat_interval = 50 / 1000  # 50ms
        
        # Start background threads
        self.running = True
        threading.Thread(target=self.election_timer, daemon=True).start()
        threading.Thread(target=self.heartbeat_timer, daemon=True).start()
    
    def election_timer(self):
        """Background thread for election timeout"""
        while self.running:
            time.sleep(0.01)  # 10ms granularity
            
            if (self.state != NodeState.LEADER and 
                time.time() - self.last_heartbeat > self.election_timeout):
                self.start_election()
    
    def heartbeat_timer(self):
        """Background thread for sending heartbeats"""
        while self.running:
            time.sleep(self.heartbeat_interval)
            
            if self.state == NodeState.LEADER:
                self.send_heartbeats()
    
    def start_election(self):
        """Start leader election"""
        print(f"Node {self.node_id} starting election for term {self.current_term + 1}")
        
        self.state = NodeState.CANDIDATE
        self.current_term += 1
        self.voted_for = self.node_id
        self.last_heartbeat = time.time()
        
        # Vote for self
        votes = 1
        
        # Request votes from peers (simplified - would use RPC in real implementation)
        for peer in self.peers:
            if self.request_vote(peer):
                votes += 1
        
        # Check if won election
        if votes > len(self.peers) // 2:
            self.become_leader()
        else:
            self.state = NodeState.FOLLOWER
    
    def request_vote(self, peer: str) -> bool:
        """Request vote from peer (simplified)"""
        # In real implementation, this would be an RPC call
        # For simulation, we'll assume 70% success rate
        return random.random() < 0.7
    
    def become_leader(self):
        """Become the leader"""
        print(f"Node {self.node_id} became leader for term {self.current_term}")
        
        self.state = NodeState.LEADER
        
        # Initialize leader state
        for peer in self.peers:
            self.next_index[peer] = len(self.log) + 1
            self.match_index[peer] = 0
    
    def send_heartbeats(self):
        """Send heartbeat to all followers"""
        print(f"Leader {self.node_id} sending heartbeats")
        
        for peer in self.peers:
            self.send_append_entries(peer, [])
    
    def send_append_entries(self, peer: str, entries: List[LogEntry]):
        """Send append entries RPC to peer"""
        # Simplified - in real implementation this would be RPC
        print(f"Sending append entries to {peer}")
    
    def append_entry(self, command: str):
        """Append new entry to log (leader only)"""
        if self.state != NodeState.LEADER:
            return False
        
        entry = LogEntry(
            term=self.current_term,
            index=len(self.log) + 1,
            command=command
        )
        
        self.log.append(entry)
        print(f"Leader {self.node_id} appended entry: {command}")
        
        # Replicate to followers
        for peer in self.peers:
            self.send_append_entries(peer, [entry])
        
        return True
    
    def get_state(self):
        """Get current node state"""
        return {
            'node_id': self.node_id,
            'state': self.state.value,
            'term': self.current_term,
            'log_size': len(self.log),
            'commit_index': self.commit_index
        }

# Test the Raft implementation
def test_raft():
    """Test Raft consensus"""
    nodes = [
        RaftNode("node1", ["node2", "node3"]),
        RaftNode("node2", ["node1", "node3"]),
        RaftNode("node3", ["node1", "node2"])
    ]
    
    # Let election happen
    time.sleep(2)
    
    # Find leader
    leader = None
    for node in nodes:
        if node.state == NodeState.LEADER:
            leader = node
            break
    
    if leader:
        print(f"\nLeader elected: {leader.node_id}")
        
        # Append some entries
        leader.append_entry("SET key1 value1")
        leader.append_entry("SET key2 value2")
        leader.append_entry("DELETE key1")
        
        time.sleep(1)
        
        # Print final state
        for node in nodes:
            print(f"Node {node.node_id}: {node.get_state()}")
    else:
        print("No leader elected")
    
    # Cleanup
    for node in nodes:
        node.running = False

if __name__ == "__main__":
    test_raft()
```

### Lab 3: Network Partition Simulation

**Objective**: Simulate network partitions and observe system behavior.

```python
# partition_simulator.py
import time
import threading
import random
from typing import Set, Dict, List

class NetworkPartition:
    def __init__(self):
        self.partitions: Dict[str, Set[str]] = {}
        self.blocked_connections: Set[tuple] = set()
    
    def create_partition(self, group1: List[str], group2: List[str]):
        """Create network partition between two groups"""
        print(f"Creating partition: {group1} | {group2}")
        
        for node1 in group1:
            for node2 in group2:
                self.blocked_connections.add((node1, node2))
                self.blocked_connections.add((node2, node1))
    
    def heal_partition(self):
        """Heal all network partitions"""
        print("Healing network partition")
        self.blocked_connections.clear()
    
    def can_communicate(self, node1: str, node2: str) -> bool:
        """Check if two nodes can communicate"""
        return (node1, node2) not in self.blocked_connections

class PartitionTolerantSystem:
    def __init__(self, node_id: str, peers: List[str], network: NetworkPartition):
        self.node_id = node_id
        self.peers = peers
        self.network = network
        self.data = {}
        self.is_available = True
        
    def write(self, key: str, value: str) -> bool:
        """Write data with partition tolerance"""
        if not self.is_available:
            return False
        
        # Check how many peers are reachable
        reachable_peers = []
        for peer in self.peers:
            if self.network.can_communicate(self.node_id, peer):
                reachable_peers.append(peer)
        
        # Need majority for write to succeed
        total_nodes = len(self.peers) + 1  # including self
        if len(reachable_peers) + 1 > total_nodes // 2:
            self.data[key] = value
            print(f"Node {self.node_id}: Write {key}={value} (reachable: {len(reachable_peers)})")
            return True
        else:
            print(f"Node {self.node_id}: Write failed - insufficient replicas")
            return False
    
    def read(self, key: str) -> str:
        """Read data (always available from local copy)"""
        if not self.is_available:
            return None
        
        value = self.data.get(key, "NOT_FOUND")
        print(f"Node {self.node_id}: Read {key}={value}")
        return value
    
    def set_availability(self, available: bool):
        """Simulate node failure"""
        self.is_available = available
        status = "online" if available else "offline"
        print(f"Node {self.node_id}: {status}")

def test_partition_tolerance():
    """Test system behavior under network partitions"""
    
    # Create network partition simulator
    network = NetworkPartition()
    
    # Create nodes
    nodes = [
        PartitionTolerantSystem("A", ["B", "C"], network),
        PartitionTolerantSystem("B", ["A", "C"], network),
        PartitionTolerantSystem("C", ["A", "B"], network)
    ]
    
    print("=== Phase 1: Normal Operation ===")
    nodes[0].write("key1", "value1")
    nodes[1].write("key2", "value2")
    
    for node in nodes:
        node.read("key1")
        node.read("key2")
    
    print("\n=== Phase 2: Create Network Partition ===")
    # Partition: A,B | C
    network.create_partition(["A", "B"], ["C"])
    
    # Writes should still work in majority partition
    nodes[0].write("key3", "value3")  # Should succeed (A+B = majority)
    nodes[2].write("key4", "value4")  # Should fail (C alone = minority)
    
    print("\n=== Phase 3: Node Failure ===")
    # Simulate node B failure
    nodes[1].set_availability(False)
    
    # Now A is alone and should not be able to write
    nodes[0].write("key5", "value5")  # Should fail
    
    # But reads should still work
    nodes[0].read("key1")
    
    print("\n=== Phase 4: Heal Partition ===")
    network.heal_partition()
    nodes[1].set_availability(True)
    
    # System should work normally again
    nodes[0].write("key6", "value6")  # Should succeed
    
    print("\n=== Final State ===")
    for node in nodes:
        print(f"Node {node.node_id} data: {node.data}")

if __name__ == "__main__":
    test_partition_tolerance()
```

## 🚀 Mini-Project: Distributed Cache

**Objective**: Build a distributed cache that demonstrates all the concepts learned.

**Requirements**:
1. Multiple cache nodes with consistent hashing
2. Configurable consistency levels (strong, eventual)
3. Fault tolerance with automatic failover
4. Network partition handling

**Architecture**:
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Client    │    │   Client    │    │   Client    │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │
       └──────────────────┼──────────────────┘
                          │
              ┌───────────┴───────────┐
              │    Load Balancer      │
              └───────────┬───────────┘
                          │
         ┌────────────────┼────────────────┐
         │                │                │
    ┌────▼────┐      ┌────▼────┐      ┌────▼────┐
    │ Cache   │◄────►│ Cache   │◄────►│ Cache   │
    │ Node 1  │      │ Node 2  │      │ Node 3  │
    └─────────┘      └─────────┘      └─────────┘
```

**Implementation Template**:
```python
# distributed_cache.py
import hashlib
import time
import threading
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from enum import Enum

class ConsistencyLevel(Enum):
    STRONG = "strong"
    EVENTUAL = "eventual"

@dataclass
class CacheEntry:
    value: str
    timestamp: float
    version: int

class ConsistentHashing:
    def __init__(self, nodes: List[str], replicas: int = 3):
        self.nodes = nodes
        self.replicas = replicas
        self.ring = {}
        self._build_ring()
    
    def _build_ring(self):
        """Build consistent hash ring"""
        for node in self.nodes:
            for i in range(self.replicas):
                key = self._hash(f"{node}:{i}")
                self.ring[key] = node
    
    def _hash(self, key: str) -> int:
        """Hash function for consistent hashing"""
        return int(hashlib.md5(key.encode()).hexdigest(), 16)
    
    def get_nodes(self, key: str, count: int = 1) -> List[str]:
        """Get nodes responsible for a key"""
        if not self.ring:
            return []
        
        key_hash = self._hash(key)
        nodes = []
        
        # Find position in ring
        sorted_hashes = sorted(self.ring.keys())
        idx = 0
        for i, hash_val in enumerate(sorted_hashes):
            if hash_val >= key_hash:
                idx = i
                break
        
        # Get nodes starting from position
        seen_nodes = set()
        for i in range(len(sorted_hashes)):
            pos = (idx + i) % len(sorted_hashes)
            node = self.ring[sorted_hashes[pos]]
            if node not in seen_nodes:
                nodes.append(node)
                seen_nodes.add(node)
                if len(nodes) >= count:
                    break
        
        return nodes

class DistributedCacheNode:
    def __init__(self, node_id: str, port: int, peers: List[Tuple[str, int]]):
        self.node_id = node_id
        self.port = port
        self.peers = peers
        self.data: Dict[str, CacheEntry] = {}
        self.is_available = True
        self.lock = threading.RLock()
        
        # Consistent hashing setup
        all_nodes = [node_id] + [peer[0] for peer in peers]
        self.hash_ring = ConsistentHashing(all_nodes)
    
    def get(self, key: str, consistency: ConsistencyLevel = ConsistencyLevel.EVENTUAL) -> Optional[str]:
        """Get value from cache"""
        with self.lock:
            if not self.is_available:
                return None
            
            if consistency == ConsistencyLevel.STRONG:
                return self._strong_get(key)
            else:
                entry = self.data.get(key)
                return entry.value if entry else None
    
    def put(self, key: str, value: str, consistency: ConsistencyLevel = ConsistencyLevel.EVENTUAL) -> bool:
        """Put value in cache"""
        with self.lock:
            if not self.is_available:
                return False
            
            if consistency == ConsistencyLevel.STRONG:
                return self._strong_put(key, value)
            else:
                return self._eventual_put(key, value)
    
    def _strong_get(self, key: str) -> Optional[str]:
        """Strong consistency read - read from majority"""
        responsible_nodes = self.hash_ring.get_nodes(key, 3)
        
        if self.node_id in responsible_nodes:
            # Get local value
            local_entry = self.data.get(key)
            
            # TODO: Read from majority of responsible nodes
            # For now, return local value
            return local_entry.value if local_entry else None
        
        return None
    
    def _strong_put(self, key: str, value: str) -> bool:
        """Strong consistency write - write to majority"""
        responsible_nodes = self.hash_ring.get_nodes(key, 3)
        
        if self.node_id not in responsible_nodes:
            return False
        
        # Create entry
        entry = CacheEntry(
            value=value,
            timestamp=time.time(),
            version=self._get_next_version(key)
        )
        
        self.data[key] = entry
        
        # TODO: Replicate to other responsible nodes
        # For now, just store locally
        print(f"Node {self.node_id}: PUT {key}={value} (strong)")
        return True
    
    def _eventual_put(self, key: str, value: str) -> bool:
        """Eventual consistency write"""
        entry = CacheEntry(
            value=value,
            timestamp=time.time(),
            version=self._get_next_version(key)
        )
        
        self.data[key] = entry
        
        # Asynchronously replicate to responsible nodes
        threading.Thread(
            target=self._async_replicate,
            args=(key, entry),
            daemon=True
        ).start()
        
        print(f"Node {self.node_id}: PUT {key}={value} (eventual)")
        return True
    
    def _get_next_version(self, key: str) -> int:
        """Get next version number for key"""
        entry = self.data.get(key)
        return (entry.version + 1) if entry else 1
    
    def _async_replicate(self, key: str, entry: CacheEntry):
        """Asynchronously replicate to other nodes"""
        responsible_nodes = self.hash_ring.get_nodes(key, 3)
        
        for node_id in responsible_nodes:
            if node_id != self.node_id:
                # TODO: Send replication request to peer
                # For simulation, we'll just log
                print(f"Node {self.node_id}: Replicating {key} to {node_id}")
    
    def get_stats(self) -> Dict:
        """Get node statistics"""
        return {
            'node_id': self.node_id,
            'available': self.is_available,
            'keys': len(self.data),
            'memory_usage': sum(len(str(entry.value)) for entry in self.data.values())
        }

def test_distributed_cache():
    """Test the distributed cache"""
    
    # Create cache nodes
    nodes = [
        DistributedCacheNode("node1", 8001, [("node2", 8002), ("node3", 8003)]),
        DistributedCacheNode("node2", 8002, [("node1", 8001), ("node3", 8003)]),
        DistributedCacheNode("node3", 8003, [("node1", 8001), ("node2", 8002)])
    ]
    
    print("=== Testing Distributed Cache ===")
    
    # Test eventual consistency
    print("\n--- Eventual Consistency Test ---")
    nodes[0].put("user:1", "John Doe", ConsistencyLevel.EVENTUAL)
    nodes[1].put("user:2", "Jane Smith", ConsistencyLevel.EVENTUAL)
    nodes[2].put("user:3", "Bob Johnson", ConsistencyLevel.EVENTUAL)
    
    time.sleep(0.1)  # Allow replication
    
    # Read from different nodes
    for i, node in enumerate(nodes):
        for key in ["user:1", "user:2", "user:3"]:
            value = node.get(key, ConsistencyLevel.EVENTUAL)
            print(f"Node {i+1} read {key}: {value}")
    
    # Test strong consistency
    print("\n--- Strong Consistency Test ---")
    nodes[0].put("config:timeout", "30", ConsistencyLevel.STRONG)
    
    for i, node in enumerate(nodes):
        value = node.get("config:timeout", ConsistencyLevel.STRONG)
        print(f"Node {i+1} strong read config:timeout: {value}")
    
    # Print statistics
    print("\n--- Node Statistics ---")
    for node in nodes:
        print(f"Node {node.node_id}: {node.get_stats()}")

if __name__ == "__main__":
    test_distributed_cache()
```

## 📊 Assessment & Next Steps

### Knowledge Check
1. **Explain the CAP theorem** and how it applies to your data warehouse components
2. **Implement leader election** in a distributed system
3. **Design a fault-tolerant system** that handles network partitions
4. **Compare consistency models** and their trade-offs

### Project Deliverables
- [ ] Working CAP theorem demonstration
- [ ] Simplified Raft consensus implementation  
- [ ] Network partition simulation
- [ ] Distributed cache with configurable consistency

### Real-world Applications
**How these concepts apply to your data warehouse:**

1. **MinIO (Object Storage)**:
   - Uses eventual consistency for high availability
   - Implements erasure coding for fault tolerance
   - Handles network partitions gracefully

2. **Apache Iceberg (Table Format)**:
   - Provides ACID transactions through optimistic concurrency
   - Uses snapshot isolation for consistent reads
   - Handles concurrent writers through version control

3. **Trino (Query Engine)**:
   - Coordinator uses strong consistency for query planning
   - Workers can operate with eventual consistency
   - Implements fault tolerance through query retries

4. **Apache Kafka (Streaming)**:
   - Uses leader-follower replication for fault tolerance
   - Provides configurable consistency guarantees
   - Handles broker failures through partition reassignment

### Next Module Preview
**Module 2: Container Orchestration** will cover:
- Docker fundamentals and best practices
- Kubernetes architecture and deployment
- Service mesh and networking
- Auto-scaling and resource management

The distributed systems concepts you've learned will be essential for understanding how containerized services coordinate and maintain consistency across your data warehouse infrastructure.

---

**Module 1 Complete!** 🎉 You now have a solid foundation in distributed systems concepts that underpin modern data infrastructure. These principles will guide your decisions throughout the rest of the bootcamp as you build scalable, fault-tolerant systems.
