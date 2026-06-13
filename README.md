# AI Voice Agent PBX Middleware

An on-premise middleware that connects an internal hotel phone system (Alcatel-Lucent OmniPCX Enterprise) to a cloud AI voice agent (ElevenLabs). It is built on FreePBX 17 and Asterisk 22 running on Debian 12, using pure SIP. A caller reaches the AI agent, which answers general questions and can hand the caller to a human department, with an automatic fallback to Reception if the AI is unavailable.

## What it does

- An internal caller reaches the AI voice agent through the existing PBX.
- The AI answers general information requests using a knowledge base.
- On request, the call is transferred to a human department through Asterisk dial back into the PBX.
- If the AI or the internet link is unavailable, the call falls back to a human automatically.

## Design principles

- The PBX never has a path to the internet. The middleware is the only host that egresses.
- Routing and transfer logic lives in Asterisk, not in fragile PBX side features.
- AI failure must never affect normal phone operation. Calls always reach a human.
- No payment, passport, or sensitive identity data is handled by the AI.

## Architecture

```
Caller  ->  Alcatel OmniPCX (PBX)  ->  Middleware (FreePBX / Asterisk)  ->  ElevenLabs AI agent
                                              |
                                    transfer dial back to a human department
```

- Internal leg: SIP over UDP with RTP voice, IP based trust between the PBX and the middleware.
- External leg: SIP over TLS with SRTP voice to the ElevenLabs agent.
- The middleware translates between the two and owns the call logic and the fallback.

See the network diagram and full communication matrix in `network-diagram.html`.

## Stack

- Debian 12 (Bookworm)
- FreePBX 17 and Asterisk 22 LTS
- Apache, MariaDB, PHP 8.2
- chrony, fail2ban, ufw, smartmontools, unattended upgrades
- ElevenLabs Conversational AI (voice agent and SIP trunk)

## Repository contents

| Path | Description |
| --- | --- |
| `BUILD-STATUS.md` | Live build state and history |
| `PROCUREMENT-AND-UPGRADE.md` | Hardware shopping list and post pilot upgrade plan |
| `docs/` | Architecture, network and firewall, gates and decisions, test plan, call flow options, trunk bring up, audit |
| `templates/` | Staged configuration for pjsip trunks, dialplan, backup, smartd, fail2ban |
| `network-diagram.html` | Network diagram and communication matrix |
| `Sera-AI-Voice-Explainer.html` | Plain language explainer for the hotel team |
| `register-elevenlabs-mcp.sh`, `remove-elevenlabs-mcp.sh` | Helper scripts |

Secrets and credentials are never stored in this repository.

## Status

Pilot. The end to end call path is working on a dedicated test line. Remaining items include human transfer extensions, production firewall lockdown, redundancy hardware, and privacy sign off. See `BUILD-STATUS.md` for the current state.
