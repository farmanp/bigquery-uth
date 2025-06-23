# Module 7: Trino Query Engine

Welcome to the Trino Query Engine module! This is the heart of your BigQuery-equivalent system - a distributed SQL query engine that provides the compute layer for your lakehouse architecture. You'll learn MPP query processing, federated analytics, and performance optimization.

## 🎯 Learning Objectives

By the end of this module, you will:
- Master Trino's distributed MPP (Massively Parallel Processing) architecture
- Deploy and configure Trino clusters with auto-scaling
- Optimize query performance through cost-based optimization
- Implement federated queries across multiple data sources
- Monitor and troubleshoot distributed query execution

## 📚 Module Overview

### Duration: 1.5 Weeks (30 hours)
- **Architecture & Theory**: 8 hours
- **Deployment & Configuration**: 10 hours
- **Performance Optimization**: 8 hours
- **Advanced Features**: 4 hours

### Prerequisites
- Distributed systems fundamentals (Module 1)
- Object storage and Iceberg knowledge (Modules 3-4)
- SQL query optimization concepts
- Container orchestration basics

## 🧠 Core Concepts

### 1. Trino Architecture

**Distributed Query Processing**

```
┌─────────────────────────────────────────────────────────────┐
│                    Trino Cluster                           │
├─────────────────────────────────────────────────────────────┤
│  Coordinator Node                                          │
│  ├── Query Planner (SQL → Execution Plan)                 │
│  ├── Scheduler (Task Distribution)                         │
│  ├── Metadata Manager (Catalog Integration)               │
│  └── Client Interface (HTTP API, JDBC)                    │
├─────────────────────────────────────────────────────────────┤
│  Worker Nodes (Auto-scaling Pool)                         │
│  ├── Worker 1: Task Executor + Memory Pool                │
│  ├── Worker 2: Task Executor + Memory Pool                │
│  ├── Worker 3: Task Executor + Memory Pool                │
│  └── Worker N: Task Executor + Memory Pool                │
├─────────────────────────────────────────────────────────────┤
│  Data Sources (via Connectors)                            │
│  ├── Iceberg (Lakehouse Tables)                          │
│  ├── PostgreSQL (OLTP Database)                          │
│  ├── MySQL (Application Database)                        │
│  ├── Kafka (Streaming Data)                              │
│  └── 400+ Other Connectors                               │
└─────────────────────────────────────────────────────────────┘
```

**Key Components**:

1. **Coordinator**: Query planning, optimization, and execution coordination
2. **Workers**: Parallel task execution with in-memory processing
3. **Connectors**: Pluggable data source integrations
4. **Memory Management**: Unified memory pools with spill-to-disk
5. **Cost-Based Optimizer**: Statistics-driven query optimization

### 2. Query Execution Model

**Pipeline Execution with Vectorization**

```python
# Conceptual Trino query execution model
class TrinoQueryExecution:
    def __init__(self, sql_query):
        self.sql_query = sql_query
        self.logical_plan = None
        self.physical_plan = None
        self.stages = []
    
    def parse_and_analyze(self):
        """Parse SQL and create logical plan"""
        # 1. Parse SQL into AST
        ast = self.parse_sql(self.sql_query)
        
        # 2. Semantic analysis and validation
        self.validate_tables_and_columns(ast)
        
        # 3. Create logical plan
        self.logical_plan = self.create_logical_plan(ast)
        
        return self.logical_plan
    
    def optimize_plan(self):
        """Apply cost-based optimizations"""
        optimizer = CostBasedOptimizer()
        
        # Rule-based optimizations
        self.logical_plan = optimizer.apply_rules([
            "predicate_pushdown",
            "projection_pushdown", 
            "join_reordering",
            "constant_folding",
            "dead_code_elimination"
        ], self.logical_plan)
        
        # Cost-based optimizations
        table_stats = self.collect_table_statistics()
        self.physical_plan = optimizer.choose_join_algorithms(
            self.logical_plan, table_stats
        )
        
        return self.physical_plan
    
    def create_execution_stages(self):
        """Break plan into distributed stages"""
        stage_builder = StageBuilder()
        
        # Create stages at exchange boundaries
        self.stages = stage_builder.fragment_plan(self.physical_plan)
        
        # Each stage runs on one or more workers
        for stage in self.stages:
            stage.parallelism = self.calculate_parallelism(stage)
        
        return self.stages
    
    def execute_pipeline(self):
        """Execute query with pipelined processing"""
        scheduler = QueryScheduler()
        
        # Schedule stages in dependency order
        for stage in self.stages:
            tasks = scheduler.create_tasks(stage)
            
            # Execute tasks in parallel across workers
            results = scheduler.execute_parallel(tasks)
            
            # Pipeline results to next stage
            scheduler.pipeline_results(results, stage.downstream_stages)
        
        return scheduler.get_final_results()

# Example vectorized processing
class VectorizedProcessor:
    def __init__(self, batch_size=65536):  # 64K row batches
        self.batch_size = batch_size
    
    def process_filter(self, column_batch, predicate):
        """Apply filter to entire column batch"""
        # SIMD-optimized filtering
        return column_batch.apply_vectorized_filter(predicate)
    
    def process_aggregation(self, column_batches, group_keys, agg_functions):
        """Vectorized hash aggregation"""
        hash_table = VectorizedHashTable()
        
        for batch in column_batches:
            hash_table.aggregate_batch(batch, group_keys, agg_functions)
        
        return hash_table.get_results()
```

### 3. Cost-Based Optimization

**Statistics Collection and Query Planning**

```python
# Cost-based optimization example
class CostBasedOptimizer:
    def __init__(self):
        self.statistics_store = StatisticsStore()
    
    def estimate_join_cost(self, left_table, right_table, join_condition):
        """Estimate cost of different join algorithms"""
        left_stats = self.statistics_store.get_table_stats(left_table)
        right_stats = self.statistics_store.get_table_stats(right_table)
        
        # Hash join cost estimation
        hash_join_cost = self.estimate_hash_join_cost(
            left_stats.row_count, 
            right_stats.row_count,
            left_stats.column_stats[join_condition.left_column],
            right_stats.column_stats[join_condition.right_column]
        )
        
        # Broadcast join cost (if one side is small)
        broadcast_join_cost = float('inf')
        if left_stats.size_bytes < 100 * 1024 * 1024:  # 100MB threshold
            broadcast_join_cost = self.estimate_broadcast_join_cost(
                left_stats, right_stats
            )
        
        # Choose best algorithm
        if hash_join_cost <= broadcast_join_cost:
            return JoinPlan("HASH", hash_join_cost)
        else:
            return JoinPlan("BROADCAST", broadcast_join_cost)
    
    def estimate_hash_join_cost(self, left_rows, right_rows, left_col_stats, right_col_stats):
        """Estimate hash join cost"""
        # Build cost: scan smaller table + build hash table
        build_rows = min(left_rows, right_rows)
        build_cost = build_rows * 1.2  # Factor for hash table overhead
        
        # Probe cost: scan larger table + probe hash table
        probe_rows = max(left_rows, right_rows)
        probe_cost = probe_rows * 1.1
        
        # Selectivity estimation
        selectivity = self.estimate_selectivity(left_col_stats, right_col_stats)
        output_rows = left_rows * right_rows * selectivity
        
        return build_cost + probe_cost + output_rows * 0.1
    
    def optimize_join_order(self, tables, join_conditions):
        """Dynamic programming join ordering"""
        n = len(tables)
        if n <= 2:
            return self.create_join_tree(tables, join_conditions)
        
        # Use dynamic programming for optimal join order
        dp = {}
        
        # Base case: single tables
        for i, table in enumerate(tables):
            dp[frozenset([i])] = (table, 0)
        
        # Build up optimal subplans
        for size in range(2, n + 1):
            for subset in self.generate_subsets(n, size):
                best_cost = float('inf')
                best_plan = None
                
                # Try all ways to split the subset
                for left_subset in self.generate_splits(subset):
                    right_subset = subset - left_subset
                    
                    if left_subset in dp and right_subset in dp:
                        left_plan, left_cost = dp[left_subset]
                        right_plan, right_cost = dp[right_subset]
                        
                        join_cost = self.estimate_join_cost(
                            left_plan, right_plan, join_conditions
                        )
                        
                        total_cost = left_cost + right_cost + join_cost
                        
                        if total_cost < best_cost:
                            best_cost = total_cost
                            best_plan = JoinNode(left_plan, right_plan)
                
                dp[subset] = (best_plan, best_cost)
        
        return dp[frozenset(range(n))][0]
```

### 4. Memory Management

**Unified Memory Architecture**

```python
class TrinoMemoryManager:
    def __init__(self, total_memory_gb=32):
        self.total_memory = total_memory_gb * 1024 * 1024 * 1024
        self.general_pool = MemoryPool(self.total_memory * 0.8)  # 80% for queries
        self.reserved_pool = MemoryPool(self.total_memory * 0.2)  # 20% reserved
        self.query_memory = {}
    
    def allocate_query_memory(self, query_id, estimated_memory):
        """Allocate memory for query execution"""
        if self.general_pool.can_allocate(estimated_memory):
            allocated = self.general_pool.allocate(estimated_memory)
            self.query_memory[query_id] = allocated
            return allocated
        else:
            # Try reserved pool for high-priority queries
            if self.reserved_pool.can_allocate(estimated_memory):
                allocated = self.reserved_pool.allocate(estimated_memory)
                self.query_memory[query_id] = allocated
                return allocated
            else:
                # Trigger spill-to-disk or query killing
                return self.handle_memory_pressure(query_id, estimated_memory)
    
    def handle_memory_pressure(self, query_id, requested_memory):
        """Handle out-of-memory situations"""
        # 1. Try to spill existing operations to disk
        spilled_memory = self.spill_operations_to_disk()
        
        if spilled_memory >= requested_memory:
            return self.general_pool.allocate(requested_memory)
        
        # 2. Kill lowest priority queries
        killed_memory = self.kill_low_priority_queries()
        
        if spilled_memory + killed_memory >= requested_memory:
            return self.general_pool.allocate(requested_memory)
        
        # 3. Reject the query
        raise OutOfMemoryException(f"Cannot allocate {requested_memory} bytes")
    
    def spill_operations_to_disk(self):
        """Spill hash tables and sort buffers to disk"""
        spilled = 0
        
        for operation in self.get_spillable_operations():
            if operation.can_spill():
                spilled += operation.spill_to_disk()
        
        return spilled

class SpillableHashTable:
    def __init__(self, memory_limit):
        self.memory_limit = memory_limit
        self.in_memory_partitions = {}
        self.spilled_partitions = {}
        self.spill_threshold = memory_limit * 0.8
    
    def put(self, key, value):
        """Insert key-value pair with automatic spilling"""
        partition = self.hash_partition(key)
        
        if partition not in self.in_memory_partitions:
            self.in_memory_partitions[partition] = {}
        
        self.in_memory_partitions[partition][key] = value
        
        # Check if we need to spill
        if self.get_memory_usage() > self.spill_threshold:
            self.spill_largest_partition()
    
    def spill_largest_partition(self):
        """Spill the largest partition to disk"""
        largest_partition = max(
            self.in_memory_partitions.keys(),
            key=lambda p: len(self.in_memory_partitions[p])
        )
        
        partition_data = self.in_memory_partitions.pop(largest_partition)
        spill_file = self.create_spill_file(largest_partition)
        spill_file.write(partition_data)
        
        self.spilled_partitions[largest_partition] = spill_file
    
    def get(self, key):
        """Get value with transparent spill handling"""
        partition = self.hash_partition(key)
        
        if partition in self.in_memory_partitions:
            return self.in_memory_partitions[partition].get(key)
        elif partition in self.spilled_partitions:
            # Read from spilled partition
            spill_file = self.spilled_partitions[partition]
            return spill_file.get(key)
        else:
            return None
```

## 🛠 Hands-on Labs

### Lab 1: Trino Cluster Deployment

**Objective**: Deploy a production-ready Trino cluster with coordinator and workers.

**Setup**:
```bash
# Create lab directory
mkdir -p 07-trino-engine/labs/cluster-deployment
cd 07-trino-engine/labs/cluster-deployment
```

**Docker Compose Configuration**:
```yaml
# docker-compose.yml
version: '3.8'

services:
  # Trino Coordinator
  trino-coordinator:
    image: trinodb/trino:latest
    hostname: trino-coordinator
    container_name: trino-coordinator
    ports:
      - "8080:8080"  # Web UI and API
    environment:
      - TRINO_ENVIRONMENT=production
    volumes:
      - ./trino-coordinator/etc:/etc/trino
      - ./trino-coordinator/catalog:/etc/trino/catalog
    networks:
      - trino-cluster
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8080/v1/info || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5

  # Trino Workers
  trino-worker-1:
    image: trinodb/trino:latest
    hostname: trino-worker-1
    container_name: trino-worker-1
    environment:
      - TRINO_ENVIRONMENT=production
    volumes:
      - ./trino-worker/etc:/etc/trino
      - ./trino-worker/catalog:/etc/trino/catalog
    networks:
      - trino-cluster
    depends_on:
      - trino-coordinator

  trino-worker-2:
    image: trinodb/trino:latest
    hostname: trino-worker-2
    container_name: trino-worker-2
    environment:
      - TRINO_ENVIRONMENT=production
    volumes:
      - ./trino-worker/etc:/etc/trino
      - ./trino-worker/catalog:/etc/trino/catalog
    networks:
      - trino-cluster
    depends_on:
      - trino-coordinator

  trino-worker-3:
    image: trinodb/trino:latest
    hostname: trino-worker-3
    container_name: trino-worker-3
    environment:
      - TRINO_ENVIRONMENT=production
    volumes:
      - ./trino-worker/etc:/etc/trino
      - ./trino-worker/catalog:/etc/trino/catalog
    networks:
      - trino-cluster
    depends_on:
      - trino-coordinator

  # Supporting services from previous modules
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: metastore
      POSTGRES_USER: hive
      POSTGRES_PASSWORD: hive123
    ports:
      - "5432:5432"
    networks:
      - trino-cluster

  hive-metastore:
    image: apache/hive:3.1.3
    depends_on:
      - postgres
    environment:
      SERVICE_NAME: metastore
      DB_DRIVER: postgres
      SERVICE_OPTS: "-Djavax.jdo.option.ConnectionDriverName=org.postgresql.Driver
                     -Djavax.jdo.option.ConnectionURL=jdbc:postgresql://postgres:5432/metastore
                     -Djavax.jdo.option.ConnectionUserName=hive
                     -Djavax.jdo.option.ConnectionPassword=hive123"
    ports:
      - "9083:9083"
    networks:
      - trino-cluster

  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9090"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin123
    ports:
      - "9000:9000"
      - "9090:9090"
    networks:
      - trino-cluster

networks:
  trino-cluster:
    driver: bridge
```

**Trino Coordinator Configuration**:
```bash
# Create coordinator configuration
mkdir -p trino-coordinator/etc trino-coordinator/catalog

# Node properties
cat > trino-coordinator/etc/node.properties << 'EOF'
node.environment=production
node.id=coordinator
node.data-dir=/data/trino
EOF

# JVM configuration
cat > trino-coordinator/etc/jvm.config << 'EOF'
-server
-Xmx4G
-XX:InitialRAMPercentage=80
-XX:MaxRAMPercentage=80
-XX:G1HeapRegionSize=32M
-XX:+ExplicitGCInvokesConcurrent
-XX:+HeapDumpOnOutOfMemoryError
-XX:+UseG1GC
-XX:+UseGCOverheadLimit
-XX:+ExitOnOutOfMemoryError
-Djdk.attach.allowAttachSelf=true
EOF

# Coordinator configuration
cat > trino-coordinator/etc/config.properties << 'EOF'
coordinator=true
node-scheduler.include-coordinator=false
http-server.http.port=8080
discovery.uri=http://trino-coordinator:8080

# Memory configuration
query.max-memory=2GB
query.max-memory-per-node=1GB
query.max-total-memory=4GB

# Performance tuning
query.max-run-time=30m
query.client.timeout=10m
query.min-expire-age=30m

# Spill configuration
spill-enabled=true
spiller-spill-path=/tmp/trino-spill
spiller-max-used-space-threshold=0.8

# Security (basic)
http-server.authentication.type=PASSWORD
http-server.https.enabled=false

# Web UI
web-ui.enabled=true
EOF

# Password authentication
cat > trino-coordinator/etc/password-authenticator.properties << 'EOF'
password-authenticator.name=file
file.password-file=/etc/trino/password.db
EOF

# Create password file (admin/admin123)
echo 'admin:$2y$10$yD8lUE7vN1oRqnL9pJ8QjOb.wKLnERGSH3VjvgE8JVj8VcvvzAO5u' > trino-coordinator/etc/password.db

# Log levels
cat > trino-coordinator/etc/log.properties << 'EOF'
io.trino=INFO
io.trino.server.security=DEBUG
io.trino.plugin.hive=DEBUG
EOF
```

**Trino Worker Configuration**:
```bash
# Create worker configuration
mkdir -p trino-worker/etc trino-worker/catalog

# Node properties (will be overridden by hostname)
cat > trino-worker/etc/node.properties << 'EOF'
node.environment=production
node.data-dir=/data/trino
EOF

# JVM configuration
cat > trino-worker/etc/jvm.config << 'EOF'
-server
-Xmx6G
-XX:InitialRAMPercentage=80
-XX:MaxRAMPercentage=80
-XX:G1HeapRegionSize=32M
-XX:+ExplicitGCInvokesConcurrent
-XX:+HeapDumpOnOutOfMemoryError
-XX:+UseG1GC
-XX:+UseGCOverheadLimit
-XX:+ExitOnOutOfMemoryError
-Djdk.attach.allowAttachSelf=true
EOF

# Worker configuration
cat > trino-worker/etc/config.properties << 'EOF'
coordinator=false
http-server.http.port=8080
discovery.uri=http://trino-coordinator:8080

# Memory configuration (larger for workers)
query.max-memory-per-node=4GB

# Spill configuration
spill-enabled=true
spiller-spill-path=/tmp/trino-spill
spiller-max-used-space-threshold=0.8

# Task configuration
task.concurrency=16
task.max-worker-threads=16
task.http-response-threads=100
task.http-timeout-threads=3

# Exchange configuration
exchange.http-client.max-connections=1000
exchange.http-client.max-connections-per-server=1000
EOF

# Log levels
cp trino-coordinator/etc/log.properties trino-worker/etc/
```

**Catalog Configurations**:
```bash
# Iceberg catalog
cat > trino-coordinator/catalog/iceberg.properties << 'EOF'
connector.name=iceberg
hive.metastore.uri=thrift://hive-metastore:9083
iceberg.catalog.type=hive
hive.s3.endpoint=http://minio:9000
hive.s3.path-style-access=true
hive.s3.aws-access-key=minioadmin
hive.s3.aws-secret-key=minioadmin123
hive.s3.ssl.enabled=false
iceberg.register-table-procedure.enabled=true
EOF

# PostgreSQL catalog
cat > trino-coordinator/catalog/postgresql.properties << 'EOF'
connector.name=postgresql
connection-url=jdbc:postgresql://postgres:5432/metastore
connection-user=hive
connection-password=hive123
EOF

# System catalog (built-in)
cat > trino-coordinator/catalog/system.properties << 'EOF'
connector.name=system
EOF

# Copy catalogs to worker directory
cp -r trino-coordinator/catalog/* trino-worker/catalog/
```

**Trino Testing Script**:
```python
# test_trino_cluster.py
import requests
import time
import json
from urllib.parse import urljoin

class TrinoClient:
    def __init__(self, coordinator_url="http://localhost:8080", user="admin", password="admin123"):
        self.coordinator_url = coordinator_url
        self.user = user
        self.password = password
        self.session = requests.Session()
        self.session.auth = (user, password)
    
    def execute_query(self, sql, catalog="iceberg", schema="default"):
        """Execute SQL query and return results"""
        headers = {
            'X-Trino-User': self.user,
            'X-Trino-Catalog': catalog,
            'X-Trino-Schema': schema,
            'Content-Type': 'text/plain'
        }
        
        # Submit query
        response = self.session.post(
            urljoin(self.coordinator_url, '/v1/statement'),
            data=sql,
            headers=headers
        )
        
        if response.status_code != 200:
            raise Exception(f"Query submission failed: {response.text}")
        
        query_info = response.json()
        next_uri = query_info['nextUri']
        
        # Poll for results
        results = []
        while next_uri:
            response = self.session.get(next_uri)
            if response.status_code != 200:
                raise Exception(f"Query polling failed: {response.text}")
            
            query_info = response.json()
            
            # Collect data if available
            if 'data' in query_info:
                results.extend(query_info['data'])
            
            # Check if query is complete
            if query_info['stats']['state'] in ['FINISHED', 'FAILED', 'CANCELED']:
                break
                
            next_uri = query_info.get('nextUri')
            time.sleep(0.1)  # Brief pause between polls
        
        if query_info['stats']['state'] == 'FAILED':
            raise Exception(f"Query failed: {query_info.get('error', {}).get('message', 'Unknown error')}")
        
        return {
            'columns': query_info.get('columns', []),
            'data': results,
            'stats': query_info['stats']
        }
    
    def get_cluster_info(self):
        """Get cluster information"""
        response = self.session.get(urljoin(self.coordinator_url, '/v1/cluster'))
        if response.status_code == 200:
            return response.json()
        else:
            raise Exception(f"Failed to get cluster info: {response.text}")
    
    def get_query_info(self, query_id):
        """Get detailed query information"""
        response = self.session.get(urljoin(self.coordinator_url, f'/v1/query/{query_id}'))
        if response.status_code == 200:
            return response.json()
        else:
            raise Exception(f"Failed to get query info: {response.text}")

def test_cluster_deployment():
    """Test Trino cluster deployment"""
    print("🚀 Testing Trino Cluster Deployment")
    
    # Wait for cluster to be ready
    print("⏳ Waiting for cluster startup...")
    time.sleep(60)
    
    client = TrinoClient()
    
    try:
        # Test 1: Cluster information
        print("\n=== Test 1: Cluster Information ===")
        cluster_info = client.get_cluster_info()
        print(f"📊 Running queries: {cluster_info.get('runningQueries', 0)}")
        print(f"📊 Blocked queries: {cluster_info.get('blockedQueries', 0)}")
        print(f"📊 Active workers: {cluster_info.get('activeWorkers', 0)}")
        
        # Test 2: Basic system query
        print("\n=== Test 2: System Query ===")
        result = client.execute_query("SELECT node_id, http_uri, node_version FROM system.runtime.nodes", "system")
        print("📊 Cluster nodes:")
        for row in result['data']:
            print(f"  Node: {row[0]}, URI: {row[1]}, Version: {row[2]}")
        
        # Test 3: Show catalogs
        print("\n=== Test 3: Available Catalogs ===")
        result = client.execute_query("SHOW CATALOGS", "system")
        print("📊 Available catalogs:")
        for row in result['data']:
            print(f"  Catalog: {row[0]}")
        
        # Test 4: Test Iceberg integration
        print("\n=== Test 4: Iceberg Integration ===")
        try:
            result = client.execute_query("SHOW SCHEMAS FROM iceberg")
            print("📊 Iceberg schemas:")
            for row in result['data']:
                print(f"  Schema: {row[0]}")
        except Exception as e:
            print(f"⚠️  Iceberg not ready yet: {e}")
        
        # Test 5: Performance test
        print("\n=== Test 5: Performance Test ===")
        test_sql = """
        SELECT 
            n,
            n * n as square,
            n * n * n as cube
        FROM (
            SELECT sequence(1, 1000000) as numbers
        ) t(nums)
        CROSS JOIN UNNEST(nums) as t(n)
        WHERE n % 10000 = 0
        ORDER BY n
        """
        
        start_time = time.time()
        result = client.execute_query(test_sql, "system")
        execution_time = time.time() - start_time
        
        print(f"📈 Query executed in {execution_time:.2f} seconds")
        print(f"📊 Rows returned: {len(result['data'])}")
        print(f"📊 Sample results: {result['data'][:3]}")
        
        print("\n✅ All tests passed! Trino cluster is operational.")
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_cluster_deployment()
```

**Run the Lab**:
```bash
# Start the cluster
docker-compose up -d

# Wait for startup
sleep 90

# Test the cluster
python test_trino_cluster.py

# Access Trino Web UI
echo "Trino Web UI: http://localhost:8080"
echo "Login: admin / admin123"
```

### Lab 2: Query Optimization

**Objective**: Understand and implement query optimization techniques in Trino.

```python
# query_optimization.py
import time
from test_trino_cluster import TrinoClient

class QueryOptimizer:
    def __init__(self):
        self.client = TrinoClient()
    
    def create_test_tables(self):
        """Create test tables for optimization examples"""
        print("🏗️  Creating test tables...")
        
        # Create large fact table
        self.client.execute_query("""
            CREATE TABLE iceberg.tpch.orders AS
            SELECT 
                orderkey,
                custkey,
                orderstatus,
                totalprice,
                orderdate,
                orderpriority,
                clerk,
                shippriority,
                'ORDER_' || CAST(orderkey AS VARCHAR) as order_comment
            FROM (
                SELECT 
                    row_number() OVER () as orderkey,
                    (random() * 100000)::BIGINT as custkey,
                    CASE 
                        WHEN random() < 0.5 THEN 'O'
                        WHEN random() < 0.8 THEN 'P' 
                        ELSE 'F'
                    END as orderstatus,
                    (random() * 500000)::DECIMAL(12,2) as totalprice,
                    DATE '1992-01-01' + INTERVAL '1' DAY * (random() * 2557)::INTEGER as orderdate,
                    CASE 
                        WHEN random() < 0.2 THEN '1-URGENT'
                        WHEN random() < 0.4 THEN '2-HIGH'
                        WHEN random() < 0.6 THEN '3-MEDIUM' 
                        WHEN random() < 0.8 THEN '4-NOT SPECIFIED'
                        ELSE '5-LOW'
                    END as orderpriority,
                    'Clerk#' || LPAD(CAST((random() * 1000)::INTEGER AS VARCHAR), 9, '0') as clerk,
                    (random() * 7)::INTEGER as shippriority
                FROM (
                    SELECT sequence(1, 1000000) as numbers
                ) t(nums)
                CROSS JOIN UNNEST(nums) as t(n)
            ) generated_data
        """)
        
        # Create dimension table
        self.client.execute_query("""
            CREATE TABLE iceberg.tpch.customer AS
            SELECT 
                custkey,
                name,
                address,
                nationkey,
                phone,
                acctbal,
                mktsegment,
                'Customer comment for ' || CAST(custkey AS VARCHAR) as comment
            FROM (
                SELECT 
                    custkey,
                    'Customer#' || LPAD(CAST(custkey AS VARCHAR), 9, '0') as name,
                    'Address for customer ' || CAST(custkey AS VARCHAR) as address,
                    (random() * 25)::INTEGER as nationkey,
                    LPAD(CAST((random() * 999999999)::BIGINT AS VARCHAR), 10, '0') as phone,
                    (random() * 10000 - 1000)::DECIMAL(12,2) as acctbal,
                    CASE 
                        WHEN random() < 0.2 THEN 'AUTOMOBILE'
                        WHEN random() < 0.4 THEN 'BUILDING'
                        WHEN random() < 0.6 THEN 'FURNITURE'
                        WHEN random() < 0.8 THEN 'HOUSEHOLD'
                        ELSE 'MACHINERY'
                    END as mktsegment
                FROM (
                    SELECT DISTINCT custkey 
                    FROM iceberg.tpch.orders
                ) unique_customers
            ) customer_data
        """)
        
        print("✅ Test tables created")
    
    def demonstrate_predicate_pushdown(self):
        """Demonstrate predicate pushdown optimization"""
        print("\n🔍 Demonstrating Predicate Pushdown...")
        
        # Query without optimization hints
        print("Query 1: Without predicate pushdown optimization")
        query1 = """
            SELECT c.name, o.totalprice, o.orderdate
            FROM iceberg.tpch.customer c
            JOIN iceberg.tpch.orders o ON c.custkey = o.custkey
            WHERE o.orderdate >= DATE '1995-01-01' 
              AND o.orderdate < DATE '1996-01-01'
              AND c.mktsegment = 'AUTOMOBILE'
        """
        
        start_time = time.time()
        result1 = self.client.execute_query(query1)
        time1 = time.time() - start_time
        
        print(f"  Execution time: {time1:.2f} seconds")
        print(f"  Rows returned: {len(result1['data'])}")
        
        # Show query plan
        explain_result = self.client.execute_query(f"EXPLAIN {query1}")
        print("  Query plan:")
        for row in explain_result['data'][:10]:  # Show first 10 lines
            print(f"    {row[0]}")
        
        # Optimized query with explicit predicate pushdown
        print("\nQuery 2: With explicit filtering first")
        query2 = """
            WITH filtered_orders AS (
                SELECT custkey, totalprice, orderdate
                FROM iceberg.tpch.orders 
                WHERE orderdate >= DATE '1995-01-01' 
                  AND orderdate < DATE '1996-01-01'
            ),
            filtered_customers AS (
                SELECT custkey, name
                FROM iceberg.tpch.customer
                WHERE mktsegment = 'AUTOMOBILE'
            )
            SELECT fc.name, fo.totalprice, fo.orderdate
            FROM filtered_customers fc
            JOIN filtered_orders fo ON fc.custkey = fo.custkey
        """
        
        start_time = time.time()
        result2 = self.client.execute_query(query2)
        time2 = time.time() - start_time
        
        print(f"  Execution time: {time2:.2f} seconds")
        print(f"  Rows returned: {len(result2['data'])}")
        
        if time1 > 0:
            improvement = ((time1 - time2) / time1) * 100
            print(f"  Performance improvement: {improvement:.1f}%")
    
    def demonstrate_join_optimization(self):
        """Demonstrate join optimization techniques"""
        print("\n🔗 Demonstrating Join Optimization...")
        
        # Test different join orders
        queries = [
            ("Large table first", """
                SELECT COUNT(*)
                FROM iceberg.tpch.orders o
                JOIN iceberg.tpch.customer c ON o.custkey = c.custkey
                WHERE c.mktsegment = 'AUTOMOBILE'
            """),
            ("Small table first (broadcast join)", """
                SELECT COUNT(*)
                FROM iceberg.tpch.customer c
                JOIN iceberg.tpch.orders o ON c.custkey = o.custkey
                WHERE c.mktsegment = 'AUTOMOBILE'
            """)
        ]
        
        for query_name, query in queries:
            print(f"\n{query_name}:")
            
            start_time = time.time()
            result = self.client.execute_query(query)
            execution_time = time.time() - start_time
            
            print(f"  Execution time: {execution_time:.2f} seconds")
            print(f"  Result: {result['data'][0][0]} rows")
            
            # Show execution plan
            explain_result = self.client.execute_query(f"EXPLAIN (TYPE DISTRIBUTED) {query}")
            plan_lines = [row[0] for row in explain_result['data']]
            
            # Look for join strategy
            for line in plan_lines:
                if 'Join' in line or 'Hash' in line or 'Broadcast' in line:
                    print(f"  Join strategy: {line.strip()}")
    
    def demonstrate_aggregation_optimization(self):
        """Demonstrate aggregation optimization"""
        print("\n📊 Demonstrating Aggregation Optimization...")
        
        # Test different aggregation patterns
        queries = [
            ("Simple aggregation", """
                SELECT 
                    orderstatus,
                    COUNT(*) as order_count,
                    SUM(totalprice) as total_value,
                    AVG(totalprice) as avg_value
                FROM iceberg.tpch.orders
                GROUP BY orderstatus
            """),
            ("Multi-level aggregation", """
                SELECT 
                    orderstatus,
                    orderpriority,
                    COUNT(*) as order_count,
                    SUM(totalprice) as total_value
                FROM iceberg.tpch.orders
                GROUP BY orderstatus, orderpriority
                ORDER BY orderstatus, orderpriority
            """),
            ("Aggregation with HAVING", """
                SELECT 
                    custkey,
                    COUNT(*) as order_count,
                    SUM(totalprice) as total_spent
                FROM iceberg.tpch.orders
                GROUP BY custkey
                HAVING COUNT(*) > 5 AND SUM(totalprice) > 100000
                ORDER BY total_spent DESC
                LIMIT 100
            """)
        ]
        
        for query_name, query in queries:
            print(f"\n{query_name}:")
            
            start_time = time.time()
            result = self.client.execute_query(query)
            execution_time = time.time() - start_time
            
            print(f"  Execution time: {execution_time:.2f} seconds")
            print(f"  Rows returned: {len(result['data'])}")
            
            # Show sample results
            if result['data']:
                print(f"  Sample result: {result['data'][0]}")
    
    def demonstrate_window_functions(self):
        """Demonstrate window function optimization"""
        print("\n🪟 Demonstrating Window Functions...")
        
        query = """
            SELECT 
                custkey,
                orderdate,
                totalprice,
                ROW_NUMBER() OVER (PARTITION BY custkey ORDER BY orderdate) as order_seq,
                SUM(totalprice) OVER (PARTITION BY custkey ORDER BY orderdate 
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as running_total,
                LAG(totalprice, 1) OVER (PARTITION BY custkey ORDER BY orderdate) as prev_order_value,
                LEAD(totalprice, 1) OVER (PARTITION BY custkey ORDER BY orderdate) as next_order_value
            FROM iceberg.tpch.orders
            WHERE custkey IN (
                SELECT custkey 
                FROM iceberg.tpch.orders 
                GROUP BY custkey 
                HAVING COUNT(*) >= 5
                LIMIT 100
            )
            ORDER BY custkey, orderdate
        """
        
        print("Window function query:")
        start_time = time.time()
        result = self.client.execute_query(query)
        execution_time = time.time() - start_time
        
        print(f"  Execution time: {execution_time:.2f} seconds")
        print(f"  Rows returned: {len(result['data'])}")
        
        # Show sample results
        print("  Sample results:")
        for i, row in enumerate(result['data'][:5]):
            print(f"    Row {i+1}: {row}")
    
    def analyze_query_performance(self, query_id):
        """Analyze query performance in detail"""
        print(f"\n🔍 Analyzing query performance for {query_id}...")
        
        try:
            query_info = self.client.get_query_info(query_id)
            
            stats = query_info.get('queryStats', {})
            print(f"  Query state: {stats.get('state', 'UNKNOWN')}")
            print(f"  Total CPU time: {stats.get('totalCpuTime', 'N/A')}")
            print(f"  Total scheduled time: {stats.get('totalScheduledTime', 'N/A')}")
            print(f"  Peak memory usage: {stats.get('peakUserMemoryReservation', 'N/A')}")
            print(f"  Input rows: {stats.get('rawInputPositions', 'N/A')}")
            print(f"  Input data size: {stats.get('rawInputDataSize', 'N/A')}")
            print(f"  Output rows: {stats.get('outputPositions', 'N/A')}")
            print(f"  Output data size: {stats.get('outputDataSize', 'N/A')}")
            
        except Exception as e:
            print(f"  Could not analyze query: {e}")

def main():
    """Run all optimization demonstrations"""
    print("🚀 Starting Trino Query Optimization Demo")
    
    optimizer = QueryOptimizer()
    
    try:
        # Setup
        optimizer.create_test_tables()
        
        # Optimization demonstrations
        optimizer.demonstrate_predicate_pushdown()
        optimizer.demonstrate_join_optimization()
        optimizer.demonstrate_aggregation_optimization()
        optimizer.demonstrate_window_functions()
        
        print("\n🎉 All optimization demonstrations completed!")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
```

## 📊 Assessment & Next Steps

### Knowledge Check
1. **Explain Trino's MPP architecture** and how it differs from traditional databases
2. **Configure a production Trino cluster** with coordinator and workers
3. **Optimize query performance** using cost-based optimization techniques
4. **Implement federated queries** across multiple data sources

### Project Deliverables
- [ ] Production-ready Trino cluster deployment
- [ ] Query optimization examples with performance comparisons
- [ ] Multi-catalog integration (Iceberg, PostgreSQL, etc.)
- [ ] Monitoring and performance analysis setup

### Real-world Applications

**Trino in your BigQuery-equivalent system:**

1. **Distributed Query Processing**: MPP execution across worker nodes
2. **Federated Analytics**: Query across multiple data sources
3. **Cost-Based Optimization**: Automatic query plan optimization
4. **Elastic Scaling**: Auto-scaling workers based on query load
5. **Memory Management**: Unified memory pools with spill-to-disk

### Next Module Preview
**Module 9: Apache Kafka Fundamentals** will cover:
- Distributed messaging and streaming architecture
- Producer/consumer patterns and stream processing
- Integration with Trino for real-time analytics
- Building streaming data pipelines for your lakehouse

The query engine you've built with Trino provides the analytical compute layer that will process both batch and streaming data in your complete lakehouse architecture.

---

**Module 7 Complete!** 🎉 You now have a powerful, distributed SQL query engine that can handle petabyte-scale analytics with BigQuery-equivalent performance and capabilities.
