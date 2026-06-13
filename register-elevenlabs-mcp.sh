#!/usr/bin/env bash
# Registers the official ElevenLabs MCP with Claude Code, reading the key from the
# locked secrets file (so the key never appears in chat/command history output).
# Run AFTER putting EL_API_KEY into /root/pbx-build/.secrets/elevenlabs.env
set -euo pipefail
source /root/pbx-build/.secrets/elevenlabs.env
: "${EL_API_KEY:?EL_API_KEY is empty in .secrets/elevenlabs.env — add the scoped key first}"
claude mcp remove elevenlabs 2>/dev/null || true
claude mcp add elevenlabs -e ELEVENLABS_API_KEY="$EL_API_KEY" -- /root/.local/bin/uvx elevenlabs-mcp
echo "[OK] elevenlabs MCP registered (user scope)."
echo ">>> RESTART Claude Code so the elevenlabs tools load into the session. <<<"
