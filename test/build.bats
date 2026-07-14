#!/usr/bin/env bats
# Verifies the jeeves container image builds successfully.
#
# Usage:
#   bats test/build.bats

IMAGE_NAME="${BATS_IMAGE_NAME:-jeeves}"
IMAGE_TAG="${BATS_IMAGE_TAG:-latest}"

@test "container image builds successfully" {
  bats_require_minimum_version "1.7.0"
  run container build -t "${IMAGE_NAME}:${IMAGE_TAG}" .
  [ "$status" -eq 0 ]
}
