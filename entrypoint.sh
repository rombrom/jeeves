#!/usr/bin/env bash
set -euo pipefail

log() {
  echo "[entrypoint] $@"
}

# Bootstrap defaults from image (idempotent — skips existing files)
if [ -d /opt/defaults ]; then
  log "Bootstrapping defaults..."
  rsync -a /opt/defaults/ /
fi

# Sync repo-managed config from /opt/config/ to /root/.pi/agent/
if [ -d /opt/config ]; then
  log "Syncing repo-managed config..."
  rsync -a --update /opt/config/ /root/
fi

sudo sysctl -p

log "Ready."

exec "$@"
