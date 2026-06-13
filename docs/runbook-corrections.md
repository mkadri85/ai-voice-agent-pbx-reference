# Source-Doc Corrections

Errors found while cross-checking the two source HTML docs (`ITBUILDRUNBOOK.html`,
`flowrisksbottlenecks.html`) and during the actual build. Fix these in the source material.

1. **Asterisk version pin** — the installer reads env var **`ASTVERSION`** (`ASTVERSION=21 bash ...`),
   default 22. The runbook's `--asteriskversion=21` CLI flag is **wrong** (confirmed by reading
   `sng_freepbx_debian_install.sh`). Default 22 is fine if not pinning.

2. **FreePBX installer purges ufw** — neither doc warns that the installer removes ufw and ships an
   open iptables stack. Re-apply ufw after install (see network-firewall.md / `pbx-firewall` skill).

3. **Phase 9 port 80** — runbook says open `http://<ip>` but the firewall only allows 443 → use
   `https://` or open 80 explicitly. (The box redirects http→setup anyway; UI works on https.)

4. **Phase 13 sign-off missing privacy check** — add acceptance **A7** (EL audio-saving OFF + retention
   verified). Critical for a hotel; absent from the runbook checklist.

5. **04-backup.sh remote retention** — `find ... -mtime +14 -delete` prunes only LOCAL backups; the
   REMOTE target is never pruned (grows unbounded). Add remote-side pruning.

6. **`fwconsole backup` syntax** — the two docs disagree (`--backup=$(...)` vs `--backup --transaction`).
   Verify against `fwconsole backup --help` on v17, or create the backup job in the UI first.

7. **Debian ISO link** — analysis SBOM links to `/current/` which now serves **Debian 13** (FreePBX 17
   rejects it). The runbook correctly pins **12.14.0** with SHA256 — back-port that fix to the analysis.

8. **Asterisk under FreePBX** — `systemctl is-active asterisk` reports **inactive** even when Asterisk
   is running (FreePBX manages it via `fwconsole`). Check with `pgrep -x asterisk` / `fwconsole status`.
   Worth noting so nobody "fixes" a non-problem.

9. **HTTPS (443) drops after a reload** — FreePBX auto-generates `/etc/apache2/ports/ports.conf` with
   only http ports (80–84, 6002) and **omits `Listen 443`**, so after a `fwconsole reload`/module
   update Apache stops binding 443 (browser: "Unable to connect" while the IP still pings; http still
   works). Fix (durable): a SEPARATE file `/etc/apache2/ports/ssl-443.conf` containing
   `<IfModule ssl_module>Listen 443</IfModule>` — pulled in by `Include ports/*.conf`, survives
   regeneration. Applied 2026-06-07. Cert is self-signed (snakeoil) → browser warning is expected on
   the LAN; install a real cert before production.
