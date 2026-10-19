# Verification report

> Historical tests from initial setup with Codex. For the subsequent Kiro-only configuration and current checks, see [codex-disabled.md](codex-disabled.md). Diagnostic scripts have also been updated to use only Kiro and no longer test the rejected Sonnet ID.

Date: 2026-10-19, Europe/Moscow. All PASS results below are live observations, not catalog claims.

| Check | Status | Evidence |
|---|---|---|
| OmniRoute health | PASS | HTTP 200. |
| Network binding | PASS | Port 20128 listens only on 127.0.0.1. |
| API authentication | PASS | Anonymous models 401; dedicated key 200. |
| Default management password | PASS | CHANGEME login 401. |
| DSH key scope | PASS | Exactly four combos, two OAuth connections, self:usage only. |
| Codex connection | PASS | Plus OAuth; live generation on all three chosen models. |
| Kiro connection | PASS | KIRO FREE; Qwen generation and Qwen/Haiku tool calls returned 200. |
| Kiro catalog Sonnet 5 | FAIL, remediated | Single-target HTTP 400 invalid model ID; removed from all routes. |
| OpenCode Free | FAIL, excluded | Upstream 403: free tier restricted to OpenCode. |
| Four-route short generation | PASS | Coding → sol, Analysis → astra, Fast/Auto → luna. |
| Four-route deterministic coding | PASS | Each returned `(a,b)=>a+b`. |
| Four-route tool calling | PASS | Each returned `add` with JSON arguments a=2,b=3. |
| Safe fallback | PASS | A real model with a nonexistent test connection scope failed; next Codex target returned FALLBACK_OK, HTTP 200. No quota was deliberately exhausted. |
| All targets unavailable | PASS | Both test connection scopes unavailable → HTTP 403 with two attempted targets; no paid fallback. This simulates connection unavailability, not real 429 quota exhaustion. |
| Test cleanup | PASS | Both disposable combos deleted; final key permits production routes only. |
| Cleanup failure regression | PASS after fix | Injected first-DELETE failure into each diagnostic script's actual cleanup block: second deletion and production-policy restoration still attempted. Before fix, neither occurred. No real API mutation in this fault-injection test. |
| Desktop generation/streaming | PASS | Exact DSH_OMNIROUTE_OK through real Desktop session. |
| Desktop tool execution | PASS after ACL fix | pwsh returned 5 in this project; model returned DSH_TOOL_OK:5. |
| Paid-provider exclusion | PASS | No paid API-key provider in the four routes or permitted connections. Existing legacy DSH providers preserved but not the Desktop default. |
| Independent billing ledger audit | BLOCKED | OAuth/free-plan usage was verified; external financial transaction records were not inspected. OmniRoute catalog costs are estimates, not invoices. |
| Optional dsh-omniroute runtime | BLOCKED, unnecessary | Manifest inspected; plugin not installed because native integration passed. |
| DeepSeek promotion / other account providers | BLOCKED or excluded | See provider-eligibility.md. No paid API or unverified promotional entitlement used. |

`scripts/verify.ps1` reruns the core security, catalog, four coding, four tool-call, target-allowlist, and Desktop-default checks (15 checks). It consumes a small amount of subscription/free allowance. Run from the existing user's PowerShell with a process-only execution-policy bypass if required. Do not launch under another Windows identity: DPAPI backups belong to the current user.

`scripts/test-fallback.ps1` and `scripts/test-kiro.ps1` are diagnostic, mutating tests. They temporarily add test combo permissions and remove them in `finally`. Cleanup attempts every deletion, reports residual IDs, and attempts production-key restoration even if a deletion fails. A lost server connection or forced process termination can still prevent restoration. The Kiro test intentionally reproduces the rejected catalog model. Do not run them during production traffic.

## Quotas observed

Direct `/api/usage/<connectionId>` probes (not the generic `/api/usage/quota` summary):

- Codex plan plus: current 5-hour window 48% remaining, reset 2026-10-19 19:40:31 Moscow; weekly 85% remaining, reset 2026-10-26 09:37:17 Moscow. These are percentages, not request counts. Other Codex sessions can consume the same allowance.
- Kiro plan KIRO FREE: 50 of 50 credits reported remaining; reset 2026-11-01 03:00 Moscow. Values may lag or round usage and are not an unlimited entitlement.
- The generic summary reported 100% with null totals and was not used as authoritative quota evidence.

OmniRoute records nonzero catalog-estimated costs for OAuth traffic (for example $0.05528392 after 23 recorded attempts). This does not establish a charge. Zero-extra-cost configuration is enforced by the selected subscription/free access paths and explicit connection list, not by treating the local cost counter as a bill or disabling accounting.
