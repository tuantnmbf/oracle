#!/bin/sh
set -eu

BACKUP_DIR="/root/rollback-adblock-lite"
BACKUP_DHCP="${BACKUP_DIR}/dhcp"
CONF_DIR="/etc/dnsmasq.d"

log() { echo "[rollback] $*"; }

if [ ! -f "${BACKUP_DHCP}" ]; then
  log "ERROR: Backup not found: ${BACKUP_DHCP}"
  log "Run install.sh (or start.sh once, previously) to create backup."
  exit 1
fi

log "Restoring /etc/config/dhcp from backup..."
cp -f "${BACKUP_DHCP}" /etc/config/dhcp

log "Removing adblock configs at ${CONF_DIR} ..."
rm -rf "${CONF_DIR}"

log "Restarting dnsmasq..."
service dnsmasq restart || /etc/init.d/dnsmasq restart

log "Rolled back to pre-adblock state."
