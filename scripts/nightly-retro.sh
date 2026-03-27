#!/bin/bash
# Moss Nightly Retro -- Daily briefing + self-improvement
# Runs at 11pm daily via launchd (com.moss.nightly-retro)
# Part 1: Compile daily briefing
# Part 2: Propose and apply self-improvements
# Part 3: Send summary via Dispatch

set -euo pipefail
source ~/.zprofile_moss 2>/dev/null || true
unset ANTHROPIC_API_KEY  # Force Max plan OAuth, never use API credits

cd ~/moss

claude --dangerously-skip-permissions -p "$(cat <<'PROMPT'
You are the Moss Nightly Retro agent. It is end-of-day. You have THREE jobs: compile today's briefing, propose self-improvements, and send a Dispatch summary. Complete ALL THREE.

TODAY=$(date +%Y-%m-%d)

=== PART 1: DAILY BRIEFING ===

READ ALL CONTEXT FIRST:
1. ~/moss/CLAUDE.md (shared rules and pipeline stages)
2. All concept files in ~/moss/pipeline/concepts/*.json
3. ~/moss/content-stats (all files -- today's content performance data)
4. ~/moss/orchestrator-state.json (system health, last run state)
5. All files in ~/moss/learnings/ (scout.md, design-build.md, content.md, launches.md)
6. ~/moss/config/thresholds.json (eval thresholds and limits)
7. ~/moss/config/scheduling.json (schedule config if it exists)
8. ~/moss/briefings/$TODAY.md (if it exists -- today's existing draft to update)
9. Query Supermemory (QMD): Ask "What happened today? Any notable wins or failures in the last 24 hours?" to get session transcripts and agent activity logs.

COMPILE THE BRIEFING. Write it to ~/moss/briefings/$TODAY.md. Use this exact structure:

```markdown
# Moss Daily Briefing -- [TODAY]

## Pipeline Overview
[For each stage that has concepts, list count + concept names]
- scouted: N (name1, name2, ...)
- researching: N (...)
- validated: N (...)
- designing-building: N (...)
- evaluating: N (...)
- content-creating: N (...)
- content-tracking: N (...)
- launch-prep: N (...)
- testflight: N (...)
- submission: N (...)
- launched: N (...)
- post-launch: N (...)
- killed today: N (names + reason)
Total active concepts: N

## Key Decisions Today
[Bullet list of any stage transitions, kills, restarts, or strategic choices made today]

## Content Performance
- Top performer: [concept name] -- [platform] -- [metric: views/likes/downloads]
- New posts published today: N [list them with concept + platform]
- Dead content (no engagement in 48h): [list or "none"]
- Notable trends in what's working: [1-2 sentences]

## System Health
- Failures today: [list with what failed and whether auto-fixed]
- Auto-fixes applied: [list or "none"]
- Tool/MCP issues: [list or "none"]
- Subagent restarts: [count and why]

## Blockers / Needs Human
[List anything requiring human action. If none, write "None -- system running autonomously."]

## Tomorrow's Priorities
[Top 3-5 things the system should focus on tomorrow, based on pipeline state]
1.
2.
3.

## Self-Improvement Proposals
[Brief summary of proposals from Part 2 -- full details in ~/moss/improvements/$TODAY.md]
- Auto-applied: N items (brief descriptions)
- Suggest (needs human approval): N items (brief descriptions)
- Flagged (significant change): N items (brief descriptions)
```

=== PART 2: SELF-IMPROVEMENT ===

SEARCH TODAY'S ACTIVITY for patterns in these three categories. Use the Supermemory query results, agent logs in orchestrator-state.json, learnings files, and any error messages you encountered while reading context above.

CATEGORY A -- FAILURES AND WORKAROUNDS:
Look for: iPhone mirroring restarts, MCP server failures, tool timeouts, build errors, subagent kills/restarts, eval loops that cycled more than twice, platform login issues, Xcode environment problems.
For each pattern: Is this the second or third time this same failure occurred? If so, it needs a fix.

CATEGORY B -- WINS:
Look for: Concepts that moved through stages faster than average, eval passes on first try, content formats that got high engagement, design approaches that passed eval quickly, scout queries that surfaced high-quality concepts, search strategies that worked well.
For each pattern: Can we encode this as a default or a learnings update?

CATEGORY C -- DRIFT:
Look for: The same eval failure type recurring (e.g., always fails on accessibility), scout surfacing concepts that always get killed at validation, content consistently underperforming on a specific platform, threshold settings that are causing too many or too few passes.
For each pattern: Is this a signal that a default, threshold, or prompt needs updating?

WRITE PROPOSALS to ~/moss/improvements/$TODAY.md. Use this exact structure:

```markdown
# Moss Self-Improvement Proposals -- [TODAY]

## Proposal 1: [Short Title]
**Category:** failures/wins/drift
**Evidence:** [Specific evidence -- timestamps, concept IDs, error messages, metrics]
**Proposed Change:**
  File: [exact file path]
  Change: [exact diff or new content -- be specific, not vague]
**Classification:** auto-apply | suggest | flag
**Rationale:** [1-2 sentences on why this change will help]

## Proposal 2: [Short Title]
...
```

CLASSIFICATION RULES (apply strictly):
- **auto-apply**: Tool workarounds (e.g., add retry logic to a script), recovery procedures (e.g., restart steps), learnings file updates (adding a win or failure pattern to ~/moss/learnings/*.md), config corrections for obvious bugs. LOW RISK -- apply immediately without human review.
- **suggest**: Default value changes, threshold tweaks (thresholds.json), prompt adjustments in agent CLAUDE.md files, scheduling changes. MEDIUM RISK -- include in briefing for human approval via Dispatch.
- **flag**: Pipeline stage changes, new agent roles, platform strategy shifts, major prompt rewrites, changes to eval criteria. HIGH RISK -- requires human decision before any action.

APPLY AUTO-APPLY ITEMS NOW:
For each proposal classified as auto-apply:
1. Make the exact change described (edit the file, add the learnings entry, fix the script)
2. Verify the change looks correct
3. git add the changed file
After applying ALL auto-apply items, make ONE commit:
  git commit -m "moss-retro $TODAY: [comma-separated summary of what was auto-applied]"
If there are zero auto-apply items, skip the commit.

=== PART 3: SEND BRIEFING VIA DISPATCH ===

Send a concise summary via Dispatch (iMessage to the configured human contact). Keep it UNDER 500 words. Use this format:

---
🌙 Moss Nightly Retro -- [TODAY]

📊 Pipeline: [total active] concepts across [N] stages
  Active builds: [count] | Content live: [count] | Awaiting human: [count]

🏆 Top content: [concept name] on [platform] -- [key metric]
📝 Published today: [count] posts

⚙️ System health: [one line -- e.g., "Clean -- no failures" or "2 failures, both auto-fixed"]

💡 Improvements: [N] auto-applied, [N] suggest, [N] flagged
[If any suggest/flag items: brief 1-line description of each]

🚨 Blockers: [list or "None"]

Full briefing: ~/moss/briefings/$TODAY.md
---

To send via Dispatch: Use the Dispatch tool or script at ~/moss/scripts/ to send the above message to the configured human contact. If Dispatch is unavailable, write the message to ~/moss/briefings/$TODAY-dispatch.txt as a fallback.

=== COMPLETION CHECKLIST ===
Before finishing, confirm:
[ ] ~/moss/briefings/$TODAY.md written with all sections
[ ] ~/moss/improvements/$TODAY.md written with numbered proposals
[ ] All auto-apply items applied to their target files
[ ] Git commit made (if any auto-apply items)
[ ] Dispatch message sent (or fallback file written)
[ ] orchestrator-state.json updated with lastRetro timestamp

Update orchestrator-state.json to add: "lastRetro": "[ISO-timestamp]", "lastRetroProposals": {"autoApplied": N, "suggest": N, "flagged": N}

Report what you did. Be specific: list each proposal and what was done with it.
PROMPT
)"
