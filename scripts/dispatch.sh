#!/bin/bash
# Moss Dispatch -- Send iMessage to human operator
# Usage: bash dispatch.sh "your message here"
# Primary: iMessage plugin via claude -p
# Fallback 1: osascript (Messages.app AppleScript)
# Fallback 2: Claude Desktop Bridge

set -euo pipefail
source ~/.zprofile_moss 2>/dev/null || true
unset ANTHROPIC_API_KEY  # Force Max plan OAuth, never use API credits

LOG_DIR="$HOME/moss/logs"
LOG_FILE="$LOG_DIR/dispatch.log"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
CHAT_ID="${DISPATCH_CHAT_ID:-any;-;loser@gagebachik.com}"

# --- Validate inputs ---

MESSAGE="${1:-}"
if [ -z "$MESSAGE" ]; then
  echo "[$TIMESTAMP] ERROR: No message provided. Usage: bash dispatch.sh \"your message\"" | tee -a "$LOG_FILE"
  exit 1
fi

# --- Primary: iMessage plugin via claude -p ---

send_imessage_plugin() {
  claude --dangerously-skip-permissions -p "Use the mcp__plugin_imessage_imessage__reply tool to send this message. chat_id: \"$CHAT_ID\", text: \"$MESSAGE\". Just send it, no commentary." 2>/dev/null
}

# --- Fallback 1: osascript ---

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

# --- Fallback 2: Claude Desktop Bridge ---

send_desktop_bridge() {
  if command -v claude-desktop-send &>/dev/null; then
    local CONTACT="${DISPATCH_CONTACT:-loser@gagebachik.com}"
    claude-desktop-send --new --approve-for 15 \
      "Open the Messages app. Send an iMessage to $CONTACT with this exact text: $MESSAGE" \
      2>/dev/null
  else
    return 1
  fi
}

# --- Attempt delivery ---

if send_imessage_plugin; then
  echo "[$TIMESTAMP] SENT (imessage-plugin): $MESSAGE" >> "$LOG_FILE"
elif send_osascript 2>/dev/null; then
  echo "[$TIMESTAMP] SENT (osascript): $MESSAGE" >> "$LOG_FILE"
elif send_desktop_bridge; then
  echo "[$TIMESTAMP] SENT (desktop-bridge): $MESSAGE" >> "$LOG_FILE"
else
  echo "[$TIMESTAMP] FAILED: All methods failed. Message: $MESSAGE" >> "$LOG_FILE"
  # Write to fallback file so message isn't lost
  echo "[$TIMESTAMP] $MESSAGE" >> "$HOME/moss/briefings/unsent-dispatch.txt"
  exit 1
fi
