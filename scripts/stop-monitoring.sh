#!/bin/bash
# Stop monitoring server

if [ -f "scripts/.monitoring-server.pid" ]; then
    PID=$(cat scripts/.monitoring-server.pid)
    echo "🛑 Stopping monitoring server (PID: $PID)..."
    kill $PID 2>/dev/null || true
    rm -f scripts/.monitoring-server.pid
    echo "✅ Monitoring server stopped"
else
    echo "ℹ️ No monitoring server PID found"
fi