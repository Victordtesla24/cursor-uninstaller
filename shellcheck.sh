#!/usr/bin/env bash
# Docker-based ShellCheck wrapper for VS Code integration
exec docker run --rm -i \
  --memory=512m --cpus=1.0 \
  -v "${PWD}:/mnt:ro" \
  koalaman/shellcheck:latest "$@"
