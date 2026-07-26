# Portability Guide — Moving Your Pi Setup Between Machines

This guide covers everything you need to replicate your pi agent setup on a
new computer. The repo handles the harness (skills, agents, workflows, wiki).
This document covers the **personal layer** — the files we intentionally
excluded from the public repo because they contain secrets, preferences, or
accumulated session data.

---

## Quick Reference: What Goes Where

| File | Contains | Public Repo? | Transfer Method |
|------|----------|:---:|---|
| `agent/AGENTS.md` | Always-on prompt + hard rules | ✅ | `./setup.ps1` auto-installs from repo |
| `agent/INDEX.md` | Skill catalog | ✅ | `./setup.ps1` auto-installs |
| `agent/skills/*/` | 11 custom skills | ✅ | `./setup.ps1` auto-installs |
| `agent/agents/*.md` | 5 subagent definitions | ✅ | `./setup.ps1` auto-installs |
| `agent/workflows/*.yaml` | 4 workflows | ✅ | `./setup.ps1` auto-installs |
| `agent/settings.json` | Provider, model, shell, packages | ❌ | **Reconfigure or copy manually** |
| `agent/models.json` | Model definitions + env-var API keys | ❌ | **Copy from template + set env vars** |
| `agent/auth.json` | OAuth tokens + raw API keys | ❌ **NEVER** | **Re-authenticate on each machine** |
| `user/PROFILE.md` | Your preferences, tone, standing rules | ❌ | **Copy manually** (personal, no secrets) |
| `user/memory/MEMORY.md` | Memory index | ❌ | **Start fresh** or copy manually |
| `user/memory/preferences.md` | Learned coding preferences | ❌ | **Start fresh** or copy manually |
| `user/memory/corrections.md` | Past corrections | ❌ | **Start fresh** (agent rebuilds it) |
| `user/memory/sessions/` | Session summaries | ❌ | **Start fresh** (agent rebuilds it) |
| `user/memory/workflows.md` | Learned workflow patterns | ❌ | **Start fresh** or copy manually |
| `llm-wiki/` | Knowledge base (46 pages) | ✅ | `./setup.ps1` auto-installs |

---

## Step-by-Step: Setting Up a New Machine

### 1. Clone and install the harness

```bash
git clone https://github.com/<you>/pi-agent-harness.git
cd pi-agent-harness
./setup.ps1   # Windows
# or
./setup.sh    # macOS/Linux/WSL
```

This installs everything marked ✅ above.

### 2. Configure settings.json

The setup script creates `~/.pi/agent/settings.json` from the template if it
doesn't exist. Edit it for your new machine:

```json
{
  "defaultProvider": "anthropic",
  "defaultModel": "claude-opus-4-8",
  "defaultThinkingLevel": "xhigh",
  "shellPath": "E:\\Git\\bin\\bash.exe",   // ← CHANGE: your shell path
  "packages": [
    "npm:pi-web-access",
    "npm:@eko24ive/pi-ask",
    "npm:@micuintus/llm-wiki",
    "npm:pi-playwright",
    "npm:pi-prompt-autoresearch",
    "npm:pi-mcp-adapter"
  ],
  "theme": "dark"
}
```

**What to change:**
- `shellPath` — path to bash on the new machine
- `defaultModel` — if you want a different default
- Add/remove packages as needed

### 3. Set up model definitions

Copy the template and fill in your provider configs:

```bash
cp ~/.pi/agent/models.template.json ~/.pi/agent/models.json
```

The template has model definitions for DeepSeek and Zhipu that reference
environment variables for API keys. Set those env vars on the new machine:

```bash
# Windows (PowerShell)
$env:DEEPSEEK_API_KEY = "sk-..."
$env:ZHIPU_API_KEY = "..."

# Or add to your shell profile (~/.bashrc, ~/.zshrc)
export DEEPSEEK_API_KEY="sk-..."
export ZHIPU_API_KEY="..."
```

To add Anthropic or other providers, edit `models.json` directly. The format:

```json
{
  "providers": {
    "anthropic": {
      "baseUrl": "https://api.anthropic.com",
      "api": "anthropic-messages",
      "apiKey": "$ANTHROPIC_API_KEY",
      "models": [
        {
          "id": "claude-opus-4-8",
          "name": "Claude Opus 4.8",
          "contextWindow": 200000,
          "maxTokens": 32000,
          "input": ["text", "image"],
          "reasoning": true,
          "cost": { "input": 15.0, "output": 75.0 }
        }
      ]
    }
  }
}
```

### 4. Authenticate (auth.json)

**This file contains raw OAuth tokens and API keys. NEVER copy it between
machines — even via private channels.**

Instead, re-authenticate on each machine. Pi typically handles this through
its own auth flow (browser OAuth or API key prompt). Check pi's
documentation for the specific auth command for each provider.

For Anthropic OAuth, for example, pi will open a browser window to
authenticate. For API-key providers, you can set them via environment
variables or pi's config commands.

### 5. Copy your PROFILE.md

`~/.pi/user/PROFILE.md` is personal but contains no secrets. You can safely
copy it between machines however you prefer:

**Option A — manual copy (simplest):**
```bash
# From old machine
cat ~/.pi/user/PROFILE.md
# Copy the content, paste into new machine
```

**Option B — private dotfiles repo:**
Keep a separate private git repo for your dotfiles including `PROFILE.md`:
```bash
# On new machine, after setting up private dotfiles
cp ~/dotfiles/pi/PROFILE.md ~/.pi/user/PROFILE.md
```

**Option C — cloud sync:**
Drop it in a synced folder (OneDrive, iCloud, Dropbox) and copy from there.

### 6. Memory — start fresh or copy

The memory directory (`~/.pi/user/memory/`) contains what the agent has learned
about you across sessions: preferences, corrections, session summaries.

**Recommendation: Start fresh.** The agent rebuilds memory by observing your
corrections and preferences. After 2-3 sessions on the new machine, it will
have relearned the key patterns. The wiki (which IS in the repo) preserves
project knowledge — the memory directory is for personal patterns.

**If you want to copy it anyway:** Same options as PROFILE.md — manual copy,
private repo, or cloud sync. The files are plain Markdown, no special format.

```
~/.pi/user/memory/
├── MEMORY.md         # Index of what's been learned
├── preferences.md    # "Prefers functional style, tabs over spaces"
├── corrections.md    # "Always use strict null checks"
├── workflows.md      # Repeated task patterns
└── sessions/         # One-paragraph summaries per day
    └── 2026-06-09.md
```

---

## The Three-Layer Sync Strategy

Think of your pi setup as three layers with different sync strategies:

```
Layer 1: THE HARNESS (public repo)     ← git clone + setup.ps1
  Skills, agents, workflows, wiki, AGENTS.md, INDEX.md
  Everything that makes the agent capable.

Layer 2: PERSONAL CONFIG (manual copy)  ← once per machine
  PROFILE.md, settings.json, models.json
  Your preferences and provider setup. No secrets.

Layer 3: SECRETS (never copy)          ← re-authenticate each time
  auth.json, API keys, OAuth tokens
  Security boundary. Each machine authenticates independently.
```

---

## Environment Variables Reference

These are the env vars referenced by `models.template.json`. Set them on
any machine where you want those providers:

| Variable | Provider | How to get |
|----------|----------|-----------|
| `DEEPSEEK_API_KEY` | DeepSeek | https://platform.deepseek.com/api_keys |
| `ZHIPU_API_KEY` | Zhipu (GLM) | https://open.bigmodel.cn/ |
| `ANTHROPIC_API_KEY` | Anthropic | https://console.anthropic.com/ (or use OAuth) |
| `OPENAI_API_KEY` | OpenAI | https://platform.openai.com/api-keys |

Pi may also support OAuth flows for some providers — check pi's auth
documentation for the latest.

---

## Quick Setup Checklist (New Machine)

```
□ 1. Clone pi-agent-harness
□ 2. Run ./setup.ps1 (or ./setup.sh)
□ 3. Edit ~/.pi/agent/settings.json (shellPath, preferences)
□ 4. Copy models.template.json → models.json, add providers
□ 5. Set environment variables for API keys
□ 6. Authenticate with pi for OAuth providers
□ 7. Copy PROFILE.md from old machine (or write from scratch)
□ 8. Install external packages: pi install npm:pi-web-access (etc.)
□ 9. Run pi and verify everything loads
```

---

## FAQ

**Q: Can I just copy the whole `~/.pi/` folder between machines?**

Not recommended. `auth.json` contains active OAuth tokens tied to the
originating machine's IP and session. Copying it will cause auth failures.
The sessions/ directory references absolute paths. Let the setup script
handle the clean parts and reconfigure the personal parts.

**Q: What about pi-web?**

pi-web is a separate repo. Clone it alongside:
```bash
git clone https://github.com/<you>/pi-web.git ~/.pi/pi-web
```
Then reference it in settings.json: add `"..\\pi-web"` to the packages array.

**Q: How do I keep the harness in sync across machines?**

```bash
cd pi-agent-harness
git pull
./setup.ps1   # re-copies updated files to ~/.pi/
```

The setup script is idempotent — run it anytime to refresh the harness files
from the latest repo version.

**Q: What if I customize a skill on one machine?**

Edit the skill in the repo (`pi-agent-harness/agent/skills/<name>/SKILL.md`),
commit, push. On the other machine: `git pull && ./setup.ps1`.

**Q: Should I keep PROFILE.md in the repo?**

No — it's personal and reveals your communication style, preferences, and
active projects. Keep it out of any public repo. If you want version control
on it, use a separate private repo.
