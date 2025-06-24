# Module 02: Container Orchestration

*Duration: 8 hours | Difficulty: Intermediate*

## Learning Objectives

By the end of this module, you will be able to:
- Understand Docker fundamentals and create optimized multi-stage builds
- Deploy and manage Kubernetes clusters for data infrastructure
- Use Helm charts to package and deploy complex applications
- Implement service mesh patterns with Istio for microservices communication
- Deploy and scale a MinIO cluster on Kubernetes

## Prerequisites

- Basic understanding of containerization concepts
- Familiarity with YAML syntax
- Module 00 (Development Environment Setup) completed
- kubectl and Docker installed

## Module Structure

### Part 1: Docker Fundamentals (2 hours)
- Container architecture and lifecycle
- Dockerfile best practices and optimization
- Multi-stage builds for production workloads
- Container security and hardening

### Part 2: Kubernetes Architecture (2.5 hours)
- Kubernetes core concepts and architecture
- Pods, Services, Deployments, and StatefulSets
- Resource management and scheduling
- Persistent volumes and storage classes

### Part 3: Helm Package Management (1.5 hours)
- Helm architecture and chart structure
- Creating and customizing charts
- Values files and templating
- Dependency management

### Part 4: Service Mesh with Istio (2 hours)
- Service mesh concepts and benefits
- Istio installation and configuration
- Traffic management and security policies
- Observability and monitoring

## Part 1: Docker Fundamentals

### Container Architecture

Containers provide process-level isolation while sharing the host OS kernel. Understanding the container lifecycle is crucial for building efficient data infrastructure.

```dockerfile
# Multi-stage build example for MinIO
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o minio-client

FROM alpine:3.18
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/minio-client .
CMD ["./minio-client"]
```

### Dockerfile Best Practices

1. **Use specific base image tags** - Avoid `latest` tag
2. **Minimize layers** - Combine RUN commands
3. **Use .dockerignore** - Exclude unnecessary files
4. **Run as non-root user** - Security best practice
5. **Multi-stage builds** - Reduce final image size

### Container Security

```dockerfile
# Security-hardened container
FROM alpine:3.18
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup
USER appuser
WORKDIR /app
COPY --chown=appuser:appgroup . .
CMD ["./app"]
```

## Part 2: Kubernetes Architecture

### Core Components

**Master Node Components:**
- **kube-apiserver** - API gateway for all operations
- **etcd** - Distributed key-value store
- **kube-scheduler** - Pod placement decisions
- **kube-controller-manager** - Manages controllers

**Worker Node Components:**
- **kubelet** - Node agent
- **kube-proxy** - Network proxy
- **Container runtime** - Docker/containerd

### Resource Management

```yaml
# Resource quotas for data workloads
apiVersion: v1
kind: ResourceQuota
metadata:
  name: data-processing-quota
spec:
  hard:
    requests.cpu: "100"
    requests.memory: "200Gi"
    limits.cpu: "200"
    limits.memory: "400Gi"
    persistentvolumeclaims: "10"
```

### Persistent Storage

```yaml
# Storage class for high-performance data workloads
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
allowVolumeExpansion: true
```

## Part 3: Helm Package Management

### Chart Structure

```
minio-chart/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── statefulset.yaml
│   └── _helpers.tpl
└── charts/
```

### Helm Templates

```yaml
# templates/statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ include "minio.fullname" . }}
spec:
  serviceName: {{ include "minio.fullname" . }}-headless
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "minio.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "minio.selectorLabels" . | nindent 8 }}
    spec:
      containers:
      - name: minio
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        resources:
          {{- toYaml .Values.resources | nindent 12 }}
```

### Values Configuration

```yaml
# values.yaml
replicaCount: 4
image:
  repository: minio/minio
  tag: RELEASE.2024-01-16T16-07-38Z
  pullPolicy: IfNotPresent

resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 1000m
    memory: 2Gi

persistence:
  enabled: true
  size: 100Gi
  storageClass: fast-ssd
```

## Part 4: Service Mesh with Istio

### Istio Architecture

Istio provides a service mesh layer that handles:
- **Traffic management** - Load balancing, routing, failover
- **Security** - Mutual TLS, access control
- **Observability** - Metrics, logs, traces

### Installation

```bash
# Install Istio
curl -L https://istio.io/downloadIstio | sh -
istioctl install --set values.defaultRevision=default
kubectl label namespace default istio-injection=enabled
```

### Traffic Management

```yaml
# Virtual service for MinIO
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: minio-vs
spec:
  hosts:
  - minio.data.local
  gateways:
  - minio-gateway
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: minio-service
        port:
          number: 9000
```

## Labs and Exercises

### Lab 1: Docker Multi-stage Build
Create an optimized Docker image for a data processing application.

**Files:** `labs/docker/Dockerfile`, `labs/docker/build.sh`

### Lab 2: MinIO on Kubernetes
Deploy a highly available MinIO cluster using StatefulSets.

**Files:** `labs/kubernetes/minio-statefulset.yaml`, `labs/kubernetes/minio-service.yaml`

### Lab 3: Helm Chart Development
Create a comprehensive Helm chart for MinIO deployment.

**Files:** `labs/helm/minio-chart/`

### Lab 4: Istio Service Mesh
Implement traffic management and security policies.

**Files:** `labs/istio/gateway.yaml`, `labs/istio/virtualservice.yaml`

## Assessment

### Hands-on Tasks
1. Build and optimize a multi-stage Docker image (Score: /25)
2. Deploy MinIO cluster with persistent storage (Score: /25)
3. Create and deploy custom Helm chart (Score: /25)
4. Configure Istio traffic management (Score: /25)

### Knowledge Check
- Container security best practices
- Kubernetes resource management
- Helm templating and values
- Service mesh benefits and use cases

## Next Steps

- **Module 03**: Object Storage Deep Dive (MinIO)
- **Module 05**: Columnar Storage
- **Module 06**: Metadata Management

## Additional Resources

- [Kubernetes Official Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Istio Documentation](https://istio.io/latest/docs/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## Troubleshooting

### Common Issues
1. **Pod pending state** - Check resource quotas and node capacity
2. **ImagePullBackOff** - Verify image name and registry access
3. **PVC binding issues** - Check storage class and provisioner
4. **Istio injection not working** - Verify namespace labels

### Debug Commands
```bash
# Pod troubleshooting
kubectl describe pod <pod-name>
kubectl logs <pod-name> -c <container-name>

# Storage troubleshooting
kubectl get pv,pvc
kubectl describe pvc <pvc-name>

# Istio troubleshooting
istioctl proxy-status
istioctl analyze
```