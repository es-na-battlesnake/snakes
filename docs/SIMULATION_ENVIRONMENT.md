# Simulation Environment Research and Simplification

## Current Setup Analysis

### Current Complexity
The simulation environment currently requires:
1. Docker image build (can fail due to SSL/network issues)
2. Docker network creation
3. Multiple containers running simultaneously
4. Container orchestration (starting, stopping, cleanup)
5. Inter-container communication via Docker network

**Complexity Score**: High
- Multiple moving parts
- Network configuration knowledge required
- Docker expertise needed
- Difficult to debug failures

### Current Architecture
```
┌─────────────────────────────────────────┐
│  Host Machine                           │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  Docker Network: "test"           │ │
│  │                                   │ │
│  │  ┌─────────────────────────────┐ │ │
│  │  │  Container: code-snek       │ │ │
│  │  │  - Ruby snake :4567         │ │ │
│  │  │  - Go snake :8081           │ │ │
│  │  │  - supervisord orchestrates │ │ │
│  │  └─────────────────────────────┘ │ │
│  │                                   │ │
│  │  ┌─────────────────────────────┐ │ │
│  │  │  Container: simulate runner │ │ │
│  │  │  - battlesnake CLI          │ │ │
│  │  │  - connects to code-snek    │ │ │
│  │  └─────────────────────────────┘ │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

---

## Simplified Alternatives

### Option 1: Single Container with Host Network (Simplest)
**Complexity**: Low

```bash
# Single command
docker run --network host code-snek

# Access snakes directly on localhost
curl http://localhost:4567/
curl http://localhost:8081/
```

**Pros**:
- No network setup
- No port mapping needed
- Simple one-liner
- Easy to debug (localhost access)

**Cons**:
- Only works on Linux hosts
- Doesn't work on macOS/Windows Docker Desktop

### Option 2: Docker Compose (Recommended)
**Complexity**: Medium

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  snakes:
    build: .
    ports:
      - "4567:4567"
      - "8081:8081"
    networks:
      - battlesnake
  
  simulator:
    image: battlesnake-simulator
    depends_on:
      - snakes
    networks:
      - battlesnake
    command: script/simulate_royale --runs 10

networks:
  battlesnake:
```

**Usage**:
```bash
# Start everything
docker-compose up

# Run simulations
docker-compose run simulator
```

**Pros**:
- Declarative configuration
- Automatic network setup
- Easy reproducibility
- Version controlled

**Cons**:
- Requires docker-compose
- Extra configuration file

### Option 3: Pre-built Image from Registry (Best for CI)
**Complexity**: Low

```yaml
# Use pre-built image instead of building
- name: Run simulations
  run: |
    docker run -d ghcr.io/es-na-battlesnake/snakes:latest
    # No build step needed
```

**Pros**:
- No build failures
- Faster CI runs
- Consistent environment

**Cons**:
- Requires image registry setup
- Need to publish images

### Option 4: Direct Process Execution (Fastest for Development)
**Complexity**: Very Low

```bash
# Start snakes directly (no Docker)
cd snakes/ruby/djdefi && bundle exec rackup -p 4567 &
cd snakes/go/pathy-snake && go run . &

# Run simulations
battlesnake play --url http://localhost:4567 --url http://localhost:8081
```

**Pros**:
- No Docker needed
- Fastest iteration
- Easy debugging
- Works everywhere

**Cons**:
- Requires all dependencies installed
- Manual process management
- Platform-specific

---

## Recommended Simplified Setup

### For Local Development: Direct Execution
Use a script that manages processes:

```bash
#!/bin/bash
# script/run_local_sim

# Start snakes in background
cd snakes/ruby/djdefi && bundle exec rackup -p 4567 > /tmp/ruby.log 2>&1 &
RUBY_PID=$!

cd snakes/go/pathy-snake && go run . > /tmp/go.log 2>&1 &
GO_PID=$!

# Wait for startup
sleep 5

# Run simulations
battlesnake play \
  --name ruby-danger-noodle --url http://localhost:4567 \
  --name pathy --url http://localhost:8081 \
  --runs 10

# Cleanup
kill $RUBY_PID $GO_PID
```

### For CI/CD: Simplified Docker Workflow
Use Docker but simplify the network setup:

```yaml
- name: Start snakes
  run: |
    docker run -d \
      --name snakes \
      -p 4567:4567 \
      -p 8081:8081 \
      code-snek
    sleep 10

- name: Run simulations  
  run: |
    # Run directly on host (snakes accessible via localhost)
    battlesnake play \
      --name ruby --url http://localhost:4567 \
      --name pathy --url http://localhost:8081 \
      --runs 50
```

**Benefits**:
- No Docker network needed
- No second container
- Simpler troubleshooting
- Faster execution

---

## Implementation Recommendations

### Short-term (Immediate)
1. ✅ Keep current Docker network approach for CI (proven to work)
2. ⏳ Add simplified local development script (no Docker)
3. ⏳ Document both approaches clearly

### Medium-term (Next iteration)
1. Consider Docker Compose for better developer experience
2. Publish pre-built images to GitHub Container Registry
3. Add health check endpoints to snakes

### Long-term (Future enhancement)
1. Single binary that includes both snakes
2. Web UI for viewing simulations
3. Automated performance regression testing

---

## Complexity Comparison

| Approach | Setup Steps | Debugging | Speed | Portability |
|----------|-------------|-----------|-------|-------------|
| Current (Docker Network) | 5 | Hard | Slow | High |
| Docker Compose | 2 | Medium | Slow | High |
| Direct Execution | 3 | Easy | Fast | Low |
| Host Network | 1 | Easy | Slow | Medium |
| Pre-built Images | 1 | Medium | Fast | High |

---

## Conclusion

**Current setup is appropriate for CI/CD** where consistency matters more than simplicity.

**For local development**, we should add a simpler option:
- Direct process execution (fastest iteration)
- Clear documentation on both approaches
- Make it easy to switch between them

**Next steps**:
1. Create `script/run_local_sim` for local testing
2. Update documentation with both approaches
3. Keep existing CI workflow as-is (proven)
