#!/bin/bash

# Check if a test pattern was provided
if [ $# -eq 0 ]; then
  # Run all tests with a 30-second timeout
  npx jest --config=jest.config.js --testTimeout=30000
else
  # Run tests matching the pattern with a 30-second timeout
  npx jest --config=jest.config.js --testTimeout=30000 -t "$1"
fi 