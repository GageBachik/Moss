# Moss v2 -- Mac Mini Setup & Handoff Guide

This guide is for a fresh Claude agent picking up the Moss v2 project on the Mac Mini. You have no context from the previous session -- everything you need is here.

## What Is This?

Moss v2 is a fully autonomous iOS app factory. It discovers trending iOS app ideas, validates them through research, builds SwiftUI apps, creates marketing content across 5 platforms, and ships to the App Store. It runs entirely on Claude AI services (Opus 4.6) on this Mac Mini.

**Architecture**: Hybrid Daemon
- Desktop Scheduled Tasks (heartbeat every 4h, content tracker every 2h, nightly retro at 11pm) are the durable backbone
- A persistent tmux session ("Moss Active") spins up for tight build/eval loops when active work exists
- A single orchestrator spawns 6 specialized subagents on-demand

**Key docs** (read these for full context):
- `~/moss/CLAUDE.md` -- shared rules all agents follow
- Design spec: wherever you cloned the shannon repo, check `docs/superpowers/specs/2026-03-26-moss-v2-design.md`
- Implementation plan: `docs/superpowers/plans/2026-03-26-moss-v2-implementation.md`

## What's Already Built

All agent prompts, scripts, configs, and learnings are in place (14 commits, 21 files). The system is fully scaffolded but has **never been run**.

```
~/moss/
  CLAUDE.md                          # Shared rules (pipeline stages, Dispatch commands, recovery procedures)
  agents/
    scout/CLAUDE.md                  # Discovers trending app ideas via TikTok/Google Trends/App Store
    validator/CLAUDE.md              # Deep research validation, GO/KILL decisions
    designer-builder/CLAUDE.md       # Unified design + SwiftUI build (no handoff friction)
    eval/CLAUDE.md                   # Automated QA (build, launch, visual via Claude vision, functional, polish)
    content-creator/CLAUDE.md        # Creates/posts content to 5 platforms via iPhone mirroring
    launcher/CLAUDE.md               # Landing pages, privacy/terms, ASO, App Store screenshots
  scripts/
    heartbeat.sh                     # Main pipeline sweep (every 4h)
    content-tracker.sh               # Stats polling (every 2h, independent)
    nightly-retro.sh                 # Daily briefing + self-improvement (11pm)
    moss-active.sh                   # tmux session for build/eval loops (on-demand)
    emergency-stop.sh                # Kill everything, freeze pipeline
  config/
    thresholds.json                  # GO/KILL criteria, eval limits, stuck detection
    platforms.json                   # TikTok, IG, X, YouTube Shorts, Threads config
    scheduling.json                  # Timing config
  pipeline/
    concepts/                        # Concept JSON files (empty -- no concepts yet)
    active-build/                    # Xcode projects (empty)
  learnings/                         # Seed knowledge for each agent role
  briefings/                         # Daily briefings (empty)
  content-stats/                     # Content performance data (empty)
  improvements/                      # Self-improvement proposals (empty)
  orchestrator-state.json            # Orchestrator recovery state
  .claude/settings.json              # QMD session indexing hooks
```

## Setup Steps (Do These First)

### 1. Credential Environment

Create `~/.zprofile_moss` with real API keys:

```bash
# Moss v2 Agent Credentials
export ANTHROPIC_API_KEY="<real-key>"
export APP_STORE_CONNECT_API_KEY="<real-key>"
export APP_STORE_CONNECT_ISSUER_ID="<real-id>"
export APP_STORE_CONNECT_KEY_ID="<real-key-id>"
export APPLE_TEAM_ID="<real-team-id>"
export REVENUECAT_API_KEY="<real-key>"
export SUPERMEMORY_API_KEY="<real-key>"
export VERCEL_TOKEN="<real-token>"
```

Then source it:
```bash
echo '[[ -f ~/.zprofile_moss ]] && source ~/.zprofile_moss' >> ~/.zprofile
source ~/.zprofile
```

### 2. Install QMD (session transcript search)

```bash
npm install -g qmd
cd ~/moss && qmd init
```

### 3. Install Supermemory MCP

```bash
claude plugins install claude-supermemory
```

Configure with your SUPERMEMORY_API_KEY and set project to "moss".

### 4. Verify Serena MCP

```bash
claude mcp list | grep -i serena
```

Should already be available. If not, install per https://github.com/oraios/serena

### 5. Verify iPhone Mirroring

- iPhone must be connected/paired with this Mac Mini
- Open iPhone Mirroring app, confirm it works
- Ensure you're logged into all 5 platforms on the iPhone: TikTok, Instagram, X, YouTube, Threads

### 6. Verify Xcode

```bash
xcodebuild -version
xcrun simctl list devices | grep "iPhone 16 Pro"
```

Xcode must be installed with iPhone 16 Pro simulator available.

### 7. Create Desktop Scheduled Tasks

Three scheduled tasks need to be created:

```bash
# Heartbeat -- main pipeline sweep
claude /schedule create --name "Moss Heartbeat" --interval 4h --command "bash ~/moss/scripts/heartbeat.sh" --cwd ~/moss

# Content Tracker -- independent stats polling
claude /schedule create --name "Moss Content Tracker" --interval 2h --command "bash ~/moss/scripts/content-tracker.sh" --cwd ~/moss

# Nightly Retro -- daily briefing + self-improvement
claude /schedule create --name "Moss Nightly Retro" --interval daily --time "23:00" --command "bash ~/moss/scripts/nightly-retro.sh" --cwd ~/moss
```

### 8. Seed Supermemory

Run this once to populate initial knowledge:

```bash
cd ~/moss
claude -p "Using the Supermemory MCP, add these initial learnings to the 'moss' project:
1. 'Carousel content format tends to get more saves than single images across TikTok and Instagram'
2. 'Apps solving specific daily frustrations perform better than broad lifestyle apps'
3. 'Custom themed UI with distinctive visual identity gets more App Store screenshot taps than generic minimalist design'
4. 'ASO keyword difficulty above 50 is extremely hard for new apps to rank in'
5. 'RevenueCat weekly subscriptions often convert better than monthly for utility apps'
6. 'Always target iOS 17+ for latest SwiftUI features and better development experience'
These are seed learnings to be updated as Moss gains real experience."
```

## First Run

Once setup is complete, trigger the first heartbeat manually:

```bash
cd ~/moss && bash scripts/heartbeat.sh
```

This will:
1. Find an empty pipeline (no concepts)
2. Spawn the Scout subagent to research trending app ideas
3. Scout creates 1-3 concept JSON files in `pipeline/concepts/`

Then run it again to trigger validation:

```bash
bash scripts/heartbeat.sh
```

This will spawn Validators for each scouted concept. From here, the pipeline runs itself via scheduled tasks.

## How to Monitor

- **Pipeline status**: `ls ~/moss/pipeline/concepts/ && cat ~/moss/pipeline/concepts/*.json | python3 -m json.tool`
- **Daily briefings**: `cat ~/moss/briefings/$(date +%Y-%m-%d).md`
- **Content stats**: `cat ~/moss/content-stats/*.json`
- **System state**: `cat ~/moss/orchestrator-state.json`
- **Dispatch**: Send/receive from Claude mobile app
- **Emergency stop**: `bash ~/moss/scripts/emergency-stop.sh`
- **Resume**: Set `halted: false` in `orchestrator-state.json`

## Dispatch Commands (from your phone)

| Command | Action |
|---------|--------|
| `moss status` | Pipeline overview |
| `moss stop` | Emergency halt |
| `moss resume` | Unfreeze |
| `moss retro` | Run nightly retro now |
| `kill {concept}` | Kill a concept |
| `prioritize {concept}` | Fast-track a concept |
| `approve all` | Approve improvement suggestions |

## Key Design Decisions

1. **No OpenClaw** -- everything runs on native Claude primitives (Agent SDK, Scheduled Tasks, Dispatch, Agent Teams)
2. **Unified Designer-Builder** -- one agent designs AND builds, eliminating the handoff friction that plagued v1
3. **Research-first validation** -- no content posting for validation; content only for validated concepts (pre-launch marketing)
4. **Independent Content Tracker** -- stats polling is completely separate from content creation (prevents cascading failures)
5. **Daily self-improvement** -- Nightly Retro observes patterns, proposes changes, auto-applies low-risk fixes
6. **iPhone mirroring primary** -- all platform interactions via mirroring (looks native/legit), web as fallback only
7. **Plain file state** -- all pipeline state in JSON/MD files, git-tracked, inspectable, recoverable
8. **Credentials in env vars only** -- ~/moss/ is git-safe, no secrets ever written to repo files
