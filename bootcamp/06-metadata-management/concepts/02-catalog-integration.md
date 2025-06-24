# Catalog Integration Patterns

## Introduction
Data catalogs serve as centralized repositories for metadata, providing data discovery, lineage tracking, and governance capabilities. This document covers integration patterns for various catalog systems and best practices for implementation.

## Data Catalog Fundamentals

### Core Components

#### 1. Metadata Repository
- **Schema Metadata**: Table structures, column definitions, data types
- **Operational Metadata**: Data lineage, processing history, quality metrics
- **Business Metadata**: Descriptions, tags, business glossary terms
- **Technical Metadata**: Storage locations, partitioning schemes, formats

#### 2. Data Discovery Engine
- **Search Capabilities**: Full-text search across metadata
- **Faceted Navigation**: Filter by data source, owner, tags
- **Recommendation Engine**: Suggest related datasets
- **Usage Analytics**: Track data asset popularity

#### 3. Lineage Tracking
- **Column-Level Lineage**: Track data transformations at column level
- **Impact Analysis**: Understand downstream effects of changes
- **Data Flow Visualization**: Graphical representation of data movement
- **Dependency Management**: Identify critical data dependencies

## Apache Atlas Integration

### Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Data Sources  │    │   Atlas Core    │    │   Atlas UI      │
│   - Hive        │────▶│   - Type System │◀───│   - Search      │
│   - Kafka       │    │   - Graph DB    │    │   - Lineage     │
│   - HBase       │    │   - REST API    │    │   - Governance  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
          │                       │                       │
          └───────────────────────┼───────────────────────┘
                                  │
                    ┌─────────────▼─────────────┐
                    │   Apache Kafka          │
                    │   (Atlas Hook Events)    │
                    └───────────────────────────┘
```

### Atlas Configuration

#### Basic Configuration (atlas-application.properties)
```properties
# Graph database configuration
atlas.graph.storage.backend=berkeleyje
atlas.graph.storage.directory=/opt/atlas/data/berkeley

# Kafka configuration for notifications
atlas.kafka.bootstrap.servers=localhost:9092
atlas.kafka.zookeeper.connect=localhost:2181

# Authentication
atlas.authentication.method=simple
atlas.authentication.simple.username=admin
atlas.authentication.simple.password=admin

# Authorization
atlas.authorization.method=simple
```

#### Advanced Configuration
```properties
# High availability setup
atlas.graph.cluster.backend=hbase2
atlas.graph.cluster.hostname=hbase-cluster

# Index backend for search
atlas.graph.index.search.backend=elasticsearch
atlas.graph.index.search.hostname=elasticsearch-cluster:9200

# Notification settings
atlas.notification.embedded=false
atlas.kafka.data=${sys:atlas.log.dir}/kafka-data
```

### Atlas Type System

#### Custom Type Definition
```json
{
  "entityDefs": [
    {
      "name": "DataPipeline",
      "superTypes": ["Process"],
      "attributeDefs": [
        {
          "name": "pipelineType",
          "typeName": "string",
          "isOptional": false,
          "cardinality": "SINGLE"
        },
        {
          "name": "scheduleCron",
          "typeName": "string",
          "isOptional": true,
          "cardinality": "SINGLE"
        },
        {
          "name": "owner",
          "typeName": "string",
          "isOptional": false,
          "cardinality": "SINGLE"
        }
      ]
    }
  ]
}
```

#### Relationship Definitions
```json
{
  "relationshipDefs": [
    {
      "name": "pipeline_dataset",
      "typeVersion": "1.0",
      "relationshipCategory": "ASSOCIATION",
      "endDef1": {
        "type": "DataPipeline",
        "name": "inputDatasets",
        "isContainer": false,
        "cardinality": "SET"
      },
      "endDef2": {
        "type": "DataSet",
        "name": "pipelines",
        "isContainer": false,
        "cardinality": "SET"
      }
    }
  ]
}
```

### Atlas Hook Integration

#### Hive Hook Configuration
```xml
<!-- hive-site.xml -->
<property>
  <name>hive.exec.post.hooks</name>
  <value>org.apache.atlas.hive.hook.HiveHook</value>
</property>

<property>
  <name>atlas.cluster.name</name>
  <value>production</value>
</property>

<property>
  <name>atlas.kafka.bootstrap.servers</name>
  <value>kafka1:9092,kafka2:9092,kafka3:9092</value>
</property>
```

#### Spark Hook Integration
```scala
import org.apache.atlas.spark.hook.SparkAtlasHook

val spark = SparkSession.builder()
  .appName("AtlasIntegration")
  .config("spark.sql.queryExecutionListeners", 
          "org.apache.atlas.spark.hook.SparkAtlasHook")
  .config("spark.sql.streaming.streamingQueryListeners",
          "org.apache.atlas.spark.hook.SparkAtlasStreamingHook")
  .getOrCreate()
```

### Programmatic Atlas Integration

#### Atlas Client Example (Java)
```java
import org.apache.atlas.AtlasClientV2;
import org.apache.atlas.model.instance.AtlasEntity;

public class AtlasIntegration {
    private AtlasClientV2 atlasClient;
    
    public void initialize() {
        this.atlasClient = new AtlasClientV2(
            new String[]{"http://atlas-server:21000"}, 
            new String[]{"admin", "admin"}
        );
    }
    
    public void createDataset(String name, String location, String owner) {
        AtlasEntity entity = new AtlasEntity("DataSet");
        entity.setAttribute("name", name);
        entity.setAttribute("location", location);
        entity.setAttribute("owner", owner);
        entity.setAttribute("createTime", System.currentTimeMillis());
        
        try {
            atlasClient.createEntity(entity);
        } catch (AtlasServiceException e) {
            // Handle exception
        }
    }
}
```

#### Python Atlas Client
```python
from apache_atlas.client.atlas import Atlas
from apache_atlas.model.entities import AtlasEntity

class AtlasManager:
    def __init__(self, host, username, password):
        self.atlas = Atlas(host, username=username, password=password)
    
    def create_table_entity(self, database, table, columns):
        # Create database entity
        db_entity = AtlasEntity(
            typeName="hive_db",
            attributes={
                "name": database,
                "clusterName": "production",
                "qualifiedName": f"{database}@production"
            }
        )
        
        # Create table entity
        table_entity = AtlasEntity(
            typeName="hive_table",
            attributes={
                "name": table,
                "db": db_entity,
                "qualifiedName": f"{database}.{table}@production"
            }
        )
        
        # Create column entities
        column_entities = []
        for col_name, col_type in columns.items():
            col_entity = AtlasEntity(
                typeName="hive_column",
                attributes={
                    "name": col_name,
                    "type": col_type,
                    "table": table_entity,
                    "qualifiedName": f"{database}.{table}.{col_name}@production"
                }
            )
            column_entities.append(col_entity)
        
        # Submit entities
        entities = [db_entity, table_entity] + column_entities
        self.atlas.entity_bulk.create(entities={"entities": entities})
```

## Unity Catalog Integration

### Architecture Overview
Unity Catalog provides a unified governance solution for data and AI assets across multiple workspaces and clouds.

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Workspace A   │    │   Unity Catalog │    │   Workspace B   │
│   - Tables      │────▶│   - Metastore   │◀───│   - Models      │
│   - Models      │    │   - Permissions │    │   - Tables      │
│   - Volumes     │    │   - Lineage     │    │   - Volumes     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                               │
                    ┌─────────────────────┐
                    │   External Systems  │
                    │   - Delta Sharing   │
                    │   - Cloud Storage   │
                    └─────────────────────┘
```

### Unity Catalog Configuration

#### Metastore Setup
```sql
-- Create metastore
CREATE METASTORE my_metastore
STORAGE 's3://my-bucket/unity-catalog'
REGION 'us-west-2';

-- Create catalog
CREATE CATALOG sales_data
COMMENT 'Sales and customer data catalog';

-- Create schema
CREATE SCHEMA sales_data.customer_data
COMMENT 'Customer information and analytics';
```

#### Permission Management
```sql
-- Grant catalog permissions
GRANT USE CATALOG, CREATE SCHEMA ON CATALOG sales_data TO `data-engineers`;

-- Grant schema permissions
GRANT USE SCHEMA, CREATE TABLE ON SCHEMA sales_data.customer_data TO `analysts`;

-- Grant table permissions
GRANT SELECT, MODIFY ON TABLE sales_data.customer_data.customers TO `marketing-team`;
```

### Unity Catalog API Integration

#### Python SDK Example
```python
from databricks.sdk import WorkspaceClient
from databricks.sdk.service.catalog import *

class UnityCatalogManager:
    def __init__(self):
        self.client = WorkspaceClient()
    
    def create_external_location(self, name, url, credential_name):
        return self.client.external_locations.create(
            name=name,
            url=url,
            credential_name=credential_name,
            comment="External data location"
        )
    
    def register_external_table(self, catalog, schema, table_name, location):
        return self.client.tables.create(
            catalog_name=catalog,
            schema_name=schema,
            name=table_name,
            table_type=TableType.EXTERNAL,
            data_source_format=DataSourceFormat.DELTA,
            storage_location=location
        )
    
    def get_table_lineage(self, table_name):
        return self.client.catalog.get_lineage(
            table_name=table_name,
            include_entity_lineage=True
        )
```

## Cross-Platform Catalog Synchronization

### Synchronization Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Source System │    │   Sync Engine   │    │   Target System │
│   - Atlas       │────▶│   - ETL Jobs    │────▶│   - Unity Cat.  │
│   - HMS         │    │   - Mapping     │    │   - Purview     │
│   - Custom      │    │   - Validation  │    │   - Custom      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Metadata Synchronization Framework

#### Configuration-Driven Sync
```yaml
# sync-config.yaml
synchronization:
  source:
    type: "atlas"
    connection:
      url: "http://atlas:21000"
      username: "admin"
      password: "admin"
    
  target:
    type: "unity_catalog"
    connection:
      workspace_url: "https://workspace.cloud.databricks.com"
      token: "${DATABRICKS_TOKEN}"
    
  mappings:
    - source_type: "hive_table"
      target_type: "table"
      attribute_mappings:
        name: "name"
        owner: "owner"
        location: "storage_location"
        schema: "schema_name"
    
  filters:
    - include_databases: ["sales", "marketing", "finance"]
    - exclude_tables: ["temp_*", "staging_*"]
    
  schedule:
    interval: "1h"
    retry_attempts: 3
```

#### Sync Engine Implementation
```python
import asyncio
from typing import Dict, List, Any
from dataclasses import dataclass

@dataclass
class MetadataEntity:
    entity_type: str
    name: str
    attributes: Dict[str, Any]
    relationships: List[Dict[str, Any]]

class MetadataSyncEngine:
    def __init__(self, config: Dict):
        self.config = config
        self.source_client = self._create_source_client()
        self.target_client = self._create_target_client()
    
    async def sync_metadata(self):
        """Main synchronization workflow"""
        try:
            # Extract metadata from source
            source_entities = await self._extract_source_metadata()
            
            # Transform entities based on mappings
            transformed_entities = self._transform_entities(source_entities)
            
            # Validate entities
            validated_entities = self._validate_entities(transformed_entities)
            
            # Load to target system
            await self._load_target_metadata(validated_entities)
            
            # Generate sync report
            self._generate_sync_report()
            
        except Exception as e:
            self._handle_sync_error(e)
    
    def _transform_entities(self, entities: List[MetadataEntity]) -> List[MetadataEntity]:
        """Transform entities based on mapping configuration"""
        transformed = []
        mappings = self.config['mappings']
        
        for entity in entities:
            for mapping in mappings:
                if entity.entity_type == mapping['source_type']:
                    new_entity = MetadataEntity(
                        entity_type=mapping['target_type'],
                        name=entity.name,
                        attributes=self._map_attributes(entity.attributes, mapping['attribute_mappings']),
                        relationships=entity.relationships
                    )
                    transformed.append(new_entity)
        
        return transformed
    
    def _map_attributes(self, source_attrs: Dict, mappings: Dict) -> Dict:
        """Map attributes from source to target format"""
        mapped_attrs = {}
        for source_key, target_key in mappings.items():
            if source_key in source_attrs:
                mapped_attrs[target_key] = source_attrs[source_key]
        return mapped_attrs
```

## Data Lineage Implementation

### Lineage Data Model

```python
from dataclasses import dataclass
from typing import List, Optional, Dict
from enum import Enum

class LineageDirection(Enum):
    UPSTREAM = "UPSTREAM"
    DOWNSTREAM = "DOWNSTREAM"
    BOTH = "BOTH"

@dataclass
class DataAsset:
    qualified_name: str
    asset_type: str
    properties: Dict[str, Any]

@dataclass
class LineageEdge:
    from_asset: DataAsset
    to_asset: DataAsset
    process_name: str
    transformation_logic: Optional[str]
    created_at: str

@dataclass
class LineageGraph:
    assets: List[DataAsset]
    edges: List[LineageEdge]
    
    def get_upstream_lineage(self, asset_name: str, depth: int = 3) -> 'LineageGraph':
        """Get upstream lineage for a given asset"""
        pass
    
    def get_downstream_lineage(self, asset_name: str, depth: int = 3) -> 'LineageGraph':
        """Get downstream lineage for a given asset"""
        pass
```

### Lineage Collection Strategies

#### 1. Hook-Based Collection
```python
class SparkLineageCollector:
    def __init__(self, catalog_client):
        self.catalog_client = catalog_client
    
    def on_sql_execution(self, sql_context):
        """Collect lineage during SQL execution"""
        input_tables = self._extract_input_tables(sql_context.logical_plan)
        output_tables = self._extract_output_tables(sql_context.logical_plan)
        
        for output_table in output_tables:
            for input_table in input_tables:
                lineage_edge = LineageEdge(
                    from_asset=input_table,
                    to_asset=output_table,
                    process_name=sql_context.app_name,
                    transformation_logic=sql_context.sql,
                    created_at=datetime.now().isoformat()
                )
                self.catalog_client.record_lineage(lineage_edge)
```

#### 2. Log-Based Collection
```python
class LogBasedLineageCollector:
    def __init__(self, log_parser, catalog_client):
        self.log_parser = log_parser
        self.catalog_client = catalog_client
    
    def process_query_logs(self, log_file_path: str):
        """Process query logs to extract lineage"""
        queries = self.log_parser.parse_log_file(log_file_path)
        
        for query in queries:
            lineage_info = self._extract_lineage_from_query(query)
            if lineage_info:
                self.catalog_client.record_lineage(lineage_info)
    
    def _extract_lineage_from_query(self, query: Dict) -> Optional[LineageEdge]:
        """Extract lineage information from query"""
        # Implementation depends on query format and database type
        pass
```

## Governance Integration Patterns

### Data Classification

#### Automated Classification
```python
class DataClassifier:
    def __init__(self, classification_rules):
        self.rules = classification_rules
    
    def classify_table(self, table_metadata: Dict) -> List[str]:
        """Classify table based on content and metadata"""
        classifications = []
        
        # Column-based classification
        for column in table_metadata.get('columns', []):
            if self._is_pii_column(column):
                classifications.append('PII')
            if self._is_financial_column(column):
                classifications.append('Financial')
        
        # Content-based classification
        sample_data = self._get_sample_data(table_metadata['location'])
        content_classifications = self._classify_content(sample_data)
        classifications.extend(content_classifications)
        
        return list(set(classifications))
    
    def _is_pii_column(self, column: Dict) -> bool:
        """Check if column contains PII data"""
        pii_patterns = ['email', 'phone', 'ssn', 'credit_card']
        column_name = column['name'].lower()
        return any(pattern in column_name for pattern in pii_patterns)
```

### Policy Enforcement

#### Tag-Based Access Control
```python
class TagBasedAccessControl:
    def __init__(self, policy_engine):
        self.policy_engine = policy_engine
    
    def evaluate_access(self, user: str, resource: str, action: str) -> bool:
        """Evaluate access based on tags and policies"""
        resource_tags = self._get_resource_tags(resource)
        user_attributes = self._get_user_attributes(user)
        
        policy_result = self.policy_engine.evaluate({
            'user': user_attributes,
            'resource': {'name': resource, 'tags': resource_tags},
            'action': action
        })
        
        return policy_result.allowed
    
    def _get_resource_tags(self, resource: str) -> List[str]:
        """Get tags associated with a resource"""
        # Query catalog for resource tags
        pass
```

## Monitoring and Observability

### Catalog Health Monitoring

```python
class CatalogMonitor:
    def __init__(self, catalog_client, metrics_client):
        self.catalog_client = catalog_client
        self.metrics_client = metrics_client
    
    def collect_health_metrics(self):
        """Collect catalog health metrics"""
        metrics = {
            'total_tables': self._count_tables(),
            'tables_with_lineage': self._count_tables_with_lineage(),
            'tables_with_descriptions': self._count_tables_with_descriptions(),
            'orphaned_tables': self._count_orphaned_tables(),
            'stale_metadata_percentage': self._calculate_stale_metadata_percentage()
        }
        
        for metric_name, value in metrics.items():
            self.metrics_client.gauge(f'catalog.{metric_name}', value)
    
    def validate_metadata_quality(self):
        """Validate metadata quality and generate reports"""
        quality_issues = []
        
        # Check for missing descriptions
        tables_without_descriptions = self._find_tables_without_descriptions()
        if tables_without_descriptions:
            quality_issues.append({
                'type': 'missing_description',
                'count': len(tables_without_descriptions),
                'tables': tables_without_descriptions
            })
        
        # Check for inconsistent naming
        naming_violations = self._find_naming_violations()
        if naming_violations:
            quality_issues.append({
                'type': 'naming_violation',
                'count': len(naming_violations),
                'violations': naming_violations
            })
        
        return quality_issues
```

## Best Practices

### 1. Metadata Quality
- **Completeness**: Ensure all datasets have descriptions and ownership information
- **Accuracy**: Implement validation rules for metadata consistency
- **Timeliness**: Keep metadata synchronized with actual data changes
- **Standardization**: Use consistent naming conventions and tagging strategies

### 2. Integration Architecture
- **Event-Driven**: Use event-driven architecture for real-time metadata updates
- **Idempotent Operations**: Ensure sync operations can be safely retried
- **Conflict Resolution**: Implement strategies for handling metadata conflicts
- **Rollback Capability**: Maintain ability to rollback failed synchronizations

### 3. Performance Optimization
- **Incremental Sync**: Only sync changed metadata to reduce processing time
- **Parallel Processing**: Use parallel processing for large-scale synchronizations
- **Caching**: Implement caching strategies for frequently accessed metadata
- **Batch Operations**: Use batch operations for bulk metadata updates

### 4. Security and Governance
- **Access Control**: Implement fine-grained access control for metadata
- **Audit Logging**: Maintain comprehensive audit logs for all metadata operations
- **Data Classification**: Implement automated data classification and tagging
- **Policy Enforcement**: Integrate with policy engines for automated governance