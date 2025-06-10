#!/bin/bash
# Monitoring Integration Script
# Starts real-time AI enhancement monitoring

echo "🚀 Starting AI Enhancement Monitoring System"

# Start the real-time data server
echo "📊 Launching real-time metrics server..."
node scripts/real-time-data-server.js &
SERVER_PID=$!

echo "✅ Monitoring server started (PID: $SERVER_PID)"
echo "📈 Dashboard available at: http://localhost:8080/dashboard"
echo "🔍 Metrics API at: http://localhost:8080/api/metrics"

# Save PID for cleanup
echo $SERVER_PID > scripts/.monitoring-server.pid

echo "🎯 AI Enhancement Monitoring System is LIVE!"
echo "Press Ctrl+C to stop monitoring"

# Keep script running
wait $SERVER_PID