# Production-Readiness Audit — 2026-06-07

Full-system check of `pbx-middleware`. Verdict: **solid pilot foundation, NOT production-ready yet.**
The base build is healthy; production status is blocked by pending decisions, vendor gates, and the
deferred redundancy hardware. Scorecard below.

## ✅ Solid
- OS Debian 12 current; kernel ok; UEFI; clock owned by **chrony**, synced (<local timezone>).
- Core services **active AND enabled at boot**: freepbx, apache2, mariadb, chrony, fail2ban, smartd,
  unattended-upgrades. (`asterisk` systemd unit is disabled/inactive **by design** — FreePBX runs it
  via fwconsole; process confirmed running.)
- Firewall **enforcing**: ufw INPUT policy DROP, LAN-only allow, fail2ban (8 jails) layered, ufw
  systemd unit now active + enabled, netfilter-persistent disabled (no open ruleset restored at boot).
- Asterisk 22.8.2 up; timerfd timing works. FreePBX 17.0.28. Disk SMART **PASSED**; 211 G free; RAM/CPU
  hugely over-provisioned.
- **Fixed during audit:** disabled unused **H.323 (chan_ooh323)** listener on :1720; improved smartd
  test schedule.

## 🔴 Blockers — must close before "production"
| # | Finding | Why it blocks | Owner / unblocks |
|---|---------|---------------|------------------|
| ~~B1~~ | ~~No FreePBX admin account~~ → **DONE**: admin `fpbxadmin` created; SIP locked (anon=no, guest=no, RTP 10000–20000); modules updated | — | ✅ closed 2026-06-07 |
| B2 | **No trunks** (`pjsip endpoints=0`) | Can't place a call at all | Vendor/EL gates G1–G5,G7 |
| B3 | **No off-box backup scheduled** (cron=0) | No recovery path; DR fails | Needs backup target (network D3) |
| B4 | **Disk monitoring is blind** — no `/etc/msmtprc` | 10-yr SSD can fail silently | Needs SMTP relay + alert email |
| B5 | **No redundancy** — single disk, no RAID/UPS/standby | Single point of failure | Phased (G8) — buy after pilot |
| B6 | **Flat network, egress not locked** | Core guardrail (OXE isolation / sole-egress) not enforced at network layer | Network decision D3 |

## 🟠 Production hardening — should fix
- **H1 SSH:** password auth ENABLED + port 22 open to LAN (0 keys installed). fail2ban mitigates, but
  for production: install an admin key + set keys-only, OR keep strictly console-only and close 22.
  *(Deferred by you — local console. Revisit before production.)*
- **H2 Service binding:** all services listen on `0.0.0.0`/`*` and rely solely on ufw. Acceptable with
  default-deny, but bind the UI/UCP to the mgmt interface for defense-in-depth.
- **H3 Privacy (G6/A7):** ElevenLabs audio-saving OFF + retention — verify in the EL console (off-box).
- **H4 BIOS (A5):** confirm at console: Restore-on-AC = On, Sleep = Off — required for power-cut
  auto-recovery. Cannot be verified from the OS.

## Acceptance status (test-plan A1–A7)
A1–A3 (call/transfer/failover): **blocked** (no trunks). A4 (security): partial — firewall good, but
SSH/privacy open. A5 (power-cut): **unverified** (BIOS + UPS). A6 (DR): **not possible** (no backup).
A7 (privacy): **unverified**. → No acceptance test currently passes end-to-end.

## In-my-control fixes available now (no external dependency)
- Apply staged smartd config + (once you give SMTP relay) wire real email alerting.
- SSH hardening (install key + keys-only) — if you want it.
- Help create the FreePBX admin account + lock SIP defaults + update modules.
Everything else needs: **D3 network**, **vendor/EL gates**, or **G8 hardware**.
