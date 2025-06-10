#!/bin/bash
# Stop the AI Enhancement Monitoring System

echo "🛑 Stopping AI Enhancement Monitoring System..."

# Check if PID file exists
if [ -f .monitoring.pid ]; then
  PID=$(cat .monitoring.pid)
  
  # Check if process is running
  if ps -p $PID > /dev/null; then
    echo "🔍 Found monitoring server process (PID: $PID)"
    echo "📊 Shutting down server..."
    
    # Send SIGTERM for graceful shutdown
    kill -TERM $PID
    
    # Wait for process to exit
    COUNTER=0
    while ps -p $PID > /dev/null && [ $COUNTER -lt 5 ]; do
      echo "⏳ Waiting for server to shut down..."
      sleep 1
      COUNTER=$((COUNTER+1))
    done
    
    # Force kill if still running
    if ps -p $PID > /dev/null; then
      echo "⚠️ Server still running, forcing shutdown..."
      kill -9 $PID
      sleep 1
    fi
    
    # Check final status
    if ps -p $PID > /dev/null; then
      echo "❌ Failed to stop server (PID: $PID)"
      exit 1
    else
      echo "✅ Server stopped successfully"
    fi
  else
    echo "ℹ️ No running monitoring server found with PID: $PID"
  fi
  
  # Remove PID file
  rm .monitoring.pid
  echo "🧹 Cleaned up monitoring PID file"
else
  echo "ℹ️ No monitoring server appears to be running"
fi

echo "✅ AI Enhancement Monitoring System is now OFFLINE"
