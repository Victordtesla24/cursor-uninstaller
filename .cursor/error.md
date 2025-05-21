(${VENV}) vicd@Vics-MacBook-Air.local cursor-uninstaller % cd /Users/Shared/cursor/cursor-uninstaller && bash .cursor/flush-logs.sh && bash .cursor/tests/run-tests.sh
[2025-05-21 11:30:38] MASTER-TEST: [0;34m[1m====== Starting Cursor Background Agent Tests ======[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34mTest directory: /Users/Shared/cursor/cursor-uninstaller/.cursor/tests[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34m============================================================[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34m[1mSystem Information:[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34mOS: Darwin 24.5.0 arm64[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34mDocker version: Docker version 28.1.1, build 4eba377[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34mBash version: 3.2.57(1)-release[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34mWorking directory: /Users/Shared/cursor/cursor-uninstaller[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34mUser: vicd[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34m============================================================[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34m[1m======= Testing: test-env-setup.sh =======[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34mBeginning test execution: test-env-setup.sh[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34mLog file: /Users/Shared/cursor/cursor-uninstaller/.cursor/logs/test-env-setup.sh.log[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34mTest started at: 2025-05-21 11:30:38[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34mTest completed at: 2025-05-21 11:30:38[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;32m✓ Test PASSED: test-env-setup.sh[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34m============================================================[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34m[1m======= Testing: test-github-integration.sh =======[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34mBeginning test execution: test-github-integration.sh[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34mLog file: /Users/Shared/cursor/cursor-uninstaller/.cursor/logs/test-github-integration.sh.log[0m
[2025-05-21 11:30:38] MASTER-TEST: [0;34mTest started at: 2025-05-21 11:30:38[0m
[2025-05-21 11:30:42] MASTER-TEST: [0;34mTest completed at: 2025-05-21 11:30:42[0m
[2025-05-21 11:30:42] MASTER-TEST: [1;33m⚠ Test returned success (exit code 0) but contains skip statements.[0m
[2025-05-21 11:30:42] MASTER-TEST: [0;32m✓ Test PASSED: test-github-integration.sh[0m
[2025-05-21 11:30:42] MASTER-TEST: [0;34m============================================================[0m
[2025-05-21 11:30:42] MASTER-TEST: [0;34m[1m======= Testing: test-docker-env.sh =======[0m
[2025-05-21 11:30:42] MASTER-TEST: [0;34mBeginning test execution: test-docker-env.sh[0m
[2025-05-21 11:30:42] MASTER-TEST: [0;34mLog file: /Users/Shared/cursor/cursor-uninstaller/.cursor/logs/test-docker-env.sh.log[0m
[2025-05-21 11:30:42] MASTER-TEST: [0;34mTest started at: 2025-05-21 11:30:42[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;34mTest completed at: 2025-05-21 11:31:25[0m
[2025-05-21 11:31:25] MASTER-TEST: [1;33m⚠ Test returned success (exit code 0) but contains skip statements.[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;31m✗ Test appears to have been SKIPPED rather than fully executed.[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;31m✗ Tests cannot return success (0) when skipped. This is treated as a failure.[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;31mFirst 10 lines from significant errors:[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;31m| [2025-05-21 11:31:20] DOCKER-TEST: [0;34mℹ | #5 2.926   liberror-perl libevent-core-2.1-7 libexpat1 libgdbm-compat4 libgdbm6[0m[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;31m| [2025-05-21 11:31:21] DOCKER-TEST: [0;34mℹ | #5 3.180   libbrotli1 libcurl3-gnutls libcurl4 liberror-perl libevent-core-2.1-7[0m[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;31m| [2025-05-21 11:31:21] DOCKER-TEST: [0;34mℹ | #5 5.829 Get:54 http://deb.debian.org/debian bookworm/main arm64 liberror-perl all 0.17029-2 [29.0 kB][0m[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;31m| [2025-05-21 11:31:21] DOCKER-TEST: [0;34mℹ | #5 7.821 update-alternatives: error: alternative path /usr/share/man/man7/bash-builtins.7.gz doesn't exist[0m[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;31m| [2025-05-21 11:31:21] DOCKER-TEST: [0;34mℹ | #5 9.734 Selecting previously unselected package liberror-perl.[0m[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;31m| [2025-05-21 11:31:21] DOCKER-TEST: [0;34mℹ | #5 9.734 Preparing to unpack .../26-liberror-perl_0.17029-2_all.deb ...[0m[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;31m| [2025-05-21 11:31:21] DOCKER-TEST: [0;34mℹ | #5 9.735 Unpacking liberror-perl (0.17029-2) ...[0m[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;31m| [2025-05-21 11:31:22] DOCKER-TEST: [0;34mℹ | #5 11.25 Setting up liberror-perl (0.17029-2) ...[0m[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;34m============================================================[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;34m[1m======= Testing: test-background-agent.sh =======[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;34mBeginning test execution: test-background-agent.sh[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;34mLog file: /Users/Shared/cursor/cursor-uninstaller/.cursor/logs/test-background-agent.sh.log[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;34mTest started at: 2025-05-21 11:31:25[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;34mTest completed at: 2025-05-21 11:31:25[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;32m✓ Test PASSED: test-background-agent.sh[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;34m============================================================[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;34m[1m======= Testing: test-agent-runtime.sh =======[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;34mBeginning test execution: test-agent-runtime.sh[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;34mLog file: /Users/Shared/cursor/cursor-uninstaller/.cursor/logs/test-agent-runtime.sh.log[0m
[2025-05-21 11:31:25] MASTER-TEST: [0;34mTest started at: 2025-05-21 11:31:25[0m
[2025-05-21 11:31:26] MASTER-TEST: [0;34mTest completed at: 2025-05-21 11:31:26[0m
[2025-05-21 11:31:26] MASTER-TEST: [0;32m✓ Test PASSED: test-agent-runtime.sh[0m
[2025-05-21 11:31:26] MASTER-TEST: [0;34m============================================================[0m
[2025-05-21 11:31:26] MASTER-TEST: [0;34m[1m======= Testing: test-linting.sh =======[0m
[2025-05-21 11:31:26] MASTER-TEST: [0;34mBeginning test execution: test-linting.sh[0m
[2025-05-21 11:31:26] MASTER-TEST: [0;34mLog file: /Users/Shared/cursor/cursor-uninstaller/.cursor/logs/test-linting.sh.log[0m
[2025-05-21 11:31:26] MASTER-TEST: [0;34mTest started at: 2025-05-21 11:31:26[0m
[2025-05-21 11:31:31] MASTER-TEST: [0;34mTest completed at: 2025-05-21 11:31:31[0m
[2025-05-21 11:31:31] MASTER-TEST: [1;33m⚠ Test returned success (exit code 0) but contains skip statements.[0m
[2025-05-21 11:31:31] MASTER-TEST: [0;32m✓ Test PASSED: test-linting.sh[0m
[2025-05-21 11:31:31] MASTER-TEST: [0;34m============================================================[0m
[2025-05-21 11:31:31] MASTER-TEST: [0;34m
[2025-05-21 11:31:31] MASTER-TEST: [0;34m======================================================[0m
[2025-05-21 11:31:31] MASTER-TEST: [0;34m[1m===== Test Run Summary =====[0m
[2025-05-21 11:31:31] MASTER-TEST: [0;34mTotal Tests Configured: 6[0m
[2025-05-21 11:31:31] MASTER-TEST: [0;32mTests Passed: 5[0m
[2025-05-21 11:31:31] MASTER-TEST: [0;31mTests Failed: 1[0m
[2025-05-21 11:31:31] MASTER-TEST: [0;34mSuccess Rate: 83%[0m
[2025-05-21 11:31:31] MASTER-TEST: [0;31mFailed tests details:[0m
[2025-05-21 11:31:31] MASTER-TEST: [0;31m  - test-docker-env.sh (INVALID SUCCESS - DETECTED SKIPPED TESTS)[0m
[2025-05-21 11:31:31] MASTER-TEST: [0;31mOVERALL RESULT: FAIL - 1 unexpected test failures[0m

(${VENV}) vicd@Vics-MacBook-Air.local cursor-uninstaller % 
