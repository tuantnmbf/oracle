#!/bin/sh
set -eu

CONF_DIR="/etc/dnsmasq.d"
#LIST_URL="https://raw.githubusercontent.com/hagezi/dns-blocklists/main/dnsmasq/pro.mini.txt"
LIST_URL="https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/dnsmasq/pro.plus.mini.txt"
LIST_FILE="${CONF_DIR}/adblock.conf"

log() { echo "[update] $*"; }

fetch_blocklist() {
  URL="$1"
  OUT="$2"
  TMP="${OUT}.tmp"

  if command -v uclient-fetch >/dev/null 2>&1; then
    for i in 1 2 3; do
      uclient-fetch -T 15 -O "${TMP}" "${URL}" && return 0
      sleep 2
    done
  fi

  if command -v wget >/dev/null 2>&1; then
    for i in 1 2 3; do
      wget -T 15 -O "${TMP}" "${URL}" && return 0
      wget -T 15 --no-check-certificate -O "${TMP}" "${URL}" && return 0
      sleep 2
    done
  fi

  return 1
}

mkdir -p "${CONF_DIR}"

if fetch_blocklist "${LIST_URL}" "${LIST_FILE}"; then
  mv -f "${LIST_FILE}.tmp" "${LIST_FILE}"
  log "List updated."
  service dnsmasq restart || /etc/init.d/dnsmasq restart
  log "dnsmasq restarted."
else
  log "WARN: update failed; keeping existing list."
fi
