#!/usr/bin/env bash
# Teardown — run once the ElevenLabs agent + SIP trunk are configured, so the API key
# and MCP do not live on the production PBX permanently (install -> use -> remove).
set -euo pipefail
claude mcp remove elevenlabs 2>/dev/null || true
# optional deeper cleanup (uncomment to fully remove):
# sed -i '/^EL_API_KEY=/c\EL_API_KEY=' /root/pbx-build/.secrets/elevenlabs.env   # blank the key, keep SIP creds
# rm -rf /root/.cache/uv                                                          # drop cached package
echo "[OK] elevenlabs MCP removed. Restart Claude Code to drop the tools."
echo "NOTE: keep the SIP creds in .secrets/elevenlabs.env — those go into the Asterisk trunk."
