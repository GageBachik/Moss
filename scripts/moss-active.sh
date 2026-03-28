#!/bin/bash
# Moss Active -- Persistent session for tight build/eval loops
# Launched by heartbeat when active builds exist
# Self-terminates when no active work remains

set -euo pipefail
source ~/.zprofile_moss 2>/dev/null || true
unset ANTHROPIC_API_KEY  # Force Max plan OAuth, never use API credits

SESSION_NAME="moss-active"

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "Moss Active session already running"
  exit 0
fi

# Launch new tmux session with Claude Code
tmux new-session -d -s "$SESSION_NAME" -c ~/moss "claude --dangerously-skip-permissions --mcp-config ~/moss/config/mcp-servers.json -p \"$(cat <<'PROMPT'
You are the Moss Active Orchestrator. You run in a persistent session for tight build/eval loops.

READ FIRST:
1. ~/moss/CLAUDE.md
2. All concept files in ~/moss/pipeline/concepts/*.json

YOUR JOB:
- Monitor concepts in 'designing-building' and 'evaluating' stages
- For 'designing-building': The Designer-Builder subagent is working. Monitor progress.
- For 'evaluating': Spawn the Eval subagent to QA the build.
- When Eval returns 'fail': Move concept back to 'designing-building' with eval report, spawn Designer-Builder to fix issues.
- When Eval returns 'pass': Move concept to 'content-creating'.
- Use /loop 15m to poll for changes every 15 minutes.

SELF-TERMINATION:
- After each poll, check if ANY concept is in 'designing-building' or 'evaluating'.
- If NONE: Write a final status update and exit. The heartbeat will not relaunch you until new builds appear.

LIFECYCLE CONTROL:
- You can kill stuck subagents: if a Designer-Builder or Eval agent hasn't updated in 30 minutes, kill and restart it.
- If you encounter a problem you can't fix after 2 attempts, escalate via Dispatch.

FIRST-RESPONDER:
- If a subagent reports a missing tool or MCP server, try to install/fix it before restarting the subagent.
- If iPhone mirroring is unresponsive, restart it before retrying.
- If Xcode build environment has issues, diagnose and fix (clean build, install deps) before re-spawning.
PROMPT
)\""

echo "Moss Active session launched in tmux session: $SESSION_NAME"
