# Module 5: Columnar Storage Optimization

Welcome to the columnar storage deep dive! This module explores how columnar formats like Parquet revolutionize analytical query performance through advanced compression, encoding, and storage optimization techniques.

## 🎯 Learning Objectives

By the end of this module, you will:
- Master Parquet file format internals and row group optimization
- Implement advanced compression techniques (dictionary encoding, RLE, bit-packing)
- Optimize predicate pushdown and column pruning for query acceleration
- Integrate columnar storage with Apache Iceberg for maximum performance
- Design storage layouts for different analytical workload patterns

## 📚 Module Overview

### Duration: 1 Week (16 hours)
- **Theory & Concepts**: 5 hours
- **Hands-on Labs**: 8 hours
- **Performance Analysis**: 3 hours

### Prerequisites
- Understanding of file systems and I/O patterns
- Basic knowledge of data compression techniques
- Familiarity with SQL query execution
- Module 3 (Object Storage) completed

## 🧠 Core Concepts

### 1. Columnar vs Row Storage

**Storage Layout Comparison**

```
Row-based Storage (Traditional):
Record 1: [id=1, name="Alice", age=25, salary=50000]
Record 2: [id=2, name="Bob", age=30, salary=60000]
Record 3: [id=3, name="Carol", age=35, salary=70000]

Storage Layout: [1,Alice,25,50000,2,Bob,30,60000,3,Carol,35,70000]

Columnar Storage (Optimized):
Column id:     [1, 2, 3]
Column name:   ["Alice", "Bob", "Carol"]
Column age:    [25, 30, 35]
Column salary: [50000, 60000, 70000]

Storage Layout: [1,2,3][Alice,Bob,Carol][25,30,35][50000,60000,70000]
```

**Advantages of Columnar Storage**:
1. **Better Compression**: Similar values stored together compress more efficiently
2. **Column Pruning**: Read only needed columns, skip others entirely
3. **Vectorized Processing**: Process entire columns at once using SIMD instructions
4. **Predicate Pushdown**: Filter data during I/O without loading into memory

### 2. Parquet File Format Architecture

**File Structure Overview**

```
┌─────────────────────────────────────────────────────────────┐
│                    Parquet File Structure                   │
├─────────────────────────────────────────────────────────────┤
│  Magic Number (4 bytes): "PAR1"                           │
├─────────────────────────────────────────────────────────────┤
│  Row Group 1                                               │
│  ├── Column Chunk 1 (e.g., user_id)                       │
│  │   ├── Page Header                                       │
│  │   ├── Repetition Levels (for nested data)              │
│  │   ├── Definition Levels (for nullable fields)          │
│  │   ├── Data Values (compressed & encoded)               │
│  │   └── Page Footer                                       │
│  ├── Column Chunk 2 (e.g., timestamp)                     │
│  └── Column Chunk N...                                     │
├─────────────────────────────────────────────────────────────┤
│  Row Group 2                                               │
│  └── (same structure as Row Group 1)                      │
├─────────────────────────────────────────────────────────────┤
│  Footer Metadata                                           │
│  ├── Schema Definition                                     │
│  ├── Row Group Metadata                                    │
│  │   ├── Column Statistics (min, max, null_count)         │
│  │   ├── Compression Type                                  │
│  │   └── Encoding Information                              │
│  └── Key-Value Metadata                                    │
├─────────────────────────────────────────────────────────────┤
│  Footer Length (4 bytes)                                   │
├─────────────────────────────────────────────────────────────┤
│  Magic Number (4 bytes): "PAR1"                           │
└─────────────────────────────────────────────────────────────┘
```

**Key Components Explained**:

1. **Row Groups**: Large horizontal partitions (64MB-1GB), unit of parallelization
2. **Column Chunks**: All values for a column within a row group
3. **Pages**: Smallest unit of I/O within a column chunk (8KB-1MB)
4. **Metadata**: Statistics and schema information for query planning

### 3. Encoding Techniques

**Dictionary Encoding**
```python
# Example: String column with repeated values
original_data = ["Product_A", "Product_B", "Product_A", "Product_C", "Product_A"]

# Dictionary encoding
dictionary = {0: "Product_A", 1: "Product_B", 2: "Product_C"}
encoded_data = [0, 1, 0, 2, 0]

# Space savings: 45 bytes -> 13 bytes (71% reduction)
```

**Run Length Encoding (RLE)**
```python
# Example: Column with many repeated values
original_data = [1, 1, 1, 1, 2, 2, 3, 3, 3, 3, 3]

# RLE encoding: (value, count) pairs
rle_encoded = [(1, 4), (2, 2), (3, 5)]

# Space savings: 44 bytes -> 12 bytes (73% reduction)
```

**Bit Packing**
```python
# Example: Small integer values (0-7, fits in 3 bits)
original_data = [5, 3, 7, 1, 0, 6, 2, 4]  # 8 integers × 32 bits = 256 bits

# Bit-packed: 3 bits per value
bit_packed = "101 011 111 001 000 110 010 100"  # 24 bits total

# Space savings: 256 bits -> 24 bits (91% reduction)
```

### 4. Compression Algorithms

**Comparison of Compression Algorithms**

| Algorithm | Compression Ratio | Speed | CPU Usage | Use Case |
|-----------|-------------------|-------|-----------|----------|
| **Snappy** | Low (2-4x) | Very Fast | Low | Real-time ingestion |
| **LZ4** | Low-Medium (2-5x) | Very Fast | Low | Low-latency queries |
| **GZIP** | Medium (5-10x) | Medium | Medium | Balanced performance |
| **ZSTD** | High (8-15x) | Fast | Medium | Modern balanced choice |
| **BROTLI** | High (10-20x) | Slow | High | Archival storage |

**Performance Analysis Example**:
```python
# Compression benchmark results for 1GB analytical dataset
compression_results = {
    "uncompressed": {"size_mb": 1024, "read_time_ms": 100, "cpu_usage": "10%"},
    "snappy": {"size_mb": 341, "read_time_ms": 120, "cpu_usage": "15%"},
    "lz4": {"size_mb": 287, "read_time_ms": 125, "cpu_usage": "18%"},
    "gzip": {"size_mb": 145, "read_time_ms": 180, "cpu_usage": "35%"},
    "zstd": {"size_mb": 118, "read_time_ms": 155, "cpu_usage": "28%"},
    "brotli": {"size_mb": 89, "read_time_ms": 320, "cpu_usage": "55%"}
}

# Winner for analytical workloads: ZSTD (best balance of size vs speed)
```

### 5. Query Optimization with Columnar Storage

**Predicate Pushdown Example**
```sql
-- Query: Find high-value transactions in Electronics category
SELECT transaction_id, amount, customer_id 
FROM sales_transactions 
WHERE category = 'Electronics' 
  AND amount > 1000 
  AND transaction_date >= '2023-01-01';

-- Without predicate pushdown:
-- 1. Read ALL data from storage (100GB)
-- 2. Apply filters in memory
-- 3. Process 1.2GB of relevant data

-- With predicate pushdown (Parquet):
-- 1. Read footer metadata first (few KB)
-- 2. Skip row groups where:
--    - max(amount) <= 1000
--    - max(transaction_date) < '2023-01-01'
--    - category statistics exclude 'Electronics'
-- 3. Read only relevant row groups (8GB)
-- 4. Within row groups, skip non-matching pages
-- 5. Process only 1.2GB of actual data

-- Result: 92% I/O reduction, 10x faster query execution
```

**Column Pruning Example**
```sql
-- Query needs only 3 columns from 50-column table
SELECT customer_id, purchase_amount, purchase_date
FROM customer_transactions
WHERE purchase_date >= '2023-01-01';

-- Column pruning benefits:
-- - Read only 3 column chunks instead of 50 (94% I/O reduction)
-- - Smaller memory footprint
-- - Better cache utilization
-- - Faster network transfer
```

## 🛠 Hands-on Labs

### Lab 1: Parquet File Analysis and Optimization

**Objective**: Analyze Parquet file internals and optimize storage layout.

**Setup**:
```bash
# Create lab environment
mkdir -p 05-columnar-storage/labs/parquet-analysis
cd 05-columnar-storage/labs/parquet-analysis

# Install dependencies
pip install pyarrow pandas numpy matplotlib seaborn parquet-tools
```

**Parquet Analysis Tool**:
```python
# parquet_analyzer.py
import pyarrow as pa
import pyarrow.parquet as pq
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
import json
from typing import Dict, List, Any

class ParquetAnalyzer:
    def __init__(self, file_path: str):
        self.file_path = file_path
        self.parquet_file = pq.ParquetFile(file_path)
        self.metadata = self.parquet_file.metadata
        self.schema = self.parquet_file.schema
        
    def analyze_file_structure(self) -> Dict[str, Any]:
        """Analyze overall file structure"""
        analysis = {
            "file_size_mb": Path(self.file_path).stat().st_size / (1024 * 1024),
            "schema": {
                "num_columns": len(self.schema),
                "columns": [
                    {
                        "name": field.name,
                        "type": str(field.type),
                        "nullable": field.nullable
                    }
                    for field in self.schema
                ]
            },
            "row_groups": {
                "count": self.metadata.num_row_groups,
                "total_rows": self.metadata.num_rows,
                "avg_rows_per_group": self.metadata.num_rows / self.metadata.num_row_groups
            }
        }
        
        return analysis
    
    def analyze_row_groups(self) -> List[Dict[str, Any]]:
        """Analyze individual row groups"""
        row_group_analysis = []
        
        for i in range(self.metadata.num_row_groups):
            rg = self.metadata.row_group(i)
            
            rg_analysis = {
                "row_group_id": i,
                "num_rows": rg.num_rows,
                "total_byte_size": rg.total_byte_size,
                "compressed_size": sum(rg.column(j).total_compressed_size for j in range(rg.num_columns)),
                "uncompressed_size": sum(rg.column(j).total_uncompressed_size for j in range(rg.num_columns)),
                "compression_ratio": 0,
                "columns": []
            }
            
            # Calculate compression ratio
            if rg_analysis["uncompressed_size"] > 0:
                rg_analysis["compression_ratio"] = rg_analysis["uncompressed_size"] / rg_analysis["compressed_size"]
            
            # Analyze each column in the row group
            for j in range(rg.num_columns):
                col = rg.column(j)
                col_analysis = {
                    "column_name": col.path_in_schema,
                    "compression": col.compression,
                    "encoding": col.encodings,
                    "compressed_size": col.total_compressed_size,
                    "uncompressed_size": col.total_uncompressed_size,
                    "num_values": col.num_values,
                    "null_count": col.statistics.null_count if col.statistics else None,
                    "min_value": str(col.statistics.min) if col.statistics else None,
                    "max_value": str(col.statistics.max) if col.statistics else None
                }
                rg_analysis["columns"].append(col_analysis)
            
            row_group_analysis.append(rg_analysis)
        
        return row_group_analysis
    
    def analyze_compression_efficiency(self) -> Dict[str, Any]:
        """Analyze compression efficiency by column and compression type"""
        compression_stats = {}
        
        for i in range(self.metadata.num_row_groups):
            rg = self.metadata.row_group(i)
            
            for j in range(rg.num_columns):
                col = rg.column(j)
                col_name = col.path_in_schema
                compression_type = str(col.compression)
                
                if col_name not in compression_stats:
                    compression_stats[col_name] = {}
                
                if compression_type not in compression_stats[col_name]:
                    compression_stats[col_name][compression_type] = {
                        "total_compressed": 0,
                        "total_uncompressed": 0,
                        "count": 0
                    }
                
                stats = compression_stats[col_name][compression_type]
                stats["total_compressed"] += col.total_compressed_size
                stats["total_uncompressed"] += col.total_uncompressed_size
                stats["count"] += 1
        
        # Calculate compression ratios
        for col_name in compression_stats:
            for compression_type in compression_stats[col_name]:
                stats = compression_stats[col_name][compression_type]
                if stats["total_compressed"] > 0:
                    stats["compression_ratio"] = stats["total_uncompressed"] / stats["total_compressed"]
                else:
                    stats["compression_ratio"] = 1.0
        
        return compression_stats
    
    def generate_report(self) -> str:
        """Generate comprehensive analysis report"""
        structure = self.analyze_file_structure()
        row_groups = self.analyze_row_groups()
        compression = self.analyze_compression_efficiency()
        
        report = f"""
# Parquet File Analysis Report

## File Overview
- **File Size**: {structure['file_size_mb']:.2f} MB
- **Total Rows**: {structure['row_groups']['total_rows']:,}
- **Columns**: {structure['schema']['num_columns']}
- **Row Groups**: {structure['row_groups']['count']}
- **Avg Rows per Group**: {structure['row_groups']['avg_rows_per_group']:.0f}

## Schema Information
"""
        
        for col in structure['schema']['columns']:
            report += f"- **{col['name']}**: {col['type']} ({'nullable' if col['nullable'] else 'required'})\n"
        
        report += "\n## Row Group Analysis\n"
        total_compressed = sum(rg['compressed_size'] for rg in row_groups)
        total_uncompressed = sum(rg['uncompressed_size'] for rg in row_groups)
        overall_ratio = total_uncompressed / total_compressed if total_compressed > 0 else 1.0
        
        report += f"- **Overall Compression Ratio**: {overall_ratio:.2f}x\n"
        report += f"- **Total Compressed Size**: {total_compressed / (1024*1024):.2f} MB\n"
        report += f"- **Total Uncompressed Size**: {total_uncompressed / (1024*1024):.2f} MB\n\n"
        
        report += "### Row Group Details\n"
        for rg in row_groups:
            report += f"- **Row Group {rg['row_group_id']}**: {rg['num_rows']:,} rows, "
            report += f"{rg['compressed_size']/(1024*1024):.2f} MB compressed, "
            report += f"{rg['compression_ratio']:.2f}x ratio\n"
        
        report += "\n## Compression Analysis by Column\n"
        for col_name, compressions in compression.items():
            report += f"\n### {col_name}\n"
            for comp_type, stats in compressions.items():
                report += f"- **{comp_type}**: {stats['compression_ratio']:.2f}x ratio, "
                report += f"{stats['total_compressed']/(1024*1024):.2f} MB compressed\n"
        
        return report
    
    def visualize_compression(self, save_path: str = None):
        """Create compression visualization"""
        compression_stats = self.analyze_compression_efficiency()
        
        # Prepare data for visualization
        cols = []
        ratios = []
        sizes = []
        
        for col_name, compressions in compression_stats.items():
            for comp_type, stats in compressions.items():
                cols.append(f"{col_name}\n({comp_type})")
                ratios.append(stats['compression_ratio'])
                sizes.append(stats['total_compressed'] / (1024 * 1024))  # MB
        
        # Create subplots
        fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(15, 12))
        
        # Compression ratios
        bars1 = ax1.bar(range(len(cols)), ratios, color='skyblue', alpha=0.7)
        ax1.set_xlabel('Column (Compression Type)')
        ax1.set_ylabel('Compression Ratio')
        ax1.set_title('Compression Ratios by Column')
        ax1.set_xticks(range(len(cols)))
        ax1.set_xticklabels(cols, rotation=45, ha='right')
        
        # Add value labels on bars
        for i, bar in enumerate(bars1):
            height = bar.get_height()
            ax1.text(bar.get_x() + bar.get_width()/2., height + 0.05,
                    f'{ratios[i]:.1f}x', ha='center', va='bottom')
        
        # Compressed sizes
        bars2 = ax2.bar(range(len(cols)), sizes, color='lightcoral', alpha=0.7)
        ax2.set_xlabel('Column (Compression Type)')
        ax2.set_ylabel('Compressed Size (MB)')
        ax2.set_title('Compressed Size by Column')
        ax2.set_xticks(range(len(cols)))
        ax2.set_xticklabels(cols, rotation=45, ha='right')
        
        # Add value labels on bars
        for i, bar in enumerate(bars2):
            height = bar.get_height()
            ax2.text(bar.get_x() + bar.get_width()/2., height + max(sizes)*0.01,
                    f'{sizes[i]:.1f}', ha='center', va='bottom')
        
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
        else:
            plt.show()

def create_sample_data():
    """Create sample data with different compression characteristics"""
    np.random.seed(42)
    
    # Generate data with different patterns
    n_rows = 100000
    
    data = {
        # High cardinality string (poor dictionary encoding)
        'transaction_id': [f"TXN_{i:08d}" for i in range(n_rows)],
        
        # Low cardinality string (excellent dictionary encoding)
        'category': np.random.choice(['Electronics', 'Clothing', 'Books', 'Home', 'Sports'], n_rows),
        
        # Highly repetitive data (excellent RLE)
        'status': np.random.choice(['ACTIVE', 'PENDING'], n_rows, p=[0.95, 0.05]),
        
        # Sequential integers (good bit-packing)
        'user_id': np.random.randint(1, 10000, n_rows),
        
        # High precision decimals (poor compression)
        'amount': np.random.uniform(0.01, 9999.99, n_rows),
        
        # Timestamps (moderate compression)
        'timestamp': pd.date_range('2023-01-01', periods=n_rows, freq='1min'),
        
        # Boolean data (excellent bit-packing)
        'is_premium': np.random.choice([True, False], n_rows, p=[0.3, 0.7]),
        
        # Nested/repeated data pattern
        'tags': [['tag1', 'tag2'] if i % 3 == 0 else ['tag1'] for i in range(n_rows)]
    }
    
    return pd.DataFrame(data)

def compression_benchmark():
    """Compare different compression algorithms"""
    print("🏗️  Creating sample dataset...")
    df = create_sample_data()
    
    compression_types = ['snappy', 'gzip', 'brotli', 'lz4', 'zstd']
    results = {}
    
    for compression in compression_types:
        print(f"📊 Testing {compression} compression...")
        
        # Write with compression
        filename = f"sample_data_{compression}.parquet"
        start_time = pd.Timestamp.now()
        
        try:
            df.to_parquet(filename, compression=compression, engine='pyarrow')
            write_time = (pd.Timestamp.now() - start_time).total_seconds()
            
            # Analyze file
            analyzer = ParquetAnalyzer(filename)
            file_size = Path(filename).stat().st_size / (1024 * 1024)  # MB
            
            # Read performance
            start_time = pd.Timestamp.now()
            _ = pd.read_parquet(filename)
            read_time = (pd.Timestamp.now() - start_time).total_seconds()
            
            results[compression] = {
                'file_size_mb': file_size,
                'write_time_sec': write_time,
                'read_time_sec': read_time,
                'compression_ratio': analyzer.analyze_compression_efficiency()
            }
            
            print(f"  ✅ {compression}: {file_size:.2f} MB, "
                  f"write: {write_time:.2f}s, read: {read_time:.2f}s")
                  
        except Exception as e:
            print(f"  ❌ {compression} failed: {e}")
            results[compression] = None
    
    return results

def main():
    """Run Parquet analysis demonstration"""
    print("🚀 Starting Parquet Analysis Lab")
    
    # Create and analyze sample data
    print("\n📊 Running compression benchmark...")
    benchmark_results = compression_benchmark()
    
    # Analyze one of the files in detail
    print("\n🔍 Detailed analysis of ZSTD compressed file...")
    if 'zstd' in benchmark_results and benchmark_results['zstd']:
        analyzer = ParquetAnalyzer("sample_data_zstd.parquet")
        
        # Generate report
        report = analyzer.generate_report()
        print(report)
        
        # Save report
        with open("parquet_analysis_report.md", "w") as f:
            f.write(report)
        
        # Create visualizations
        analyzer.visualize_compression("compression_analysis.png")
        print("📈 Visualizations saved to compression_analysis.png")
    
    # Compare compression results
    print("\n📊 Compression Benchmark Summary:")
    print("| Algorithm | Size (MB) | Write (s) | Read (s) | Ratio |")
    print("|-----------|-----------|-----------|----------|-------|")
    
    for comp, result in benchmark_results.items():
        if result:
            # Calculate overall compression ratio from first column
            first_col_stats = list(result['compression_ratio'].values())[0]
            first_comp_stats = list(first_col_stats.values())[0]
            ratio = first_comp_stats.get('compression_ratio', 1.0)
            
            print(f"| {comp:9} | {result['file_size_mb']:9.2f} | "
                  f"{result['write_time_sec']:9.2f} | {result['read_time_sec']:8.2f} | "
                  f"{ratio:5.1f}x |")
    
    print("\n🎉 Parquet analysis completed!")

if __name__ == "__main__":
    main()
```

### Lab 2: Storage Layout Optimization

**Objective**: Optimize storage layout for different query patterns.

```python
# storage_optimizer.py
import pyarrow as pa
import pyarrow.parquet as pq
import pandas as pd
import numpy as np
from typing import List, Dict, Any
import time

class StorageLayoutOptimizer:
    
    def __init__(self, df: pd.DataFrame):
        self.df = df
        self.query_patterns = []
    
    def add_query_pattern(self, columns: List[str], filters: Dict[str, Any], 
                         frequency: int = 1):
        """Add a query pattern for optimization"""
        self.query_patterns.append({
            'columns': columns,
            'filters': filters,
            'frequency': frequency
        })
    
    def optimize_row_group_size(self, target_size_mb: int = 128) -> Dict[str, Any]:
        """Optimize row group size based on target"""
        df_size_mb = self.df.memory_usage(deep=True).sum() / (1024 * 1024)
        rows_per_mb = len(self.df) / df_size_mb
        optimal_rows_per_group = int(target_size_mb * rows_per_mb)
        
        return {
            'current_rows': len(self.df),
            'estimated_size_mb': df_size_mb,
            'rows_per_mb': rows_per_mb,
            'optimal_rows_per_group': optimal_rows_per_group,
            'estimated_row_groups': len(self.df) // optimal_rows_per_group + 1
        }
    
    def analyze_column_access_patterns(self) -> Dict[str, float]:
        """Analyze which columns are accessed together"""
        column_weights = {col: 0 for col in self.df.columns}
        
        for pattern in self.query_patterns:
            for col in pattern['columns']:
                if col in column_weights:
                    column_weights[col] += pattern['frequency']
        
        # Normalize weights
        max_weight = max(column_weights.values()) if column_weights.values() else 1
        return {col: weight / max_weight for col, weight in column_weights.items()}
    
    def suggest_partitioning(self) -> List[str]:
        """Suggest partitioning columns based on filter patterns"""
        filter_frequency = {}
        
        for pattern in self.query_patterns:
            for filter_col in pattern['filters'].keys():
                if filter_col not in filter_frequency:
                    filter_frequency[filter_col] = 0
                filter_frequency[filter_col] += pattern['frequency']
        
        # Sort by frequency and cardinality
        suggestions = []
        for col, freq in sorted(filter_frequency.items(), key=lambda x: x[1], reverse=True):
            if col in self.df.columns:
                cardinality = self.df[col].nunique()
                # Good partition columns: frequently filtered, moderate cardinality
                if 10 <= cardinality <= 1000:
                    suggestions.append(col)
        
        return suggestions[:3]  # Top 3 suggestions
    
    def benchmark_layouts(self) -> Dict[str, Any]:
        """Benchmark different storage layouts"""
        results = {}
        
        # Test different row group sizes
        row_group_sizes = [64, 128, 256, 512]  # MB
        
        for size_mb in row_group_sizes:
            layout_name = f"row_group_{size_mb}mb"
            results[layout_name] = self._benchmark_layout(
                row_group_size_mb=size_mb
            )
        
        # Test different compression algorithms
        compressions = ['snappy', 'gzip', 'zstd']
        for compression in compressions:
            layout_name = f"compression_{compression}"
            results[layout_name] = self._benchmark_layout(
                compression=compression
            )
        
        return results
    
    def _benchmark_layout(self, row_group_size_mb: int = 128, 
                         compression: str = 'snappy') -> Dict[str, Any]:
        """Benchmark a specific storage layout"""
        # Calculate rows per group
        optimization = self.optimize_row_group_size(row_group_size_mb)
        rows_per_group = optimization['optimal_rows_per_group']
        
        filename = f"benchmark_{row_group_size_mb}mb_{compression}.parquet"
        
        # Write with specific settings
        start_time = time.time()
        self.df.to_parquet(
            filename,
            compression=compression,
            row_group_size=rows_per_group,
            engine='pyarrow'
        )
        write_time = time.time() - start_time
        
        # Measure file size
        file_size = Path(filename).stat().st_size / (1024 * 1024)
        
        # Benchmark read performance for query patterns
        read_times = []
        for pattern in self.query_patterns:
            start_time = time.time()
            
            # Read with column pruning and filtering
            df_filtered = pd.read_parquet(
                filename,
                columns=pattern['columns'],
                filters=[(col, '==', val) for col, val in pattern['filters'].items()]
            )
            
            read_time = time.time() - start_time
            read_times.append(read_time)
        
        avg_read_time = np.mean(read_times) if read_times else 0
        
        return {
            'file_size_mb': file_size,
            'write_time_sec': write_time,
            'avg_read_time_sec': avg_read_time,
            'rows_per_group': rows_per_group,
            'compression': compression
        }

def create_realistic_dataset():
    """Create a realistic dataset for optimization testing"""
    np.random.seed(42)
    n_rows = 1_000_000
    
    # Simulate e-commerce transaction data
    categories = ['Electronics', 'Clothing', 'Books', 'Home', 'Sports', 'Beauty', 'Toys']
    statuses = ['completed', 'pending', 'cancelled', 'refunded']
    countries = ['US', 'UK', 'DE', 'FR', 'JP', 'CA', 'AU']
    
    data = {
        'transaction_id': [f"TXN_{i:08d}" for i in range(n_rows)],
        'user_id': np.random.randint(1, 100000, n_rows),
        'product_id': np.random.randint(1, 10000, n_rows),
        'category': np.random.choice(categories, n_rows),
        'amount': np.random.lognormal(3, 1, n_rows),  # Realistic price distribution
        'quantity': np.random.randint(1, 10, n_rows),
        'status': np.random.choice(statuses, n_rows, p=[0.8, 0.1, 0.07, 0.03]),
        'country': np.random.choice(countries, n_rows, p=[0.4, 0.15, 0.1, 0.1, 0.1, 0.1, 0.05]),
        'timestamp': pd.date_range('2023-01-01', periods=n_rows, freq='30s'),
        'is_mobile': np.random.choice([True, False], n_rows, p=[0.6, 0.4]),
        'discount_percent': np.random.exponential(5, n_rows),  # Most have small discounts
    }
    
    return pd.DataFrame(data)

def main():
    """Run storage optimization demonstration"""
    print("🚀 Starting Storage Layout Optimization Lab")
    
    # Create realistic dataset
    print("🏗️  Creating realistic dataset...")
    df = create_realistic_dataset()
    print(f"   Dataset: {len(df):,} rows, {len(df.columns)} columns")
    print(f"   Memory usage: {df.memory_usage(deep=True).sum() / (1024*1024):.2f} MB")
    
    # Initialize optimizer
    optimizer = StorageLayoutOptimizer(df)
    
    # Add common query patterns
    print("\n📊 Adding common query patterns...")
    
    # Pattern 1: Sales by category (frequent)
    optimizer.add_query_pattern(
        columns=['category', 'amount', 'quantity'],
        filters={'status': 'completed'},
        frequency=10
    )
    
    # Pattern 2: Country analysis (moderate)
    optimizer.add_query_pattern(
        columns=['country', 'amount', 'timestamp'],
        filters={'country': 'US'},
        frequency=5
    )
    
    # Pattern 3: Mobile transactions (occasional)
    optimizer.add_query_pattern(
        columns=['is_mobile', 'amount', 'category'],
        filters={'is_mobile': True},
        frequency=2
    )
    
    # Pattern 4: High-value transactions (rare but important)
    optimizer.add_query_pattern(
        columns=['transaction_id', 'user_id', 'amount', 'category'],
        filters={'amount': 1000},  # Simplified filter for demo
        frequency=1
    )
    
    # Analyze current data
    print("\n🔍 Analyzing data characteristics...")
    
    # Row group optimization
    row_group_opt = optimizer.optimize_row_group_size()
    print(f"   Optimal row group size: {row_group_opt['optimal_rows_per_group']:,} rows")
    print(f"   Estimated row groups: {row_group_opt['estimated_row_groups']}")
    
    # Column access analysis
    column_weights = optimizer.analyze_column_access_patterns()
    print(f"   Most accessed columns: {sorted(column_weights.items(), key=lambda x: x[1], reverse=True)[:5]}")
    
    # Partitioning suggestions
    partition_suggestions = optimizer.suggest_partitioning()
    print(f"   Suggested partition columns: {partition_suggestions}")
    
    # Benchmark different layouts
    print("\n⚡ Benchmarking storage layouts...")
    benchmark_results = optimizer.benchmark_layouts()
    
    # Display results
    print("\n📊 Benchmark Results:")
    print("| Layout | Size (MB) | Write (s) | Avg Read (s) | Efficiency Score |")
    print("|--------|-----------|-----------|--------------|------------------|")
    
    for layout, result in benchmark_results.items():
        # Calculate efficiency score (lower is better)
        # Combines file size, write time, and read time
        size_score = result['file_size_mb'] / 100  # Normalize to ~1.0
        write_score = result['write_time_sec'] / 10  # Normalize to ~1.0
        read_score = result['avg_read_time_sec'] * 10  # Weight read performance higher
        efficiency = size_score + write_score + read_score
        
        print(f"| {layout:18} | {result['file_size_mb']:9.1f} | "
              f"{result['write_time_sec']:9.2f} | {result['avg_read_time_sec']:12.3f} | "
              f"{efficiency:16.2f} |")
    
    # Find best layout
    best_layout = min(benchmark_results.items(), 
                     key=lambda x: x[1]['file_size_mb'] + x[1]['avg_read_time_sec'] * 10)
    
    print(f"\n🏆 Best layout: {best_layout[0]}")
    print(f"   File size: {best_layout[1]['file_size_mb']:.1f} MB")
    print(f"   Avg read time: {best_layout[1]['avg_read_time_sec']:.3f} seconds")
    
    print("\n🎉 Storage optimization analysis completed!")

if __name__ == "__main__":
    main()
```

### Lab 3: Iceberg Integration Optimization

**Objective**: Optimize Parquet files within Iceberg table format.

```python
# iceberg_optimization.py
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *
import time
import json

class IcebergOptimizer:
    
    def __init__(self):
        self.spark = self._create_spark_session()
    
    def _create_spark_session(self):
        """Create optimized Spark session for Iceberg"""
        return SparkSession.builder \
            .appName("Iceberg Storage Optimization") \
            .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
            .config("spark.sql.catalog.spark_catalog", "org.apache.iceberg.spark.SparkSessionCatalog") \
            .config("spark.sql.catalog.spark_catalog.type", "hive") \
            .config("spark.serializer", "org.apache.spark.serializer.KryoSerializer") \
            .config("spark.sql.adaptive.enabled", "true") \
            .config("spark.sql.adaptive.coalescePartitions.enabled", "true") \
            .getOrCreate()
    
    def create_optimized_table(self, table_name: str, df, partition_cols: list = None):
        """Create Iceberg table with optimized storage settings"""
        
        writer = df.writeTo(table_name) \
            .tableProperty("format-version", "2") \
            .tableProperty("write.parquet.compression-codec", "zstd") \
            .tableProperty("write.parquet.row-group-size-bytes", "134217728") \
            .tableProperty("write.parquet.page-size-bytes", "1048576") \
            .tableProperty("write.parquet.dict-size-bytes", "2097152") \
            .tableProperty("write.metadata.compression-codec", "gzip") \
            .tableProperty("write.target-file-size-bytes", "536870912")
        
        if partition_cols:
            writer = writer.partitionedBy(*partition_cols)
        
        writer.createOrReplace()
        
        print(f"✅ Created optimized Iceberg table: {table_name}")
        return table_name
    
    def analyze_table_performance(self, table_name: str):
        """Analyze table performance characteristics"""
        
        # Get table files info
        files_df = self.spark.sql(f"SELECT * FROM {table_name}.files")
        files_stats = files_df.agg(
            count("*").alias("file_count"),
            sum("file_size_in_bytes").alias("total_size_bytes"),
            avg("file_size_in_bytes").alias("avg_file_size_bytes"),
            min("file_size_in_bytes").alias("min_file_size_bytes"),
            max("file_size_in_bytes").alias("max_file_size_bytes")
        ).collect()[0]
        
        # Get partition info
        partitions_df = self.spark.sql(f"SELECT * FROM {table_name}.partitions")
        partition_count = partitions_df.count()
        
        # Get snapshots info
        snapshots_df = self.spark.sql(f"SELECT * FROM {table_name}.snapshots")
        snapshot_count = snapshots_df.count()
        
        analysis = {
            "files": {
                "count": files_stats["file_count"],
                "total_size_mb": files_stats["total_size_bytes"] / (1024 * 1024),
                "avg_size_mb": files_stats["avg_file_size_bytes"] / (1024 * 1024),
                "min_size_mb": files_stats["min_file_size_bytes"] / (1024 * 1024),
                "max_size_mb": files_stats["max_file_size_bytes"] / (1024 * 1024)
            },
            "partitions": {"count": partition_count},
            "snapshots": {"count": snapshot_count}
        }
        
        return analysis
    
    def benchmark_query_performance(self, table_name: str, queries: list):
        """Benchmark query performance on optimized table"""
        results = []
        
        for i, query in enumerate(queries):
            print(f"🔍 Running query {i+1}/{len(queries)}...")
            
            # Warm up
            self.spark.sql(query.format(table=table_name)).count()
            
            # Actual benchmark
            start_time = time.time()
            result_count = self.spark.sql(query.format(table=table_name)).count()
            end_time = time.time()
            
            execution_time = end_time - start_time
            
            results.append({
                "query_id": i + 1,
                "execution_time_sec": execution_time,
                "result_count": result_count,
                "query": query
            })
            
            print(f"   ✅ Query {i+1}: {execution_time:.3f}s, {result_count:,} results")
        
        return results
    
    def optimize_table_maintenance(self, table_name: str):
        """Perform table maintenance operations"""
        print(f"🔧 Performing maintenance on {table_name}...")
        
        # Compact small files
        print("   📦 Compacting data files...")
        compact_start = time.time()
        self.spark.sql(f"CALL spark_catalog.system.rewrite_data_files('{table_name}')")
        compact_time = time.time() - compact_start
        print(f"   ✅ Compaction completed in {compact_time:.2f}s")
        
        # Update table statistics
        print("   📊 Computing table statistics...")
        stats_start = time.time()
        self.spark.sql(f"ANALYZE TABLE {table_name} COMPUTE STATISTICS")
        stats_time = time.time() - stats_start
        print(f"   ✅ Statistics updated in {stats_time:.2f}s")
        
        # Expire old snapshots (keep last 10)
        print("   🗑️  Expiring old snapshots...")
        expire_start = time.time()
        self.spark.sql(f"""
            CALL spark_catalog.system.expire_snapshots(
                table => '{table_name}',
                retain_last => 10
            )
        """)
        expire_time = time.time() - expire_start
        print(f"   ✅ Snapshots expired in {expire_time:.2f}s")
        
        return {
            "compact_time_sec": compact_time,
            "stats_time_sec": stats_time,
            "expire_time_sec": expire_time
        }

def create_sample_ecommerce_data(spark, num_rows: int = 5_000_000):
    """Create large sample e-commerce dataset"""
    
    # Create sample data using Spark
    from pyspark.sql.functions import rand, when, date_add, lit
    
    print(f"🏗️  Creating sample dataset with {num_rows:,} rows...")
    
    # Generate base dataset
    df = spark.range(num_rows).select(
        col("id").alias("transaction_id"),
        (rand() * 100000).cast("int").alias("user_id"),
        (rand() * 50000).cast("int").alias("product_id"),
        when(rand() < 0.3, "Electronics")
        .when(rand() < 0.5, "Clothing")
        .when(rand() < 0.7, "Books")
        .when(rand() < 0.85, "Home")
        .otherwise("Sports").alias("category"),
        (rand() * 1000 + 10).cast("decimal(10,2)").alias("amount"),
        (rand() * 10 + 1).cast("int").alias("quantity"),
        when(rand() < 0.8, "completed")
        .when(rand() < 0.9, "pending")
        .when(rand() < 0.97, "cancelled")
        .otherwise("refunded").alias("status"),
        when(rand() < 0.4, "US")
        .when(rand() < 0.55, "UK")
        .when(rand() < 0.65, "DE")
        .when(rand() < 0.75, "FR")
        .when(rand() < 0.85, "JP")
        .when(rand() < 0.95, "CA")
        .otherwise("AU").alias("country"),
        date_add(lit("2023-01-01"), (rand() * 365).cast("int")).alias("transaction_date"),
        (rand() < 0.6).alias("is_mobile"),
        (rand() * 30).cast("decimal(5,2)").alias("discount_percent")
    )
    
    return df

def main():
    """Run Iceberg optimization demonstration"""
    print("🚀 Starting Iceberg Storage Optimization Lab")
    
    optimizer = IcebergOptimizer()
    
    try:
        # Create large sample dataset
        sample_df = create_sample_ecommerce_data(optimizer.spark, 5_000_000)
        
        # Test different optimization strategies
        optimization_strategies = [
            {
                "name": "unoptimized",
                "table": "ecommerce_unoptimized", 
                "partition_cols": None,
                "description": "No partitioning, default settings"
            },
            {
                "name": "date_partitioned",
                "table": "ecommerce_date_partitioned",
                "partition_cols": ["transaction_date"],
                "description": "Partitioned by date"
            },
            {
                "name": "category_partitioned", 
                "table": "ecommerce_category_partitioned",
                "partition_cols": ["category"],
                "description": "Partitioned by category"
            },
            {
                "name": "multi_partitioned",
                "table": "ecommerce_multi_partitioned", 
                "partition_cols": ["country", "category"],
                "description": "Multi-level partitioning"
            }
        ]
        
        # Create tables with different strategies
        strategy_results = {}
        
        for strategy in optimization_strategies:
            print(f"\n📊 Testing strategy: {strategy['name']}")
            print(f"   Description: {strategy['description']}")
            
            # Create table
            start_time = time.time()
            table_name = optimizer.create_optimized_table(
                strategy["table"], 
                sample_df, 
                strategy["partition_cols"]
            )
            creation_time = time.time() - start_time
            
            # Analyze table
            analysis = optimizer.analyze_table_performance(table_name)
            analysis["creation_time_sec"] = creation_time
            analysis["strategy"] = strategy["name"]
            
            strategy_results[strategy["name"]] = analysis
            
            print(f"   ✅ Created in {creation_time:.2f}s")
            print(f"   📁 {analysis['files']['count']} files, "
                  f"{analysis['files']['total_size_mb']:.1f} MB total")
            print(f"   📂 {analysis['partitions']['count']} partitions")
        
        # Define benchmark queries
        benchmark_queries = [
            # Query 1: Category aggregation (benefits from category partitioning)
            "SELECT category, COUNT(*), SUM(amount) FROM {table} WHERE status = 'completed' GROUP BY category",
            
            # Query 2: Country-specific analysis (benefits from country partitioning)
            "SELECT COUNT(*) FROM {table} WHERE country = 'US' AND amount > 100",
            
            # Query 3: Date range query (benefits from date partitioning)
            "SELECT COUNT(*) FROM {table} WHERE transaction_date >= '2023-06-01' AND transaction_date < '2023-07-01'",
            
            # Query 4: Complex multi-filter query
            "SELECT category, AVG(amount) FROM {table} WHERE country IN ('US', 'UK') AND status = 'completed' AND is_mobile = true GROUP BY category"
        ]
        
        # Benchmark each strategy
        print("\n⚡ Running performance benchmarks...")
        benchmark_results = {}
        
        for strategy_name, analysis in strategy_results.items():
            table_name = f"ecommerce_{strategy_name}" if strategy_name != "unoptimized" else "ecommerce_unoptimized"
            
            print(f"\n🔍 Benchmarking {strategy_name}...")
            query_results = optimizer.benchmark_query_performance(table_name, benchmark_queries)
            
            benchmark_results[strategy_name] = {
                "queries": query_results,
                "avg_execution_time": sum(q["execution_time_sec"] for q in query_results) / len(query_results)
            }
        
        # Performance maintenance test
        print("\n🔧 Testing maintenance operations...")
        maintenance_table = "ecommerce_multi_partitioned"
        maintenance_results = optimizer.optimize_table_maintenance(maintenance_table)
        
        # Display comprehensive results
        print("\n📊 Optimization Strategy Comparison:")
        print("| Strategy | Files | Size (MB) | Partitions | Avg Query Time (s) | Creation Time (s) |")
        print("|----------|-------|-----------|------------|-------------------|-------------------|")
        
        for strategy_name, analysis in strategy_results.items():
            benchmark = benchmark_results[strategy_name]
            print(f"| {strategy_name:15} | {analysis['files']['count']:5} | "
                  f"{analysis['files']['total_size_mb']:9.1f} | {analysis['partitions']['count']:10} | "
                  f"{benchmark['avg_execution_time']:17.3f} | {analysis['creation_time_sec']:17.2f} |")
        
        print(f"\n📊 Query Performance Breakdown:")
        for i, query in enumerate(benchmark_queries, 1):
            print(f"\n🔍 Query {i}: {query[:60]}...")
            print("| Strategy | Time (s) | Results |")
            print("|----------|----------|---------|")
            
            for strategy_name in strategy_results.keys():
                query_result = benchmark_results[strategy_name]["queries"][i-1]
                print(f"| {strategy_name:15} | {query_result['execution_time_sec']:8.3f} | "
                      f"{query_result['result_count']:7,} |")
        
        # Recommendations
        print("\n💡 Optimization Recommendations:")
        
        best_overall = min(benchmark_results.items(), key=lambda x: x[1]["avg_execution_time"])
        print(f"   🏆 Best overall performance: {best_overall[0]} ({best_overall[1]['avg_execution_time']:.3f}s avg)")
        
        smallest_storage = min(strategy_results.items(), key=lambda x: x[1]["files"]["total_size_mb"])
        print(f"   💾 Most storage efficient: {smallest_storage[0]} ({smallest_storage[1]['files']['total_size_mb']:.1f} MB)")
        
        fewest_files = min(strategy_results.items(), key=lambda x: x[1]["files"]["count"])
        print(f"   📁 Fewest files: {fewest_files[0]} ({fewest_files[1]['files']['count']} files)")
        
        print(f"\n🔧 Maintenance Performance:")
        print(f"   📦 Compaction: {maintenance_results['compact_time_sec']:.2f}s")
        print(f"   📊 Statistics: {maintenance_results['stats_time_sec']:.2f}s")
        print(f"   🗑️  Snapshot cleanup: {maintenance_results['expire_time_sec']:.2f}s")
        
        print("\n🎉 Iceberg optimization analysis completed!")
        
    finally:
        optimizer.spark.stop()

if __name__ == "__main__":
    main()
```

## 📊 Assessment & Next Steps

### Knowledge Check
1. **Explain columnar storage advantages** over row-based storage for analytical workloads
2. **Compare compression algorithms** and their trade-offs for different data types  
3. **Optimize Parquet file layouts** for specific query patterns
4. **Integrate columnar optimization** with Iceberg table format

### Project Deliverables
- [ ] Parquet file analysis and compression benchmarking
- [ ] Storage layout optimization for different access patterns
- [ ] Iceberg table optimization with performance testing
- [ ] Comprehensive performance comparison report

### Real-world Applications

**Columnar storage in your data warehouse:**

1. **Query Acceleration**: 10-100x faster analytical queries through column pruning
2. **Storage Efficiency**: 5-20x compression ratios reduce storage costs
3. **I/O Optimization**: Read only required data, skip irrelevant columns/rows
4. **Vectorized Processing**: SIMD instructions process entire columns efficiently
5. **Predicate Pushdown**: Filter during I/O, not in memory

### Next Module Preview
**Module 6: Metadata Management** will cover:
- Hive Metastore architecture and deployment
- Schema registry and governance
- Cross-engine metadata sharing
- Unity Catalog integration patterns

The columnar storage optimizations you've mastered provide the foundation for efficient metadata-driven query planning and execution.

---

**Module 5 Complete!** 🎉 You now understand how to optimize columnar storage for maximum analytical performance, forming the storage backbone of your BigQuery-equivalent system.