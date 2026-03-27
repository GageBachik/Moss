#!/bin/bash
# Moss Dispatch -- Send iMessage to human operator
# Usage: bash dispatch.sh "your message here"
# Rate-limited: max 1 message per 5 minutes with same content
# Fallback 1: osascript (Messages.app AppleScript)
# Fallback 2: write to unsent file (never spawns claude -p to avoid fork bombs)

set -euo pipefail
source ~/.zprofile_moss 2>/dev/null || true
unset ANTHROPIC_API_KEY  # Force Max plan OAuth, never use API credits

LOG_DIR="$HOME/moss/logs"
LOG_FILE="$LOG_DIR/dispatch.log"
RATE_FILE="$LOG_DIR/.dispatch-last"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# --- Validate inputs ---

MESSAGE="${1:-}"
if [ -z "$MESSAGE" ]; then
  echo "[$TIMESTAMP] ERROR: No message provided. Usage: bash dispatch.sh \"your message\"" | tee -a "$LOG_FILE"
  exit 1
fi

# --- Rate limit: skip if same message sent in last 5 minutes ---

MSG_HASH=$(echo "$MESSAGE" | md5 -q 2>/dev/null || echo "$MESSAGE" | md5sum | cut -d' ' -f1)
if [ -f "$RATE_FILE" ]; then
  LAST_HASH=$(head -1 "$RATE_FILE" 2>/dev/null || echo "")
  LAST_TIME=$(tail -1 "$RATE_FILE" 2>/dev/null || echo "0")
  NOW=$(date +%s)
  DIFF=$((NOW - LAST_TIME))
  if [ "$MSG_HASH" = "$LAST_HASH" ] && [ "$DIFF" -lt 300 ]; then
    echo "[$TIMESTAMP] RATE-LIMITED (same message within 5min): $MESSAGE" >> "$LOG_FILE"
    exit 0
  fi
fi
echo "$MSG_HASH" > "$RATE_FILE"
date +%s >> "$RATE_FILE"

# --- Send via osascript (primary for scripts) ---

send_osascript() {
  local CONTACT="${DISPATCH_CONTACT:-loser@gagebachik.com}"
  osascript <<EOF
tell application "Messages"
  set targetService to 1st account whose service type = iMessage
  set targetBuddy to participant "$CONTACT" of targetService
  send "$MESSAGE" to targetBuddy
end tell
EOF
}

# --- Attempt delivery ---
# NOTE: Never use claude -p here — it spawns a full process and can cause fork bombs
# when called from subagents that are already in retry loops.

if send_osascript 2>/dev/null; then
  echo "[$TIMESTAMP] SENT (osascript): $MESSAGE" >> "$LOG_FILE"
else
  echo "[$TIMESTAMP] UNSENT (osascript failed): $MESSAGE" >> "$LOG_FILE"
  echo "[$TIMESTAMP] $MESSAGE" >> "$HOME/moss/briefings/unsent-dispatch.txt"
fi
