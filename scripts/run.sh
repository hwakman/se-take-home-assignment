#!/bin/bash
set -e

# Load nvm if it exists (for local development)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# CI mode: run the CLI binary and generate result.txt
if [ "$CI" = "true" ]; then
    echo "Running CLI application..."
    ./order-controller
    echo "CLI application execution completed"
    exit 0
fi

# Local dev mode: start both backend and frontend
cleanup() {
    echo ""
    echo "Shutting down servers..."
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
    exit
}

trap cleanup SIGINT SIGTERM

echo "Starting McDonald's Order System..."

echo "Starting Backend (Go API) on :8080..."
go run cmd/api/main.go &
BACKEND_PID=$!

sleep 2

echo "Starting Frontend (Next.js) on :3000..."
cd frontend && npm run dev &
FRONTEND_PID=$!

echo "------------------------------------------------"
echo "McDonald's Order System is running!"
echo "Backend: http://localhost:8080"
echo "Frontend: http://localhost:3000"
echo "Press Ctrl+C to stop both servers."
echo "------------------------------------------------"

wait $BACKEND_PID $FRONTEND_PID