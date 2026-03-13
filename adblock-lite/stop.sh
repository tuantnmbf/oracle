#!/bin/sh
set -eu

CONF_DIR="/etc/dnsmasq.d"
LIST_FILE="${CONF_DIR}/adblock.conf"
TMP_FILE="/tmp/adblock.conf"

log() { echo "[stop] $*"; }

if [ -f "${LIST_FILE}" ]; then
  log "Disabling adblock-lite (moving list to /tmp)..."
  mv -f "${LIST_FILE}" "${TMP_FILE}"
else
  log "List not found at ${LIST_FILE}. Maybe already stopped."
fi

log "Restarting dnsmasq..."
service dnsmasq restart || /etc/init.d/dnsmasq restart

log "Adblock-lite is OFF."
