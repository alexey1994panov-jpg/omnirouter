# DSH Route Definitions

> Historical initial configuration. Codex was subsequently disabled at the user's request. Current Kiro-only routes are in [README](../../README.md) and [configuration.json](configuration.json).

Created: 2026-10-19

All targets use OAuth/subscription allowance connections. No paid API-key provider appears in any route.

| Route | Strategy | Ordered/eligible targets |
|---|---|---|
| `DSH-Coding` | `priority` | `cx/gpt-6-sol`, `kr/qwen3-coder-next` |
| `DSH-Analysis` | `priority` | `cx/gpt-6-astra`, `cx/gpt-6-sol`, `kr/qwen3-coder-next` |
| `DSH-Fast` | `fill-first` | `cx/gpt-6-luna`, `kr/claude-haiku-4.5`, `kr/qwen3-coder-next` |
| `DSH-Auto` | `auto` | `cx/gpt-6-sol`, `cx/gpt-6-luna`, `kr/qwen3-coder-next`, `kr/claude-haiku-4.5` |

Each route enables health checks and `failoverBeforeRetry`, with zero same-target retries. This prioritizes switching provider/model on an availability or rate-limit error. `DSH-Auto` uses the installed task-aware `auto` strategy but only across the explicit target list.

`kr/claude-sonnet-5` was advertised by the catalog but returned HTTP 400 (invalid model ID) in a single-target live test. It was removed from every route. Qwen and Haiku both returned valid `add(2,3)` tool calls.

The DSH key permits exactly these four combos and the two authorized connection IDs. It has `self:usage` scope, no management scope, and no direct model access. A newly added provider or connection cannot silently enter the current allowlist.

The tiny `DSH-Auto` catalog-cost budget is an extra routing filter, not a billing guarantee. The zero-additional-cost boundary is the explicit OAuth/free-plan connection allowlist. Quota and health scoring use available provider snapshots; missing or stale snapshots cannot predict a real rate limit perfectly.

## Initial Live Results

| Route | Status | Served by |
|---|---|---|
| `DSH-Coding` | PASS | `cx/gpt-6-sol` |
| `DSH-Analysis` | PASS | `cx/gpt-6-astra` |
| `DSH-Fast` | PASS | `cx/gpt-6-luna` |
| `DSH-Auto` | PASS | `cx/gpt-6-luna` |

The root built-in `auto` route is not granted to DSH as a production default. In 3.8.51 it does not pass the same restricted-key virtual-combo policy as `auto/*`, and its dynamic pool can contain the unusable OpenCode Free path. `auto/offline` is excluded because local model execution is prohibited.

