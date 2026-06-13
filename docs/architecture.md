# Architecture

## Purpose
Internal hotel callers reach an **ElevenLabs AI voice agent** for general info, with a reliable path
to a human. The middleware bridges the hotel PBX and ElevenLabs, owns all routing, and isolates the
PBX from the internet.

## Trust zones
- **VLAN 1 — PBX Voice:** Alcatel **OXE R12.2** (IVR, extensions, ring groups). The "press 2" IVR key
  routes via ARS over an internal SIP trunk to the middleware. OXE is a static-IP peer (no REGISTER).
- **VLAN 2 — Middleware:** this box. **FreePBX 17 / Asterisk 22**, Debian 12. The dialplan
  (`from-oxe`, `to-EL`, transfer map, fallback). **Only egress point.** UDP/RTP inside ↔ TLS/SRTP out.
- **Internet (outbound only):** **ElevenLabs** `sip.rtc.elevenlabs.io`, TLS 5061 + SRTP, G.711/G.722.
  Privacy: audio-saving OFF, minimal/zero retention.
- **VLAN 3 — IT Mgmt:** SSH (keys) + HTTPS UI + off-box backup target. No internet-facing admin.

> NOTE: the VLANs above are the **target** design. The box is currently on a **flat LAN 10.0.0.x**
> pending the network decision — see network-firewall.md.

## Call flow
1. Caller dials the service line → OXE IVR → presses **2** → ARS selects the internal SIP trunk.
2. OXE → Asterisk (`from-oxe`), UDP/RTP, G.711 a-law, RFC2833 DTMF.
3. Asterisk dials ElevenLabs over **TLS 5061 + SRTP**; AI answers (transport interworking inside↔out).
4. **Transfer:** AI requests a department → Asterisk **owns the transfer via dial-back** into an OXE
   extension (avoids fragile OXE-side SIP REFER).
5. **Fallback:** if ElevenLabs is down/slow (qualify-OPTIONS + 5–8 s timeout) → Reception → Operator.

## Guardrails (never violate)
- OXE never reaches the internet; middleware is the only egress.
- Routing/transfer logic lives in Asterisk (dial-back), not OXE REFER.
- AI failure must never affect normal PBX operation — deterministic fallback to Reception.
- No guest PII to ElevenLabs; no PMS/payment/booking path in the dialplan (Phase 1 scope).

## Key facts
- **OXE = R12.2** (confirmed) → TLS/SRTP + REFER are platform-supported (still must confirm licensed/
  enabled on this box — gate G2).
- ElevenLabs SIP forbids UDP signalling (TCP/TLS only); G.711 a-law matches the OXE.
- ElevenLabs concurrency is capped **per workspace** (e.g. Pro = 20) — a real ceiling; fallback absorbs
  overflow.
