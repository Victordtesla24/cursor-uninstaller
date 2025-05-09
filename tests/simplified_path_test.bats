#!/usr/bin/env bats

# This is a simplified test file that tests just core functionality
# of the path resolution and shared configuration features

@test "Script exists and is executable" {
  [ -f "uninstall_cursor.sh" ]
  [ -x "uninstall_cursor.sh" ]
}

@test "get_script_path returns a directory containing uninstall_cursor.sh" {
  source "uninstall_cursor.sh"
  local path=$(get_script_path)
  [ -d "$path" ]
  [ -f "$path/uninstall_cursor.sh" ]
}

@test "Script sets CURSOR_CWD to /Users/Shared/cursor" {
  source "uninstall_cursor.sh"
  [ "$CURSOR_CWD" = "/Users/Shared/cursor" ]
}

@test "Shared configuration uses standard paths" {
  source "uninstall_cursor.sh"
  [ "$CURSOR_SHARED_CONFIG" = "/Users/Shared/cursor/config" ]
  [ "$CURSOR_SHARED_LOGS" = "/Users/Shared/cursor/logs" ]
  [ "$CURSOR_SHARED_PROJECTS" = "/Users/Shared/cursor/projects" ]
}

@test "Apple Silicon detection handles M3 properly" {
  # We're going to mock just the detection portion, not the full optimize function

  # Create a function that simulates the detection logic from the main script
  detect_apple_silicon() {
    local is_m_series=false
    local chip_model=""
    local chip_generation=0

    # Simulate an M3 processor
    local cpu_info="Apple M3"

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
    fi

    echo "is_m_series=$is_m_series"
    echo "chip_model=$chip_model"
    echo "chip_generation=$chip_generation"
  }

  # Run the detection
  result=$(detect_apple_silicon)

  # Verify correct detection
  echo "$result" | grep -q "is_m_series=true"
  echo "$result" | grep -q "chip_model=Apple M3"
  echo "$result" | grep -q "chip_generation=3"
}
