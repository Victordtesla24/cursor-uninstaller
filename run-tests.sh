#!/bin/bash

# Check if an argument was provided
if [ $# -eq 0 ]; then
  # Run all tests with a 30-second timeout
  echo "Running all tests..."
  npx jest --testTimeout=30000
else
  # Run the specified test file or pattern with a 30-second timeout
  echo "Running tests: $1"
  npx jest "$1" --testTimeout=30000
fi 