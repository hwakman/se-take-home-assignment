#!/bin/bash
set -e

# Load nvm if it exists (for local development)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# CI mode: run Go tests only (frontend tests are handled by the CI workflow)
if [ "$CI" = "true" ]; then
    echo "Running unit tests..."
    go test ./... -v
    echo "Unit tests completed"
    exit 0
fi

# Local dev mode: run both backend and frontend tests
echo "Running Backend unit tests..."
go test ./... -v

echo "Running Frontend unit tests with coverage..."
cd frontend && npm run test:coverage

echo "All tests completed successfully!"
