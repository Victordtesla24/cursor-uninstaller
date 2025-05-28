#!/bin/bash
# Mock sudo for testing
echo "MOCK SUDO: $*" >> test_environment/logs/sudo_calls.log
case "$1" in
    "-v") exit 0 ;;
    "find") shift; command find "$@" 2>/dev/null || true ;;
    "rm") shift; echo "MOCK: would remove $*" ;;
    "chmod") shift; echo "MOCK: would chmod $*" ;;
    "chown") shift; echo "MOCK: would chown $*" ;;
    *) echo "MOCK: sudo $*" ;;
esac
