# OmniRoute and DSH Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Secure OmniRoute on loopback, connect verified zero-additional-cost providers, create DSH-oriented routes, and make DSH Desktop use those routes through OmniRoute's authenticated OpenAI-compatible API.

**Architecture:** DSH uses its supported custom `openai-completions` provider to call `http://127.0.0.1:20128/v1`. OmniRoute authenticates a DSH-specific key and routes only to provider connections whose access path has been verified as unable to incur additional charges.

**Tech Stack:** Windows PowerShell, OmniRoute 3.8.51 npm installation, SQLite-backed OmniRoute storage managed only through supported interfaces, DSH Desktop/Harness 0.2.1-rc.2, OpenAI Chat Completions compatibility.

**Spec:** `docs/superpowers/specs/2026-10-19-omniroute-dsh-integration-design.md`

## Global Constraints

- Do not configure a paid API, payment method, automatic balance refill, or route that can fall through to paid capacity.
- Do not install or start large local models.
- Do not delete existing connections, providers, sessions, or user data.
- Do not expose or store secrets in this repository, reports, command output, or logs.
- Do not mutate OmniRoute SQLite directly or edit packaged DSH application files.
- Use only model and route identifiers confirmed by live discovery or pinned 3.8.51 documentation.
- Return an availability error when all eligible free candidates are unavailable.
- Pause for user interaction only for browser OAuth, external credential rotation, acceptance of provider terms, or equivalent identity-bound actions.

## Review Focus

- A server restart must not revert the loopback binding or API-key requirement.
- A built-in automatic route must not silently admit a paid or unverified provider.
- The DSH key must authenticate successfully without appearing in process arguments, logs, or reports.
- Fallback must preserve tool-calling compatibility and must not consume real quota merely to simulate exhaustion.
- Existing DSH providers and sessions must remain intact after the new provider becomes default.

---

### Task 1: Capture a Redacted Baseline and Back Up User Data

**Files:**
- Create: timestamped backup directory outside this repository
- Create: `docs/omniroute-dsh/baseline.md`

**Interfaces:**
- Consumes: installed OmniRoute and DSH directories
- Produces: recoverable backup and redacted baseline used by every later task

- [ ] **Step 1: Resolve the exact running executable, data directory, DSH home, process IDs, listeners, versions, and supported CLI commands**

  Record only non-secret metadata.

- [ ] **Step 2: Copy OmniRoute and DSH configuration to a timestamped backup outside the repository**

  Include OmniRoute `.env` and database sidecars, and DSH settings/profile/credential files. Do not copy sessions or bulky caches unless restoration requires them.

- [ ] **Step 3: Verify backup completeness without printing file contents**

  Compare filenames, sizes, and hashes for copied files.

- [ ] **Step 4: Write the redacted baseline**

  Include versions, listener addresses, provider/route counts, health status, backup location, and restoration prerequisites. Never include credential values.

- [ ] **Step 5: Verify the baseline contains no secret-shaped strings**

  Scan for API-key, bearer-token, password, and known credential formats; remove any matches that are values rather than field names.

### Task 2: Secure the OmniRoute Management and Inference Planes

**Files:**
- Modify: `%USERPROFILE%\.omniroute\.env` through a supported OmniRoute environment command or a narrowly scoped text edit
- Modify: OmniRoute credential storage through a supported dashboard/management API only
- Modify: `docs/omniroute-dsh/security-verification.md`

**Interfaces:**
- Consumes: Task 1 backup
- Produces: loopback-only server, non-default management password, authenticated `/v1` API, DSH-specific key

- [ ] **Step 1: Determine the supported 3.8.51 commands or management endpoints for environment settings, password change, and API-key creation**

  Confirm request shapes from installed source/docs before invoking them.

- [ ] **Step 2: Set persistent `OMNIROUTE_SERVER_HOST=127.0.0.1` and `REQUIRE_API_KEY=true`**

  Preserve `STORAGE_ENCRYPTION_KEY` exactly and do not display it.

- [ ] **Step 3: Generate and install a unique management password**

  Use a supported flow, store it outside the repository, and never print it. If the supported flow requires browser interaction, pause with exact instructions.

- [ ] **Step 4: Restart OmniRoute through its supported supervisor command**

- [ ] **Step 5: Verify security behavior**

  Expected: port 20128 listens on loopback only; `/api/health` returns 200; unauthenticated `/v1/models` returns 401; `CHANGEME` cannot authenticate.

- [ ] **Step 6: Create a dedicated `DSH` API key with auto-combo access and the narrowest supported model/combo restrictions**

  Capture the key directly into a process-local secure variable or credential store without echoing it.

- [ ] **Step 7: Record redacted PASS/FAIL results**

### Task 3: Verify Provider Terms, Cost Boundaries, and Installed Support

**Files:**
- Create: `docs/omniroute-dsh/provider-eligibility.md`

**Interfaces:**
- Consumes: official provider documentation, installed OmniRoute catalog, live connection state
- Produces: allowlist of providers and models permitted in routes

- [ ] **Step 1: Inspect pinned OmniRoute 3.8.51 documentation and live provider catalog**

  Cover OpenAI Codex subscription, OpenCode Free, Kiro, Qoder, Kimi, Qwen, Z.AI, GLM Flash, and DeepSeek V4.1 Flash.

- [ ] **Step 2: Verify each candidate against current primary documentation**

  Record authentication method, third-party-agent permission, recurring/free quota, reset period, and whether billing can occur.

- [ ] **Step 3: Resolve DeepSeek V4.1 Flash specifically**

  Separate official DeepSeek API pricing from app-specific offers such as WorkBuddy or OpenCode. Exclude any offer without a documented third-party API and applicable terms.

- [ ] **Step 4: Build the provider allowlist**

  Mark each candidate `ELIGIBLE`, `EXCLUDED`, or `AUTHORIZATION REQUIRED`, with source links and evidence date.

- [ ] **Step 5: Verify no allowed provider can fall through to paid usage**

### Task 4: Connect Keyless and Subscription Providers

**Files:**
- Modify: OmniRoute provider storage through supported interfaces
- Modify: `docs/omniroute-dsh/provider-tests.md`

**Interfaces:**
- Consumes: Task 3 allowlist
- Produces: tested provider connections and live model IDs

- [ ] **Step 1: Enable and test keyless OpenCode Free if it is present in the installed version**

- [ ] **Step 2: Connect OpenAI Codex through OmniRoute's official subscription OAuth flow**

  Pause for browser authorization. Do not use an OpenAI Platform API key.

- [ ] **Step 3: Connect other eligible OAuth/subscription providers one at a time**

  Request user interaction only when an authorization page is ready. Skip candidates classified `EXCLUDED`.

- [ ] **Step 4: Discover live models for each connection**

  Record exact IDs, context limits, tool capability, quota visibility, and connection health.

- [ ] **Step 5: Send one minimal text request per provider**

  Mark `PASS`, `FAIL`, or `BLOCKED`, and avoid repeated quota-consuming retries.

- [ ] **Step 6: Confirm connected accounts have no paid fallback**

### Task 5: Validate Built-In Routing and Create DSH Routes

**Files:**
- Modify: OmniRoute combo storage through supported APIs/UI
- Create: `docs/omniroute-dsh/routes.md`

**Interfaces:**
- Consumes: verified live model allowlist from Task 4
- Produces: `DSH-Coding`, `DSH-Analysis`, `DSH-Fast`, and `DSH-Auto`

- [ ] **Step 1: Query and test `auto`, `auto/coding`, `auto/fast`, and `auto/offline`**

  Confirm candidate membership. Exclude `auto/offline` if it requires local inference. Do not expose an auto route to DSH if it includes unverified paid candidates.

- [ ] **Step 2: Inspect supported combo strategies**

  Validate `fill-first` and available error/rate-limit fallback semantics against installed 3.8.51 behavior.

- [ ] **Step 3: Create `DSH-Coding`**

  Order verified tool-capable coding models by quality, then reliability. Configure fallback for rate limit, provider error, and unavailability.

- [ ] **Step 4: Create `DSH-Analysis`**

  Order verified reasoning and long-context models by quality.

- [ ] **Step 5: Create `DSH-Fast`**

  Order verified low-latency models and use `fill-first` or the installed equivalent.

- [ ] **Step 6: Create `DSH-Auto`**

  Use a supported automatic strategy restricted to the verified allowlist. If installed auto routing cannot enforce the allowlist, implement this as an explicit combo rather than a built-in auto alias.

- [ ] **Step 7: Verify exhaustion behavior**

  Disable a test-only candidate or use the supported health/circuit-breaker facility. Expected: fallback stays inside the allowlist; with every test candidate unavailable, the request fails explicitly.

- [ ] **Step 8: Record exact route definitions without secrets**

### Task 6: Configure DSH Through Its Supported Provider Interface

**Files:**
- Modify: DSH settings and credential store through its Models UI or documented CLI
- Modify: `docs/omniroute-dsh/dsh-integration.md`

**Interfaces:**
- Consumes: DSH API key and route IDs
- Produces: DSH custom provider `omniroute` with four models

- [ ] **Step 1: Reconfirm DSH 0.2.1-rc.2 custom-provider schema and credential command/UI**

- [ ] **Step 2: Add provider `omniroute`**

  Use base URL `http://127.0.0.1:20128/v1`, protocol `openai-completions`, the managed DSH credential reference, and the four exact route IDs.

- [ ] **Step 3: Verify the saved provider without reading back its secret**

- [ ] **Step 4: Send an authenticated DSH request through `DSH-Auto`**

- [ ] **Step 5: Change the DSH default model only after Step 4 passes**

- [ ] **Step 6: Evaluate `dsh-omniroute` compatibility**

  Do not install it if the custom provider supplies routing, authentication, discovery, tool calling, and streaming correctly.

### Task 7: Run the End-to-End Verification Matrix

**Files:**
- Create: `docs/omniroute-dsh/test-report.md`

**Interfaces:**
- Consumes: completed OmniRoute and DSH configuration
- Produces: evidence-backed final status

- [ ] **Step 1: Recheck versions, processes, health, listener, authentication, and provider status**

- [ ] **Step 2: Test short generation and a small deterministic coding request through every route**

- [ ] **Step 3: Test tool calling through each route that advertises support**

- [ ] **Step 4: Test safe fallback and all-candidates-unavailable behavior**

- [ ] **Step 5: Test DSH Desktop end to end through OmniRoute**

- [ ] **Step 6: Inspect usage records and route definitions for evidence of paid requests**

  Expected: zero paid-provider calls and no eligible route containing a paid candidate.

- [ ] **Step 7: Mark every required check `PASS`, `FAIL`, or `BLOCKED` with concise evidence**

### Task 8: Document Recovery and Remaining Manual Actions

**Files:**
- Create: `docs/omniroute-dsh/restore.md`
- Create: `docs/omniroute-dsh/final-report.md`

**Interfaces:**
- Consumes: baseline, backup metadata, routes, and test report
- Produces: secret-free operational handoff

- [ ] **Step 1: Write restoration instructions**

  Include how to stop OmniRoute, restore the timestamped files, restart, and verify health. Reference but do not embed the secret-bearing backup location contents.

- [ ] **Step 2: Write the final report**

  List connected providers, models, free-use conditions, quotas, fallback behavior, routes, DSH status, unresolved problems, and manual actions.

- [ ] **Step 3: Add credential-rotation instructions**

  Require revocation and replacement of the two DSH credentials exposed during the audit; do not identify them by value.

- [ ] **Step 4: Scan every repository deliverable for secrets**

- [ ] **Step 5: Re-run the security and end-to-end smoke checks after documentation is complete**
