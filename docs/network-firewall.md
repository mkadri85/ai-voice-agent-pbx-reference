# Network & Firewall

## Current state (pilot)
- Box on **flat LAN**: `10.0.0.10/24`, gw `10.0.0.1`, DNS `1.1.1.1`, iface `eno1`.
- This is NOT the designed segmented VLAN layout — it's the existing network. Decision pending.

## Target design (after the network decision)
| Element | Zone | Address (design placeholder) | Notes |
|---|---|---|---|
| Alcatel OXE R12.2 | VLAN 1 PBX | `10.10.10.10` | static peer; SIP 5060/udp + RTP |
| Asterisk middleware | VLAN 2 | `10.10.20.10/24` gw `.1` | only egress host |
| IT admin / backup | VLAN 3 mgmt | `10.10.30.0/24` | SSH+HTTPS only; SFTP backup |
| ElevenLabs SIP | Internet (out) | `sip.rtc.elevenlabs.io` | dynamic IPs · TLS 5061 |

## Firewall — CURRENT (interim, ufw authoritative)
- ufw **default-DENY incoming**, **allow outgoing** (egress lockdown deferred to the network decision).
- Inbound allowed: **22 / 443 / 80 from `10.0.0.0/24`** (current LAN) — INTERIM, replace with ADMIN_CIDR.
- fail2ban jails layered on top (asterisk/ssh/apache/pbx-gui/recidive...).
- `netfilter-persistent` **disabled** so the installer's open ruleset isn't restored at boot.

### ⚠ The ufw gotcha (important)
The FreePBX installer **purges ufw** and installs its own open iptables stack. After any installer
re-run, ufw will be gone — re-apply with the **`pbx-firewall`** skill. (This is why `netfilter-persistent`
is disabled and ufw is made authoritative.)

## Firewall — TARGET (production, after network + gates)
Replace the interim rules with the allowlist (default-deny in AND out):
```
# inbound
allow from <OXE_IP>      to any port 5060 proto udp          # OXE signalling
allow from <OXE_IP>      to any port 10000:20000 proto udp   # OXE RTP
allow from <ADMIN_CIDR>  to any port 22  proto tcp           # SSH (mgmt)
allow from <ADMIN_CIDR>  to any port 443 proto tcp           # FreePBX UI
# outbound (lock egress)
allow out 53 ; allow out 123/udp ; allow out 80,443/tcp      # DNS · NTP · apt
allow out 5061/tcp                                           # SIP-TLS -> ElevenLabs
allow out 10000:60000/udp                                    # SRTP media -> ElevenLabs
default deny outgoing
```
Set `OXE_IP` and `ADMIN_CIDR` from gates G7/G1. Apply via the `pbx-firewall` skill (production mode).
