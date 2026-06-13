# Project Documentation — Index

AI Voice Agent Middleware · the hotel · Phase 1 production pilot.

| Doc | What's in it |
|-----|--------------|
| [architecture.md](architecture.md) | System purpose, trust zones, call flow, guardrails |
| [call-flow-options.md](call-flow-options.md) | **For management** — the 3 Sera call-flow options + phased rollout (2→3→1) |
| [network-firewall.md](network-firewall.md) | Addressing plan, current vs target firewall, the ufw gotcha |
| [gates-and-decisions.md](gates-and-decisions.md) | Blocking gates G1–G8, open decisions, owners |
| [oxe-trunk-bringup.md](oxe-trunk-bringup.md) | **Vendor request message** + OXE trunk bring-up steps (OXE=172.16.0.5) |
| [test-plan.md](test-plan.md) | Go-live acceptance criteria A1–A7 + how to test each |
| [runbook-corrections.md](runbook-corrections.md) | Errors found in the source HTML docs |

Living state (update as you go): [`../BUILD-STATUS.md`](../BUILD-STATUS.md)
Upgrade/procurement: [`../PROCUREMENT-AND-UPGRADE.md`](../PROCUREMENT-AND-UPGRADE.md)
Source material: the two HTML docs `ITBUILDRUNBOOK.html` and `flowrisksbottlenecks.html` (uploads).

**For any new agent:** read `/root/CLAUDE.md` → this index → BUILD-STATUS.md. Use the `pbx-*` skills.
