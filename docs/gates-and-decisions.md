# Blocking Gates & Open Decisions

No trunk work or live call test until these close. The box is healthy and the base build is done
without them.

## Decisions (user)
- **D1 — Host:** wipe → Debian 12 bare-metal. ✅ done.
- **D2 — Phased pilot (Option 1):** build on current single-disk / flat-network, prove usability,
  THEN assess upgrades. ✅ agreed. (See ../PROCUREMENT-AND-UPGRADE.md)
- **D3 — Network:** ⛔ OPEN — stay on flat 10.0.0.x or move to segmented VLANs? Drives the real
  firewall + final IP.
- **D4 — Sera scope (user decision):** **FULL-SERVICE** like N8N — collects room numbers + submits
  service requests (housekeeping/maintenance/etc.) to an internal webhook, reuses N8N's RAG + Claude
  Sonnet 4.5. ⚠️ Crosses the "no guest PII to EL" guardrail → **requires hotel G6 sign-off before live
  guest traffic**, and the **internal webhook endpoint must be built** (replacing external n8n). Hard
  limits remain: no payment/card, passport/ID, or booking-charge (those → human transfer).

## Vendor / ElevenLabs gates
| Gate | What | Owner | Status |
|------|------|-------|--------|
| G0 | OXE call-server release | — | ✅ RESOLVED — R12.2 (modern; TLS/SRTP + REFER supported) |
| G1 | OXE SIP-trunk license active + free channel count (incl. dial-back doubling) | ALE vendor | ⛔ open |
| G2 | TLS/SRTP enabled on the internal trunk (else UDP/RTP confined to VLAN) | ALE vendor | ⛔ open |
| G3 | Transfer method validated OXE-side (dial-back vs REFER) | ALE vendor + Asterisk | ⛔ open |
| G4 | Codec + DTMF compatibility end-to-end (G.711 a-law + RFC2833) | Asterisk eng | ⛔ open |
| G5 | ElevenLabs trunk creds, plan tier vs peak concurrency, privacy (audio-off/retention) | project + EL admin | 🟡 in progress — MCP connected; tier=**starter** (verify concurrency cap vs hotel peak); existing agent "N8N" + number <NUMBER> present (don't touch); create separate hotel agent + trunk |
| G6 | Transcript retention & hotel policy sign-off | hotel compliance | ⛔ open |
| G7 | Extension/ring-group numbers + Asterisk owner + firewall approver + **OXE access IP & account** | hotel IT + ALE | ⛔ open — hotel PBX is on **another IP with its own account**; hotel to provide BOTH the access IP and account/creds later |
| G8 | Redundancy hardware (2nd SSD/RAID1 + UPS + cold-standby) | hotel IT / procurement | ⏳ deferred (phased) |

## Values needed (fill into templates when gates close)
- `<OXE_IP>` (G1/G7) · `<RECEPTION_EXT>=100` `<HK_EXT>=200` `<RESV_EXT>=300` `<DUTY_EXT>=400`
  `<OPERATOR>=0` (placeholders — confirm via G7) · `<EL_SIP_USERNAME>` `<EL_SIP_PASSWORD>`
  `<EL_NUMBER>` (G5) · `<ADMIN_CIDR>` (D3/G7) · `<BACKUP_TARGET_IP>` (D3) · `<ALERT_EMAIL>` + SMTP relay.

## Next actionable steps (no external dependency)
1. FreePBX first web setup: create admin account (browser, `https://10.0.0.10/admin`).
2. SIP lockdown: Allow Anonymous = No, Allow Guests = No, RTP 10000–20000; update modules. (`fwconsole`)
3. Disk-alert email: smartd + msmtp (needs alert address + SMTP relay).
4. Then: D3 network → real firewall; gates G1–G7 → apply trunks (`pbx-trunks`) → call test (`pbx-go-live`).
