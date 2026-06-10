#!/usr/bin/env bash
set -euxo pipefail

if [ -d "/config" ]; then
    rsync -a --update "/config/" "$HOME/.pi/"
fi

exec "$@"
