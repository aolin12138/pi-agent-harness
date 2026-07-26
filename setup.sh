#!/usr/bin/env bash
# pi-agent-harness setup — Unix/macOS/WSL
# Run from the repo root: ./setup.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
PI_HOME="${PI_HOME:-$HOME/.pi}"
AGENT_DIR="$PI_HOME/agent"
WIKI_DIR="$PI_HOME/llm-wiki"
USER_DIR="$PI_HOME/user"

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

echo -e "${BOLD}pi-agent-harness setup${RESET}"
echo "Repo: $REPO_ROOT"
echo "Target: $PI_HOME"
echo ""

# ── Step 1: Ensure pi directories exist ──────────────────────
echo -e "${BOLD}[1/6]${RESET} Creating directories..."
mkdir -p "$AGENT_DIR"/{skills,agents,workflows}
mkdir -p "$WIKI_DIR"
mkdir -p "$USER_DIR"/memory/sessions
echo -e "  ${GREEN}✓${RESET} Directories ready"

# ── Step 2: Install agent config files ───────────────────────
echo -e "${BOLD}[2/6]${RESET} Installing agent configuration..."

# AGENTS.md and INDEX.md
cp "$REPO_ROOT/agent/AGENTS.md" "$AGENT_DIR/AGENTS.md"
cp "$REPO_ROOT/agent/INDEX.md" "$AGENT_DIR/INDEX.md"
echo -e "  ${GREEN}✓${RESET} AGENTS.md + INDEX.md"

# Settings (prompt if no existing settings.json)
if [ ! -f "$AGENT_DIR/settings.json" ]; then
  cp "$REPO_ROOT/agent/settings.template.json" "$AGENT_DIR/settings.json"
  echo -e "  ${YELLOW}⚠${RESET} Created settings.json from template — edit with your API keys and paths"
else
  echo -e "  ${GREEN}✓${RESET} settings.json already exists (preserved)"
fi

# Models template (copy if no existing models.json)
if [ ! -f "$AGENT_DIR/models.json" ]; then
  cp "$REPO_ROOT/agent/models.template.json" "$AGENT_DIR/models.json"
  echo -e "  ${YELLOW}⚠${RESET} Created models.json from template — set API key env vars and add providers"
else
  echo -e "  ${GREEN}✓${RESET} models.json already exists (preserved)"
fi

# ── Step 3: Install custom skills ────────────────────────────
echo -e "${BOLD}[3/6]${RESET} Installing custom skills..."
SKILL_COUNT=0
for skill_dir in "$REPO_ROOT"/agent/skills/*/; do
  skill_name=$(basename "$skill_dir")
  rm -rf "$AGENT_DIR/skills/$skill_name"
  cp -r "$skill_dir" "$AGENT_DIR/skills/$skill_name"
  SKILL_COUNT=$((SKILL_COUNT + 1))
done
echo -e "  ${GREEN}✓${RESET} $SKILL_COUNT skills installed"

# ── Step 4: Install agents and workflows ─────────────────────
echo -e "${BOLD}[4/6]${RESET} Installing agents and workflows..."

cp "$REPO_ROOT"/agent/agents/*.md "$AGENT_DIR/agents/"
echo -e "  ${GREEN}✓${RESET} $(ls "$REPO_ROOT/agent/agents/"*.md | wc -l | tr -d ' ') agent definitions"

cp "$REPO_ROOT"/agent/workflows/*.yaml "$AGENT_DIR/workflows/"
echo -e "  ${GREEN}✓${RESET} $(ls "$REPO_ROOT/agent/workflows/"*.yaml | wc -l | tr -d ' ') workflow definitions"

# ── Step 5: Install wiki ─────────────────────────────────────
echo -e "${BOLD}[5/6]${RESET} Installing wiki knowledge base..."
if [ -f "$WIKI_DIR/index.md" ]; then
  echo -e "  ${YELLOW}⚠${RESET} Wiki already exists — skipping (delete $WIKI_DIR to reinstall)"
else
  cp -r "$REPO_ROOT/wiki/"* "$WIKI_DIR/"
  echo -e "  ${GREEN}✓${RESET} Wiki installed"
fi

# ── Step 6: User model setup ─────────────────────────────────
echo -e "${BOLD}[6/6]${RESET} Setting up user model..."
if [ ! -f "$USER_DIR/PROFILE.md" ]; then
  cat > "$USER_DIR/PROFILE.md" << 'PROFILEEOF'
# User Profile

This file is loaded at the start of every session. Keep it concise.

---

## Communication Style
- **Verbosity:** balanced
- **Tone:** direct

## Technical Preferences
- **Languages:** TypeScript, Python
- **Code style:** functional over OOP, follow existing patterns, no over-engineering

## Standing Instructions
- Never auto-commit to git
- Prefer frameworks and principles over rigid scripts
- Don't bloat — add only what's needed

## Active Projects
- (add your projects here)
PROFILEEOF
  echo -e "  ${GREEN}✓${RESET} Created PROFILE.md — edit with your preferences"
else
  echo -e "  ${GREEN}✓${RESET} PROFILE.md exists (preserved)"
fi

if [ ! -f "$USER_DIR/memory/MEMORY.md" ]; then
  echo "# Agent Memory Index" > "$USER_DIR/memory/MEMORY.md"
  echo -e "  ${GREEN}✓${RESET} Created MEMORY.md"
fi

# ── External dependencies note ────────────────────────────────
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}Setup complete!${RESET}"
echo ""
echo "Next steps:"
echo "  1. Edit ~/.pi/agent/settings.json — set your defaultProvider, defaultModel, and shellPath"
echo "  2. Install external skill packages (if not already installed by pi):"
echo "       pi install npm:pi-web-access"
echo "       pi install npm:@eko24ive/pi-ask"
echo "       pi install npm:@micuintus/llm-wiki"
echo "       pi install npm:pi-playwright"
echo "       pi install npm:pi-mcp-adapter"
echo "  3. Copy models.template.json to models.json: cp agent/models.template.json ~/.pi/agent/models.json"
echo "  4. Set API key environment variables (DEEPSEEK_API_KEY, ZHIPU_API_KEY, etc.)"
echo "  5. Authenticate with pi for your LLM providers (OAuth or API key prompt)"
echo "  6. Copy PROFILE.md from your old machine, or edit ~/.pi/user/PROFILE.md from scratch"
echo "  7. Start pi: pi"
echo ""
echo "See PORTABILITY.md for the full guide on transferring personal config between machines."
echo ""
echo -e "${YELLOW}To update the harness later: git pull && ./setup.sh${RESET}"
