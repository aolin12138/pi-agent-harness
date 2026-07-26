# Raw Sources Registry

## sessions/

Pi agent session JSONL files — referenced by path, not copied.

| Path | Slug | Topics |
|------|------|--------|
| `~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-31T12-32-57-390Z_019e7e05-ea2e-7bdc-9854-8467f53629be.jsonl` | 2026-05-31-wiki-graph | pi-web, wiki-graph, d3, force-directed, visualization, audit-dashboard |
| `~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-31T10-09-42-027Z_019e7d82-c28b-79d2-8a24-840383e63797.jsonl` | 2026-05-31-pi-web-bugfix | pi-web, bugfix, subagent-sidebar, thinking-sync, live-indicator, wiki-audit |
| `~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-31T03-56-31-222Z_019e7c2d-1a76-7bbb-9116-46a0ef80b7fa.jsonl` | 2026-05-31-pkb-create | pkb, llm-wiki, knowledge-base |
| `~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-31T00-11-30-471Z_019e7b5f-1927-789d-be08-4fc024de4402.jsonl` | 2026-05-31-session-a | (pending analysis) |
| `~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-31T00-13-11-885Z_019e7b60-a54d-7221-8e33-cd268330027c.jsonl` | 2026-05-31-session-b | (pending analysis) |
| `~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-30T07-33-19-798Z_0b842475-365cef47-e5f7e9b0-b598.jsonl` | 2026-05-30-session-c | (pending analysis) |
| `~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-30T00-51-27-998Z_019e765d-527e-7e21-b8a3-c99c1c93e05c.jsonl` | 2026-05-30-session-d | (pending analysis) |
| `~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-28T11-51-49-680Z_37f6d344-4edda2e6-1e6ef2ce-7d74.jsonl` | 2026-05-28-session-e | (pending analysis) |
| `~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-28T11-48-12-741Z_5857a605-02455504-e14d5776-37e5.jsonl` | 2026-05-28-session-f | (pending analysis) |
| `~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-28T11-45-47-169Z_4d9f47a6-12281624-c09d813e-a655.jsonl` | 2026-05-28-session-g | (pending analysis) |
| `~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-28T10-53-28-097Z_019e6e37-c0a1-7344-95d8-c3de14fbd6ff.jsonl` | 2026-05-28-session-h | (pending analysis) |
| `~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-27T14-18-27-897Z_d127d673-dbba8f61-d4e393bc-aaa2.jsonl` | 2026-05-27-session-i | (pending analysis) |
| `~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-27T06-20-48-020Z_4ccd8be2-3ce6ef0f-ea140734-9bd5.jsonl` | 2026-05-27-session-j | (pending analysis) |
| `~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-27T06-18-38-422Z_019e6815-c7d6-7445-80a6-a86c0848b80e.jsonl` | 2026-05-27-session-k | (pending analysis) |
| `~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-27T06-18-00-110Z_019e6815-322e-7256-b07e-bab68589457b.jsonl` | 2026-05-27-session-l | (pending analysis) |

*(Additional sessions from Apr 27–May 27 listed in directory; slugs pending individual analysis)*

## Mockly project

| Path | Slug | Topics |
|------|------|--------|
| `~/.pi/agent/sessions/--E--OneDrive - The University of Auckland-Desktop-Mockly-Mockly--/2026-04-22T06-06-54-901Z_019db3cc-77b5-746e-9b17-70157a95830a.jsonl` | 2026-04-22-mockly-debug | mockly, debugging, stuck-process |
| `~/.pi/agent/sessions/--E--OneDrive - The University of Auckland-Desktop-Mockly-Mockly--/2026-04-22T06-14-13-238Z_019db3d3-27f6-73dc-b8fc-3ab7a2602bdf.jsonl` | 2026-04-22-mockly-empty | mockly, abandoned |

## artifacts/

Files produced during sessions.

| Path | Slug | Topics |
|------|------|--------|
| `C:/Users/User/.pi/PLAN-pkb-llm-wiki.md` | plan-pkb-llm-wiki | pkb, llm-wiki, architecture |
| `C:/Users/User/.pi/plan-2-mcp-server.md` | plan-2-mcp-server | mcp, server, plan |
| `C:/Users/User/.pi/pi-web/README.md` | pi-web-readme | pi-web, architecture |
| `C:/Users/User/.pi/extension-change-log-2026-05-27.md` | extension-changelog | extensions, changelog |

## codegraph/

CodeGraph knowledge graph snapshots — exhaustive structural maps per project.

| Path | Slug | Nodes | Edges | Topics |
|------|------|-------|-------|--------|
| `E:/OneDrive - The University of Auckland/Desktop/Mockly/Mockly/` | mockly-repo | 746 | 1,261 | mockly, interview, elevenlabs, react, express, prisma, mcp |
| `C:/Users/User/.pi/` | pi-config-repo | 1,485 | 3,872 | pi, extensions, agents, workflows, pi-web |
| `C:/Users/User/.pi/pi-web/` | pi-web-repo | 262 | 537 | pi-web, preact, vite, zustand, websocket |
