#!/bin/sh
set -eu

DIR="/root/adblock-lite"
log() { echo "[restart] $*"; }

log "Stopping..."
sh "${DIR}/stop.sh" || true

log "Starting..."
sh "${DIR}/start.sh"

log "Done."
