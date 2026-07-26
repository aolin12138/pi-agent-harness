# pi-agent-harness setup — Windows PowerShell
# Run from the repo root: .\setup.ps1
param(
    [string]$PiHome = "$env:USERPROFILE\.pi"
)

$ErrorActionPreference = "Stop"
$RepoRoot = $PSScriptRoot
$AgentDir = Join-Path $PiHome "agent"
$WikiDir = Join-Path $PiHome "llm-wiki"
$UserDir = Join-Path $PiHome "user"

Write-Host "pi-agent-harness setup" -ForegroundColor Cyan
Write-Host "Repo: $RepoRoot"
Write-Host "Target: $PiHome"
Write-Host ""

# ── Step 1: Ensure pi directories exist ──────────────────────
Write-Host "[1/6] Creating directories..." -ForegroundColor Yellow
$dirs = @(
    "$AgentDir\skills", "$AgentDir\agents", "$AgentDir\workflows",
    "$WikiDir",
    "$UserDir\memory\sessions"
)
foreach ($d in $dirs) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
}
Write-Host "  ✓ Directories ready" -ForegroundColor Green

# ── Step 2: Install agent config files ───────────────────────
Write-Host "[2/6] Installing agent configuration..." -ForegroundColor Yellow
Copy-Item "$RepoRoot\agent\AGENTS.md" "$AgentDir\AGENTS.md" -Force
Copy-Item "$RepoRoot\agent\INDEX.md" "$AgentDir\INDEX.md" -Force
Write-Host "  ✓ AGENTS.md + INDEX.md" -ForegroundColor Green

if (-not (Test-Path "$AgentDir\settings.json")) {
    Copy-Item "$RepoRoot\agent\settings.template.json" "$AgentDir\settings.json"
    Write-Host "  ⚠ Created settings.json from template — edit with your API keys and paths" -ForegroundColor Yellow
} else {
    Write-Host "  ✓ settings.json already exists (preserved)" -ForegroundColor Green
}

# ── Step 3: Install custom skills ────────────────────────────
Write-Host "[3/6] Installing custom skills..." -ForegroundColor Yellow
$skillCount = 0
Get-ChildItem "$RepoRoot\agent\skills" -Directory | ForEach-Object {
    $dest = Join-Path $AgentDir "skills" $_.Name
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    Copy-Item $_.FullName $dest -Recurse -Force
    $script:skillCount++
}
Write-Host "  ✓ $skillCount skills installed" -ForegroundColor Green

# ── Step 4: Install agents and workflows ─────────────────────
Write-Host "[4/6] Installing agents and workflows..." -ForegroundColor Yellow
Copy-Item "$RepoRoot\agent\agents\*.md" "$AgentDir\agents\" -Force
$agentCount = (Get-ChildItem "$RepoRoot\agent\agents\*.md").Count
Write-Host "  ✓ $agentCount agent definitions" -ForegroundColor Green

Copy-Item "$RepoRoot\agent\workflows\*.yaml" "$AgentDir\workflows\" -Force
$wfCount = (Get-ChildItem "$RepoRoot\agent\workflows\*.yaml").Count
Write-Host "  ✓ $wfCount workflow definitions" -ForegroundColor Green

# ── Step 5: Install wiki ─────────────────────────────────────
Write-Host "[5/6] Installing wiki knowledge base..." -ForegroundColor Yellow
if (Test-Path "$WikiDir\index.md") {
    Write-Host "  ⚠ Wiki already exists — skipping (delete $WikiDir to reinstall)" -ForegroundColor Yellow
} else {
    Copy-Item "$RepoRoot\wiki\*" $WikiDir -Recurse -Force
    Write-Host "  ✓ Wiki installed" -ForegroundColor Green
}

# ── Step 6: User model setup ─────────────────────────────────
Write-Host "[6/6] Setting up user model..." -ForegroundColor Yellow
if (-not (Test-Path "$UserDir\PROFILE.md")) {
    @"
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
"@ | Out-File -FilePath "$UserDir\PROFILE.md" -Encoding UTF8
    Write-Host "  ✓ Created PROFILE.md — edit with your preferences" -ForegroundColor Green
} else {
    Write-Host "  ✓ PROFILE.md exists (preserved)" -ForegroundColor Green
}

if (-not (Test-Path "$UserDir\memory\MEMORY.md")) {
    "# Agent Memory Index" | Out-File -FilePath "$UserDir\memory\MEMORY.md" -Encoding UTF8
    Write-Host "  ✓ Created MEMORY.md" -ForegroundColor Green
}

# ── External dependencies note ────────────────────────────────
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Edit ~/.pi/agent/settings.json — set your defaultProvider, defaultModel, and shellPath"
Write-Host "  2. Install external skill packages (if not already installed by pi):"
Write-Host "       pi install npm:pi-web-access"
Write-Host "       pi install npm:@eko24ive/pi-ask"
Write-Host "       pi install npm:@micuintus/llm-wiki"
Write-Host "       pi install npm:pi-playwright"
Write-Host "       pi install npm:pi-mcp-adapter"
Write-Host "  3. Edit ~/.pi/user/PROFILE.md with your preferences"
Write-Host "  4. Start pi: pi"
Write-Host ""
Write-Host "To update the harness later: git pull; .\setup.ps1" -ForegroundColor Yellow
