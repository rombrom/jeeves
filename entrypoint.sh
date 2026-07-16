#!/usr/bin/env bash
set -euo pipefail

log() {
  echo "[entrypoint] $@"
}

# Sync repo-managed config from /opt/config/ to /root/.pi/agent/
if [ -d /opt/config ]; then
  log "Syncing repo-managed config..."
  rsync -a --update /opt/config/ /root/
fi

log "Installing Pi packages..."
for pkg in $(jq -r < ~/.pi/agent/settings.json '.packages[]'); do
  pi install "$pkg"
done

log "Applying kernel settings..."
sysctl --system || true

log "Ready."

exec "$@"
