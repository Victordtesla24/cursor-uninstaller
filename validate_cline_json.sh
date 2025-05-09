#!/bin/bash

CONFIG_PATH="./cline.config.json"
REDIS_HOST="localhost"
REDIS_PORT=6379

echo "Step 1: Check if cline.config.json exists..."
if [ ! -f "$CONFIG_PATH" ]; then
  echo "ERROR: cline.config.json not found at $CONFIG_PATH"
  exit 1
fi
echo "Found cline.config.json."

echo "Step 2: Validate JSON syntax..."
if ! jq empty "$CONFIG_PATH" 2>/dev/null; then
  echo "ERROR: cline.config.json contains invalid JSON."
  exit 1
fi
echo "JSON syntax is valid."

echo "Step 3: Check Redis connectivity for L1 cache tier..."
if ! nc -z "$REDIS_HOST" "$REDIS_PORT"; then
  echo "WARNING: Cannot connect to Redis at $REDIS_HOST:$REDIS_PORT."
  echo "Ensure Redis server is running and accessible."
else
  echo "Redis connection successful."
fi

echo "Step 4: Extract configured model and cache settings..."
MODEL=$(jq -r '.model.name' "$CONFIG_PATH")
PROVIDER=$(jq -r '.model.provider' "$CONFIG_PATH")
MODE=$(jq -r '.model.mode' "$CONFIG_PATH")
CACHE_ENABLED=$(jq -r '.cache.enabled' "$CONFIG_PATH")

echo "Configured Model: $MODEL"
echo "Provider: $PROVIDER"
echo "Mode: $MODE"
echo "Cache Enabled: $CACHE_ENABLED"

if [ "$CACHE_ENABLED" != "true" ]; then
  echo "WARNING: Cache is disabled. Enabling cache can reduce token usage and costs."
fi

echo "Step 5: Verify model selection rules presence..."
RULES_COUNT=$(jq '.modelSelectionRules | length' "$CONFIG_PATH")
if [ "$RULES_COUNT" -lt 1 ]; then
  echo "WARNING: No model selection rules found. This may cause inefficient token usage."
else
  echo "Model selection rules configured: $RULES_COUNT"
fi

echo "Validation complete. If any warnings/errors appeared, address them as per instructions."

exit 0
c
