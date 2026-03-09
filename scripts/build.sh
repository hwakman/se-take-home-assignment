#!/bin/bash
set -e

# Load nvm if it exists (for local development)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# CI mode: build the CLI binary only
if [ "$CI" = "true" ]; then
    echo "Building CLI application..."
    go build -o order-controller ./cmd/cli/main.go
    echo "Build completed"
    exit 0
fi

# Local dev mode: build both backend and frontend
echo "Building Backend (Go API)..."
go build -o order-controller ./cmd/api/main.go

echo "Building Frontend (Next.js)..."
cd frontend && npm run build

echo "Builds completed successfully!"