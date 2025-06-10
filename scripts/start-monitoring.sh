#!/bin/bash
# Start the AI Enhancement Monitoring System

echo "🚀 Starting AI Enhancement Monitoring System"
echo "📊 Launching real-time metrics server..."

# Create logs directory if it doesn't exist
mkdir -p logs

# Kill any existing process
if [ -f .monitoring.pid ]; then
  OLD_PID=$(cat .monitoring.pid)
  if ps -p $OLD_PID > /dev/null; then
    echo "⚠️ Found existing monitoring server (PID: $OLD_PID), stopping it..."
    kill $OLD_PID 2>/dev/null
    sleep 1
  fi
  rm .monitoring.pid
fi

# Start the server in the background
node scripts/real-time-data-server.js > logs/monitoring.log 2>&1 &
PID=$!

# Save the PID to a file for later use
echo $PID > .monitoring.pid

# Check if server started successfully
sleep 2
if ps -p $PID > /dev/null; then
  echo "✅ Monitoring server started (PID: $PID)"
  echo "📈 Dashboard available at: http://localhost:8080/dashboard"
  echo "🔍 Metrics API at: http://localhost:8080/api/metrics"
  echo "🎯 AI Enhancement Monitoring System is LIVE!"
  echo "Press Ctrl+C to stop monitoring"
  
  # Keep monitoring the log
  tail -f logs/monitoring.log
else
  echo "❌ Failed to start monitoring server"
  exit 1
fi
