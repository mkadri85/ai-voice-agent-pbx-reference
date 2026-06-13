# AI Voice Middleware — Machine Build Status

Host: Lenovo ThinkCentre M93p · i7-4770 · 16 GB · 1× 238 GB SSD (no RAID yet) · UEFI
OS:   Debian 12 (bookworm), hostname `pbx-middleware`
Decision: **Option 1, phased** — install FreePBX now on the current single-disk / current-network
setup, **prove usability first (pilot)**, THEN assess upgrades (RAID1, UPS, standby, VLAN).
See PROCUREMENT-AND-UPGRADE.md for the shopping + post-pilot review list.

## ✅ Done (this pass — base machine, network-independent)
- Packages: chrony, fail2ban, ufw, smartmontools, msmtp-mta, unattended-upgrades, mdadm
  (curl/wget/gnupg/ca-certificates already present).
- Clock: **chrony** owns time (systemd-timesyncd disabled). TZ <local timezone>, synchronized.
- Auto security updates: unattended-upgrades enabled.
- Folders: /var/backups/pbx (0700), /root/pbx-build (+ templates/).
- FreePBX 17.0.28 + Asterisk 22.8.2 + PHP 8.2.31 installed (Sangoma installer; log /var/log/pbx/).
  timerfd timing test PASSED (pure-SIP, no DAHDI). Web UI up (http/https, HTTP 302 to setup).
  NOTE: FreePBX runs Asterisk under fwconsole, so `systemctl is-active asterisk` = inactive is NORMAL.
- Firewall (INTERIM, ufw authoritative): ufw default-DENY inbound, outbound OPEN for build.
  Allowed inbound: 22/443/80 from 10.0.0.0/24 (current LAN) — replace with real ADMIN_CIDR later.
  IMPORTANT: the FreePBX installer PURGED ufw + added iptables-persistent (INPUT ACCEPT = open).
  Fix applied: reinstalled ufw, set INPUT policy DROP, layered fail2ban jails on top, and
  DISABLED netfilter-persistent so the open ruleset is NOT restored at boot (power-cut safe).
  ufw enabled for boot. fail2ban: 8 jails active (asterisk/ssh/apache/pbx-gui/recidive...).
- Disk: SMART baseline saved (smart-baseline-sda.txt). Health PASSED; 88,069 power-on hrs (~10 yr).
- FreePBX admin account created: **fpbxadmin** (temp pw issued — CHANGE on first login). ampusers seeded.
- SIP defaults LOCKED: Anonymous=no (ALLOW_SIP_ANON), Guest=no (allowguest), RTP range 10000–20000.
- Modules updated (fwconsole moduleadmin upgradeall). H.323/chan_ooh323 disabled (port 1720 closed).
- Audit: see docs/production-readiness-audit.md — verdict = healthy pilot, NOT production yet.
- ElevenLabs (G5/G6) via MCP: uv + official elevenlabs-mcp installed; MCP **connected & tested** (read-only
  OK). Secrets at .secrets/elevenlabs.env (700/600). Helpers: register-/remove-elevenlabs-mcp.sh.
  Plan = install→use→remove (don't leave API key on prod box). Tier = **starter** (G5 concurrency to verify).
  PRE-EXISTING on the account (DO NOT TOUCH): agent "N8N" (<OTHER_AGENT_ID>) + SIP number
  <NUMBER> ("DutyMobile").
  CREATED: hotel agent **"Sera"** (<AGENT_ID>) — voice Sarah (EXAVITQu4vr4xnSDxMaL),
  English, eleven_turbo_v2; privacy G6 DONE: record_voice=false, retention_days=0; no-PII system prompt.
  Sera scope = **FULL-SERVICE** (decision D4): reused N8N's RAG (2 docs) + **claude-sonnet-4-5** + merged
  full-service prompt (collects room#, submits requests; hard-limits payment/passport/booking → human).
  ⚠️ Crosses no-PII guardrail → needs hotel **G6 sign-off** before live guest traffic.
  Webhook WIRED (interim): tool_ids = Webhook-2S_Communication (<TOOL_ID> →
  external n8n host) + Time (<TOOL_ID>...). Switch to INTERNAL endpoint later (D4). Note: inline
  end_call dropped (EL forbids inline tools + tool_ids together) — re-add via dashboard later.
  SIP TRUNK: ✅ **CREATED** via API (correct schema found in the elevenlabs SDK: inbound_trunk_config +
  credentials). <PHONE_NUMBER_ID>, label "Sera-Hotel-Trunk", **assigned to Sera**,
  **digest auth** (user <SIP_TRUNK_USER> + pw), **media_encryption=required (SRTP)**, allowed_addresses
  0.0.0.0/0 (digest is the gate). Dial id (EL_NUMBER) = <EL_NUMBER>. Creds in .secrets/elevenlabs.env
  (EL_SIP_USERNAME/PASSWORD/NUMBER/PHONE_NUMBER_ID). Asterisk dials
  sip:<EL_NUMBER>@sip.rtc.elevenlabs.io:5061;transport=tls + digest + SRTP.
  → G5 trunk DONE. Remaining G5: plan/concurrency upgrade before front-door (Option 1).
  HARDENING (later): once network known, restrict inbound allowed_addresses to the middleware egress IP.
  Transfer stays **Asterisk dial-back** (NOT N8N's EL transfer-to-phone). Test Sera via EL "Test agent" widget.
  ⚠️ Webhook naming ambiguity: account has BOTH QMSnEmail (n8n-hostinger) and Webhook-2S_Communication
  (external n8n) — confirm which n8n is the live/correct one.
- OXE/PBX side (gate G7): the hotel's PBX is on **another IP with its own account** — hotel to provide
  BOTH the access IP and the account/creds LATER. Trunk + firewall to OXE stay deferred until then.
- **OXE access (G7, partial — received 2026-06-11):** OXE **SIP server = 172.16.0.5**; a number
  **<DID>** ↔ internal extension **<EXT>**. Reachability from middleware 10.0.0.10 **CONFIRMED**:
  ping 0.46ms, **TCP 5060 OPEN**, routes via gw 10.0.0.1 (2 hops). → OXE_IP for trunk = 172.16.0.5.
  Flat network already reaches OXE (VLAN now a security choice, not a connectivity blocker).
  ENTRY POINT CONFIRMED: ext **<EXT>** / DID **<DID>** = dedicated **TEST line assigned to us**
  (inside <EXT>, outside <DID>) → OXE routes it over the trunk to middleware 10.0.0.10. Safe to
  test against (isolated from real reception/guest traffic).
  STILL NEED: OXE trunk auth
  (IP-static-peer vs user/pass) + transport (UDP/TCP); dept extension numbers for dial-back; SIP-trunk
  license active (G1); codec (G.711 a-law). Did NOT send unsolicited SIP to the production OXE yet.
  PREPARED (safe, no OXE traffic): pjsip OXE leg pre-filled 172.16.0.5 + UDP&TCP transports + qualify
  OFF until whitelisted; vendor request + bring-up steps → docs/oxe-trunk-bringup.md.
- TRUNKS APPLIED (2026-06-12): /etc/asterisk/pjsip_custom.conf + extensions_custom.conf live.
  OXE endpoint loads, identifies 172.16.0.5 ✓ (reuses FreePBX 0.0.0.0-udp transport; added TLS:5061).
  Bug fixed: chan_pjsip needs **dtmf_mode=rfc4733** (NOT rfc2833 — template/doc error). EL qualify
  disabled (EL ignores OPTIONS — false "Unavailable").
- 🔴 **NEW BLOCKER — hotel perimeter firewall blocks outbound SIP.** Middleware (10.0.0.10) cannot
  reach ElevenLabs SIP at all: sip-static.rtc.elevenlabs.io (199.88.252.34) + sip.rtc.elevenlabs.io on
  TCP 5061/5060/443 ALL blocked; a public SIP server also blocked; meanwhile 1.1.1.1:443 / 8.8.8.8:53 /
  github:443 work. Our ufw = allow-outgoing (not the cause). CONFIRMED by port test: 1.1.1.1:443 OPEN
  0.02s but 1.1.1.1:5061 + 8.8.8.8:5060 TIMEOUT 6s → SIP ports filtered network-wide (not EL-specific,
  not a closed port, not our config). traceroute dies after gw 10.0.0.1 → 10.0.50.1. Possible SIP ALG.
  → **Hotel network team must allow
  10.0.0.10 → ElevenLabs SIP** (whitelist static IP 199.88.252.34, TCP/TLS 5061 + SRTP media UDP
  ~10000-60000). Until then Asterisk→Sera fails. OXE↔middleware leg is fine and testable independently.
  ✅ CONFIRMED BY LIVE CALL (2026-06-12): DID <DID> → OXE → trunk → middleware → played
  demo-congrats (heard). Alcatel routing + trunk signalling + audio path PROVEN. (Local only — not EL.)
- ✅✅ **SIP EGRESS OPENED + SERA ANSWERS (2026-06-12 ~17:57):** network team opened outbound SIP to
  ElevenLabs only (general SIP still blocked — secure). Controlled originate Asterisk→Sera: TLS verify
  OK → 407 (digest accepted) → 180 Ringing → **200 OK (Sera answered)**. Full chain works. Dialplan
  from-oxe switched from echo-test back to Dial(PJSIP/<EL_NUMBER>@elevenlabs). Ready for live call to
  <EXT> / <DID>. Fallback still a placeholder msg (dept dial-back pending extension numbers).
  ROBUSTNESS TODO: consider pointing EL contact at sip-static.rtc.elevenlabs.io (199.88.252.34) so a
  changing LB IP can't break it (both open now; LB used in the proven call).
- ✅✅✅ **TWO-WAY AUDIO FIXED (2026-06-12):** first real call = call connected but silent. Cause = NAT:
  middleware (10.0.0.10) is behind hotel NAT (public IP **203.0.113.10**); SDP advertised the private
  IP so EL sent Sera's audio nowhere. Fix: on [transport-tls] added external_media_address=203.0.113.10
  + external_signaling_address=203.0.113.10 + local_net=10.0.0.0/24, and direct_media=no on elevenlabs
  endpoint (Asterisk relays). Verified with Milliwatt originate: RTP Rx=299 / Tx=300 (audio both ways).
  Media firewall is OK (audio crosses). Ready for live two-way call to <EXT> / <DID>.
  NOTE: 203.0.113.10 is the hotel's public IP — if it ever changes, update external_*_address.
- ✅ MEDIA FIX #2 (2026-06-12): real bridged call still silent — SDP capture showed OXE **media** comes
  from **172.16.0.8** (media gateway) but ufw only allowed 172.16.0.5 (call server) → caller audio
  dropped by our own firewall → whole chain dead. Fix: ufw allow 172.16.0.0/24 (SIP+RTP). Addresses
  all verified correct (OXE←10.0.0.10, EL←203.0.113.10 public). Retesting.
- 🎉🎉🎉 **END-TO-END CALL WORKS (2026-06-12):** live call (inside <EXT> + outside <DID>) → Sera
  answers, full two-way conversation. ~60s call: RTP matched both legs (~3000 pkts each), **0 packet
  loss, ~0 jitter** — clean audio. Media chain proven. Remaining: conversational RESPONSE LATENCY
  (AI thinking time, not network) — tune via LLM model / turn-taking. Also pending: dept-extension
  transfers, production firewall lockdown, robustness (sip-static endpoint), G6 sign-off.
- ✅ LATENCY TUNED (2026-06-12): response delay "much better" after setting Sera turn_eagerness=eager +
  speculative_turn=true (kept Claude Sonnet 4.5). PILOT IS WORKING on the test line <EXT>/<DID>.
- Call-flow rollout DECIDED (phased **2→3→1**): Option 2 overflow/after-hours → Option 3 menu opt-in
  ("press 2") → Option 1 AI front door (end-goal). Same middleware dialplan supports all 3; per-phase
  change = Alcatel routing (G7) + EL concurrency. Front-door (Opt 1) needs EL plan upgrade (G5) + G6
  sign-off + instant press-0 escape. Management doc: docs/call-flow-options.md.

## 👤 Users
- `root` — sole admin (local console; no SSH hardening requested this phase).
- `asterisk` — service account, created by the FreePBX installer (verify post-install).
- No other users required for Phase 1. (Off-box `backup` user lives on the BACKUP TARGET host, not here.)

## ⏳ Pending — NETWORK decision (flat 10.0.0.0/24 vs designed VLAN 10.10.20.0/24)
- Final static IP (Phase 5 values).
- Real firewall allowlist (Phase 7): OXE_IP + ADMIN_CIDR inbound; lock egress to EL+DNS+NTP+repos.
  → Replace the three INTERIM 10.0.0.0/24 rules with the real ADMIN_CIDR.
- Backup target host (DEST_HOST in 04-backup.sh) + cron schedule.

## ⏳ Pending — VENDOR / ElevenLabs gates (G1–G8)
- G1/G2 OXE SIP-trunk license + TLS/SRTP enabled · G3 transfer method · G5 EL creds/tier/privacy
- G6 transcript policy · G7 extension numbers + firewall owner · G8 2nd SSD + UPS + cold-standby

## 📁 Staged templates (in templates/ — NOT applied; fill placeholders first)
- pjsip_custom.conf        → /etc/asterisk/  (after G1–G5 + IPs)   [needs `core restart now`]
- extensions_custom.conf   → /etc/asterisk/  (after G7 ext numbers)
- fail2ban-asterisk.local  → /etc/fail2ban/jail.d/  (AFTER asterisk installed)
- smartd.conf              → /etc/smartd.conf (set ALERT_EMAIL + /etc/msmtprc first)
- 04-backup.sh             → /usr/local/sbin/ (set DEST_HOST, then cron)

## ▶ Next steps (in order)
1. FreePBX first web setup: create admin account; Settings → Asterisk SIP Settings →
   Allow Anonymous Inbound SIP = No, Allow SIP Guests = No, RTP range 10000–20000; update modules.
2. Apply fail2ban jail + smartd (after setting ALERT_EMAIL + msmtp relay).
3. Resolve network (VLAN/IP) → set real IP + real firewall allowlist.
4. Close vendor/EL gates → fill + apply trunk templates → `core restart now`.
5. Procure 2nd SSD/UPS/standby → RAID1 install + restore (Option 1 path).

## ⚠ Doc corrections found during build (fix in the runbook)
- Asterisk pin = env var **`ASTVERSION=21`** (installer default 22). The runbook's
  `--asteriskversion=21` flag is WRONG — confirmed by reading the installer source.
- Phase 9 says open http:// but the firewall blocks port 80 → use https:// or open 80 explicitly.
- Runbook Phase 13 sign-off is MISSING a privacy/EL-audio-off check (analysis A7).
- 04-backup.sh prunes only LOCAL backups; remote side never pruned.
