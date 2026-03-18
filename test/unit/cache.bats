#!/usr/bin/env bats

setup() {
  load '../helpers'
  load_claude_lens
  setup_temp
}

teardown() {
  teardown_temp
}

@test "cache_set writes data atomically" {
  cache_set "$TEST_CACHE_DIR/test-cache" "hello world"
  [ -f "$TEST_CACHE_DIR/test-cache" ]
  [ "$(cat "$TEST_CACHE_DIR/test-cache")" = "hello world" ]
}

@test "cache_get returns data within TTL" {
  cache_set "$TEST_CACHE_DIR/test-cache" "cached data"
  run cache_get "$TEST_CACHE_DIR/test-cache" 10
  [ "$status" -eq 0 ]
  [ "$output" = "cached data" ]
}

@test "cache_get returns empty after TTL expires" {
  cache_set "$TEST_CACHE_DIR/test-cache" "old data"
  sleep 2
  run cache_get "$TEST_CACHE_DIR/test-cache" 1
  [ "$status" -eq 1 ]
}

@test "cache_get returns empty for nonexistent file" {
  run cache_get "$TEST_CACHE_DIR/nonexistent" 10
  [ "$status" -eq 1 ]
}

@test "file_age returns seconds since modification" {
  touch "$TEST_CACHE_DIR/test-file"
  run file_age "$TEST_CACHE_DIR/test-file"
  [ "$status" -eq 0 ]
  [ "$output" -le 2 ]
}
