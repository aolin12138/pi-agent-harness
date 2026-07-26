---
title: "pi extension `ctx.ui.custom` lifecycle"
type: reference
updated: 2026-06-08
sources:
  - "C:/Users/User/AppData/Roaming/npm/node_modules/@earendil-works/pi-coding-agent/docs/extensions.md"
  - "C:/Users/User/AppData/Roaming/npm/node_modules/@eko24ive/pi-ask/src/ui/controller.ts"
  - "C:/Users/User/AppData/Roaming/npm/node_modules/@eko24ive/pi-ask/node_modules/@earendil-works/pi-coding-agent/examples/extensions/question.ts"
tags: [pi, extension, ctx-ui, custom, ask-user, tui]
---

# pi extension `ctx.ui.custom` lifecycle

`ctx.ui.custom<T>(callback)` is the pi-core extension point for rendering a
full custom TUI widget with keyboard input. Used by `pi-ask` (`ask_user`
tool), the `question` example, snake / space-invaders / doom-overlay,
etc.

## Callback signature

```ts
ctx.ui.custom<T>(
  callback: (
    tui: TUI,
    theme: Theme,
    keybindings: Keybindings,
    done: (result: T) => void,
  ) => {
    render: (width: number) => string[];
    invalidate?: () => void;
    handleInput?: (data: string) => void;
    dispose?: () => void;
  }
): Promise<T>
```

- `done(result)` resolves the returned Promise.
- The returned widget object is owned by pi-core; it calls `render` and
  forwards keyboard input via `handleInput`.

## Lifecycle gotcha (relevant for pi-web)

`ctx.ui.custom` is **not present** on `ctx.ui` at the time the
`session_start` event handler runs. pi-core appears to install it
lazily — likely only when a tool first calls it. This means an
extension cannot wrap or proxy the original:

```ts
pi.on("session_start", (_, ctx) => {
  const orig = ctx.ui.custom;       // undefined here
  ctx.ui.custom = wrap(orig);       // we just overwrote `undefined`
});
```

`Reflect.get(ctx.ui, 'custom')` returns `undefined` even from inside a
Proxy installed in `session_start`. By the time anyone calls
`ctx.ui.custom(...)`, the proxy/override is already in place and the
original implementation never gets installed.

### Consequences

1. Extensions can fully *replace* `ctx.ui.custom` (e.g., route to web).
2. Extensions **cannot** wrap pi-core's default TUI implementation.
3. Only one custom-UI provider can win per tool call.

### What would unblock mirroring

A pi-core change such as one of:

- Install the default `ctx.ui.custom` *before* `session_start` fires.
- Provide an `onBeforeCustom(handler)` hook on `pi` so extensions can
  intercept without overwriting.
- Provide a `ctx.ui.customSink` array; pi-core composes them.

## Standard input mapping (CLI side)

If you ever do get the original widget, these are the input strings the
default TUI handler accepts (from `@eko24ive/pi-ask`):

| Key | data string |
|---|---|
| Number shortcut | `"1"`–`"9"` (matches `/^[1-9]$/`) |
| Enter | `"enter"` |
| Escape | `"escape"` |
| Tab | `"tab"` |
| Shift+Tab | `"backtab"` |
| Arrow up | `"up"` |
| Arrow down | `"down"` |
| Space | `"space"` |

Determined via `matchesKey(data, "enter")` / `matchesBinding(data, …)`
calls in `pi-ask/src/ui/input.ts` plus `DIGIT_SHORTCUT_PATTERN = /^[1-9]$/`.

## Cross-references

- `C:/Users/User/.pi/pi-web/.wiki/bugfixes-2026-06-08.md` — concrete failure trying to
  wrap this.
