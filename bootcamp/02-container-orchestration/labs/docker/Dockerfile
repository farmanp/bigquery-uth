# Multi-stage Dockerfile for Data Processing Application
# This demonstrates best practices for containerizing data workloads

# Stage 1: Build environment
FROM golang:1.21-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git ca-certificates

# Set working directory
WORKDIR /app

# Copy dependency files first (better caching)
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application with optimizations
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o data-processor ./cmd/processor

# Stage 2: Runtime environment
FROM alpine:3.18

# Install runtime dependencies
RUN apk --no-cache add ca-certificates tzdata

# Create non-root user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /app/data-processor .

# Copy configuration files
COPY --chown=appuser:appgroup configs/ ./configs/

# Change ownership of application directory
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ./data-processor health || exit 1

# Run the application
CMD ["./data-processor", "serve"]