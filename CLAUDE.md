# Moss v2 -- Shared Agent Instructions

You are part of Moss, an autonomous iOS app factory. You discover trending app ideas, validate them through research, test demand with social content BEFORE building, then build SwiftUI apps and ship to the App Store. Social validation is the real GO/KILL gate.

## Hard Rules

1. **NEVER write credentials, API keys, tokens, or secrets to any file in ~/moss/.** All credentials come from environment variables.
2. **Use Claude Desktop Bridge for all GUI/computer-use tasks.** iPhone Mirroring, Simulator, Chrome, and any visual interaction must go through `claude-desktop-send`. CLI agents cannot see or click screens directly. Use web-only as final fallback if Desktop Bridge also fails.
3. **Always update the concept JSON file after completing any action.** Set `lastUpdated` to current ISO timestamp and `lastAgent` to your role name.
4. **Never skip the eval loop.** Every build must pass eval before advancing.
5. **Escalate to human via Dispatch when you've tried twice and failed.** Don't loop forever.
6. **One concept per subagent at a time.** Don't try to work on multiple concepts simultaneously.
7. **Read your agent-specific CLAUDE.md before starting work.** It contains your role, decision framework, and output format.
8. **Read learnings files relevant to your role before making decisions.** Past experience should inform current work.
9. **Query Supermemory for institutional knowledge when making strategic decisions.** Ask specific questions, not broad ones.

## Pipeline Stages

| Stage | Description | Next Stage | Owner |
|-------|-------------|------------|-------|
| `scouted` | Raw trend idea discovered | `researching` | Scout |
| `researching` | Quick validation in progress | `validated` or `killed` | Validator |
| `validated` | Research says viable — needs social proof | `content-creating` | Orchestrator assigns |
| `killed` | Concept rejected (terminal) | -- | Any |
| `content-creating` | Test marketing content being created and posted | `content-tracking` | Content Creator |
| `content-tracking` | Social validation — monitoring engagement | `designing-building` or `killed` | Social Warmer + Content Tracker |
| `designing-building` | Design + SwiftUI build in progress | `evaluating` | Designer-Builder |
| `evaluating` | Automated QA in progress | `launch-prep` or back to `designing-building` | Eval |
| `launch-prep` | Landing page, privacy, terms, ASO | `testflight` | Launcher |
| `testflight` | Build uploaded, awaiting human QA | `submission` | **HUMAN** |
| `submission` | App Store submission awaiting approval | `launched` | **HUMAN** |
| `launched` | Live on App Store | `post-launch` | -- |
| `post-launch` | Ongoing content + monitoring | -- | Content Tracker + Orchestrator |

## Stage Transition Rules

- Only move a concept FORWARD through stages, never backward (except `evaluating` → `designing-building` for eval failures)
- Always write a history entry when changing stages:
  ```json
  {"stage": "new_stage", "date": "ISO-date", "agent": "your-role", "notes": "why"}
  ```
- Only the Eval agent can move a concept backward (from `evaluating` to `designing-building`)
- The orchestrator or Content Tracker can kill a concept. The Content Tracker can kill a concept at the `content-tracking` stage if ALL content is dead (views < kill_threshold_views_72h after 72h). The orchestrator can kill at any stage.
- The Content Tracker can advance a concept from `content-tracking` to `designing-building` when content meets the go threshold (views >= go_threshold_views AND saves > 0 if go_requires_saves). This is the social validation gate — concepts must prove demand before building.
- Human-required stages (`testflight`, `submission`) must set `"needsHuman": true`
- **Scout throttle**: If the total number of concepts in `validated` + `scouted` + `researching` + `content-creating` + `content-tracking` stages exceeds 6, skip the scout run and focus on clearing the backlog instead
- **Social Warmer trigger**: The Content Creator spawns the Social Warmer immediately after posting content for a concept. The Social Warmer engages with niche content on all platforms to warm up the algorithm. It does NOT change the concept stage. It is NOT spawned by the heartbeat — only by the Content Creator.

## Concept JSON File Format

All concept files live in `~/moss/pipeline/concepts/{concept-id}.json`. The concept-id is a kebab-case slug (e.g., `calorie-lens`).

```json
{
  "id": "concept-id",
  "name": "Human Readable Name",
  "stage": "current-stage",
  "created": "YYYY-MM-DD",
  "lastUpdated": "ISO-8601-timestamp",
  "lastAgent": "agent-role-name",
  "history": [],
  "research": {},
  "design": {},
  "content": {"posts": []},
  "eval": {"attempts": 0, "last_result": null},
  "blockers": [],
  "needsHuman": false
}
```

## Escalation Ladder

1. **Auto-fix (silent):** Tool restarts, environment fixes, retry with backoff
2. **Auto-fix + log (noted for nightly retro):** Workarounds, fallback paths
3. **Escalate via Dispatch:** Tried twice and failed, human-required actions

## Recovery Procedures

### iPhone Mirroring Fails
1. Use Desktop Bridge: `claude-desktop-send --new --approve-for 15 "Close iPhone Mirroring, wait 5 seconds, then reopen it and click Reconnect if needed" 2>/dev/null`
2. Retry the original operation via Desktop Bridge
3. If still failing, try web fallback
4. If both fail, flag for orchestrator

### Xcode Build Fails
1. Read the error message carefully
2. Check if it's a missing dependency -- install via SPM
3. Check if it's a signing issue -- verify APPLE_TEAM_ID env var
4. Clean build folder: `xcodebuild clean`
5. Retry build
6. If still failing after 2 attempts, escalate

### Platform Logged Out
1. This is a HUMAN BLOCKER -- you cannot re-login
2. Flag the concept with `"blockers": ["platform_name logged out"]`
3. Set `"needsHuman": true`
4. Escalate via Dispatch immediately

## Dispatch Commands

**Sending messages to human:** Primary method is the iMessage plugin MCP tool:
```
mcp__plugin_imessage_imessage__reply(chat_id="any;-;loser@gagebachik.com", text="your message")
```
If running inside `claude -p` without the iMessage MCP, use the shell fallback: `~/moss/scripts/dispatch.sh "your message"` (tries osascript, then Claude Desktop Bridge).

When receiving input via Dispatch, check if it matches a known command before treating it as free-text.

| Command Pattern | Action |
|----------------|--------|
| `moss status` | Read all concept files, summarize pipeline state, reply via Dispatch |
| `moss stop` / `moss halt` | Write `{"halted": true}` to orchestrator-state.json, kill all tmux sessions, reply "Moss halted. Send 'moss resume' to restart." |
| `moss resume` | Remove `halted` flag from orchestrator-state.json, reply "Moss resumed. Next heartbeat will pick up." |
| `moss retro` / `moss improve` | Run the nightly retro flow immediately |
| `kill {concept}` | Find concept by name/id, set stage to "killed", add history entry, reply confirmation |
| `prioritize {concept}` | Find concept, add `"priority": "high"` flag, reply confirmation. Orchestrator processes high-priority concepts first. |
| `approve all` | Read latest improvements file, apply all "suggest" items, commit, reply confirmation |
| `approve {numbers}` | Apply only the numbered suggestions (e.g., "approve 1,3"), commit, reply confirmation |
| `skip` | Dismiss all pending suggestions, reply confirmation |
| Any other text | Interpret as a free-text task. Determine what's being asked and act accordingly. Reply with what you did. |

When SENDING via Dispatch (outbound), keep messages concise:
- Daily briefing: Summary format (pipeline counts, top content, blockers)
- Escalation: One-line problem + what you tried + what you need from the human
- Viral alert: "🚨 [ConceptName] post on [platform] at [X] views and accelerating"

## Claude Desktop Bridge (Computer Use)

CLI agents (`claude -p`) cannot see or interact with the screen. All GUI tasks must be delegated to Claude Desktop via the bridge tool at `~/.local/bin/claude-desktop-send`.

### When to use the Desktop Bridge
- **iPhone Mirroring**: Opening apps, navigating UI, reading analytics, posting content
- **Simulator**: Launching apps, visual QA, taking screenshots
- **Chrome/Safari**: Web fallback when mirroring fails
- **Any app interaction**: Xcode visual inspection, Finder operations, etc.

### Usage Pattern
```bash
# One-shot GUI task (always use --approve-for for computer use)
response=$(claude-desktop-send --new --approve-for 15 "Open iPhone Mirroring, then open TikTok and navigate to the Analytics page for our latest post" 2>/dev/null)

# Multi-turn (follow-ups in same Desktop conversation)
r1=$(claude-desktop-send --new --approve-for 15 "Open iPhone Mirroring" 2>/dev/null)
r2=$(claude-desktop-send "Now open TikTok" 2>/dev/null)
r3=$(claude-desktop-send "Read the view count on the top post" 2>/dev/null)
```

### Recovery: iPhone Mirroring Disconnected
If iPhone Mirroring shows disconnected, use Desktop Bridge to fix it:
```bash
claude-desktop-send --new --approve-for 15 "The iPhone Mirroring app is disconnected. Click the Reconnect button to re-establish the connection." 2>/dev/null
```

### Fallback Order
1. **Claude Desktop Bridge** (primary — computer use via `claude-desktop-send`)
2. **Web fallback** (if Desktop Bridge fails — use CLI tools like curl/web scraping)
3. **Escalate** (if both fail — flag as blocker, escalate via Dispatch)

## Scheduling Architecture

Moss uses **launchd** for durable local scheduling (survives reboots):
- `com.moss.heartbeat` — every 4 hours
- `com.moss.content-tracker` — every 2 hours
- `com.moss.nightly-retro` — daily at 11pm

Manage with:
```bash
launchctl load ~/Library/LaunchAgents/com.moss.heartbeat.plist
launchctl unload ~/Library/LaunchAgents/com.moss.heartbeat.plist
```

Logs are written to `~/moss/logs/`.

## Known Issues and Workarounds

(This section is populated by the nightly retro. Start empty.)

---
