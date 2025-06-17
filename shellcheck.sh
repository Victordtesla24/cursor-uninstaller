#!/usr/bin/env bash
# Docker-based ShellCheck wrapper for VS Code integration
exec docker run --rm -i \
  -v "${PWD}:/mnt:ro" \
  koalaman/shellcheck:latest "$@"
