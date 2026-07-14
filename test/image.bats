#!/usr/bin/env bats
# Runtime checks for the jeeves container image.
#
# Usage:
#   bats test/image.bats          # run all tests
#   bats -t test/image.bats       # show output even on success
#   bats --filter 'binaries' test/image.bats  # run only matching tests

IMAGE_NAME="${BATS_IMAGE_NAME:-jeeves}"
IMAGE_TAG="${BATS_IMAGE_TAG:-latest}"
IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"
CONTAINER_NAME="jeeves-test-image"

# ---------------------------------------------------------------------------
# Lifecycle hooks
# ---------------------------------------------------------------------------

setup_file() {
  container rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
  run container run --detach --name "${CONTAINER_NAME}" "${IMAGE}"
  [ "$status" -eq 0 ]
}

teardown_file() {
  bats::on_failure() {
    echo "--- container logs ---" >&3
    container logs "${CONTAINER_NAME}" >&3
    echo "--- end logs ---" >&3
  }
  container stop "${CONTAINER_NAME}" >/dev/null 2>&1 || true
  container rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
}

# ---------------------------------------------------------------------------
# Tests - image runs
# ---------------------------------------------------------------------------

@test "image starts and hostname resolves" {
  run container exec "${CONTAINER_NAME}" hostname
  [ "$status" -eq 0 ]
  [ -n "${output// /}" ]
}

@test "image has a working shell (bash)" {
  run container exec "${CONTAINER_NAME}" bash -c 'echo hello'
  [ "$status" -eq 0 ]
  [[ "$output" == "hello" ]]
}

# ---------------------------------------------------------------------------
# Tests - required binaries
# ---------------------------------------------------------------------------

REQUIRED_BINARIES=(
  claude
  curl
  fd
  git
  jq
  mise
  nc
  pi
  psql
  rg
  tree
  wget
)

@test "all required binaries are available" {
  run container exec "${CONTAINER_NAME}" bash -c '
    fail=0
    for bin in "$@"; do
      if ! command -v "$bin" >/dev/null 2>&1; then
        echo "MISSING: $bin"
        fail=1
      fi
    done
    exit $fail
  ' _ "${REQUIRED_BINARIES[@]}"
  [ "$status" -eq 0 ]
  [[ -z "$output" ]]
}
