# Development Environment Setup

This guide walks through setting up your development environment for the BigQuery-equivalent data warehouse bootcamp.

## 🖥 System Requirements

### Minimum Hardware
- **CPU**: 4+ cores (Intel i5/AMD Ryzen 5 or better)
- **RAM**: 16GB (32GB recommended for full stack)
- **Storage**: 100GB free space (SSD recommended)
- **Network**: Stable internet connection

### Recommended Hardware
- **CPU**: 8+ cores (Intel i7/AMD Ryzen 7 or better)
- **RAM**: 32GB+ for smooth multi-service operation
- **Storage**: 500GB+ SSD for containers and data
- **Network**: High-speed internet for container pulls

## 🐳 Core Development Tools

### 1. Docker Desktop
```bash
# macOS (using Homebrew)
brew install --cask docker

# Verify installation
docker --version
docker-compose --version
```

**Docker Configuration:**
- Allocate at least 8GB RAM to Docker
- Enable Kubernetes (optional for later modules)
- Configure resource limits appropriately

### 2. Container Registry Access
```bash
# Login to Docker Hub (or your preferred registry)
docker login

# Test container pull
docker pull hello-world
docker run hello-world
```

### 3. Kubernetes (kubectl)
```bash
# macOS
brew install kubectl

# Verify installation
kubectl version --client
```

### 4. Development IDE
**Recommended: VS Code with Extensions**
```bash
# Install VS Code
brew install --cask visual-studio-code

# Useful extensions (install via VS Code marketplace):
# - Docker
# - Kubernetes
# - YAML
# - SQL Tools
# - Python
# - Java Extension Pack
```

## 🔧 Programming Languages

### Python 3.8+
```bash
# macOS (using Homebrew)
brew install python@3.11

# Verify installation
python3 --version
pip3 --version

# Create virtual environment for bootcamp
python3 -m venv bootcamp-env
source bootcamp-env/bin/activate
```

**Essential Python Packages:**
```bash
pip install \
  pandas \
  pyarrow \
  sqlalchemy \
  psycopg2-binary \
  kafka-python \
  pyspark \
  jupyter \
  notebook \
  requests \
  boto3
```

### Java 11+ (for Spark, Trino, Kafka)
```bash
# macOS
brew install openjdk@11

# Add to PATH (add to ~/.zshrc)
export PATH="/usr/local/opt/openjdk@11/bin:$PATH"
export JAVA_HOME="/usr/local/opt/openjdk@11"

# Verify installation
java -version
javac -version
```

### Scala (Optional for Spark development)
```bash
# macOS
brew install scala

# Verify installation
scala -version
```

## 📊 Database Tools

### SQL Client (DBeaver)
```bash
# macOS
brew install --cask dbeaver-community

# Alternative: Command-line tools
brew install postgresql  # for psql client
```

### MinIO Client (mc)
```bash
# macOS
brew install minio/stable/mc

# Verify installation
mc --version
```

## 🛠 Infrastructure Tools

### Terraform (for advanced modules)
```bash
# macOS
brew install terraform

# Verify installation
terraform version
```

### Helm (for Kubernetes deployments)
```bash
# macOS
brew install helm

# Verify installation
helm version
```

## 🐍 Project Structure Setup

Create the bootcamp project directory:
```bash
# Navigate to your projects directory
cd ~/Documents/projects/bigquery-uth/bootcamp

# Create module directories
mkdir -p {00-setup,01-distributed-systems,02-container-orchestration,03-object-storage}
mkdir -p {04-apache-iceberg,05-columnar-storage,06-metadata-management}
mkdir -p {07-trino-engine,08-sql-optimization,09-kafka-fundamentals}
mkdir -p {10-flink-streaming,11-change-data-capture,12-spark-processing}
mkdir -p {13-workflow-orchestration,14-monitoring-observability}
mkdir -p {15-performance-tuning,16-security-governance}

# Create shared resources directory
mkdir -p shared/{docker-compose,kubernetes,datasets,scripts}
```

## 🚀 Quick Validation Test

Run this comprehensive test to validate your setup:

```bash
# Create validation script
cat > validate-setup.sh << 'EOF'
#!/bin/bash

echo "🔍 Validating Development Environment Setup..."

# Test Docker
echo "Testing Docker..."
docker run --rm hello-world > /dev/null 2>&1 && \
  echo "✅ Docker: Working" || echo "❌ Docker: Failed"

# Test Docker Compose
echo "Testing Docker Compose..."
docker-compose --version > /dev/null 2>&1 && \
  echo "✅ Docker Compose: Working" || echo "❌ Docker Compose: Failed"

# Test Python
echo "Testing Python..."
python3 -c "import pandas, pyarrow; print('✅ Python with required packages: Working')" 2>/dev/null || \
  echo "❌ Python packages: Missing dependencies"

# Test Java
echo "Testing Java..."
java -version > /dev/null 2>&1 && \
  echo "✅ Java: Working" || echo "❌ Java: Failed"

# Test kubectl
echo "Testing kubectl..."
kubectl version --client > /dev/null 2>&1 && \
  echo "✅ kubectl: Working" || echo "❌ kubectl: Failed"

# Test MinIO client
echo "Testing MinIO client..."
mc --version > /dev/null 2>&1 && \
  echo "✅ MinIO client: Working" || echo "❌ MinIO client: Failed"

echo "🎉 Environment validation complete!"
EOF

chmod +x validate-setup.sh
./validate-setup.sh
```

## 📁 Sample Data Setup

Download sample datasets for the bootcamp:
```bash
# Create datasets directory
mkdir -p shared/datasets

# Download sample data (we'll use NYC Taxi dataset)
cd shared/datasets

# Small sample for initial testing
curl -o nyc_taxi_sample.parquet \
  "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2023-01.parquet"

# Create sample JSON data
cat > sample_events.json << 'EOF'
{"timestamp": "2023-01-01T00:00:00Z", "user_id": 1, "event": "login", "properties": {"platform": "web"}}
{"timestamp": "2023-01-01T00:01:00Z", "user_id": 1, "event": "page_view", "properties": {"page": "/dashboard"}}
{"timestamp": "2023-01-01T00:02:00Z", "user_id": 2, "event": "login", "properties": {"platform": "mobile"}}
EOF

echo "✅ Sample datasets ready"
```

## 🐳 Base Docker Compose Setup

Create a base docker-compose file for shared services:
```bash
# Create base docker-compose for common services
cat > shared/docker-compose/base-services.yml << 'EOF'
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
      - lakehouse

  # MinIO Object Storage
  minio:
    image: minio/minio:latest
    command: server /data --console-address ":9090"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin123
    ports:
      - "9000:9000"  # API
      - "9090:9090"  # Console
    volumes:
      - minio_data:/data
    networks:
      - lakehouse

  # Hive Metastore
  metastore:
    image: apache/hive:3.1.3
    depends_on:
      - postgres
    environment:
      DB_DRIVER: postgres
      SERVICE_NAME: metastore
      SERVICE_OPTS: "-Djavax.jdo.option.ConnectionDriverName=org.postgresql.Driver
                     -Djavax.jdo.option.ConnectionURL=jdbc:postgresql://postgres:5432/metastore
                     -Djavax.jdo.option.ConnectionUserName=hive
                     -Djavax.jdo.option.ConnectionPassword=hive123"
    ports:
      - "9083:9083"
    networks:
      - lakehouse

volumes:
  postgres_data:
  minio_data:

networks:
  lakehouse:
    driver: bridge
EOF

echo "✅ Base Docker Compose configuration ready"
```

## 📚 IDE Configuration

### VS Code Settings
Create workspace settings for the bootcamp:
```bash
mkdir -p .vscode

cat > .vscode/settings.json << 'EOF'
{
    "python.defaultInterpreterPath": "./bootcamp-env/bin/python",
    "python.formatting.provider": "black",
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "files.associations": {
        "*.sql": "sql",
        "*.hql": "sql",
        "*.yaml": "yaml",
        "*.yml": "yaml"
    },
    "docker.enableDockerComposeLanguageService": true,
    "kubernetes.vs-code-api-version": "v1"
}
EOF

cat > .vscode/extensions.json << 'EOF'
{
    "recommendations": [
        "ms-python.python",
        "ms-vscode.vscode-docker",
        "ms-kubernetes-tools.vscode-kubernetes-tools",
        "redhat.vscode-yaml",
        "mtxr.sqltools",
        "ms-vscode.vscode-json"
    ]
}
EOF
```

## ✅ Verification Checklist

Before proceeding to Module 1, ensure you have:

- [ ] Docker Desktop installed and running
- [ ] Python 3.8+ with required packages installed
- [ ] Java 11+ installed and configured
- [ ] kubectl installed for Kubernetes interaction
- [ ] MinIO client (mc) installed
- [ ] VS Code with recommended extensions
- [ ] Base docker-compose services can start successfully
- [ ] Sample datasets downloaded and accessible
- [ ] Virtual environment activated

## 🆘 Troubleshooting

### Common Issues

**Docker Desktop not starting:**
- Ensure virtualization is enabled in BIOS
- Check Docker Desktop resource allocation
- Restart Docker Desktop service

**Python package installation errors:**
- Ensure virtual environment is activated
- Update pip: `pip install --upgrade pip`
- Install packages individually if bulk install fails

**Java not found:**
- Verify JAVA_HOME environment variable
- Check PATH includes Java bin directory
- Restart terminal after setting environment variables

**Port conflicts:**
- Check if ports 5432, 9000, 9083 are already in use
- Modify docker-compose port mappings if needed
- Use `lsof -i :PORT` to identify conflicting processes

## 🎯 Next Steps

Once your environment is set up:
1. Test the base services: `cd shared/docker-compose && docker-compose up -f base-services.yml`
2. Verify MinIO console access: http://localhost:9090
3. Proceed to [Module 1: Distributed Systems Fundamentals](../01-distributed-systems/README.md)

---

**Environment Ready!** 🚀 You're now prepared to begin the BigQuery-equivalent data warehouse bootcamp journey.
