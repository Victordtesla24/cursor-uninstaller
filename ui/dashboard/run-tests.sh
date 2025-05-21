#!/bin/bash

# Run all tests
npm test

# Display success message if all tests pass
if [ $? -eq 0 ]; then
  echo ""
  echo "✅ All tests completed successfully!"
  echo "✅ Great job fixing the tests!"
  echo ""
fi