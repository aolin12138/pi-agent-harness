# Implementation Plan: pi-web Bug Fixes

## 1. Objective

Fix two bugs in pi-web:
1. Subagent sessions (especially fork-mode) not showing as children in the sidebar
2. Thinking level changes made in CLI not reflecting live in the web UI

## 2. Confirmed Assumptions and Constraints

- Session `.jsonl` files have a first-line header with `"type": "session"` that may contain `"parentSession"` — an absolute path to the parent session `.jsonl` file
- Fork-mode subagent sessions inherit the parent's `firstMessage` text, making the current regex `isSubagentSession()` unreliable
- The extension server polls state every 250ms but only broadcasts entry count changes, not thinking level changes
- The web UI has a `uiStore` with `setThinkingLevel()` that the RPC handler can call
- No server-side validation needed — the changes are straightforward data plumbing
- The `Session` interface in `sessionStore.ts` may need a new field

## 3. Open Questions

None — the investigation confirmed exact code locations and data flow.

## 4. Step-by-Step Plan

### Bug 1: Subagent sessions not showing in sidebar

#### Step 1.1: Read `parentSession` in `/api/sessions` and include it in returned data

**File:** `C:/Users/User/.pi/pi-web/extensions/server.ts`  
**Location:** The `/api/sessions` handler (~lines 91-130)

Currently the endpoint reads `sessionId` from the first `"session"` type entry but ignores `parentSession`. Fix: also extract and include `parentSession`.

**Change:** In the inner session-parsing loop (after `sessionId` is extracted), also capture `parentSession`:

```
// In the session header parsing block, add:
let parentSession = "";
// ... inside the existing try/catch where e.type === "session":
if (e.type === "session" && !sessionId) {
  sessionId = e.id || "";
  parentSession = e.parentSession || "";
}
```

Then include `parentSession` in the returned session object (around line where `sess.push(...)` happens):

```javascript
sess.push({
  file: f, firstMessage: sessionName || fm || "", name: sessionName,
  id: sessionId, filePath: dn + "/" + f, timestamp: fs.statSync(fp).mtimeMs,
  parentSession: parentSession || "",  // NEW FIELD
});
```

#### Step 1.2: Add `parentSession` to the `Session` interface

**File:** `C:/Users/User/.pi/pi-web/src/store/sessionStore.ts`  
**Location:** The `Session` interface (~lines 3-9)

Add the field:

```typescript
export interface Session {
  id?: string;
  name: string;
  firstMessage?: string;
  file: string;
  filePath: string;
  timestamp: string;
  parentSession?: string;  // NEW: path to parent session file, if any
}
```

#### Step 1.3: Update `isSubagentSession()` to use `parentSession`

**File:** `C:/Users/User/.pi/pi-web/src/components/SessionSidebar.tsx`  
**Location:** The `isSubagentSession` function (~line 191)

Replace the regex-based check with `parentSession`-based check:

```typescript
function isSubagentSession(session: Session): boolean {
  return !!session.parentSession;
}
```

#### Step 1.4: Update `buildChildMap()` to use `parentSession` directly

**File:** `C:/Users/User/.pi/pi-web/src/components/SessionSidebar.tsx`  
**Location:** The `buildChildMap` function (~lines 204-214)

Currently it uses `extractParentSessionId(firstMessage)` which extracts a parent ID from an artifact path. Replace with direct matching using `parentSession` file path to parent's `filePath`:

```typescript
function buildChildMap(mainSessions: Session[], subSessions: Session[]): Map<string, Session[]> {
  const map = new Map<string, Session[]>();
  for (const sub of subSessions) {
    if (!sub.parentSession) continue;
    // parentSession is an absolute file path; match against main sessions' filePath
    const parent = mainSessions.find((m) => sub.parentSession!.endsWith(m.filePath));
    if (parent?.id) {
      if (!map.has(parent.id)) map.set(parent.id, []);
      map.get(parent.id)!.push(sub);
    }
  }
  return map;
}
```

#### Step 1.5: Remove now-unused `extractParentSessionId()` function

**File:** `C:/Users/User/.pi/pi-web/src/components/SessionSidebar.tsx`  
**Location:** ~lines 194-203

Delete the entire `extractParentSessionId` function since it's no longer called.

### Bug 2: Thinking level changes not broadcast to web UI

#### Step 2.1: Broadcast thinking level on `set_thinking_level` command

**File:** `C:/Users/User/.pi/pi-web/extensions/server.ts`  
**Location:** The `handleCommand` function, `set_thinking_level` case (~line 203)

After `pi.setThinkingLevel?.(cmd.level)`, update the cache and broadcast:

```typescript
case "set_thinking_level":
  pi.setThinkingLevel?.(cmd.level);
  cachedThinkingLevel = cmd.level;
  broadcast({ type: "thinking_level_changed", level: cmd.level });
  res(true);
  break;
```

#### Step 2.2: Detect thinking level changes in polling loop and broadcast

**File:** `C:/Users/User/.pi/pi-web/extensions/server.ts`  
**Location:** The `pollTimer` setInterval inside `session_start` handler (~line 268)

Modify the polling callback to also check for thinking level changes:

```typescript
pollTimer = setInterval(() => {
  try {
    const prevThinkingLevel = cachedThinkingLevel;
    refreshCache(ctx, pi);
    // New entries
    if (cachedEntries.length > lastCount) {
      const newEntries = cachedEntries.slice(lastCount);
      lastCount = cachedEntries.length;
      broadcast({ type: "new_entries", entries: newEntries });
    }
    // Thinking level change
    if (cachedThinkingLevel !== prevThinkingLevel) {
      broadcast({ type: "thinking_level_changed", level: cachedThinkingLevel });
    }
  } catch {}
}, POLL_MS);
```

#### Step 2.3: Handle `thinking_level_changed` event in RPC handler

**File:** `C:/Users/User/.pi/pi-web/src/services/rpc-handler.ts`  
**Location:** The `handleRPCEvent` switch statement

Add a new case to handle the thinking level change event:

```typescript
case 'thinking_level_changed': {
  const level = event.level as string;
  if (level !== undefined) {
    const { useUIStore } = await import('../store/uiStore');
    useUIStore.getState().setThinkingLevel(level);
  }
  break;
}
```

Wait — `handleRPCEvent` is not async and doesn't currently import `useUIStore`. Need a different approach.

**Revised approach:** Import `useUIStore` at the top of `rpc-handler.ts` and handle it directly:

At the top of the file, add:
```typescript
import { useUIStore } from '../store/uiStore';
```

Then in the switch:
```typescript
case 'thinking_level_changed':
  if (typeof event.level === 'string') {
    useUIStore.getState().setThinkingLevel(event.level);
  }
  break;
```

#### Step 2.4: Ensure WebSocket routes the new event type to rpc-handler

**File:** `C:/Users/User/.pi/pi-web/src/services/websocket.ts`  
**Location:** The `handleMessage` method switch (~lines 116-145)

Currently the websocket handler routes `event` messages to `rpcEvent`. Since `thinking_level_changed` is broadcast as a top-level message (not inside an `event` wrapper), it won't be caught by the current switch.

**Option A:** Send it as `{ type: "event", event: { type: "thinking_level_changed", level } }` — but this would require rework of the broadcast.

**Option B (simpler):** Add a dedicated case in the websocket handler:

```typescript
case 'thinking_level_changed':
  emit('thinkingLevelChanged', message);
  break;
```

Then in `rpc-handler.ts`, add a listener:

```typescript
onWSEvent('thinkingLevelChanged', (msg: any) => {
  if (typeof msg.level === 'string') {
    useUIStore.getState().setThinkingLevel(msg.level);
  }
});
```

**Decision:** Use Option B — it's the minimal change, consistent with how `mirror_sync` and `tasks` already work as top-level message types.

#### Step 2.5: Import `onWSEvent` in `rpc-handler.ts`

**File:** `C:/Users/User/.pi/pi-web/src/services/rpc-handler.ts`  
**Location:** Top of file

Add import:
```typescript
import { onWSEvent } from './websocket';
```

(Already imported indirectly via chatStore? No — checking the file, it's not imported. It needs to be added.)

#### Step 2.6: Register the thinking level listener at module scope

**File:** `C:/Users/User/.pi/pi-web/src/services/rpc-handler.ts`  
**Location:** After the existing module-level code (e.g., after `parsePossibleTasks`)

Add:
```typescript
// Listen for thinking level changes broadcast by the server
import { onWSEvent } from './websocket';
import { useUIStore } from '../store/uiStore';

onWSEvent('thinkingLevelChanged', (msg: any) => {
  if (typeof msg.level === 'string') {
    useUIStore.getState().setThinkingLevel(msg.level);
  }
});
```

Wait — this would be at module scope but the imports are already needed. Let me reconsider.

Actually, the simplest approach: put the listener registration at module scope in `rpc-handler.ts` with the import at the top.

**Revised Step 2.3-2.6 (combined):**

In `rpc-handler.ts`:
- Add `import { useUIStore } from '../store/uiStore';` at the top
- Add `import { onWSEvent } from './websocket';` (if not already present — checking the file, it's not there)
- Add at module scope:

```typescript
onWSEvent('thinkingLevelChanged', (msg: any) => {
  if (typeof msg.level === 'string') {
    useUIStore.getState().setThinkingLevel(msg.level);
  }
});
```

---

## 5. Risks and Mitigations

| Risk | Mitigation |
|------|-----------|
| `parentSession` may be absent in older sessions | The `parentSession\|\| ""` fallback handles this gracefully |
| `parentSession` is an absolute path, `filePath` is relative — matching may fail | Use `.endsWith(filePath)` which matches the relative suffix of the absolute `parentSession` path |
| `broadcast` inside `set_thinking_level` command handler may miss connected clients if broadcast is undefined | `broadcast` is already defined and used throughout the code |
| Polling loop already runs — adding thinking check adds negligible overhead | The 250ms interval is already established; one extra string comparison is trivial |

## 6. Acceptance Criteria

1. After restarting pi-web with these changes:
   - Fork-mode subagent sessions appear as children under their parent session in the sidebar
   - The child count badge (e.g., "2 ⎇") shows on parent sessions that have subagents
   - Expanding the parent reveals the subagent sessions
2. Running `set_thinking_level` in the CLI or via the web UI updates the thinking level display live across all connected clients
3. The regex-based `isSubagentSession()` function is replaced by `parentSession`-based detection
4. The old `extractParentSessionId()` function is removed
5. No regressions: main sessions still display correctly, search still works, model picker still works

## 7. Files Changed

| File | Lines touched | Change summary |
|------|--------------|----------------|
| `extensions/server.ts` | ~3 locations | Extract `parentSession` from session header, include in API response, broadcast thinking level on command, detect thinking level change in poll loop |
| `src/store/sessionStore.ts` | 1 line | Add `parentSession?: string` to `Session` interface |
| `src/components/SessionSidebar.tsx` | ~30 lines changed | Replace `isSubagentSession()`, rewrite `buildChildMap()`, delete `extractParentSessionId()` |
| `src/services/websocket.ts` | ~3 lines | Add `thinking_level_changed` case to `handleMessage` |
| `src/services/rpc-handler.ts` | ~3 lines | Add import + listener for `thinkingLevelChanged` |

## 8. Validation Notes

- Verified `parentSession` field exists in session header `.jsonl` files (confirmed on a fork-mode session)
- Verified `/api/sessions` endpoint code path — opens files, reads first 30 lines, builds session objects
- Verified `SessionSidebar.tsx` uses the regex approach for subagent detection
- Verified extension server WS command handling for `set_thinking_level` does not update cache or broadcast
- Verified polling loop only checks entry count changes, not thinking level
- Verified websocket handler routes all message types but has no `thinking_level_changed` case
- Confirmed `uiStore.setThinkingLevel()` exists and persists to localStorage
