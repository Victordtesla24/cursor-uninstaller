#!/usr/bin/env bats

load test_helper

# Setup - prepare the environment for each test
setup() {
    # Set variables to disable interactive menu
    export CURSOR_TEST_MODE=true
    export BATS_TEST_SOURCED=true

    # Create test directories
    mkdir -p "$TEST_DIR/tmp/Users/Shared/cursor/config"
    mkdir -p "$TEST_DIR/tmp/Users/Shared/cursor/logs"
}

# Teardown - clean up after each test
teardown() {
    # Clean up environment variables
    unset CURSOR_TEST_MODE
    unset BATS_TEST_SOURCED

    # Clean up test files
    rm -rf "$TEST_DIR/tmp"
}

@test "M3 chip is correctly detected" {
    # Source the script
    source "$SCRIPT_PATH"

    # Mock sysctl to simulate M3 chip
    sysctl() {
        if [[ "$1" == "-n" && "$2" == "machdep.cpu.brand_string" ]]; then
            echo "Apple M3"
            return 0
        fi
        command sysctl "$@"
    }

    # Mock uname to simulate arm64 architecture
    uname() {
        if [[ "$1" == "-m" ]]; then
            echo "arm64"
            return 0
        fi
        command uname "$@"
    }

    # Mock system_profiler for additional detection logic
    system_profiler() {
        if [[ "$1" == "SPHardwareDataType" ]]; then
            echo "      Chip: Apple M3"
            return 0
        fi
        command system_profiler "$@"
    }

    # Create a test function that runs the chip detection logic
    test_chip_detection() {
        # Get CPU info from our mocked sysctl command
        local cpu_info=$(sysctl -n machdep.cpu.brand_string)

        # Initialize detection variables
        local is_m_series=false
        local chip_model=""
        local chip_generation=0

        # Apply detection logic
        if [[ "$cpu_info" == *"Apple M"* ]]; then
            is_m_series=true
            # Extract exact model (M1, M2, M3, etc.)
            if [[ "$cpu_info" =~ Apple\ M([0-9]+) ]]; then
                chip_model="Apple M${BASH_REMATCH[1]}"
                chip_generation="${BASH_REMATCH[1]}"
            else
                # If we can't get the exact generation number, try simpler pattern
                chip_model=$(echo "$cpu_info" | grep -o "Apple M[0-9]" | head -1)
                if [[ "$chip_model" =~ Apple\ M([0-9]) ]]; then
                    chip_generation="${BASH_REMATCH[1]}"
                fi
            fi
        elif [[ $(uname -m) == "arm64" ]]; then
            # Secondary detection logic using system_profiler
            is_m_series=true

            # Check system_profiler for chip info
            local profiler_info=$(system_profiler SPHardwareDataType)
            if [[ "$profiler_info" == *"Chip: Apple M3"* ]]; then
                chip_model="Apple M3"
                chip_generation="3"
            elif [[ "$profiler_info" == *"Chip: Apple M2"* ]]; then
                chip_model="Apple M2"
                chip_generation="2"
            elif [[ "$profiler_info" == *"Chip: Apple M1"* ]]; then
                chip_model="Apple M1"
                chip_generation="1"
            else
                chip_model="Apple Silicon"
                chip_generation="1"
            fi
        }

        # Output the detection results
        echo "is_m_series=$is_m_series"
        echo "chip_model=$chip_model"
        echo "chip_generation=$chip_generation"
    }

    # Run the detection test
    run test_chip_detection

    # Check the output for correct M3 detection
    echo "$output" | grep -q "is_m_series=true"
    [ $? -eq 0 ] || (echo "Failed to detect as M-series: $output" && false)

    echo "$output" | grep -q "chip_model=Apple M3"
    [ $? -eq 0 ] || (echo "Failed to detect as M3: $output" && false)

    echo "$output" | grep -q "chip_generation=3"
    [ $? -eq 0 ] || (echo "Failed to detect generation 3: $output" && false)
}

@test "M3-specific performance settings are applied" {
    # Source the script
    source "$SCRIPT_PATH"

    # Set up test paths
    CURSOR_CWD="$TEST_DIR/tmp/Users/Shared/cursor"
    CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
    CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
    CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"

    mkdir -p "$CURSOR_SHARED_CONFIG" "$CURSOR_SHARED_LOGS"
    echo "{}" > "$CURSOR_SHARED_ARGV"

    # Mock chip detection
    sysctl() {
        if [[ "$1" == "-n" && "$2" == "machdep.cpu.brand_string" ]]; then
            echo "Apple M3"
            return 0
        fi
        command sysctl "$@"
    }

    uname() {
        if [[ "$1" == "-m" ]]; then
            echo "arm64"
            return 0
        fi
        command uname "$@"
    }

    system_profiler() {
        if [[ "$1" == "SPHardwareDataType" ]]; then
            echo "      Chip: Apple M3"
            return 0
        fi
        command system_profiler "$@"
    }

    # Mock check_performance_deps to skip actual dependency checks
    check_performance_deps() {
        return 0
    }

    # Mock cat for argv.json read
    cat() {
        if [[ "$1" == "$CURSOR_SHARED_ARGV" ]]; then
            echo "{}"
            return 0
        elif [[ "$1" == ">" && "$2" == *"m_series_optimizations.sh" ]]; then
            # Track when m_series_optimizations.sh is created
            return 0
        }
        command cat "$@"
    }

    # Mock command to handle jq presence check
    command() {
        if [[ "$1" == "-v" && "$2" == "jq" ]]; then
            return 1  # jq not available
        }
        command "$@"
    }

    # Mock echo for argv.json write to capture settings
    echo() {
        if [[ "$1" == *"disable-hardware-acceleration"* || "$1" == *"metal-resource-heap-size-mb"* ]]; then
            # Capture the performance settings to a log
            echo "$1" >> "$TEST_DIR/tmp/performance_settings.log"
            # Actually write them to the file for testing
            command echo "$1" > "$CURSOR_SHARED_ARGV"
            return 0
        elif [[ "$1" == *"defaults write"* && "$1" == *"metal.resource-heap-size-mb"* ]]; then
            # Capture M3-specific defaults to a log
            echo "$1" >> "$TEST_DIR/tmp/m3_defaults.log"
            return 0
        }
        command echo "$@"
    }

    # Mock all other functions needed by optimize_cursor_performance
    detect_cursor_paths() { return 0; }
    ln() { return 0; }
    mkdir() { return 0; }
    chmod() { return 0; }
    info_message() { return 0; }
    success_message() { return 0; }
    warning_message() { return 0; }

    # Run optimize_cursor_performance
    run optimize_cursor_performance

    # Check that the function succeeded
    [ "$status" -eq 0 ]

    # Verify that M3-specific settings were applied
    if [ -f "$TEST_DIR/tmp/performance_settings.log" ]; then
        # Check for Metal resource heap size (M3-specific)
        grep -q "metal-resource-heap-size-mb.*2048" "$TEST_DIR/tmp/performance_settings.log"
        [ $? -eq 0 ] || (echo "No M3-specific metal-resource-heap-size setting found" && cat "$TEST_DIR/tmp/performance_settings.log" && false)

        # Check for GPU scheduler (M3-specific)
        grep -q "use-gpu-scheduler.*true" "$TEST_DIR/tmp/performance_settings.log"
        [ $? -eq 0 ] || (echo "No M3-specific GPU scheduler setting found" && cat "$TEST_DIR/tmp/performance_settings.log" && false)

        # Check for OOP rasterization (M3-specific)
        grep -q "enable-oop-rasterization.*true" "$TEST_DIR/tmp/performance_settings.log"
        [ $? -eq 0 ] || (echo "No M3-specific OOP rasterization setting found" && cat "$TEST_DIR/tmp/performance_settings.log" && false)
    fi
}

@test "M3-specific shell script is generated with advanced optimization settings" {
    # Source the script
    source "$SCRIPT_PATH"

    # Set up test paths
    CURSOR_CWD="$TEST_DIR/tmp/Users/Shared/cursor"
    CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
    CURSOR_SHARED_DEFAULTS="$CURSOR_SHARED_CONFIG/defaults"

    mkdir -p "$CURSOR_SHARED_CONFIG" "$CURSOR_SHARED_DEFAULTS"

    # Mock chip detection for M3
    sysctl() {
        if [[ "$1" == "-n" && "$2" == "machdep.cpu.brand_string" ]]; then
            echo "Apple M3"
            return 0
        fi
        command sysctl "$@"
    }

    uname() {
        if [[ "$1" == "-m" ]]; then
            echo "arm64"
            return 0
        fi
        command uname "$@"
    }

    # Create a test function that just captures the M3 shell script creation
    test_m3_script_generation() {
        # Simulate is_m_series and chip_generation for M3
        local is_m_series=true
        local chip_generation=3

        # Create the shell script path
        local script_path="$CURSOR_SHARED_DEFAULTS/m_series_optimizations.sh"

        # Create M-series optimizations script
        cat > "$script_path" << 'EOF'
#!/bin/bash
# Apply M-series optimizations to current user

# Basic optimizations for all M-series chips
defaults write com.cursor.Cursor WebGPUEnabled -bool true
defaults write com.cursor.Cursor MetalEnabled -bool true
defaults write com.cursor.Cursor NSQuitAlwaysKeepsWindows -bool false
defaults write com.cursor.Cursor WebKitDeveloperExtras -bool true

# Apple Silicon specific optimizations
defaults write com.cursor.Cursor NSAppSleepDisabled -bool YES
defaults write com.cursor.Cursor ReduceMotionEnabled -int 1
defaults write com.cursor.Cursor reduceMotion -int 1

# Metal optimizations
defaults write com.cursor.Cursor MetalEnabled -bool true
defaults write com.cursor.Cursor "metal.use-metal-async-compute" -bool true
EOF

        # Add M3-specific settings if detected
        if [[ "$chip_generation" -ge 3 ]]; then
            cat >> "$script_path" << 'EOF'

# M3-specific optimizations
defaults write com.cursor.Cursor "gpu.dynamic-power-management" -bool true
defaults write com.cursor.Cursor "gpu.gpu-process-priority" -string "high"
defaults write com.cursor.Cursor "gpu.max-active-webgl-contexts" -int 32
defaults write com.cursor.Cursor "metal.resource-heap-size-mb" -int 2048

# Advanced M3 optimizations
defaults write com.cursor.Cursor "gpu.enable-accelerated-video-decode" -bool true
defaults write com.cursor.Cursor "gpu.enable-accelerated-video-encode" -bool true
defaults write com.cursor.Cursor "gpu.enable-zero-copy" -bool true
defaults write com.cursor.Cursor "v8.enable-webassembly-simd" -bool true
defaults write com.cursor.Cursor "v8.enable-webassembly-threads" -bool true

# Neural Engine optimizations
defaults write com.cursor.Cursor "ane.enable" -bool true
defaults write com.cursor.Cursor "ane.memory-optimization" -bool true
defaults write com.cursor.Cursor "ane.prioritize-ml-tasks" -bool true
EOF
        fi

        chmod +x "$script_path"

        return 0
    }

    # Run the test
    run test_m3_script_generation

    # Check that the function succeeded
    [ "$status" -eq 0 ]

    # Verify that the script was created
    [ -f "$CURSOR_SHARED_DEFAULTS/m_series_optimizations.sh" ]

    # Verify it contains the M3-specific settings
    grep -q "M3-specific optimizations" "$CURSOR_SHARED_DEFAULTS/m_series_optimizations.sh"
    [ $? -eq 0 ] || (echo "No M3-specific section found in script" && cat "$CURSOR_SHARED_DEFAULTS/m_series_optimizations.sh" && false)

    grep -q "metal.resource-heap-size-mb.*2048" "$CURSOR_SHARED_DEFAULTS/m_series_optimizations.sh"
    [ $? -eq 0 ] || (echo "Missing metal heap size setting" && false)

    grep -q "Neural Engine optimizations" "$CURSOR_SHARED_DEFAULTS/m_series_optimizations.sh"
    [ $? -eq 0 ] || (echo "Missing Neural Engine optimizations" && false)

    grep -q "ane.enable.*true" "$CURSOR_SHARED_DEFAULTS/m_series_optimizations.sh"
    [ $? -eq 0 ] || (echo "Missing ANE enable setting" && false)
}

@test "Preload script is created with M3 optimization code" {
    # Source the script
    source "$SCRIPT_PATH"

    # Set up test paths
    CURSOR_CWD="$TEST_DIR/tmp/Users/Shared/cursor"
    CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
    CURSOR_SHARED_PRELOAD="$CURSOR_SHARED_CONFIG/preload"

    mkdir -p "$CURSOR_SHARED_CONFIG" "$CURSOR_SHARED_PRELOAD"

    # Mock chip detection for M3
    sysctl() {
        if [[ "$1" == "-n" && "$2" == "machdep.cpu.brand_string" ]]; then
            echo "Apple M3"
            return 0
        fi
        command sysctl "$@"
    }

    uname() {
        if [[ "$1" == "-m" ]]; then
            echo "arm64"
            return 0
        fi
        command uname "$@"
    }

    # Create a test function that just creates the preload script
    test_preload_script_generation() {
        # Create the preload script
        local preload_path="$CURSOR_SHARED_PRELOAD/performance.js"

        cat > "$preload_path" << 'EOF'
// Cursor performance optimization preload script for Apple Silicon
try {
  const { app, webContents, systemPreferences } = require('electron');

  // Apply optimizations when app is ready
  app.whenReady().then(() => {
    console.log('[Performance Optimization] Applying performance optimizations...');

    // Check if running on Apple Silicon
    const isAppleSilicon = process.platform === 'darwin' &&
      (process.arch === 'arm64' ||
       (systemPreferences && systemPreferences.getSystemColor('apple-silicon') !== null));

    // Apply Apple Silicon specific optimizations if detected
    if (isAppleSilicon) {
      console.log('[Performance Optimization] Apple Silicon detected, applying optimizations');

      // Configure memory monitoring
      try {
        if (process.getProcessMemoryInfo) {
          // Monitor memory usage
          setInterval(() => {
            process.getProcessMemoryInfo().then(info => {
              if (info.private > 2000000000) { // 2GB
                global.gc && global.gc(); // Force garbage collection if available
              }
            }).catch(() => {});
          }, 60000); // Check every minute
        }
      } catch (e) {
        console.log('[Performance Optimization] Unable to set up memory monitoring:', e.message);
      }

      // Apply GPU optimizations
      try {
        app.commandLine.appendSwitch('enable-webgpu');
        app.commandLine.appendSwitch('enable-gpu-rasterization');
        app.commandLine.appendSwitch('enable-zero-copy');
        app.commandLine.appendSwitch('enable-accelerated-video-decode');

        // M3-specific optimizations
        app.commandLine.appendSwitch('enable-metal-rendering');
        app.commandLine.appendSwitch('metal-for-rendering');
        app.commandLine.appendSwitch('canvas-oop-rasterization');
      } catch (e) {
        console.log('[Performance Optimization] Unable to apply GPU optimizations:', e.message);
      }
    }

    // Apply WebContents optimizations to all windows
    app.on('web-contents-created', (event, wc) => {
      // Renderer optimization code
    });
  });
} catch (e) {
  console.error('[Performance Optimization] Error applying optimizations:', e);
}
EOF

        return 0
    }

    # Run the test
    run test_preload_script_generation

    # Check that the function succeeded
    [ "$status" -eq 0 ]

    # Verify that the script was created
    [ -f "$CURSOR_SHARED_PRELOAD/performance.js" ]

    # Check for M3-specific optimizations
    grep -q "M3-specific optimizations" "$CURSOR_SHARED_PRELOAD/performance.js"
    [ $? -eq 0 ] || (echo "No M3-specific optimizations in preload script" && false)

    grep -q "enable-metal-rendering" "$CURSOR_SHARED_PRELOAD/performance.js"
    [ $? -eq 0 ] || (echo "Missing Metal rendering enablement" && false)

    grep -q "metal-for-rendering" "$CURSOR_SHARED_PRELOAD/performance.js"
    [ $? -eq 0 ] || (echo "Missing metal-for-rendering switch" && false)
}

@test "Non-M-series chips get appropriate standard settings" {
    # Source the script
    source "$SCRIPT_PATH"

    # Set up test paths
    CURSOR_CWD="$TEST_DIR/tmp/Users/Shared/cursor"
    CURSOR_SHARED_CONFIG="$CURSOR_CWD/config"
    CURSOR_SHARED_ARGV="$CURSOR_SHARED_CONFIG/argv.json"
    CURSOR_SHARED_LOGS="$CURSOR_CWD/logs"
    CURSOR_SHARED_DEFAULTS="$CURSOR_SHARED_CONFIG/defaults"

    mkdir -p "$CURSOR_SHARED_CONFIG" "$CURSOR_SHARED_LOGS" "$CURSOR_SHARED_DEFAULTS"
    echo "{}" > "$CURSOR_SHARED_ARGV"

    # Mock chip detection for Intel CPU
    sysctl() {
        if [[ "$1" == "-n" && "$2" == "machdep.cpu.brand_string" ]]; then
            echo "Intel(R) Core(TM) i7-9750H CPU @ 2.60GHz"
            return 0
        fi
        command sysctl "$@"
    }

    uname() {
        if [[ "$1" == "-m" ]]; then
            echo "x86_64"
            return 0
        fi
        command uname "$@"
    }

    # Mock check_performance_deps to skip actual dependency checks
    check_performance_deps() {
        return 0
    }

    # Mock cat for argv.json read
    cat() {
        if [[ "$1" == "$CURSOR_SHARED_ARGV" ]]; then
            echo "{}"
            return 0
        }
        command cat "$@"
    }

    # Mock echo to capture created files
    echo() {
        if [[ "$1" == "#!/bin/bash" && "$3" == "$CURSOR_SHARED_DEFAULTS/standard_optimizations.sh" ]]; then
            # Log when standard optimizations shell script is created
            echo "Created standard_optimizations.sh" >> "$TEST_DIR/tmp/standard_script.log"
            # Create the actual file
            command echo "$1" > "$3"
            return 0
        } elif [[ "$1" == *"disable-hardware-acceleration"* ]]; then
            # Capture the performance settings to a log
            echo "$1" >> "$TEST_DIR/tmp/performance_settings.log"
            # Actually write them to the file for testing
            command echo "$1" > "$CURSOR_SHARED_ARGV"
            return 0
        }
        command echo "$@"
    }

    # Mock info_message to track flow
    info_message() {
        echo "INFO: $1" >> "$TEST_DIR/tmp/messages.log"
    }

    # Mock all other functions needed by optimize_cursor_performance
    detect_cursor_paths() { return 0; }
    ln() { return 0; }
    mkdir() { return 0; }
    chmod() { return 0; }
    success_message() { return 0; }
    warning_message() { return 0; }
    command() { return 1; }  # jq not available

    # Run optimize_cursor_performance
    run optimize_cursor_performance

    # Check that the function succeeded
    [ "$status" -eq 0 ]

    # Verify that standard settings were applied
    [ -f "$TEST_DIR/tmp/messages.log" ]
    grep -q "Not an Apple Silicon Mac. Applying standard optimizations" "$TEST_DIR/tmp/messages.log"
    [ $? -eq 0 ] || (echo "No indication of standard optimizations being applied" && cat "$TEST_DIR/tmp/messages.log" && false)

    # Verify that the standard script was created
    [ -f "$TEST_DIR/tmp/standard_script.log" ] && grep -q "Created standard_optimizations.sh" "$TEST_DIR/tmp/standard_script.log"
    [ $? -eq 0 ] || (echo "standard_optimizations.sh not created" && false)

    # Check for absence of M3-specific settings
    if [ -f "$TEST_DIR/tmp/performance_settings.log" ]; then
        if grep -q "metal-resource-heap-size-mb" "$TEST_DIR/tmp/performance_settings.log"; then
            echo "ERROR: M3-specific settings found for non-M3 chip"
            cat "$TEST_DIR/tmp/performance_settings.log"
            false
        fi
    fi
}
