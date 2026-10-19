# Provider Connection Tests

> Initial connection tests. Codex is now disabled and excluded from DSH; current verification is in [codex-disabled.md](codex-disabled.md).

Tested: 2026-10-19

| Provider | Authentication | Model | Status | Evidence |
|---|---|---|---|---|
| OpenAI Codex | Official OAuth, ChatGPT Plus workspace | `cx/gpt-6-luna` | PASS | HTTP 200; exact response `CODEX_OK`; decision header named provider `cx`. |
| Kiro | Official Google device OAuth | `kr/qwen3-coder-next` | PASS | HTTP 200; exact response `KIRO_OK`; decision header named provider `kr`. |
| OpenCode Free | Keyless | `oc/big-pickle` through `auto/coding` | FAIL | HTTP 403; upstream restricts the free tier to use inside OpenCode. |
| DeepSeek API | Not configured | `deepseek-flash` | BLOCKED | Official API is priced; connecting it would violate the zero-additional-cost constraint. |
| Qoder | Not configured | — | BLOCKED | Requires a separate authorization/account and live billing verification. |
| Kimi | Not configured | — | BLOCKED | Direct API/coding-plan entitlement was not proven free; existing exposed DSH key is excluded pending rotation. |
| Z.AI | Not configured | — | BLOCKED | Installed API-key/web-cookie methods do not establish a no-charge, low-risk path. |

At the initial connection tests, no populated quota snapshots or remaining percentages had been returned. Later direct per-connection usage probes returned the actual plans, windows, and remaining allowance; see [current quota observations](test-report.md#quotas-observed). Provider errors/cooldowns remain necessary when quota data is missing or stale.

