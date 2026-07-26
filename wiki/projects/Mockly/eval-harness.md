# Mockly Eval Harness

Automated testing framework for the ElevenLabs-hosted technical interview agent.
Built to independently test against a sandbox agent; approved configs get promoted to production.

## Architecture

```
test-suite/
  agent/config.json          ← canonical source of truth (full ElevenLabs agent payload)
  scenarios/                 ← 27 test scenario JSON files
    NN-description.json      ← one per test case
  live/
    runner.mjs               ← CLI entry — parallel executor
    run-one.mjs              ← single scenario runner (WS connect → sim-user loop → collect)
    ws-client.mjs            ← ElevenLabs WebSocket client
    sim-user.mjs             ← DeepSeek-powered simulated candidate
    judge.mjs                ← DeepSeek criteria evaluator (per-scenario, independent)
    review-report.mjs        ← HTML report generator (filterable, LATEST tags)
    verify.mjs               ← workflow node tracking
  lib/
    agent-api.mjs            ← ElevenLabs API (GET/PATCH agent)
    config.mjs               ← test agent ID, model, MCP server IDs
    loader.mjs               ← scenario loader + validator
    criteria-layers.mjs      ← 3-layer criteria merge (Universal → Per-Phase → Per-Scenario)
    auto-sync.mjs            ← local↔live agent diff + push
    diff-classify.mjs        ← change classification (mutable/restricted/forbidden)
    run-output.mjs           ← run folder + manifest + report generation
  scripts/
    push-agent.mjs           ← push local config → live test agent
    bootstrap-agent.mjs      ← create test agent from template
    promote-to-template.mjs  ← promote config → n8n production template
    stress-mcp.mjs           ← MCP server load test (100 concurrent sessions)
  runs/                      ← timestamped run folders
    <timestamp>/
      manifest.json, agent-config.json, scenarios/*.json, report.html, summary.md
```

## Flow

1. **Load scenario** → `loader.mjs` reads scenario JSON + validates
2. **Auto-sync** → diff local vs live agent, auto-PATCH mutable changes
3. **WS conversation** → `ws-client.mjs` opens ElevenLabs WebSocket
4. **Sim-user loop** → DeepSeek-powered candidate drives conversation
5. **Code injection** → `[INJECT_CODE]` markers → test store → MCP tools → Judge0
6. **Judge** → DeepSeek evaluates transcript against 3-layer criteria (independent per scenario)
7. **Report** → HTML with filterable cards, LATEST tags, transcripts, tool calls

## Key mechanisms

- **Transcript trim to target phase** — prevents Phase 1 tests evaluating Phase 4 behavior
- **Code injection via [INJECT_CODE]** — sim-user writes real code → test store → Judge0 execution
- **Tool call detection** — ws-client captures `skip_turn`, `notify_condition_X_met`, `end_call`
- **Parallel execution** — `--concurrency N` pool, typical 4x speedup
- **MCP server load-tested** — 100 concurrent sessions, zero data leaks

## Quality gates

| Exit | Meaning |
|------|---------|
| 0 | Promotable — all criteria passed |
| 1 | Behaviour fail — fix prompt |
| 2 | Harness error — fix infra |
| 3 | Leak detected — critical, must fix |

## Current state (2026-07-06)

- **27 scenarios** across all 4 phases + transitions + full interviews
- **Model**: `gemini-3.1-pro-preview` (switched from gpt-4o, cheaper + better instruction following)
- **MCP tools**: `get_current_code` + `run_code_against_tests` via ngrok → localhost:3000 → Judge0
- **Phase 4**: 5-step assessment (walkthrough → edge cases → complexity → bonus → close)
- **Test store**: in-memory Map, fuzzy ID matching, mockResults support

## Run journals

- [2026-06-24 Eval infra bootstrap](runs/2026-06-24-eval-infra.md)
- [2026-07-03 First full suite run](runs/2026-07-03-full-suite.md)
- [2026-07-06 Prompt iteration + model switch](runs/2026-07-06-prompt-iteration.md)
