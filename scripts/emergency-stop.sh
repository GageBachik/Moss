#!/bin/bash
# Moss Emergency Stop
# Kills all Moss processes, freezes pipeline, sends Dispatch alert

set -euo pipefail

echo "MOSS EMERGENCY STOP"

# Kill Moss Active tmux session
if tmux has-session -t moss-active 2>/dev/null; then
  tmux kill-session -t moss-active
  echo "  Killed moss-active session"
fi

# Kill any running Claude processes in ~/moss context
pkill -f "claude.*moss" 2>/dev/null && echo "  Killed Claude processes" || echo "  No Claude processes found"

# Set halted state
cd ~/moss
python3 -c "
import json
from datetime import datetime, timezone
state = {
    'halted': True,
    'haltedAt': datetime.now(timezone.utc).isoformat(),
    'lastRun': None,
    'activeSubagents': [],
    'pendingActions': [],
    'restartLog': []
}
with open('orchestrator-state.json', 'w') as f:
    json.dump(state, f, indent=2)
"

echo "  Pipeline frozen -- orchestrator-state.json set to halted"
echo ""
echo "To resume: send 'moss resume' via Dispatch, or run:"
echo "  cd ~/moss && python3 -c \"import json; d=json.load(open('orchestrator-state.json')); d['halted']=False; json.dump(d,open('orchestrator-state.json','w'),indent=2)\""
