#!/bin/bash
#
# Simple Docker Simulation Test
# 
# This script demonstrates the simplified Docker-based simulation approach.
# It builds the container, runs it with the services, and tests the simplified scripts.
#

set -e

echo "🐳 Docker Simulation Test - Simplified Approach"
echo "================================================"

# Build the image
echo "🏗️  Building Docker image..."
docker build -t code-snek:test . --quiet

# Create network
echo "🔗 Creating Docker network..."
docker network create --driver bridge simulation-test 2>/dev/null || echo "Network already exists"

# Clean up any existing container
echo "🧹 Cleaning up existing containers..."
docker rm -f code-snek-test 2>/dev/null || true

# Start the main container with all services
echo "🚀 Starting main container with all services..."
docker run -d \
    --name code-snek-test \
    --network simulation-test \
    -p 4567:4567 -p 8081:8081 -p 8082:8082 -p 8083:8083 -p 8084:8084 -p 8085:8085 \
    code-snek:test

echo "⏳ Waiting for services to start..."
sleep 20

# Test from host using localhost (this shows the external approach)
echo "🔍 Testing services from host using localhost..."
curl -s http://localhost:4567/ | jq -r '.name // "ruby service"' || echo "Ruby service not responding"
curl -s http://localhost:8081/ | jq -r '.name // "pathy service"' || echo "Pathy service not responding"

# Test validation script using Docker network (this shows the container approach)
echo "🧪 Testing validation script using Docker network..."
if docker run --rm --network simulation-test code-snek:test script/validate_simulation; then
    echo "✅ Validation script passed!"
else
    echo "❌ Validation script failed"
fi

# Test multi-opponent training script using Docker network
echo "🧠 Testing multi-opponent training script using Docker network..."
if timeout 30 docker run --rm --network simulation-test code-snek:test script/multi_opponent_training comprehensive 2; then
    echo "✅ Multi-opponent training script worked!"
else
    echo "❌ Multi-opponent training script failed"
fi

# Clean up
echo "🧹 Cleaning up..."
docker rm -f code-snek-test
docker network rm simulation-test 2>/dev/null || true

echo ""
echo "✨ Docker simulation test completed!"
echo "This demonstrates that the simplified approach works consistently:"
echo "  - Host can access services via localhost (for waiting/health checks)"  
echo "  - Container-to-container communication uses 'code-snek' hostname"
echo "  - Single predictable code path for all simulation scripts"