# Procurement & Upgrade Plan — phased

## Decision (agreed)
Run the system on the **current single-disk / current-network setup** to prove it works and is
usable (the pilot). **Then** assess what to upgrade, based on what we actually observe — instead of
buying hardware up front. Nothing below blocks the pilot; it's the "step 2" shopping + review list.

---

## What to buy later (when we decide to harden for production)

### 1. Second SSD  — for RAID1 disk mirroring (protects against drive death)
- **Why:** the current drive is healthy but ~10 years old (88k power-on hours). A mirror means if
  one drive dies, the system keeps running with no data loss.
- **What to order:** a brand-new **2.5" SATA SSD, 256 GB or larger** (a modern 480/500 GB is fine and
  cheap — the mirror just uses the smaller drive's size). **Do NOT** buy another old/used drive.
- **Before ordering, confirm on this Lenovo ThinkCentre M93p:** one free **SATA data port**, a spare
  **SATA power lead**, and a **2.5" drive bay/bracket**. (M93p chassis are small — bay/port space is
  limited; check inside first.)
- **Note:** RAID1 is cleanest to build at install time, so the plan is: when the 2nd drive arrives,
  reinstall onto the mirror and **restore the saved FreePBX config** (no rework lost).

### 2. UPS battery — for power cuts (keeps it alive / shuts down cleanly)
- **Why:** lets the box ride through short outages and shut down safely; combined with the BIOS
  "restore on AC power" setting, it auto-powers-back-on when mains returns.
- **What to order:** a small **line-interactive UPS, ~650–900 VA**, with a USB cable (so the box can
  see it). That's ample for one low-power desktop doing voice.

### 3. Cold-standby spare box — for total hardware failure
- **Why:** if the whole PC dies, you swap to a spare and restore — back in service in hours, not days.
- **What to order:** any reliable small PC that can run Debian 12 (≥4 GB RAM, ≥40 GB disk). It just
  sits imaged and shelved. Doesn't need to match the i7-4770.

---

## Upgrade assessment — review AFTER the pilot (decides if/what we actually need)
Run the pilot for a representative period, then check:
- **Call volume:** what's the real peak number of simultaneous AI calls? (sizes the ElevenLabs plan)
- **Load:** CPU / RAM under that peak (expected: very low on an i7-4770 — confirm).
- **Call quality:** any choppy audio / latency to ElevenLabs over the hotel internet?
- **Disk wear trend:** re-check SMART vs. today's baseline — is the old SSD degrading?
- **Outage behaviour:** did the "press 2 → fallback to Reception" path work every time?
- **Then prioritise:** RAID1 → UPS → standby → network segmentation (VLAN) + egress lockdown.

Baseline for the disk comparison is saved at: `/root/pbx-build/smart-baseline-sda.txt`
