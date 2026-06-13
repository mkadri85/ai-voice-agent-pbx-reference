# OXE ↔ Middleware SIP Trunk — Vendor Request & Bring-up

## A. Message to forward to the Alcatel (ALE) vendor / hotel telecom
*(copy-paste; fill nothing — they fill the blanks)*

> We are connecting an on-prem AI voice middleware (FreePBX/Asterisk, IP **10.0.0.10**) to the
> OmniPCX Enterprise (SIP server **172.16.0.5**, R12.2) over an internal SIP trunk. The middleware is
> reachable from the OXE and vice-versa (confirmed: ping 0.46 ms, TCP 5060 open). Please set up / confirm:
>
> 1. **SIP trunk** between OXE `172.16.0.5` ⇄ middleware `10.0.0.10`.
> 2. **Whitelist `10.0.0.10`** in the OXE's SIP security so our signalling isn't blocked.
> 3. **Auth:** IP-based **static peer** (no registration / no username-password) — please confirm.
> 4. **Transport:** **UDP 5060** preferred — please confirm UDP or TCP.
> 5. **Codec:** **G.711 a-law**; **DTMF:** RFC2833.
> 6. **SIP-trunk license:** confirm it's active and how many **free channels** (each AI call + each
>    transfer-back uses channels — budget for doubling).
> 7. **Entry point (confirmed ours for testing):** extension **<EXT>** / DID **<DID>** is the
>    **dedicated test line assigned to us** (callable inside as <EXT>, outside as <DID>). Please
>    **route calls to it over the SIP trunk to the middleware `10.0.0.10`.**
> 8. **Department extensions** for warm transfers (the AI hands callers back to a human via the trunk):
>    Reception ____ · Housekeeping ____ · Reservations ____ · Duty Manager ____ · Operator ____
> 9. Please **tell us once `10.0.0.10` is whitelisted** so we can run a safe "are-you-there" (SIP
>    OPTIONS) handshake test. **We will send no SIP to the OXE until you confirm whitelisting.**

## B. Values we still need (gate G7 / G1)
| Item | Value |
|---|---|
| OXE SIP server | `172.16.0.5` ✅ |
| Middleware | `10.0.0.10` ✅ |
| Transport (UDP/TCP) | ____ (vendor) |
| Auth (IP-static / userpass) | ____ (vendor) |
| AI entry number/extension | **<EXT>** / **<DID>** ✅ our dedicated TEST line → route to middleware |
| Reception / HK / Resv / Duty / Operator ext | ____ / ____ / ____ / ____ / ____ |
| SIP-trunk license + free channels | ____ |

## C. Our bring-up steps (once vendor confirms + whitelists us)
1. Fill department extensions into `templates/extensions_custom.conf` (transfer map).
2. Apply trunks: `pbx-trunks` skill copies `pjsip_custom.conf` (OXE=172.16.0.5 pre-filled, transport
   per vendor) + `extensions_custom.conf` → `/etc/asterisk/`, then `core restart now`.
3. **Controlled handshake test:** enable `qualify` on `oxe_aor` (or `asterisk -rx "pjsip send OPTIONS ..."`)
   → expect the OXE to reply (transport + reachability proven for real).
4. Production firewall (`pbx-firewall` mode B): allow `172.16.0.5` :5060 + RTP in; lock egress.
5. Test call per the agreed Phase-1 flow (overflow/after-hours) → AI answers → transfer → fallback.

## D. Already prepared (safe, no OXE traffic sent)
- `templates/pjsip_custom.conf`: OXE leg pre-filled with `172.16.0.5`, UDP **and** TCP transports
  staged, `qualify` left OFF with a note to enable only after whitelisting.
- ElevenLabs leg complete (trunk created, creds in `.secrets/`).
- Reachability verified by ping + TCP-port check only — **no SIP sent to the live OXE.**
