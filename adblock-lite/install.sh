#!/bin/sh
set -eu

# ===== Config =====
CONF_DIR="/etc/dnsmasq.d"
BACKUP_DIR="/root/rollback-adblock-lite"
BACKUP_DHCP="${BACKUP_DIR}/dhcp"
STAMP_FILE="${BACKUP_DIR}/.backup_done"

LOCAL_ALLOW="${CONF_DIR}/ad-allowlist.conf"
LOCAL_DENY="${CONF_DIR}/ad-denylist.conf"

log() { echo "[install] $*"; }

log "Preparing directories..."
mkdir -p "${CONF_DIR}" "${BACKUP_DIR}"

# ===== Backup once (for rollback) =====
if [ ! -f "${STAMP_FILE}" ]; then
  log "Creating first-time backup to ${BACKUP_DIR} ..."
  cp /etc/config/dhcp "${BACKUP_DHCP}"
  cp /etc/dnsmasq.conf "${BACKUP_DIR}/dnsmasq.conf" 2>/dev/null || true
  cp -r /etc/dnsmasq.d "${BACKUP_DIR}/dnsmasq.d" 2>/dev/null || true
  date > "${STAMP_FILE}"
  log "Backup done."
else
  log "Backup already exists. Skipping."
fi

# ===== Apply dnsmasq UCI settings =====
log "Configuring dnsmasq to load ${CONF_DIR} ..."
uci set dhcp.@dnsmasq[0].confdir="${CONF_DIR}"

# Light tunings (an toàn cho RAM thấp)
uci set dhcp.@dnsmasq[0].cache_size='5000' 2>/dev/null || true
uci set dhcp.@dnsmasq[0].negcache='1' 2>/dev/null || true
uci set dhcp.@dnsmasq[0].domainneeded='1' 2>/dev/null || true
uci set dhcp.@dnsmasq[0].boguspriv='1' 2>/dev/null || true

uci commit dhcp

# ===== Create local allow/deny files (if missing) =====
if [ ! -f "${LOCAL_ALLOW}" ]; then
  cat > "${LOCAL_ALLOW}" <<'ALW'
# Whitelist domains (override block) – examples:
# server=/example-whitelist.com/#
# server=/bank.example.vn/#
ALW
  log "Created ${LOCAL_ALLOW}"
fi

if [ ! -f "${LOCAL_DENY}" ]; then
  cat > "${LOCAL_DENY}" <<'DNW'
# Blacklist domains (force block) – examples:
# address=/example-blacklist.com/0.0.0.0
# address=/ads.example.vn/0.0.0.0
DNW
  log "Created ${LOCAL_DENY}"
fi

log "Install complete. No adblock enabled yet."
log "Next step: run /root/adblock-lite/start.sh to download list and enable blocking."
