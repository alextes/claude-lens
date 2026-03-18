# test/helpers.bash - shared test utilities for bats

# Load claude-lens functions without executing main
load_claude_lens() {
  source "${BATS_TEST_DIRNAME}/../../claude-lens.sh" --source-only
}

# Create a temporary directory for cache files, cleaned up after each test
setup_temp() {
  export TEST_CACHE_DIR
  TEST_CACHE_DIR=$(mktemp -d /tmp/claude-lens-test-XXXXXX)
}

teardown_temp() {
  [ -n "${TEST_CACHE_DIR:-}" ] && rm -rf "$TEST_CACHE_DIR"
}

# Helper: pipe fixture JSON to a function that reads stdin
pipe_fixture() {
  local fixture="$1"
  cat "${BATS_TEST_DIRNAME}/../fixtures/${fixture}"
}

# Helper: get file age in seconds (cross-platform)
# macOS uses stat -f %m, Linux uses stat -c %Y
_file_mtime() {
  stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null || echo 0
}
