# Module 3: Object Storage Deep Dive

Welcome to the object storage module! This module covers MinIO, the S3-compatible object storage that forms the foundation of your lakehouse architecture. You'll learn about distributed storage, erasure coding, and performance optimization.

## 🎯 Learning Objectives

By the end of this module, you will:
- Master MinIO architecture and deployment patterns
- Understand erasure coding and data protection mechanisms
- Implement S3-compatible storage APIs and integrations
- Optimize storage performance for analytical workloads
- Configure multi-node clusters with high availability

## 📚 Module Overview

### Duration: 1 Week (20 hours)
- **Theory & Concepts**: 5 hours
- **Hands-on Labs**: 12 hours
- **Performance Optimization**: 3 hours

### Prerequisites
- Basic understanding of distributed systems (Module 1)
- Familiarity with HTTP APIs and REST
- Docker and containerization knowledge

## 🧠 Core Concepts

### 1. Object Storage Fundamentals

**Object Storage vs Block Storage vs File Storage**

```
Object Storage (MinIO):
┌─────────────────────────────────────────┐
│ Bucket: analytics-data                  │
│ ├── Object: 2023/01/sales.parquet      │
│ │   ├── Metadata: content-type, size   │
│ │   └── Data: Binary blob              │
│ ├── Object: 2023/02/sales.parquet      │
│ │   ├── Metadata: content-type, size   │
│ │   └── Data: Binary blob              │
│ └── Object: schemas/sales.avsc          │
│     ├── Metadata: version, checksum    │
│     └── Data: Schema definition        │
└─────────────────────────────────────────┘
```

**Key Characteristics**:
- **Flat namespace**: Objects are stored in buckets with unique keys
- **HTTP/REST API**: Access via standard web protocols
- **Metadata**: Rich metadata support for analytics
- **Scalability**: Horizontally scalable to petabytes
- **Durability**: High durability through replication/erasure coding

### 2. MinIO Architecture

**Single-Node vs Multi-Node Deployment**

```
Single Node:
┌─────────────────┐
│   MinIO Server  │
│  ┌───────────┐  │
│  │   Disk 1  │  │
│  │   Disk 2  │  │
│  │   Disk 3  │  │
│  │   Disk 4  │  │
│  └───────────┘  │
└─────────────────┘

Multi-Node (Distributed):
┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│  MinIO      │  │  MinIO      │  │  MinIO      │  │  MinIO      │
│  Node 1     │  │  Node 2     │  │  Node 3     │  │  Node 4     │
│ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │
│ │ Disk 1  │ │  │ │ Disk 1  │ │  │ │ Disk 1  │ │  │ │ Disk 1  │ │
│ │ Disk 2  │ │  │ │ Disk 2  │ │  │ │ Disk 2  │ │  │ │ Disk 2  │ │
│ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │
└─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘
```

**Core Components**:
- **MinIO Server**: Core storage engine
- **Distributed Mode**: Automatic data distribution and replication
- **Console**: Web-based management interface
- **CLI (mc)**: Command-line administration tool

### 3. Erasure Coding

**How Erasure Coding Works**

```python
# Conceptual example of erasure coding
class ErasureCoding:
    def __init__(self, data_shards=4, parity_shards=2):
        self.data_shards = data_shards
        self.parity_shards = parity_shards
        self.total_shards = data_shards + parity_shards
    
    def encode(self, data):
        """
        Split data into chunks and create parity shards
        Example: 4+2 erasure coding can survive 2 disk failures
        """
        # Split data into equal chunks
        chunk_size = len(data) // self.data_shards
        data_chunks = [data[i:i+chunk_size] for i in range(0, len(data), chunk_size)]
        
        # Create parity chunks (simplified)
        parity_chunks = self.create_parity(data_chunks)
        
        return data_chunks + parity_chunks
    
    def create_parity(self, data_chunks):
        """Create parity shards for error correction"""
        # Simplified parity calculation
        parity1 = self.xor_chunks(data_chunks[0], data_chunks[1])
        parity2 = self.xor_chunks(data_chunks[2], data_chunks[3])
        return [parity1, parity2]
    
    def xor_chunks(self, chunk1, chunk2):
        """XOR two chunks for parity"""
        return bytes(a ^ b for a, b in zip(chunk1, chunk2))
    
    def can_recover(self, failed_shards):
        """Check if data can be recovered from failures"""
        return len(failed_shards) <= self.parity_shards
```

**Erasure Coding Benefits**:
- **Storage Efficiency**: Better than replication (1.5x vs 3x overhead)
- **Fault Tolerance**: Survives multiple disk/node failures
- **Performance**: Parallel read/write across multiple disks
- **Cost Effective**: Lower storage costs than replication

### 4. S3 Compatibility

**S3 API Operations**

```python
# S3-compatible operations with MinIO
import boto3
from botocore.exceptions import ClientError

class MinIOClient:
    def __init__(self, endpoint_url, access_key, secret_key):
        self.client = boto3.client(
            's3',
            endpoint_url=endpoint_url,
            aws_access_key_id=access_key,
            aws_secret_access_key=secret_key,
            region_name='us-east-1'  # Required for S3 compatibility
        )
    
    def create_bucket(self, bucket_name):
        """Create a new bucket"""
        try:
            self.client.create_bucket(Bucket=bucket_name)
            print(f"Bucket {bucket_name} created successfully")
        except ClientError as e:
            print(f"Error creating bucket: {e}")
    
    def upload_file(self, file_path, bucket_name, object_key):
        """Upload a file to bucket"""
        try:
            self.client.upload_file(file_path, bucket_name, object_key)
            print(f"File {file_path} uploaded as {object_key}")
        except ClientError as e:
            print(f"Error uploading file: {e}")
    
    def list_objects(self, bucket_name, prefix=None):
        """List objects in bucket"""
        try:
            kwargs = {'Bucket': bucket_name}
            if prefix:
                kwargs['Prefix'] = prefix
            
            response = self.client.list_objects_v2(**kwargs)
            return response.get('Contents', [])
        except ClientError as e:
            print(f"Error listing objects: {e}")
            return []
    
    def get_object_metadata(self, bucket_name, object_key):
        """Get object metadata"""
        try:
            response = self.client.head_object(Bucket=bucket_name, Key=object_key)
            return response['Metadata']
        except ClientError as e:
            print(f"Error getting metadata: {e}")
            return {}
    
    def presigned_url(self, bucket_name, object_key, expiration=3600):
        """Generate presigned URL for object access"""
        try:
            url = self.client.generate_presigned_url(
                'get_object',
                Params={'Bucket': bucket_name, 'Key': object_key},
                ExpiresIn=expiration
            )
            return url
        except ClientError as e:
            print(f"Error generating presigned URL: {e}")
            return None
```

## 🛠 Hands-on Labs

### Lab 1: MinIO Single-Node Setup

**Objective**: Deploy and configure a single-node MinIO instance.

**Setup**:
```bash
# Create lab directory
mkdir -p 03-object-storage/labs/single-node
cd 03-object-storage/labs/single-node
```

**Docker Compose Configuration**:
```yaml
# docker-compose.yml
version: '3.8'

services:
  minio:
    image: minio/minio:latest
    container_name: minio-single
    command: server /data --console-address ":9090"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin123
      MINIO_REGION_NAME: us-east-1
    ports:
      - "9000:9000"  # API
      - "9090:9090"  # Console
    volumes:
      - minio_data:/data
      - ./config:/root/.minio
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/ready"]
      interval: 30s
      timeout: 20s
      retries: 3
    networks:
      - minio-net

  # MinIO Client for testing
  mc:
    image: minio/mc:latest
    container_name: minio-client
    depends_on:
      - minio
    entrypoint: >
      /bin/sh -c "
      sleep 10;
      /usr/bin/mc alias set local http://minio:9000 minioadmin minioadmin123;
      /usr/bin/mc mb local/test-bucket;
      /usr/bin/mc mb local/analytics-data;
      /usr/bin/mc mb local/raw-data;
      echo 'MinIO setup complete';
      tail -f /dev/null
      "
    networks:
      - minio-net

volumes:
  minio_data:

networks:
  minio-net:
    driver: bridge
```

**Testing Script**:
```python
# test_minio.py
import boto3
import json
import time
from botocore.exceptions import ClientError

def test_minio_operations():
    """Test basic MinIO operations"""
    
    # Create MinIO client
    client = boto3.client(
        's3',
        endpoint_url='http://localhost:9000',
        aws_access_key_id='minioadmin',
        aws_secret_access_key='minioadmin123',
        region_name='us-east-1'
    )
    
    bucket_name = 'test-bucket'
    
    try:
        # Test 1: List buckets
        print("=== Test 1: List Buckets ===")
        response = client.list_buckets()
        for bucket in response['Buckets']:
            print(f"Bucket: {bucket['Name']}, Created: {bucket['CreationDate']}")
        
        # Test 2: Upload object
        print("\n=== Test 2: Upload Object ===")
        test_data = json.dumps({
            "timestamp": time.time(),
            "message": "Hello MinIO!",
            "metrics": {"cpu": 75, "memory": 60}
        })
        
        client.put_object(
            Bucket=bucket_name,
            Key='test-data.json',
            Body=test_data,
            ContentType='application/json',
            Metadata={'source': 'test-script', 'version': '1.0'}
        )
        print("Object uploaded successfully")
        
        # Test 3: List objects
        print("\n=== Test 3: List Objects ===")
        response = client.list_objects_v2(Bucket=bucket_name)
        for obj in response.get('Contents', []):
            print(f"Object: {obj['Key']}, Size: {obj['Size']} bytes, Modified: {obj['LastModified']}")
        
        # Test 4: Get object
        print("\n=== Test 4: Get Object ===")
        response = client.get_object(Bucket=bucket_name, Key='test-data.json')
        content = response['Body'].read().decode('utf-8')
        metadata = response['Metadata']
        print(f"Content: {content}")
        print(f"Metadata: {metadata}")
        
        # Test 5: Object metadata
        print("\n=== Test 5: Object Metadata ===")
        response = client.head_object(Bucket=bucket_name, Key='test-data.json')
        print(f"Content-Type: {response['ContentType']}")
        print(f"Last-Modified: {response['LastModified']}")
        print(f"ETag: {response['ETag']}")
        
        # Test 6: Presigned URL
        print("\n=== Test 6: Presigned URL ===")
        url = client.generate_presigned_url(
            'get_object',
            Params={'Bucket': bucket_name, 'Key': 'test-data.json'},
            ExpiresIn=3600
        )
        print(f"Presigned URL: {url}")
        
        # Test 7: Multipart upload (for large files)
        print("\n=== Test 7: Multipart Upload ===")
        large_data = "x" * (10 * 1024 * 1024)  # 10MB file
        
        # Initiate multipart upload
        response = client.create_multipart_upload(
            Bucket=bucket_name,
            Key='large-file.txt'
        )
        upload_id = response['UploadId']
        
        # Upload parts
        part_size = 5 * 1024 * 1024  # 5MB parts
        parts = []
        
        for i in range(0, len(large_data), part_size):
            part_number = len(parts) + 1
            part_data = large_data[i:i + part_size]
            
            response = client.upload_part(
                Bucket=bucket_name,
                Key='large-file.txt',
                PartNumber=part_number,
                UploadId=upload_id,
                Body=part_data
            )
            
            parts.append({
                'ETag': response['ETag'],
                'PartNumber': part_number
            })
        
        # Complete multipart upload
        client.complete_multipart_upload(
            Bucket=bucket_name,
            Key='large-file.txt',
            UploadId=upload_id,
            MultipartUpload={'Parts': parts}
        )
        print("Multipart upload completed")
        
        print("\n✅ All tests passed!")
        
    except ClientError as e:
        print(f"❌ Error: {e}")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")

if __name__ == "__main__":
    test_minio_operations()
```

**Run the Lab**:
```bash
# Start MinIO
docker-compose up -d

# Wait for startup
sleep 30

# Install Python dependencies
pip install boto3

# Run tests
python test_minio.py

# Access MinIO Console
echo "MinIO Console: http://localhost:9090"
echo "Login: minioadmin / minioadmin123"
```

### Lab 2: Multi-Node MinIO Cluster

**Objective**: Deploy a distributed MinIO cluster with erasure coding.

**Setup**:
```bash
mkdir -p 03-object-storage/labs/multi-node
cd 03-object-storage/labs/multi-node
```

**Docker Compose for Multi-Node**:
```yaml
# docker-compose-cluster.yml
version: '3.8'

services:
  minio1:
    image: minio/minio:latest
    hostname: minio1
    container_name: minio1
    command: server http://minio{1...4}/data{1...2} --console-address ":9090"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin123
      MINIO_REGION_NAME: us-east-1
    ports:
      - "9001:9000"
      - "9091:9090"
    volumes:
      - minio1-data1:/data1
      - minio1-data2:/data2
    networks:
      - minio-cluster
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/ready"]
      interval: 30s
      timeout: 10s
      retries: 5

  minio2:
    image: minio/minio:latest
    hostname: minio2
    container_name: minio2
    command: server http://minio{1...4}/data{1...2} --console-address ":9090"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin123
      MINIO_REGION_NAME: us-east-1
    ports:
      - "9002:9000"
      - "9092:9090"
    volumes:
      - minio2-data1:/data1
      - minio2-data2:/data2
    networks:
      - minio-cluster
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/ready"]
      interval: 30s
      timeout: 10s
      retries: 5

  minio3:
    image: minio/minio:latest
    hostname: minio3
    container_name: minio3
    command: server http://minio{1...4}/data{1...2} --console-address ":9090"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin123
      MINIO_REGION_NAME: us-east-1
    ports:
      - "9003:9000"
      - "9093:9090"
    volumes:
      - minio3-data1:/data1
      - minio3-data2:/data2
    networks:
      - minio-cluster
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/ready"]
      interval: 30s
      timeout: 10s
      retries: 5

  minio4:
    image: minio/minio:latest
    hostname: minio4
    container_name: minio4
    command: server http://minio{1...4}/data{1...2} --console-address ":9090"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin123
      MINIO_REGION_NAME: us-east-1
    ports:
      - "9004:9000"
      - "9094:9090"
    volumes:
      - minio4-data1:/data1
      - minio4-data2:/data2
    networks:
      - minio-cluster
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/ready"]
      interval: 30s
      timeout: 10s
      retries: 5

  # Load balancer for client access
  nginx:
    image: nginx:alpine
    container_name: minio-lb
    ports:
      - "9000:9000"
      - "9090:9090"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - minio1
      - minio2
      - minio3
      - minio4
    networks:
      - minio-cluster

volumes:
  minio1-data1:
  minio1-data2:
  minio2-data1:
  minio2-data2:
  minio3-data1:
  minio3-data2:
  minio4-data1:
  minio4-data2:

networks:
  minio-cluster:
    driver: bridge
```

**Nginx Load Balancer Configuration**:
```nginx
# nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream minio_s3 {
        server minio1:9000;
        server minio2:9000;
        server minio3:9000;
        server minio4:9000;
    }

    upstream minio_console {
        server minio1:9090;
        server minio2:9090;
        server minio3:9090;
        server minio4:9090;
    }

    server {
        listen 9000;
        
        # Increase body size for large uploads
        client_max_body_size 1G;
        
        # Proxy timeouts
        proxy_connect_timeout 300;
        proxy_send_timeout 300;
        proxy_read_timeout 300;
        send_timeout 300;

        location / {
            proxy_pass http://minio_s3;
            proxy_set_header Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # WebSocket upgrade headers
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }

    server {
        listen 9090;
        
        location / {
            proxy_pass http://minio_console;
            proxy_set_header Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # WebSocket upgrade for console
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }
}
```

**Cluster Testing Script**:
```python
# test_cluster.py
import boto3
import concurrent.futures
import time
import random
import string
from botocore.exceptions import ClientError

class MinIOClusterTester:
    def __init__(self, endpoint_url='http://localhost:9000'):
        self.client = boto3.client(
            's3',
            endpoint_url=endpoint_url,
            aws_access_key_id='minioadmin',
            aws_secret_access_key='minioadmin123',
            region_name='us-east-1'
        )
        self.bucket_name = 'cluster-test'
    
    def setup_bucket(self):
        """Create test bucket"""
        try:
            self.client.create_bucket(Bucket=self.bucket_name)
            print(f"✅ Bucket '{self.bucket_name}' created")
        except ClientError as e:
            if e.response['Error']['Code'] == 'BucketAlreadyOwnedByYou':
                print(f"✅ Bucket '{self.bucket_name}' already exists")
            else:
                print(f"❌ Error creating bucket: {e}")
    
    def test_fault_tolerance(self):
        """Test fault tolerance by simulating node failures"""
        print("\n=== Testing Fault Tolerance ===")
        
        # Upload test objects
        test_objects = []
        for i in range(10):
            key = f"fault-test-{i}.txt"
            data = f"Test data for fault tolerance {i} - " + "x" * 1000
            
            self.client.put_object(
                Bucket=self.bucket_name,
                Key=key,
                Body=data
            )
            test_objects.append(key)
        
        print(f"✅ Uploaded {len(test_objects)} test objects")
        
        # Verify all objects are accessible
        print("📊 Verifying object accessibility...")
        for key in test_objects:
            try:
                response = self.client.get_object(Bucket=self.bucket_name, Key=key)
                print(f"✅ {key}: Accessible")
            except ClientError as e:
                print(f"❌ {key}: Error - {e}")
        
        print("\n💡 To test fault tolerance:")
        print("1. Stop one MinIO node: docker stop minio1")
        print("2. Run this test again to verify objects are still accessible")
        print("3. Stop another node and test again")
        print("4. With 4+4 erasure coding, can survive 4 node failures")
    
    def test_performance(self):
        """Test cluster performance with concurrent operations"""
        print("\n=== Testing Performance ===")
        
        def upload_worker(worker_id):
            """Worker function for concurrent uploads"""
            uploaded = 0
            start_time = time.time()
            
            for i in range(50):  # 50 uploads per worker
                key = f"perf-test-{worker_id}-{i}.txt"
                # Generate random data
                data = ''.join(random.choices(string.ascii_letters + string.digits, k=10000))
                
                try:
                    self.client.put_object(
                        Bucket=self.bucket_name,
                        Key=key,
                        Body=data
                    )
                    uploaded += 1
                except ClientError as e:
                    print(f"❌ Upload error: {e}")
            
            duration = time.time() - start_time
            return uploaded, duration
        
        # Test with different levels of concurrency
        for num_workers in [1, 5, 10]:
            print(f"\n📊 Testing with {num_workers} concurrent workers...")
            
            start_time = time.time()
            
            with concurrent.futures.ThreadPoolExecutor(max_workers=num_workers) as executor:
                futures = [executor.submit(upload_worker, i) for i in range(num_workers)]
                results = [future.result() for future in concurrent.futures.as_completed(futures)]
            
            total_time = time.time() - start_time
            total_uploads = sum(result[0] for result in results)
            
            print(f"✅ Completed {total_uploads} uploads in {total_time:.2f} seconds")
            print(f"📈 Throughput: {total_uploads/total_time:.2f} uploads/second")
    
    def test_large_file_upload(self):
        """Test large file upload with multipart"""
        print("\n=== Testing Large File Upload ===")
        
        # Create 50MB test file
        file_size = 50 * 1024 * 1024
        chunk_size = 5 * 1024 * 1024  # 5MB chunks
        
        print(f"📦 Creating {file_size // (1024*1024)}MB test file...")
        
        # Generate large data
        data = b'x' * file_size
        
        start_time = time.time()
        
        try:
            # Use multipart upload for large files
            response = self.client.create_multipart_upload(
                Bucket=self.bucket_name,
                Key='large-test-file.bin'
            )
            upload_id = response['UploadId']
            
            parts = []
            part_number = 1
            
            for i in range(0, len(data), chunk_size):
                part_data = data[i:i + chunk_size]
                
                response = self.client.upload_part(
                    Bucket=self.bucket_name,
                    Key='large-test-file.bin',
                    PartNumber=part_number,
                    UploadId=upload_id,
                    Body=part_data
                )
                
                parts.append({
                    'ETag': response['ETag'],
                    'PartNumber': part_number
                })
                
                part_number += 1
                print(f"📤 Uploaded part {part_number-1}")
            
            # Complete upload
            self.client.complete_multipart_upload(
                Bucket=self.bucket_name,
                Key='large-test-file.bin',
                UploadId=upload_id,
                MultipartUpload={'Parts': parts}
            )
            
            upload_time = time.time() - start_time
            throughput = file_size / upload_time / (1024 * 1024)  # MB/s
            
            print(f"✅ Upload completed in {upload_time:.2f} seconds")
            print(f"📈 Throughput: {throughput:.2f} MB/s")
            
        except ClientError as e:
            print(f"❌ Large file upload error: {e}")
    
    def get_cluster_info(self):
        """Get cluster information"""
        print("\n=== Cluster Information ===")
        
        try:
            # List all objects to check distribution
            response = self.client.list_objects_v2(Bucket=self.bucket_name)
            objects = response.get('Contents', [])
            
            total_size = sum(obj['Size'] for obj in objects)
            print(f"📊 Total objects: {len(objects)}")
            print(f"📊 Total size: {total_size / (1024*1024):.2f} MB")
            
            # Bucket location
            response = self.client.get_bucket_location(Bucket=self.bucket_name)
            print(f"🗺  Bucket location: {response.get('LocationConstraint', 'us-east-1')}")
            
        except ClientError as e:
            print(f"❌ Error getting cluster info: {e}")

def main():
    """Run all cluster tests"""
    tester = MinIOClusterTester()
    
    print("🚀 Starting MinIO Cluster Tests")
    
    tester.setup_bucket()
    tester.test_fault_tolerance()
    tester.test_performance()
    tester.test_large_file_upload()
    tester.get_cluster_info()
    
    print("\n🎉 All tests completed!")

if __name__ == "__main__":
    main()
```

**Run the Cluster Lab**:
```bash
# Start cluster
docker-compose -f docker-compose-cluster.yml up -d

# Wait for cluster to be ready
sleep 60

# Run cluster tests
python test_cluster.py

# Test fault tolerance manually
docker stop minio1
python test_cluster.py  # Should still work

# Restart node
docker start minio1
```

### Lab 3: Performance Optimization

**Objective**: Optimize MinIO for analytical workloads.

**Performance Tuning Configuration**:
```yaml
# docker-compose-optimized.yml
version: '3.8'

services:
  minio1:
    image: minio/minio:latest
    hostname: minio1
    container_name: minio1-opt
    command: server http://minio{1...4}/data{1...4} --console-address ":9090"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin123
      MINIO_REGION_NAME: us-east-1
      # Performance optimizations
      MINIO_API_REQUESTS_MAX: "10000"
      MINIO_API_REQUESTS_DEADLINE: "10s"
      MINIO_API_CLUSTER_DEADLINE: "10s"
      MINIO_API_CORS_ALLOW_ORIGIN: "*"
    ports:
      - "9001:9000"
      - "9091:9090"
    volumes:
      # Use multiple drives per node for better performance
      - minio1-data1:/data1
      - minio1-data2:/data2
      - minio1-data3:/data3
      - minio1-data4:/data4
    networks:
      - minio-cluster
    deploy:
      resources:
        limits:
          memory: 4G
        reservations:
          memory: 2G
    ulimits:
      nofile:
        soft: 65536
        hard: 65536

  # Similar configuration for other nodes...
  # (omitted for brevity - use same pattern)
```

**Performance Testing Script**:
```python
# performance_test.py
import boto3
import time
import threading
import concurrent.futures
import statistics
from botocore.exceptions import ClientError

class PerformanceTester:
    def __init__(self, endpoint_url='http://localhost:9000'):
        self.client = boto3.client(
            's3',
            endpoint_url=endpoint_url,
            aws_access_key_id='minioadmin',
            aws_secret_access_key='minioadmin123',
            region_name='us-east-1'
        )
        self.bucket_name = 'perf-test'
    
    def setup(self):
        """Setup test environment"""
        try:
            self.client.create_bucket(Bucket=self.bucket_name)
        except ClientError:
            pass  # Bucket already exists
    
    def test_upload_throughput(self, file_sizes, concurrency_levels):
        """Test upload throughput with different file sizes and concurrency"""
        print("=== Upload Throughput Test ===")
        
        results = {}
        
        for size_mb in file_sizes:
            print(f"\n📊 Testing {size_mb}MB files...")
            size_bytes = size_mb * 1024 * 1024
            test_data = b'x' * size_bytes
            
            for concurrency in concurrency_levels:
                print(f"  Concurrency: {concurrency}")
                
                def upload_worker(worker_id):
                    start_time = time.time()
                    key = f"perf-{size_mb}mb-{concurrency}c-{worker_id}-{start_time}.bin"
                    
                    try:
                        self.client.put_object(
                            Bucket=self.bucket_name,
                            Key=key,
                            Body=test_data
                        )
                        return time.time() - start_time
                    except ClientError as e:
                        print(f"Upload error: {e}")
                        return None
                
                # Run concurrent uploads
                start_time = time.time()
                
                with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as executor:
                    futures = [executor.submit(upload_worker, i) for i in range(concurrency)]
                    durations = [f.result() for f in concurrent.futures.as_completed(futures)]
                
                total_time = time.time() - start_time
                valid_durations = [d for d in durations if d is not None]
                
                if valid_durations:
                    total_mb = size_mb * len(valid_durations)
                    throughput = total_mb / total_time
                    avg_latency = statistics.mean(valid_durations)
                    
                    results[f"{size_mb}MB-{concurrency}c"] = {
                        'throughput_mbps': throughput,
                        'avg_latency_s': avg_latency,
                        'successful_uploads': len(valid_durations)
                    }
                    
                    print(f"    Throughput: {throughput:.2f} MB/s")
                    print(f"    Avg Latency: {avg_latency:.3f}s")
        
        return results
    
    def test_read_performance(self, num_objects=100):
        """Test read performance with random access patterns"""
        print("\n=== Read Performance Test ===")
        
        # First, upload test objects
        print("📤 Uploading test objects...")
        test_data = b'x' * (1024 * 1024)  # 1MB objects
        object_keys = []
        
        for i in range(num_objects):
            key = f"read-test-{i}.bin"
            self.client.put_object(
                Bucket=self.bucket_name,
                Key=key,
                Body=test_data
            )
            object_keys.append(key)
        
        # Test sequential reads
        print("📖 Testing sequential reads...")
        start_time = time.time()
        
        for key in object_keys:
            try:
                response = self.client.get_object(Bucket=self.bucket_name, Key=key)
                data = response['Body'].read()
            except ClientError as e:
                print(f"Read error: {e}")
        
        sequential_time = time.time() - start_time
        sequential_throughput = (num_objects * len(test_data)) / sequential_time / (1024 * 1024)
        
        print(f"Sequential read throughput: {sequential_throughput:.2f} MB/s")
        
        # Test random reads
        print("🎲 Testing random reads...")
        import random
        random.shuffle(object_keys)
        
        start_time = time.time()
        
        for key in object_keys:
            try:
                response = self.client.get_object(Bucket=self.bucket_name, Key=key)
                data = response['Body'].read()
            except ClientError as e:
                print(f"Read error: {e}")
        
        random_time = time.time() - start_time
        random_throughput = (num_objects * len(test_data)) / random_time / (1024 * 1024)
        
        print(f"Random read throughput: {random_throughput:.2f} MB/s")
        
        return {
            'sequential_throughput_mbps': sequential_throughput,
            'random_throughput_mbps': random_throughput
        }
    
    def test_multipart_performance(self, file_size_mb=100, part_size_mb=5):
        """Test multipart upload performance"""
        print(f"\n=== Multipart Upload Test ({file_size_mb}MB file) ===")
        
        file_size = file_size_mb * 1024 * 1024
        part_size = part_size_mb * 1024 * 1024
        
        # Generate test data
        print("📦 Generating test data...")
        test_data = b'x' * file_size
        
        # Single upload test
        print("📤 Testing single upload...")
        start_time = time.time()
        
        try:
            self.client.put_object(
                Bucket=self.bucket_name,
                Key='single-upload-test.bin',
                Body=test_data
            )
            single_upload_time = time.time() - start_time
            single_throughput = file_size_mb / single_upload_time
            print(f"Single upload: {single_throughput:.2f} MB/s")
        except ClientError as e:
            print(f"Single upload failed: {e}")
            single_throughput = 0
        
        # Multipart upload test
        print("🔀 Testing multipart upload...")
        start_time = time.time()
        
        try:
            response = self.client.create_multipart_upload(
                Bucket=self.bucket_name,
                Key='multipart-upload-test.bin'
            )
            upload_id = response['UploadId']
            
            parts = []
            part_number = 1
            
            for i in range(0, len(test_data), part_size):
                part_data = test_data[i:i + part_size]
                
                response = self.client.upload_part(
                    Bucket=self.bucket_name,
                    Key='multipart-upload-test.bin',
                    PartNumber=part_number,
                    UploadId=upload_id,
                    Body=part_data
                )
                
                parts.append({
                    'ETag': response['ETag'],
                    'PartNumber': part_number
                })
                
                part_number += 1
            
            self.client.complete_multipart_upload(
                Bucket=self.bucket_name,
                Key='multipart-upload-test.bin',
                UploadId=upload_id,
                MultipartUpload={'Parts': parts}
            )
            
            multipart_time = time.time() - start_time
            multipart_throughput = file_size_mb / multipart_time
            print(f"Multipart upload: {multipart_throughput:.2f} MB/s")
            
        except ClientError as e:
            print(f"Multipart upload failed: {e}")
            multipart_throughput = 0
        
        return {
            'single_upload_mbps': single_throughput,
            'multipart_upload_mbps': multipart_throughput
        }

def main():
    """Run performance tests"""
    tester = PerformanceTester()
    tester.setup()
    
    print("🚀 Starting Performance Tests\n")
    
    # Test upload throughput with different file sizes and concurrency
    upload_results = tester.test_upload_throughput(
        file_sizes=[1, 5, 10],  # MB
        concurrency_levels=[1, 5, 10, 20]
    )
    
    # Test read performance
    read_results = tester.test_read_performance(num_objects=50)
    
    # Test multipart upload
    multipart_results = tester.test_multipart_performance()
    
    print("\n📊 Performance Summary:")
    print(f"Upload Results: {upload_results}")
    print(f"Read Results: {read_results}")
    print(f"Multipart Results: {multipart_results}")

if __name__ == "__main__":
    main()
```

## 🔧 Integration Examples

### Integration with Apache Spark

```python
# spark_minio_integration.py
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, TimestampType

def create_spark_session():
    """Create Spark session with MinIO configuration"""
    spark = SparkSession.builder \
        .appName("MinIO Integration") \
        .config("spark.hadoop.fs.s3a.endpoint", "http://localhost:9000") \
        .config("spark.hadoop.fs.s3a.access.key", "minioadmin") \
        .config("spark.hadoop.fs.s3a.secret.key", "minioadmin123") \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
        .config("spark.sql.adaptive.enabled", "true") \
        .config("spark.sql.adaptive.coalescePartitions.enabled", "true") \
        .getOrCreate()
    
    return spark

def test_spark_minio():
    """Test Spark with MinIO"""
    spark = create_spark_session()
    
    # Create sample data
    schema = StructType([
        StructField("id", IntegerType(), True),
        StructField("name", StringType(), True),
        StructField("age", IntegerType(), True),
        StructField("city", StringType(), True)
    ])
    
    data = [
        (1, "John Doe", 30, "New York"),
        (2, "Jane Smith", 25, "Los Angeles"),
        (3, "Bob Johnson", 35, "Chicago")
    ]
    
    df = spark.createDataFrame(data, schema)
    
    # Write to MinIO as Parquet
    df.write \
        .mode("overwrite") \
        .parquet("s3a://analytics-data/users/")
    
    print("✅ Data written to MinIO")
    
    # Read back from MinIO
    df_read = spark.read.parquet("s3a://analytics-data/users/")
    df_read.show()
    
    # Perform analytics query
    df_read.createOrReplaceTempView("users")
    result = spark.sql("SELECT city, COUNT(*) as user_count FROM users GROUP BY city")
    result.show()
    
    spark.stop()

if __name__ == "__main__":
    test_spark_minio()
```

## 📊 Assessment & Next Steps

### Knowledge Check
1. **Explain erasure coding** and its benefits over replication
2. **Deploy a multi-node MinIO cluster** with fault tolerance
3. **Optimize MinIO performance** for analytical workloads
4. **Integrate MinIO with Spark** for data processing

### Project Deliverables
- [ ] Single-node MinIO deployment with S3 API testing
- [ ] Multi-node cluster with load balancing and fault tolerance
- [ ] Performance benchmarking and optimization
- [ ] Integration examples with analytical frameworks

### Real-world Applications
**How MinIO fits in your data warehouse:**

1. **Data Lake Storage**: Petabyte-scale storage for raw data
2. **Backup & Archive**: Long-term retention with lifecycle policies
3. **Multi-Cloud**: S3-compatible interface for cloud portability
4. **Edge Computing**: Distributed storage for edge analytics

### Next Module Preview
**Module 4: Apache Iceberg Mastery** will cover:
- Table format internals and metadata management
- ACID transactions and snapshot isolation
- Schema evolution and time travel
- Integration with query engines

The object storage foundation you've built with MinIO will serve as the persistent layer for Iceberg tables, enabling advanced analytical capabilities with ACID guarantees.

---

**Module 3 Complete!** 🎉 You now have a robust, scalable object storage foundation that can handle petabyte-scale data with high availability and performance optimized for analytical workloads.
