#!/bin/sh
set -eu

CONF_DIR="/etc/dnsmasq.d"
# HaGeZi pro.mini (định dạng dnsmasq, phần lớn là local=/domain/)
# LIST_URL="https://raw.githubusercontent.com/hagezi/dns-blocklists/main/dnsmasq/pro.mini.txt"
LIST_URL="https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/dnsmasq/pro.plus.mini.txt"
LIST_FILE="${CONF_DIR}/adblock.conf"

log() { echo "[start] $*"; }

require_net() {
  # Wait up to ~30s for WAN
  for i in $(seq 1 15); do
    if ping -c1 -W1 1.1.1.1 >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  return 1
}

fetch_blocklist() {
  URL="$1"
  OUT="$2"
  TMP="${OUT}.tmp"

  # Try uclient-fetch first (native on OpenWrt)
  if command -v uclient-fetch >/dev/null 2>&1; then
    for i in 1 2 3; do
      uclient-fetch -T 15 -O "${TMP}" "${URL}" && return 0
      sleep 2
    done
  fi

  # Fallback: wget (BusyBox) - no --tries, do manual retries
  if command -v wget >/dev/null 2>&1; then
    for i in 1 2 3; do
      # Try normal TLS first
      wget -T 15 -O "${TMP}" "${URL}" && return 0
      # Fallback if CA bundle missing
      wget -T 15 --no-check-certificate -O "${TMP}" "${URL}" && return 0
      sleep 2
    done
  fi

  return 1
}

if [ ! -d "${CONF_DIR}" ]; then
  log "ERROR: ${CONF_DIR} not found. Run install.sh first."
  exit 1
fi

log "Waiting for network..."
if ! require_net; then
  log "WARN: WAN seems down; will use existing list if present."
fi

log "Downloading blocklist..."
if fetch_blocklist "${LIST_URL}" "${LIST_FILE}"; then
  mv -f "${LIST_FILE}.tmp" "${LIST_FILE}"
  log "Blocklist downloaded to ${LIST_FILE}"
else
  log "WARN: download failed; keeping existing ${LIST_FILE} if exists."
  [ -f "${LIST_FILE}" ] || { log "ERROR: No list available to enable."; exit 1; }
fi

log "Restarting dnsmasq..."
service dnsmasq restart || /etc/init.d/dnsmasq restart

log "Adblock-lite is ON."
log "Test: nslookup ads.google.com 127.0.0.1  (expect NXDOMAIN or 0.0.0.0 tùy list)"
