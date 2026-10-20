# SDD ledger — plan: docs/superpowers/plans/2026-10-19-omniroute-dsh-integration.md

Setup ruling: the workspace is not a Git repository, so worktrees, task commits, task-start/task-done Git ranges, and a branch review package are unavailable. Progress is recorded in this ledger, all mutations are backed up first, and verification uses explicit commands. Cost if wrong: no Git rollback for repository documentation; application rollback remains available from the external configuration backup.

TDD ruling: Tasks primarily mutate third-party application configuration rather than production code. The user approved the implementation plan but did not separately waive the skill's configuration exception, so every behavior change will use an equivalent RED/GREEN operational check where safe: capture the failing precondition, apply the supported configuration change, then rerun the same check. Cost if wrong: configuration behavior has repeatable evidence but not unit-test isolation.

Pre-flight: Task 1 backup/baseline feeds every later task — backup must be verified before Task 2.
Pre-flight: Task 2 produces the DSH API key consumed by Task 6 — key must move directly into managed credential storage without repository or report output.
Pre-flight: Task 3 allowlist is consumed by Tasks 4 and 5 — no connection or combo may be added before eligibility is recorded.
Pre-flight: Task 4 live model IDs are consumed by Task 5 — route definitions must use discovery results, not catalog assumptions.
Pre-flight: Task 5 route IDs are consumed by Tasks 6 and 7 — DSH configuration and tests must use exact created IDs.
Pre-flight: Tasks 1–7 produce evidence consumed by Task 8 — reports must state unresolved failures and blocked OAuth steps rather than infer success.

Task 1: complete (external backup created and hashed; redacted baseline written; secret scan required before final handoff).

Task 2: Ruling: generated management and DSH secrets are stored as Windows current-user DPAPI ciphertext in the external backup directory, because the user requested automation without placing secrets in the repository. Cost if wrong: another Windows account or a reinstalled user profile cannot decrypt them; restoration can still revert the original configuration backup.
Task 2: Ruling: `omniroute restart` is a foreground command in this installation, so post-restart checks run in a separate invocation. Cost if wrong: none to persistent configuration; the evidence remains from fresh probes.
Task 2: complete (listener `127.0.0.1:20128`; health 200; anonymous models 401; old password 401; DSH key create 201 and authenticated models 200).

Task 3: Ruling: provider marketing claims in the OmniRoute catalog are discovery hints, not proof that an account cannot be billed. Only the keyless OpenCode Free path is eligible for a live test before OAuth; every other candidate remains authorization-required or excluded. Cost if wrong: fewer providers are connected now, but no unintended spend is possible.
Task 3: Ruling: DeepSeek V4.1 Flash official API is excluded because official pricing is nonzero; the WorkBuddy promotion is app-specific and has no verified transferable API entitlement for OmniRoute. Cost if wrong: the promotional model is unavailable through DSH rather than risking a billed API call or terms violation.
Task 3: complete (provider allowlist documented from pinned OmniRoute and current primary sources).

Task 4: Ruling: live evidence overrides bundled marketing — OpenCode Free is excluded after its upstream returned 403 for use outside OpenCode. Cost if wrong: one advertised free backend is unavailable, but DSH does not repeatedly hit a guaranteed rejection.
Task 4: complete (Codex Plus OAuth and Kiro OAuth active; direct minimal requests returned 200; exact model IDs discovered; other candidates blocked rather than risking billing or web-cookie terms).
Task 5: Ruling: the built-in root `auto` route is not exposed because restricted-key handling rejected it and its dynamic pool included OpenCode Free. `DSH-Auto` uses the same installed strategy over an explicit eligible target list. Cost if wrong: newly added free providers do not join automatically until the combo is reviewed and updated.
Task 5: partial (four combos created and basic generation passed; safe fallback, all-unavailable, and tool calling remain to be verified).

Task 5: Ruling: remove catalog-advertised kr/claude-sonnet-5 after a single-target live 400 invalid-model response; retain verified Qwen/Haiku — catalog visibility did not prove entitlement — cost if wrong: a potentially usable model remains unavailable until its correct ID is verified.
Task 5: complete (all four routes passed deterministic coding and add(2,3) tool calls; temporary connection-scope unavailability switched to Codex, all-unavailable returned 403; disposable combos removed; key now permits only four production combos and two authorized connections).

Task 6: Ruling: active Desktop home is .dsh-desktop, separate from backed-up legacy .dsh; configure the running Desktop through its authenticated settings/credentials API — supported UI service preserves existing references — cost: initial backup does not capture exact pre-change Desktop default. Saved post-integration Desktop profile/credentials externally and corrected baseline/recovery docs.
Task 6: Ruling: native OpenAI-compatible provider passes generation, streaming, and tools, so do not install optional dsh-omniroute — manifest inspected but runtime compatibility untested; plugin would need management scopes — cost if wrong: no in-DSH quota dashboard/catalog sync.
Task 6: Ruling: grant existing project owner non-inheriting WRITE_OWNER after backing up ACL — installed DSH Windows sandbox requires it to apply its integrity label, existing owner rights lacked it — cost if wrong: owner retains additional label-management authority on this directory; existing other ACLs preserved. Set-Acl failed domain trust lookup; numeric-SID icacls succeeded. DSH sandbox remains enabled.
Task 6: complete (supported provider and managed credential saved; live Desktop session exact DSH_OMNIROUTE_OK; real pwsh tool returned 5 and final DSH_TOOL_OK:5 in the actual project after ACL repair; final default omniroute/DSH-Auto).

Task 7: Ruling: use /api/usage/<connectionId> for quotas, not generic summary, and distinguish catalog-estimated costs from financial billing — summary had null totals and misleading 100%; estimates are nonzero even for OAuth — cost if wrong: no claim of independent billing-ledger audit. No paid API-key connection is allowed.
Task 7: complete (15 core checks PASS; tested Kiro Qwen/Haiku tool calls; rejected Sonnet removed; quotas recorded with reset times; independent financial ledger and optional plugin runtime explicitly BLOCKED).
Task 8: reports and secret-free configuration snapshot written; final review, secret scan, and handoff pending.

Final review: fresh read-only reviewer found no Critical issue; Important cleanup defect confirmed RED (first DELETE error skipped second DELETE and key-policy restoration), fixed with per-delete error handling and nested finally, GREEN fault injection in both actual cleanup blocks. Minor stale quota/backup descriptions corrected; structural verification now compares exact route names, strategies, and ordered memberships with the snapshot.
Final review declined-to-judge ruling: do not claim independent billing/contractual audit, real 429 exhaustion, optional plugin runtime, executed rollback, long-context performance, or future availability — none was exercised; disclose the boundaries in reports. Cost if wrong: a limit or future provider change requires revalidation rather than relying on a guarantee.
Backup: final consistent SQLite snapshot saved under external backup root/configured; integrity_check=ok. Desktop profile, credentials, and OmniRoute environment copied alongside it.
Retention ruling: preserve this ledger because no Git history exists — deleting it would remove the only execution decision record. Cost: a small additional documentation directory.
Task 8: complete (final 15-check suite PASS after review fixes, both cleanup fault-injection regressions PASS, PowerShell syntax errors=0, backup integrity=ok; final handoff links reports and required legacy credential rotation).
Branch completion ruling: no Git repository or development branch exists, so merge/PR/worktree cleanup is inapplicable. Keep application configuration and documentation in place; no repository was initialized or user history altered.

User follow-up: exclude the paid ChatGPT subscription from OmniRoute/DSH and document model toggles. Completed: Codex connection inactive; all cx targets removed; DSH key permits only Kiro; four route names preserved with Qwen/Haiku. Updated snapshot, diagnostics and verification; README added; historical reports labeled superseded. Current backup saved under external kiro-only directory, integrity_check=ok. Verification: 17/17 PASS; real Desktop KIRO_ONLY_OK; Kiro-only fallback200, all-unavailable503, cleanup200, fresh Auto200. Codex application's own connection unchanged. OAuth record retained for reversible user-controlled reactivation; no tokens revoked or deleted.

Repository: project published to github.com/alexey1994panov-jpg/omnirouter. Ruling: the workspace had no Git history, so the first commit is a plain import of the existing files rather than reconstructed history. MIT license and a dependency-free CI job (JSON validity, PowerShell parse, secret-shaped-string scan) added; CI cannot reach OmniRoute, so the live suite stays a manual step. Cost if wrong: CI proves syntax and hygiene only, not runtime behavior.

Portability: hard-coded `C:\Users\...` paths replaced with `%USERPROFILE%`/`%APPDATA%` in scripts and `%USERPROFILE%` in docs. Ruling: sanitize paths rather than keep a machine-specific snapshot, because the repo is public. Cost if wrong: the snapshot no longer records the literal path, only the environment variable it resolves from.

Free models: the three Kiro models verified by live tool-call probes (sonnet-4.5, deepseek-3.2, minimax-m2.5) were added to the four routes; all four re-tested through the real DSH key and 17/17 checks PASS afterwards. Quota cost of the whole research and re-verification: 0.24 of 50 credits. Ruling: keep all models on the single Kiro account and document that this adds quality and fallback, not quota.

DSH default: the user switched the DSH default to `deepseek-account/deepseek-flash`, outside OmniRoute. Ruling: do not revert a user's model choice; record it and replace the "default must be DSH-Auto" check with a provider+default check (omniroute provider intact, and any omniroute default must be one of the four routes). Cost if wrong: the suite no longer asserts that DSH-Auto is selected by default, because that is now an explicit user decision rather than a configuration invariant.

Not done: GLM Flash connection (needs a free Z.AI key held by the user) and the optional dsh-omniroute plugin (still uninstalled).
