#!/usr/bin/env bash
# 04-backup.sh — config-only off-box backup.  STAGED — set DEST_HOST after VLAN decision.
# Schedule via cron @ 02:30 once the backup target exists:
#   30 2 * * *  /usr/local/sbin/04-backup.sh >> /var/log/pbx-backup.log 2>&1
set -euo pipefail
DEST_USER=backup
DEST_HOST=<BACKUP_TARGET_IP>     # mgmt-VLAN backup target — PENDING network decision
DEST_DIR=/srv/pbx-backups
STAMP=$(date +%Y%m%d-%H%M)
WORK=/var/backups/pbx/$STAMP
mkdir -p "$WORK"

# 1. FreePBX backup (config DB + dialplan).  NOTE: verify exact fwconsole 17 syntax
#    with `fwconsole backup --help`; the docs disagreed — create a backup job in the UI first.
fwconsole backup --backup --transaction 2>/dev/null || true

# 2. raw config + firewall + raid snapshot (belt-and-braces)
cp -a /etc/asterisk/pjsip_custom.conf /etc/asterisk/extensions_custom.conf "$WORK"/ 2>/dev/null || true
ufw status numbered > "$WORK/ufw.rules"
mdadm --detail --scan > "$WORK/mdadm.conf" 2>/dev/null || true
tar czf "$WORK.tgz" -C /var/backups/pbx "$STAMP"

# 3. push off-box over SFTP (keys-only)
sftp -b - "$DEST_USER@$DEST_HOST" <<EOF
put $WORK.tgz $DEST_DIR/
EOF

# 4. prune LOCAL > 14 days  (TODO: also prune the REMOTE side — neither doc did)
find /var/backups/pbx -name '*.tgz' -mtime +14 -delete
echo "[OK] backup $STAMP pushed to $DEST_HOST:$DEST_DIR"
