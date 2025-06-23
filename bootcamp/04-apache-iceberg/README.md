# Module 4: Apache Iceberg Mastery

Welcome to the Apache Iceberg module! This is where your lakehouse architecture comes alive with ACID transactions, schema evolution, and time travel capabilities. Iceberg transforms your object storage into a true analytical database.

## 🎯 Learning Objectives

By the end of this module, you will:
- Master Iceberg table format internals and metadata management
- Implement ACID transactions with snapshot isolation
- Enable schema evolution and time travel queries
- Integrate Iceberg with multiple compute engines (Spark, Trino, Flink)
- Optimize table performance with partitioning and compaction

## 📚 Module Overview

### Duration: 1.5 Weeks (30 hours)
- **Theory & Concepts**: 8 hours
- **Hands-on Labs**: 18 hours
- **Integration Projects**: 4 hours

### Prerequisites
- Object storage fundamentals (Module 3)
- Understanding of database ACID properties
- Basic knowledge of columnar storage formats

## 🧠 Core Concepts

### 1. Iceberg Table Format Architecture

**Three-Layer Architecture**

```
┌─────────────────────────────────────────────────────────────┐
│                    Iceberg Table                            │
├─────────────────────────────────────────────────────────────┤
│  Catalog Layer (Metadata Management)                       │
│  ├── Table Metadata (schema, partitions, properties)       │
│  ├── Snapshot History (versions, timestamps)               │
│  └── Manifest Lists (snapshot to manifest mapping)         │
├─────────────────────────────────────────────────────────────┤
│  Metadata Layer (File Organization)                        │
│  ├── Manifest Files (data file locations, statistics)     │
│  ├── Data File Lists (file paths, partition values)       │
│  └── Delete Files (row-level deletes, equality deletes)    │
├─────────────────────────────────────────────────────────────┤
│  Data Layer (Actual Data Storage)                          │
│  ├── Data Files (Parquet, ORC, Avro)                      │
│  ├── Partition Directories (optional for compatibility)    │
│  └── Delete Files (position deletes, equality deletes)     │
└─────────────────────────────────────────────────────────────┘
```

**Key Components Explained**:

1. **Table Metadata**: JSON file containing schema, partition spec, sort order
2. **Manifest Lists**: Track which manifests belong to a snapshot
3. **Manifest Files**: List data files with statistics for query planning
4. **Data Files**: Actual data stored in columnar format (usually Parquet)

### 2. ACID Transactions

**Optimistic Concurrency Control**

```python
# Conceptual Iceberg transaction model
class IcebergTransaction:
    def __init__(self, table, base_snapshot_id):
        self.table = table
        self.base_snapshot_id = base_snapshot_id
        self.new_data_files = []
        self.deleted_data_files = []
        self.schema_updates = []
    
    def add_data_file(self, file_path, partition_values, metrics):
        """Add new data file to transaction"""
        self.new_data_files.append({
            'file_path': file_path,
            'partition': partition_values,
            'record_count': metrics.record_count,
            'file_size_bytes': metrics.file_size,
            'column_sizes': metrics.column_sizes,
            'value_counts': metrics.value_counts,
            'null_value_counts': metrics.null_counts,
            'lower_bounds': metrics.lower_bounds,
            'upper_bounds': metrics.upper_bounds
        })
    
    def delete_data_file(self, file_path):
        """Mark data file for deletion"""
        self.deleted_data_files.append(file_path)
    
    def commit(self):
        """Atomically commit transaction"""
        # 1. Create new manifest files
        new_manifests = self.create_manifests()
        
        # 2. Create new manifest list
        manifest_list = self.create_manifest_list(new_manifests)
        
        # 3. Create new table metadata
        new_metadata = self.create_table_metadata(manifest_list)
        
        # 4. Atomic commit using conditional updates
        success = self.table.commit_metadata(
            current_snapshot_id=self.base_snapshot_id,
            new_metadata=new_metadata
        )
        
        if not success:
            raise ConflictException("Concurrent modification detected")
        
        return new_metadata.current_snapshot_id
```

**ACID Properties in Iceberg**:
- **Atomicity**: All-or-nothing commits using atomic metadata updates
- **Consistency**: Schema validation and constraint enforcement
- **Isolation**: Snapshot isolation prevents read anomalies
- **Durability**: Metadata and data persisted to reliable storage

### 3. Schema Evolution

**Supported Schema Changes**

```python
# Schema evolution examples
class SchemaEvolution:
    
    def add_column(self, table, column_name, column_type, default_value=None):
        """Add new column (always safe)"""
        new_schema = table.schema().add_column(
            column_name, 
            column_type, 
            default_value
        )
        
        table.update_schema().add_column(
            column_name, column_type, default_value
        ).commit()
    
    def rename_column(self, table, old_name, new_name):
        """Rename column (safe, preserves data)"""
        table.update_schema().rename_column(
            old_name, new_name
        ).commit()
    
    def promote_column_type(self, table, column_name, new_type):
        """Promote column type (int -> long, float -> double)"""
        table.update_schema().update_column(
            column_name, new_type
        ).commit()
    
    def make_column_optional(self, table, column_name):
        """Make required column optional"""
        table.update_schema().make_column_optional(
            column_name
        ).commit()
    
    def add_nested_field(self, table, parent_column, field_name, field_type):
        """Add field to struct column"""
        table.update_schema().add_column(
            f"{parent_column}.{field_name}", 
            field_type
        ).commit()

# Example usage
evolution = SchemaEvolution()

# Start with simple schema
original_schema = """
{
  "type": "struct",
  "fields": [
    {"id": 1, "name": "user_id", "type": "long", "required": true},
    {"id": 2, "name": "name", "type": "string", "required": true},
    {"id": 3, "name": "age", "type": "int", "required": false}
  ]
}
"""

# Evolve schema over time
evolution.add_column(table, "email", "string")
evolution.add_column(table, "address", "struct<street:string,city:string,zip:string>")
evolution.promote_column_type(table, "age", "long")
evolution.add_nested_field(table, "address", "country", "string")
```

### 4. Time Travel

**Query Historical Data**

```sql
-- Time travel queries in Iceberg
-- Query data as of specific timestamp
SELECT * FROM sales_table 
FOR SYSTEM_TIME AS OF '2023-12-01 10:00:00';

-- Query data as of specific snapshot
SELECT * FROM sales_table 
FOR SYSTEM_VERSION AS OF 12345678901234567890;

-- Compare data between two points in time
WITH current_data AS (
  SELECT * FROM sales_table
),
historical_data AS (
  SELECT * FROM sales_table 
  FOR SYSTEM_TIME AS OF '2023-11-01 00:00:00'
)
SELECT 
  c.product_id,
  c.current_sales - h.historical_sales as sales_growth
FROM current_data c
JOIN historical_data h ON c.product_id = h.product_id;
```

## 🛠 Hands-on Labs

### Lab 1: Basic Iceberg Operations

**Objective**: Create and manipulate Iceberg tables with Spark.

**Setup**:
```bash
# Create lab directory
mkdir -p 04-apache-iceberg/labs/basic-operations
cd 04-apache-iceberg/labs/basic-operations

# Create requirements.txt
cat > requirements.txt << 'EOF'
pyspark==3.4.1
pyiceberg[s3fs,hive]==0.5.1
pandas==2.0.3
pyarrow==12.0.1
boto3==1.28.57
EOF

pip install -r requirements.txt
```

**Docker Compose Setup**:
```yaml
# docker-compose.yml
version: '3.8'

services:
  # PostgreSQL for Hive Metastore
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: metastore
      POSTGRES_USER: hive  
      POSTGRES_PASSWORD: hive123
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - iceberg

  # Hive Metastore
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
                     -Djavax.jdo.option.ConnectionPassword=hive123
                     -Dhadoop.proxyuser.root.hosts=*
                     -Dhadoop.proxyuser.root.groups=*"
    ports:
      - "9083:9083"
    volumes:
      - ./warehouse:/opt/hive/data/warehouse
    networks:
      - iceberg

  # MinIO for object storage
  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9090"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin123
    ports:
      - "9000:9000"
      - "9090:9090"
    volumes:
      - minio_data:/data
    networks:
      - iceberg

  # MinIO client setup
  mc:
    image: minio/mc:latest
    depends_on:
      - minio
    entrypoint: >
      /bin/sh -c "
      sleep 10;
      /usr/bin/mc alias set local http://minio:9000 minioadmin minioadmin123;
      /usr/bin/mc mb local/warehouse --ignore-existing;
      /usr/bin/mc mb local/lakehouse --ignore-existing;
      echo 'MinIO buckets created';
      exit 0;
      "
    networks:
      - iceberg

volumes:
  postgres_data:
  minio_data:

networks:
  iceberg:
    driver: bridge
```

**Basic Iceberg Operations**:
```python
# iceberg_basics.py
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType, TimestampType
from pyspark.sql.functions import current_timestamp, lit
import pandas as pd
from datetime import datetime, timedelta

def create_spark_session():
    """Create Spark session with Iceberg configuration"""
    return SparkSession.builder \
        .appName("Iceberg Basics") \
        .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
        .config("spark.sql.catalog.spark_catalog", "org.apache.iceberg.spark.SparkSessionCatalog") \
        .config("spark.sql.catalog.spark_catalog.type", "hive") \
        .config("spark.sql.catalog.spark_catalog.uri", "thrift://localhost:9083") \
        .config("spark.sql.catalog.lakehouse", "org.apache.iceberg.spark.SparkCatalog") \
        .config("spark.sql.catalog.lakehouse.type", "hive") \
        .config("spark.sql.catalog.lakehouse.uri", "thrift://localhost:9083") \
        .config("spark.sql.catalog.lakehouse.warehouse", "s3a://warehouse/") \
        .config("spark.hadoop.fs.s3a.endpoint", "http://localhost:9000") \
        .config("spark.hadoop.fs.s3a.access.key", "minioadmin") \
        .config("spark.hadoop.fs.s3a.secret.key", "minioadmin123") \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
        .getOrCreate()

def create_sample_table(spark):
    """Create sample Iceberg table"""
    print("🏗️  Creating sample Iceberg table...")
    
    # Create sample data
    schema = StructType([
        StructField("transaction_id", StringType(), False),
        StructField("user_id", IntegerType(), False),
        StructField("product_id", StringType(), False),
        StructField("quantity", IntegerType(), False),
        StructField("price", DoubleType(), False),
        StructField("transaction_date", TimestampType(), False),
        StructField("category", StringType(), False)
    ])
    
    # Generate sample data
    import random
    from datetime import datetime, timedelta
    
    sample_data = []
    categories = ["Electronics", "Clothing", "Books", "Home", "Sports"]
    
    for i in range(1000):
        sample_data.append((
            f"TXN_{i:06d}",
            random.randint(1, 100),
            f"PROD_{random.randint(1, 50):03d}",
            random.randint(1, 10),
            round(random.uniform(10.0, 500.0), 2),
            datetime.now() - timedelta(days=random.randint(0, 365)),
            random.choice(categories)
        ))
    
    df = spark.createDataFrame(sample_data, schema)
    
    # Create Iceberg table
    df.writeTo("lakehouse.sales.transactions") \
        .tableProperty("format-version", "2") \
        .partitionedBy("category") \
        .createOrReplace()
    
    print("✅ Sample table created with 1000 transactions")
    return df

def demonstrate_basic_operations(spark):
    """Demonstrate basic Iceberg operations"""
    print("\n📊 Demonstrating basic operations...")
    
    # Read the table
    df = spark.table("lakehouse.sales.transactions")
    
    print(f"📈 Total records: {df.count()}")
    print("📋 Sample data:")
    df.show(10)
    
    # Show table schema
    print("\n🏗️  Table schema:")
    df.printSchema()
    
    # Show partition information
    print("\n📂 Partition information:")
    spark.sql("DESCRIBE TABLE EXTENDED lakehouse.sales.transactions").show(50, truncate=False)

def demonstrate_schema_evolution(spark):
    """Demonstrate schema evolution capabilities"""
    print("\n🔄 Demonstrating schema evolution...")
    
    # Add new column
    spark.sql("""
        ALTER TABLE lakehouse.sales.transactions 
        ADD COLUMN discount_percent DOUBLE
    """)
    print("✅ Added discount_percent column")
    
    # Add nested column
    spark.sql("""
        ALTER TABLE lakehouse.sales.transactions 
        ADD COLUMN customer_info STRUCT<name: STRING, email: STRING>
    """)
    print("✅ Added customer_info struct column")
    
    # Show updated schema
    print("\n🆕 Updated schema:")
    spark.table("lakehouse.sales.transactions").printSchema()
    
    # Insert data with new columns
    print("\n📝 Inserting data with new schema...")
    spark.sql("""
        INSERT INTO lakehouse.sales.transactions
        VALUES (
            'TXN_NEW_001',
            101,
            'PROD_NEW_001',
            2,
            99.99,
            current_timestamp(),
            'Electronics',
            10.0,
            named_struct('name', 'John Doe', 'email', 'john@example.com')
        )
    """)
    
    # Query with new columns
    print("🔍 Querying with new columns:")
    spark.sql("""
        SELECT transaction_id, user_id, price, discount_percent, customer_info.name as customer_name
        FROM lakehouse.sales.transactions 
        WHERE discount_percent IS NOT NULL
    """).show()

def demonstrate_time_travel(spark):
    """Demonstrate time travel capabilities"""
    print("\n⏰ Demonstrating time travel...")
    
    # Get current snapshot info
    snapshots = spark.sql("SELECT * FROM lakehouse.sales.transactions.snapshots").collect()
    print(f"📸 Current snapshots: {len(snapshots)}")
    
    for snapshot in snapshots[-3:]:  # Show last 3 snapshots
        print(f"  Snapshot {snapshot.snapshot_id}: {snapshot.committed_at} ({snapshot.operation})")
    
    if len(snapshots) >= 2:
        # Query historical snapshot
        older_snapshot_id = snapshots[-2].snapshot_id
        
        print(f"\n🕐 Querying snapshot {older_snapshot_id}:")
        spark.sql(f"""
            SELECT COUNT(*) as record_count
            FROM lakehouse.sales.transactions
            FOR SYSTEM_VERSION AS OF {older_snapshot_id}
        """).show()
        
        # Compare current vs historical
        print("📊 Comparing current vs historical data:")
        spark.sql(f"""
            SELECT 
                'current' as version, COUNT(*) as record_count
            FROM lakehouse.sales.transactions
            UNION ALL
            SELECT 
                'historical' as version, COUNT(*) as record_count
            FROM lakehouse.sales.transactions
            FOR SYSTEM_VERSION AS OF {older_snapshot_id}
        """).show()

def demonstrate_maintenance_operations(spark):
    """Demonstrate table maintenance operations"""
    print("\n🔧 Demonstrating maintenance operations...")
    
    # Show table files before maintenance
    print("📁 Table files before maintenance:")
    files_before = spark.sql("SELECT * FROM lakehouse.sales.transactions.files").count()
    print(f"   File count: {files_before}")
    
    # Compact small files
    print("🗜️  Compacting small files...")
    spark.sql("CALL lakehouse.system.rewrite_data_files('lakehouse.sales.transactions')")
    print("✅ Compaction completed")
    
    # Show files after compaction
    files_after = spark.sql("SELECT * FROM lakehouse.sales.transactions.files").count()
    print(f"📁 Files after compaction: {files_after}")
    
    # Expire old snapshots (keep last 5)
    print("🗑️  Expiring old snapshots...")
    spark.sql("""
        CALL lakehouse.system.expire_snapshots(
            table => 'lakehouse.sales.transactions',
            retain_last => 5
        )
    """)
    print("✅ Old snapshots expired")
    
    # Remove orphaned files
    print("🧹 Removing orphaned files...")
    spark.sql("CALL lakehouse.system.remove_orphan_files('lakehouse.sales.transactions')")
    print("✅ Orphaned files removed")

def main():
    """Run all Iceberg demonstrations"""
    print("🚀 Starting Iceberg Basic Operations Demo")
    
    spark = create_spark_session()
    
    try:
        # Basic operations
        create_sample_table(spark)
        demonstrate_basic_operations(spark)
        
        # Advanced features
        demonstrate_schema_evolution(spark)
        demonstrate_time_travel(spark)
        demonstrate_maintenance_operations(spark)
        
        print("\n🎉 All demonstrations completed successfully!")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        raise
    finally:
        spark.stop()

if __name__ == "__main__":
    main()
```

**Run the Lab**:
```bash
# Start services
docker-compose up -d

# Wait for services to be ready
sleep 60

# Run the demo
python iceberg_basics.py
```

### Lab 2: Advanced Iceberg Features

**Objective**: Explore advanced Iceberg features including merge operations, row-level deletes, and partition evolution.

```python
# advanced_iceberg.py
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
import random
from datetime import datetime, timedelta

def create_advanced_spark_session():
    """Create Spark session with advanced Iceberg features"""
    return SparkSession.builder \
        .appName("Advanced Iceberg") \
        .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
        .config("spark.sql.catalog.lakehouse", "org.apache.iceberg.spark.SparkCatalog") \
        .config("spark.sql.catalog.lakehouse.type", "hive") \
        .config("spark.sql.catalog.lakehouse.uri", "thrift://localhost:9083") \
        .config("spark.sql.catalog.lakehouse.warehouse", "s3a://warehouse/") \
        .config("spark.hadoop.fs.s3a.endpoint", "http://localhost:9000") \
        .config("spark.hadoop.fs.s3a.access.key", "minioadmin") \
        .config("spark.hadoop.fs.s3a.secret.key", "minioadmin123") \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
        .config("spark.sql.iceberg.handle-timestamp-without-timezone", "true") \
        .getOrCreate()

def demonstrate_merge_operations(spark):
    """Demonstrate MERGE operations (UPSERT)"""
    print("\n🔄 Demonstrating MERGE operations...")
    
    # Create target table
    spark.sql("""
        CREATE OR REPLACE TABLE lakehouse.sales.customer_profiles (
            customer_id INT,
            name STRING,
            email STRING,
            total_spent DOUBLE,
            last_purchase_date TIMESTAMP,
            status STRING
        ) USING iceberg
        PARTITIONED BY (status)
    """)
    
    # Insert initial data
    initial_data = [
        (1, "John Doe", "john@example.com", 500.0, datetime(2023, 1, 15), "ACTIVE"),
        (2, "Jane Smith", "jane@example.com", 750.0, datetime(2023, 2, 20), "ACTIVE"),
        (3, "Bob Johnson", "bob@example.com", 200.0, datetime(2023, 1, 10), "INACTIVE")
    ]
    
    spark.createDataFrame(initial_data, ["customer_id", "name", "email", "total_spent", "last_purchase_date", "status"]) \
        .writeTo("lakehouse.sales.customer_profiles").append()
    
    print("✅ Initial customer data inserted")
    
    # Create updates/new customers
    updates_data = [
        (1, "John Doe", "john.doe@example.com", 650.0, datetime(2023, 3, 15), "ACTIVE"),  # Update existing
        (2, "Jane Smith", "jane@example.com", 950.0, datetime(2023, 3, 20), "VIP"),      # Update with status change
        (4, "Alice Wilson", "alice@example.com", 300.0, datetime(2023, 3, 25), "ACTIVE") # New customer
    ]
    
    updates_df = spark.createDataFrame(updates_data, ["customer_id", "name", "email", "total_spent", "last_purchase_date", "status"])
    updates_df.createOrReplaceTempView("customer_updates")
    
    # Perform MERGE operation
    spark.sql("""
        MERGE INTO lakehouse.sales.customer_profiles target
        USING customer_updates source
        ON target.customer_id = source.customer_id
        WHEN MATCHED THEN UPDATE SET
            name = source.name,
            email = source.email,
            total_spent = source.total_spent,
            last_purchase_date = source.last_purchase_date,
            status = source.status
        WHEN NOT MATCHED THEN INSERT (
            customer_id, name, email, total_spent, last_purchase_date, status
        ) VALUES (
            source.customer_id, source.name, source.email, 
            source.total_spent, source.last_purchase_date, source.status
        )
    """)
    
    print("✅ MERGE operation completed")
    
    # Show results
    print("📊 Customer profiles after MERGE:")
    spark.table("lakehouse.sales.customer_profiles").orderBy("customer_id").show()

def demonstrate_row_level_deletes(spark):
    """Demonstrate row-level delete operations"""
    print("\n🗑️  Demonstrating row-level deletes...")
    
    # Show data before delete
    print("📊 Data before delete:")
    spark.sql("SELECT * FROM lakehouse.sales.customer_profiles ORDER BY customer_id").show()
    
    # Delete inactive customers
    spark.sql("""
        DELETE FROM lakehouse.sales.customer_profiles 
        WHERE status = 'INACTIVE'
    """)
    
    print("✅ Deleted inactive customers")
    
    # Show data after delete
    print("📊 Data after delete:")
    spark.sql("SELECT * FROM lakehouse.sales.customer_profiles ORDER BY customer_id").show()
    
    # Show delete files (Iceberg v2 feature)
    print("📁 Delete files created:")
    spark.sql("SELECT * FROM lakehouse.sales.customer_profiles.files").show(truncate=False)

def demonstrate_partition_evolution(spark):
    """Demonstrate partition evolution"""
    print("\n📂 Demonstrating partition evolution...")
    
    # Create table with date partitioning
    spark.sql("""
        CREATE OR REPLACE TABLE lakehouse.sales.orders (
            order_id STRING,
            customer_id INT,
            order_date DATE,
            amount DOUBLE,
            product_category STRING
        ) USING iceberg
        PARTITIONED BY (days(order_date))
    """)
    
    # Insert sample data
    from datetime import date, timedelta
    
    orders_data = []
    base_date = date(2023, 1, 1)
    
    for i in range(100):
        orders_data.append((
            f"ORD_{i:05d}",
            random.randint(1, 20),
            base_date + timedelta(days=random.randint(0, 365)),
            round(random.uniform(50, 1000), 2),
            random.choice(["Electronics", "Clothing", "Books", "Home"])
        ))
    
    spark.createDataFrame(orders_data, ["order_id", "customer_id", "order_date", "amount", "product_category"]) \
        .writeTo("lakehouse.sales.orders").append()
    
    print("✅ Sample orders data inserted")
    
    # Show current partitioning
    print("📊 Current partitioning (by day):")
    spark.sql("SELECT * FROM lakehouse.sales.orders.partitions LIMIT 10").show()
    
    # Evolve partition spec to monthly partitioning
    spark.sql("""
        ALTER TABLE lakehouse.sales.orders 
        ADD PARTITION FIELD months(order_date)
    """)
    
    # Drop daily partitioning (Iceberg handles data migration)
    spark.sql("""
        ALTER TABLE lakehouse.sales.orders 
        DROP PARTITION FIELD days(order_date)
    """)
    
    print("✅ Partition evolved from daily to monthly")
    
    # Show new partitioning
    print("📊 New partitioning (by month):")
    spark.sql("SELECT * FROM lakehouse.sales.orders.partitions LIMIT 10").show()

def demonstrate_branching_and_tagging(spark):
    """Demonstrate branching and tagging (Iceberg v2)"""
    print("\n🌿 Demonstrating branching and tagging...")
    
    # Create a branch for experimental changes
    spark.sql("""
        ALTER TABLE lakehouse.sales.customer_profiles 
        CREATE BRANCH experimental
    """)
    print("✅ Created 'experimental' branch")
    
    # Make changes on the branch
    spark.sql("""
        INSERT INTO lakehouse.sales.customer_profiles.branch_experimental
        VALUES (99, 'Test User', 'test@example.com', 0.0, current_timestamp(), 'TEST')
    """)
    print("✅ Inserted test data on experimental branch")
    
    # Show data on main branch (should not include test data)
    print("📊 Data on main branch:")
    spark.sql("SELECT COUNT(*) FROM lakehouse.sales.customer_profiles").show()
    
    # Show data on experimental branch (should include test data)
    print("📊 Data on experimental branch:")
    spark.sql("SELECT COUNT(*) FROM lakehouse.sales.customer_profiles.branch_experimental").show()
    
    # Create a tag for the current state
    spark.sql("""
        ALTER TABLE lakehouse.sales.customer_profiles 
        CREATE TAG v1_0 AS OF VERSION 1
    """)
    print("✅ Created tag 'v1_0'")
    
    # Clean up experimental branch
    spark.sql("""
        ALTER TABLE lakehouse.sales.customer_profiles 
        DROP BRANCH experimental
    """)
    print("✅ Dropped experimental branch")

def main():
    """Run advanced Iceberg demonstrations"""
    print("🚀 Starting Advanced Iceberg Features Demo")
    
    spark = create_advanced_spark_session()
    
    try:
        demonstrate_merge_operations(spark)
        demonstrate_row_level_deletes(spark)
        demonstrate_partition_evolution(spark)
        demonstrate_branching_and_tagging(spark)
        
        print("\n🎉 All advanced demonstrations completed!")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        spark.stop()

if __name__ == "__main__":
    main()
```

### Lab 3: Multi-Engine Integration

**Objective**: Integrate Iceberg with multiple compute engines (Spark, Trino, Flink).

**Trino Integration**:
```yaml
# Add to docker-compose.yml
  trino:
    image: trinodb/trino:latest
    container_name: trino-coordinator
    ports:
      - "8080:8080"
    volumes:
      - ./trino/etc:/etc/trino
    networks:
      - iceberg
```

**Trino Configuration**:
```bash
# Create Trino configuration
mkdir -p trino/etc/catalog

# Trino Iceberg catalog
cat > trino/etc/catalog/iceberg.properties << 'EOF'
connector.name=iceberg
hive.metastore.uri=thrift://hive-metastore:9083
iceberg.catalog.type=hive
hive.s3.endpoint=http://minio:9000
hive.s3.path-style-access=true  
hive.s3.aws-access-key=minioadmin
hive.s3.aws-secret-key=minioadmin123
EOF
```

**Multi-Engine Test**:
```python
# multi_engine_test.py
import subprocess
import time

def test_trino_iceberg():
    """Test Iceberg table access from Trino"""
    print("🔍 Testing Trino + Iceberg integration...")
    
    # Wait for Trino to start
    time.sleep(30)
    
    # Execute query via Trino CLI
    trino_query = """
    SELECT 
        status,
        COUNT(*) as customer_count,
        AVG(total_spent) as avg_spent
    FROM iceberg.sales.customer_profiles 
    GROUP BY status
    """
    
    try:
        result = subprocess.run([
            "docker", "exec", "trino-coordinator", 
            "trino", "--execute", trino_query
        ], capture_output=True, text=True)
        
        print("📊 Trino query results:")
        print(result.stdout)
        
        if result.returncode == 0:
            print("✅ Trino integration successful")
        else:
            print(f"❌ Trino error: {result.stderr}")
            
    except Exception as e:
        print(f"❌ Trino test failed: {e}")

if __name__ == "__main__":
    test_trino_iceberg()
```

## 📊 Assessment & Next Steps

### Knowledge Check
1. **Explain Iceberg's three-layer architecture** and the role of each layer
2. **Implement schema evolution** without breaking existing queries
3. **Demonstrate time travel queries** for auditing and debugging
4. **Optimize table performance** with partitioning and maintenance

### Project Deliverables
- [ ] Basic Iceberg table operations with ACID transactions
- [ ] Schema evolution examples with backward compatibility
- [ ] Time travel and branching demonstrations
- [ ] Multi-engine integration (Spark + Trino)
- [ ] Table maintenance and optimization procedures

### Real-world Applications

**Iceberg in your data warehouse:**

1. **Data Lake ACID Properties**: Transform your data lake into a database
2. **Schema Evolution**: Handle changing data formats without breaking pipelines
3. **Time Travel**: Audit changes and debug data issues
4. **Multi-Engine Support**: Use different engines for different workloads
5. **Performance Optimization**: Efficient query execution with metadata

### Next Module Preview
**Module 7: Trino Query Engine** will cover:
- MPP query architecture and execution
- Connector ecosystem for federated queries
- Query optimization and performance tuning
- Integration with Iceberg for analytical processing

The Iceberg foundation you've built provides the transactional data layer that Trino will query efficiently across your lakehouse architecture.

---

**Module 4 Complete!** 🎉 You now have mastered Apache Iceberg and can build ACID-compliant analytical tables with schema evolution, time travel, and multi-engine support.
