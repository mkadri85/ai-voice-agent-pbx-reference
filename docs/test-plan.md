# Go-Live Acceptance Test Plan

Run before declaring the pilot live. Each maps to an acceptance criterion from the analysis.

| # | Test | Pass condition |
|---|------|----------------|
| A1 | **Press-2 → AI** | Caller presses 2 on OXE IVR, AI answers clearly, handles a basic question end-to-end. |
| A2 | **Department transfer** | AI transfers correctly to each dept via dial-back; mapping verified (Recep/HK/Resv/Duty/Op). |
| A3 | **Failover** | Disable the EL trunk → call reaches Reception within the timeout (5–8 s). |
| A4 | **Security** | No inbound from internet; anon/guest SIP rejected; fail2ban bans brute force; EL cannot reach OXE. |
| A5 | **Power-cut** | Pull power → box auto-boots (BIOS restore-on-AC) and services return unattended (incl. firewall). |
| A6 | **DR drill** | Restore config onto a fresh/standby disk within target window (< 4 h). |
| A7 | **Privacy** | ElevenLabs audio-saving OFF & retention verified in the EL console. *(missing from the runbook — don't skip)* |

## Health checks (run on the box)
```
fwconsole --version
asterisk -V
asterisk -rx "core show version"
asterisk -rx "timing test"            # expect timerfd working
asterisk -rx "pjsip show endpoints"   # oxe + elevenlabs listed (after trunks applied)
asterisk -rx "pjsip show aors"        # elevenlabs AOR qualifies Avail
systemctl is-active freepbx apache2 mariadb chrony fail2ban smartd
ufw status verbose                    # default deny + allowlist
pgrep -x asterisk                     # asterisk runs under fwconsole (systemd unit shows inactive — normal)
cat /proc/mdstat 2>/dev/null          # if RAID1 fitted: "active raid1"
```
Use the **`pbx-status`** skill to run the read-only subset; **`pbx-go-live`** to walk A1–A7.

## Bottlenecks to watch during the pilot (feed the upgrade review)
EL workspace concurrency cap · OXE licensed channels (2 legs per transferred call) · WAN to EL
(call quality) · single-box availability · aging SSD · failover detection latency (keep the pre-dial
DEVICE_STATE check + tight timeout).
