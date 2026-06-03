#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# jeeves entrypoint
#
# On every start, merges /config (user-provided overrides) into ~/.pi
# (the pi-coding-agent config directory). User files always win — this is
# a one-way overlay, never destructive to existing session data.
# ============================================================================

PI_DIR="/$HOME/.pi"
CONFIG_DIR="/config"

# --- Merge /config into ~/.pi ------------------------------------------------
# rsync --ignore-existing copies only files that don't already exist in the
# destination, so session data (sessions/, output files) is never clobbered
# and user-provided overrides in /config always take precedence.
if [ -d "$CONFIG_DIR" ]; then
    rsync -a --ignore-existing "$CONFIG_DIR/" "$PI_DIR/"
fi

# --- Pass through to the original CMD ----------------------------------------
exec "$@"
