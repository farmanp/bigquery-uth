#!/bin/bash

# Module 5: Columnar Storage Optimization - Lab Setup Script

set -e

echo "🚀 Setting up Module 5 Labs: Columnar Storage Optimization"

# Create lab directories
echo "📁 Creating lab directories..."
mkdir -p parquet-analysis
mkdir -p storage-optimization  
mkdir -p compression-benchmark
mkdir -p iceberg-integration

# Create Python virtual environment
echo "🐍 Setting up Python environment..."
python3 -m venv lab-env
source lab-env/bin/activate

# Install dependencies
echo "📦 Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Download sample datasets (if needed)
echo "💾 Preparing sample datasets..."
if [ ! -f "sample_data.csv" ]; then
    echo "Creating synthetic sample data..."
    python3 -c "
import pandas as pd
import numpy as np
from datetime import datetime, timedelta

# Generate sample e-commerce data
np.random.seed(42)
n_rows = 1000000

categories = ['Electronics', 'Clothing', 'Books', 'Home', 'Sports']
countries = ['US', 'UK', 'DE', 'FR', 'JP', 'CA', 'AU']
statuses = ['completed', 'pending', 'cancelled', 'refunded']

data = {
    'transaction_id': [f'TXN_{i:08d}' for i in range(n_rows)],
    'user_id': np.random.randint(1, 100000, n_rows),
    'product_id': np.random.randint(1, 10000, n_rows),
    'category': np.random.choice(categories, n_rows),
    'amount': np.random.lognormal(3, 1, n_rows),
    'quantity': np.random.randint(1, 10, n_rows),
    'status': np.random.choice(statuses, n_rows, p=[0.8, 0.1, 0.07, 0.03]),
    'country': np.random.choice(countries, n_rows, p=[0.4, 0.15, 0.1, 0.1, 0.1, 0.1, 0.05]),
    'timestamp': pd.date_range('2023-01-01', periods=n_rows, freq='30s'),
    'is_mobile': np.random.choice([True, False], n_rows, p=[0.6, 0.4]),
    'discount_percent': np.random.exponential(5, n_rows)
}

df = pd.DataFrame(data)
df.to_csv('sample_data.csv', index=False)
print(f'✅ Created sample_data.csv with {len(df):,} rows')
"
fi

# Create lab starter files
echo "📄 Creating lab starter files..."

# Lab 1: Parquet Analysis
cat > parquet-analysis/lab1_starter.py << 'EOF'
#!/usr/bin/env python3
"""
Lab 1: Parquet File Analysis and Optimization
=============================================

Objectives:
- Analyze Parquet file structure and metadata
- Compare different compression algorithms
- Optimize row group and page sizes
- Measure compression ratios and performance

Run: python lab1_starter.py
"""

import pyarrow as pa
import pyarrow.parquet as pq
import pandas as pd
import numpy as np
import time
from pathlib import Path

def load_sample_data():
    """Load the sample dataset"""
    print("📊 Loading sample data...")
    df = pd.read_csv('../sample_data.csv')
    print(f"   Loaded {len(df):,} rows with {len(df.columns)} columns")
    return df

def analyze_parquet_file(filename):
    """Analyze a Parquet file's structure"""
    print(f"\n🔍 Analyzing {filename}...")
    
    # TODO: Implement Parquet analysis
    # 1. Load parquet file metadata
    # 2. Analyze row groups, columns, and compression
    # 3. Display statistics
    
    pass

def compression_benchmark():
    """Benchmark different compression algorithms"""
    print("\n⚡ Running compression benchmark...")
    
    df = load_sample_data()
    compressions = ['snappy', 'gzip', 'brotli', 'lz4', 'zstd']
    
    results = {}
    
    for compression in compressions:
        print(f"   Testing {compression}...")
        
        # TODO: Implement compression benchmark
        # 1. Write file with specific compression
        # 2. Measure file size and write/read times
        # 3. Store results
        
        pass
    
    return results

if __name__ == "__main__":
    print("🚀 Lab 1: Parquet Analysis and Optimization")
    
    # Run compression benchmark
    results = compression_benchmark()
    
    # Analyze one of the generated files
    analyze_parquet_file("sample_data_zstd.parquet")
    
    print("\n🎉 Lab 1 completed!")
EOF

# Lab 2: Storage Optimization
cat > storage-optimization/lab2_starter.py << 'EOF'
#!/usr/bin/env python3
"""
Lab 2: Storage Layout Optimization
=================================

Objectives:
- Optimize row group sizes for different query patterns
- Test column pruning and predicate pushdown
- Analyze query performance with different layouts
- Design optimal partitioning strategies

Run: python lab2_starter.py
"""

import pandas as pd
import numpy as np
import time
from typing import List, Dict

class StorageOptimizer:
    def __init__(self, df: pd.DataFrame):
        self.df = df
        self.query_patterns = []
    
    def add_query_pattern(self, columns: List[str], filters: Dict, frequency: int = 1):
        """Add a query pattern for optimization analysis"""
        # TODO: Implement query pattern tracking
        pass
    
    def optimize_row_group_size(self, target_size_mb: int = 128):
        """Calculate optimal row group size"""
        # TODO: Implement row group size optimization
        pass
    
    def benchmark_layouts(self):
        """Benchmark different storage layouts"""
        # TODO: Implement layout benchmarking
        pass

def main():
    print("🚀 Lab 2: Storage Layout Optimization")
    
    # Load sample data
    df = pd.read_csv('../sample_data.csv')
    optimizer = StorageOptimizer(df)
    
    # TODO: Add query patterns and run optimization
    
    print("\n🎉 Lab 2 completed!")

if __name__ == "__main__":
    main()
EOF

# Lab 3: Compression Deep Dive
cat > compression-benchmark/lab3_starter.py << 'EOF'
#!/usr/bin/env python3
"""
Lab 3: Compression Algorithm Deep Dive
=====================================

Objectives:
- Compare compression algorithms across different data types
- Analyze encoding techniques (dictionary, RLE, bit-packing)
- Measure decompression performance
- Understand compression trade-offs

Run: python lab3_starter.py
"""

import pandas as pd
import numpy as np
import pyarrow as pa
import pyarrow.parquet as pq
import time
import matplotlib.pyplot as plt

def create_diverse_dataset():
    """Create dataset with diverse compression characteristics"""
    np.random.seed(42)
    n_rows = 500000
    
    data = {
        # High cardinality (poor dictionary encoding)
        'unique_ids': [f"ID_{i:08d}" for i in range(n_rows)],
        
        # Low cardinality (excellent dictionary encoding)  
        'categories': np.random.choice(['A', 'B', 'C', 'D', 'E'], n_rows),
        
        # Highly repetitive (excellent RLE)
        'status': np.random.choice(['ACTIVE', 'INACTIVE'], n_rows, p=[0.95, 0.05]),
        
        # Sequential integers (good bit-packing)
        'sequence': range(n_rows),
        
        # Random integers (moderate compression)
        'random_ints': np.random.randint(0, 1000000, n_rows),
        
        # Floating point (poor compression)
        'amounts': np.random.uniform(0.01, 9999.99, n_rows),
        
        # Boolean (excellent bit-packing)
        'flags': np.random.choice([True, False], n_rows)
    }
    
    return pd.DataFrame(data)

def analyze_compression_by_datatype():
    """Analyze how different data types compress"""
    print("📊 Analyzing compression by data type...")
    
    df = create_diverse_dataset()
    
    # TODO: Implement compression analysis by data type
    # 1. Test each column separately
    # 2. Compare compression ratios
    # 3. Analyze encoding techniques
    
    pass

def benchmark_decompression_speed():
    """Benchmark decompression performance"""
    print("⚡ Benchmarking decompression speed...")
    
    # TODO: Implement decompression benchmarking
    # 1. Create files with different compressions
    # 2. Measure read times
    # 3. Analyze CPU usage
    
    pass

if __name__ == "__main__":
    print("🚀 Lab 3: Compression Algorithm Deep Dive")
    
    analyze_compression_by_datatype()
    benchmark_decompression_speed()
    
    print("\n🎉 Lab 3 completed!")
EOF

# Lab 4: Iceberg Integration
cat > iceberg-integration/lab4_starter.py << 'EOF'
#!/usr/bin/env python3
"""
Lab 4: Iceberg Integration Optimization  
======================================

Objectives:
- Optimize Parquet files within Iceberg tables
- Test file compaction and maintenance
- Analyze table performance metrics
- Compare partitioning strategies

Run: python lab4_starter.py
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import *
import time

def create_spark_session():
    """Create Spark session for Iceberg"""
    # TODO: Configure Spark for Iceberg with optimization settings
    pass

def create_optimized_iceberg_table():
    """Create Iceberg table with optimal settings"""
    # TODO: Implement optimized Iceberg table creation
    pass

def benchmark_iceberg_performance():
    """Benchmark Iceberg table performance"""
    # TODO: Implement Iceberg performance benchmarking
    pass

if __name__ == "__main__":
    print("🚀 Lab 4: Iceberg Integration Optimization")
    
    # Note: This lab requires Docker setup for Iceberg
    print("📝 This lab requires the Iceberg Docker environment from Module 4")
    print("   Please ensure docker-compose is running before proceeding")
    
    print("\n🎉 Lab 4 setup completed!")
EOF

# Create Jupyter notebook examples
echo "📓 Creating Jupyter notebook examples..."

cat > parquet-analysis/analysis_notebook.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Parquet File Analysis Notebook\n",
    "\n",
    "Interactive exploration of Parquet file internals and optimization techniques."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import pyarrow as pa\n",
    "import pyarrow.parquet as pq\n",
    "import pandas as pd\n",
    "import numpy as np\n",
    "import matplotlib.pyplot as plt\n",
    "import seaborn as sns\n",
    "\n",
    "# Load sample data\n",
    "df = pd.read_csv('../sample_data.csv')\n",
    "print(f\"Dataset: {len(df):,} rows, {len(df.columns)} columns\")\n",
    "df.head()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Exercise 1: Basic Parquet Operations\n",
    "\n",
    "Write the DataFrame to Parquet with different compression algorithms and analyze the results."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# TODO: Implement compression comparison\n",
    "compressions = ['snappy', 'gzip', 'brotli', 'zstd']\n",
    "\n",
    "for compression in compressions:\n",
    "    # Write with compression\n",
    "    # Measure file size\n",
    "    # Measure write/read performance\n",
    "    pass"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Exercise 2: Row Group Analysis\n",
    "\n",
    "Experiment with different row group sizes and analyze their impact."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# TODO: Test different row group sizes\n",
    "row_group_sizes = [10000, 50000, 100000, 500000]\n",
    "\n",
    "for size in row_group_sizes:\n",
    "    # Write with specific row group size\n",
    "    # Analyze resulting file structure\n",
    "    pass"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.8.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

# Create Docker setup for advanced labs
echo "🐳 Creating Docker environment for Iceberg integration..."

cat > iceberg-integration/docker-compose.yml << 'EOF'
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
                     -Djavax.jdo.option.ConnectionPassword=hive123"
    ports:
      - "9083:9083"

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

volumes:
  postgres_data:
  minio_data:
EOF

# Create README for labs
cat > README.md << 'EOF'
# Module 5 Labs: Columnar Storage Optimization

This directory contains hands-on labs for exploring columnar storage optimization techniques.

## Setup

1. Run the setup script:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

2. Activate the virtual environment:
   ```bash
   source lab-env/bin/activate
   ```

## Labs Overview

### Lab 1: Parquet Analysis (`parquet-analysis/`)
- Analyze Parquet file structure and metadata
- Compare compression algorithms
- Optimize file layouts

### Lab 2: Storage Optimization (`storage-optimization/`)
- Optimize for different query patterns
- Test column pruning and predicate pushdown
- Design partitioning strategies

### Lab 3: Compression Benchmark (`compression-benchmark/`)
- Deep dive into compression techniques
- Analyze encoding methods
- Performance trade-off analysis

### Lab 4: Iceberg Integration (`iceberg-integration/`)
- Optimize Parquet within Iceberg tables
- Table maintenance and compaction
- Performance benchmarking

## Running the Labs

Each lab can be run independently:

```bash
# Lab 1
cd parquet-analysis
python lab1_starter.py

# Lab 2  
cd storage-optimization
python lab2_starter.py

# Lab 3
cd compression-benchmark  
python lab3_starter.py

# Lab 4 (requires Docker)
cd iceberg-integration
docker-compose up -d
python lab4_starter.py
```

## Jupyter Notebooks

Interactive notebooks are available for hands-on exploration:

```bash
jupyter notebook parquet-analysis/analysis_notebook.ipynb
```

## Troubleshooting

- Ensure Python 3.8+ is installed
- For Docker issues, ensure Docker Desktop is running
- Check virtual environment activation if packages are missing
EOF

echo "✅ Lab environment setup completed!"
echo ""
echo "📁 Directory structure:"
echo "   📄 requirements.txt - Python dependencies"
echo "   📄 setup.sh - Environment setup script"
echo "   📁 parquet-analysis/ - Lab 1 files"
echo "   📁 storage-optimization/ - Lab 2 files"
echo "   📁 compression-benchmark/ - Lab 3 files"
echo "   📁 iceberg-integration/ - Lab 4 files"
echo ""
echo "🚀 To get started:"
echo "   1. chmod +x setup.sh && ./setup.sh"
echo "   2. source lab-env/bin/activate"
echo "   3. cd parquet-analysis && python lab1_starter.py"
echo ""
echo "📚 See README.md for detailed instructions"