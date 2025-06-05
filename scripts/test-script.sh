#!/bin/bash
# Test script with intentional issues for validation demo

echo "Hello World"
source ./nonexistent-file.sh
function test_function() {
    echo "This is a test"
}

# This will cause a ShellCheck warning
cd $HOME
