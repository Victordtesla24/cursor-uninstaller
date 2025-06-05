#!/bin/bash
# Test script with intentional issues for validation demo

echo "Hello World"
# shellcheck source=/dev/null
source ./nonexistent-file.sh 2>/dev/null || echo "Warning: Optional config file not found"
function test_function() {
    echo "This is a test"
}

# Fixed ShellCheck warning
cd "$HOME" || exit
