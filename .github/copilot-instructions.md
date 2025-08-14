# ES NA Battlesnakes Repository

This repository contains multiple Battlesnake implementations in Ruby, Go, and Python. Each snake runs as a web server that responds to the Battlesnake API.

**ALWAYS reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### Initial Setup and Dependencies
Run these commands in order to set up the development environment:

```bash
# Install Ruby dependencies - NEVER CANCEL: Takes ~45 seconds
sudo gem install bundler
sudo bundle install

# Install Python dependencies - Takes ~7 seconds  
pip3 install flake8 pathfinding

# Install supervisor for process management - Takes ~2 minutes
sudo apt-get update && sudo apt-get install -y supervisor

# Optional: Install Go tools and battlesnake CLI - Takes ~30 seconds
sudo chmod +x setup-go.sh && sudo ./setup-go.sh
```

### Build and Test Commands

**Ruby Snakes:**
```bash
# Run Ruby tests - Takes <1 second
script/test djdefi

# Test specific Ruby snake manually
cd snakes/ruby/djdefi && bundle exec rackup --host 0.0.0.0 -p 4567
```

**Go Snakes:**
```bash
# Build Go snakes - Takes ~11 seconds per snake
cd snakes/go/pathy-snake && go build .

# Run Go tests - NEVER CANCEL: Takes ~4 seconds
go test -v ./snakes/...

# Test specific Go snake manually  
cd snakes/go/pathy-snake && go run . --host 0.0.0.0 --port 8081
```

**Python Snakes:**
```bash
# Run Python tests - Takes <0.1 seconds (NOTE: some tests may fail due to known issues)
python3 snakes/python/summer-league-2022/src/tests.py -v

# Lint Python code - Takes <1 second
flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
```

### Running the Full Application

**Docker Method (Recommended):**
```bash
# Build Docker image - NEVER CANCEL: Takes ~29 seconds. Set timeout to 60+ seconds.
docker build . --file Dockerfile --tag battlesnake

# Run all snakes via Docker - Takes <1 second to start  
docker run -d -p 4567:4567 -p 8081:8081 --name battlesnake-run battlesnake

# View logs
docker logs battlesnake-run

# Stop container
docker stop battlesnake-run && docker rm battlesnake-run
```

**Local Supervisor Method:**
```bash
# Start all snakes locally (requires supervisor installation)
sudo script/server

# Note: Go snakes may fail if Go is not installed at /usr/local/go/bin/go
# The supervisord.conf expects this path but system Go is at /usr/bin/go
```

## Validation and Testing

### Manual Endpoint Testing
After starting the application, test these endpoints:

```bash
# Test Ruby snake (djdefi) - Should return JSON with apiversion, author, color, etc.
curl "http://localhost:4567/"

# Test Go snake (pathy-snake) - Should return JSON with apiversion, author, color, etc.  
curl "http://localhost:8081/"
```

### Validation Scenarios
**ALWAYS run these validation steps after making changes:**

1. **Build Test:** Verify all components build successfully
2. **Unit Test:** Run language-specific test suites  
3. **Integration Test:** Start application and test endpoints
4. **Docker Test:** Build and run Docker container
5. **Endpoint Test:** Manually verify snake API responses

**Example full validation workflow:**
```bash
# 1. Build test
sudo bundle install && go build ./snakes/go/pathy-snake/... 

# 2. Unit tests  
script/test djdefi && go test -v ./snakes/...

# 3. Integration test via Docker
docker build . --tag test-build && docker run -d -p 4567:4567 -p 8081:8081 --name test-run test-build

# 4. Endpoint tests
curl "http://localhost:4567/" && curl "http://localhost:8081/"

# 5. Cleanup
docker stop test-run && docker rm test-run
```

## Important Timing and Timeout Information

**CRITICAL: NEVER CANCEL these operations. Always set appropriate timeouts:**

- **Bundle install:** 45 seconds (set timeout to 90+ seconds)
- **Docker build:** 29 seconds (set timeout to 60+ seconds)  
- **Go build:** 11 seconds per snake (set timeout to 30+ seconds)
- **Go tests:** 4 seconds (set timeout to 15+ seconds)
- **Ruby tests:** <1 second (set timeout to 10+ seconds)
- **Python setup:** 7 seconds (set timeout to 30+ seconds)
- **Supervisor install:** 2 minutes (set timeout to 300+ seconds)

## Common Tasks and File Locations

### Repository Structure
```
snakes/
├── ruby/           # Ruby snakes (ports 4567+)
│   ├── djdefi/     # Main Ruby snake implementation  
│   └── */          # Other Ruby snakes
├── go/             # Go snakes (ports 8080+)
│   ├── pathy-snake/    # Main Go snake with pathfinding
│   ├── spring-league-2022/  # Competition snake
│   └── starter-snake/      # Basic Go implementation
└── python/         # Python snakes
    ├── starter-snake/      # Basic Python implementation
    └── summer-league-2022/ # Competition snake
```

### Key Configuration Files
- `supervisord.conf` - Process management configuration
- `Dockerfile` - Container build instructions
- `Gemfile` - Ruby dependencies
- `go.mod` - Go module definition  
- `script/server` - Launches all snakes via supervisord
- `script/test` - Runs Ruby tests

### Build Artifacts (Excluded from Git)
- `coverage/` - Ruby test coverage reports
- `snakes/go/*/pathy-snake` - Go binary files
- `snakes/go/*/starter-snake` - Go binary files

## Troubleshooting

### Known Issues
- **Python tests fail:** Some Python snake tests have known failures in pathfinding logic
- **Go path mismatch:** supervisord.conf expects Go at `/usr/local/go/bin/go` but system installs at `/usr/bin/go`
- **Bundle permissions:** Bundle install requires sudo due to system gem directory permissions
- **Supervisor warnings:** Running as root generates warnings but is expected in container environment

### Quick Fixes
- **Ruby snake won't start:** Run `sudo bundle install` first
- **Go snake won't build:** Check Go installation with `which go && go version`
- **Docker build fails:** Ensure Docker daemon is running
- **Tests timeout:** Increase timeout values, especially for bundle install and Docker operations
- **Permission errors:** Use `sudo` for system-level operations (bundle, apt-get, supervisor)

## CI/CD Integration

### GitHub Actions Workflows
- `.github/workflows/pr-build.yml` - Main PR validation
- `.github/workflows/go.yml` - Go-specific tests  
- `.github/workflows/python.yml` - Python-specific tests
- `.github/workflows/docker-image.yml` - Docker build validation

### Pre-commit Validation
Always run these before committing:
```bash
# Lint and format
flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

# Test all components
script/test djdefi && go test -v ./snakes/...

# Verify Docker build
docker build . --tag validation-test
```