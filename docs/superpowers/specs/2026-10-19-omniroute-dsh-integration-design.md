# OmniRoute and DSH Integration Design

## Objective

Configure the installed OmniRoute 3.8.51 and DeepSeek Harness Desktop 0.2.1-rc.2 so DSH uses OmniRoute as its local OpenAI-compatible gateway. The resulting system must prefer zero-additional-cost models, fail closed rather than use paid capacity, preserve existing data, and expose OmniRoute only on the local machine.

## Verified Starting State

- OmniRoute 3.8.51 is installed globally and running on port 20128.
- Its health endpoint responds successfully.
- Port 20128 currently binds to `0.0.0.0`.
- The dashboard uses the default management password `CHANGEME`.
- `/v1/models` rejects an unauthenticated request, but the current database contains no user-created API keys.
- OmniRoute currently has no provider connections, custom provider nodes, combos, or quota snapshots.
- DSH Desktop bundles Harness 0.2.1-rc.2 and supports custom OpenAI-compatible providers.
- DSH currently defaults to a different external provider rather than OmniRoute.
- Existing DSH credentials remain in place. Two credentials exposed during diagnostics must be rotated by the user at their issuing providers.

## Safety Constraints

- Do not configure a paid API, payment method, automatic balance refill, or route that can fall through to paid capacity.
- Use subscription access only through an officially supported OAuth or subscription-provider flow.
- Do not install or start large local models.
- Do not delete existing provider connections, DSH providers, sessions, or user data.
- Store secrets only in OmniRoute or DSH credential storage, never in this repository or reports.
- Never print credential values in commands, logs, test output, or reports.
- Back up relevant configuration before the first mutation.
- When no free candidate remains, return an explicit availability error.

## Architecture

```text
DSH Desktop
  -> custom provider using OpenAI Chat Completions
  -> http://127.0.0.1:20128/v1
  -> OmniRoute API-key authentication
  -> DSH-* combo or built-in auto/* route
  -> eligible zero-cost provider connection
```

The basic integration uses DSH's supported custom-provider mechanism. The `dsh-omniroute` plugin will be installed only if inspection proves it is compatible with DSH 0.2.1-rc.2 and provides a required capability that the custom provider cannot supply.

## Configuration Method

Use application-supported UI, CLI, or HTTP management APIs whenever available. Direct SQLite mutation and modification of packaged application files are prohibited. A DSH profile configuration file may be changed only through a documented DSH command or the supported Models settings interface.

Before changes, copy the OmniRoute data directory and the DSH configuration files into a timestamped backup outside the repository. Backups may contain secrets and therefore must not be copied into project documentation.

## Security Design

1. Configure OmniRoute's npm installation with `OMNIROUTE_SERVER_HOST=127.0.0.1` and `REQUIRE_API_KEY=true`.
2. Replace `CHANGEME` with a unique generated management password through a supported mechanism. Store it outside the repository and do not display it.
3. Create a dedicated API key named for DSH, with access limited to the intended combos/models where OmniRoute 3.8.51 supports those restrictions.
4. Store that key in DSH's managed credential store.
5. Restart OmniRoute and verify that port 20128 listens only on loopback, unauthenticated `/v1` access fails, authenticated access succeeds, and dashboard login no longer accepts `CHANGEME`.

## Provider Eligibility

A provider is eligible only after all of the following are verified:

- It is accessible through OmniRoute 3.8.51 using a documented integration.
- Its current terms permit third-party agent or API use.
- The selected access path cannot charge money.
- Its model identifiers are returned by the installed OmniRoute instance or documented for the pinned version.
- A real minimal request succeeds.

Initial candidates are OpenCode Free and official subscription/OAuth integrations for OpenAI Codex, Kiro, Qoder, Kimi, Qwen, and Z.AI. Keyless providers may be enabled automatically. OAuth providers require the user to complete the browser authorization step. API-key providers are excluded unless the account can be proven incapable of incurring charges.

DeepSeek V4.1 Flash is not considered free merely because a catalog entry has zero displayed cost. The official DeepSeek API is excluded unless its account-level billing state proves requests cannot incur charges. A WorkBuddy promotion or another application-specific offer is excluded unless it exposes a documented third-party-agent API, its terms permit this use, and OmniRoute 3.8.51 supports it.

## Routing Design

Only verified eligible models may appear in custom combos.

- `DSH-Coding`: strongest tool-capable coding models first; fallback on rate limit, provider error, or unavailability.
- `DSH-Analysis`: highest-quality eligible reasoning and long-context models first.
- `DSH-Fast`: lowest-latency eligible models first.
- `DSH-Auto`: an automatic task-aware route using eligible candidates only.

Built-in `auto`, `auto/coding`, `auto/fast`, and `auto/offline`, plus strategies such as `fill-first`, will be tested before custom combos are finalized. `auto/offline` must not trigger local-model installation or execution and will be excluded if it requires a local model. Route identifiers and model identifiers will be taken from live discovery or the pinned 3.8.51 documentation.

Fallback tests will use a disabled or deliberately invalid test-only candidate, or a supported circuit-breaker/test facility. Real quotas will not be deliberately exhausted.

## DSH Integration

Create a custom DSH provider with:

- a permanent lowercase provider ID;
- base URL `http://127.0.0.1:20128/v1`;
- protocol `openai-completions` unless live compatibility tests prove `openai-responses` is required;
- the dedicated OmniRoute API key stored through DSH credential management;
- discovered route/model IDs for `DSH-Coding`, `DSH-Analysis`, `DSH-Fast`, and `DSH-Auto`.

Existing DSH providers remain configured. The default model changes to `DSH-Auto` only after an authenticated test succeeds. No DSH downgrade is permitted without a reproducible incompatibility and explicit user approval.

## Verification Matrix

The final report will mark every check `PASS`, `FAIL`, or `BLOCKED`:

1. Installed versions and running processes.
2. OmniRoute health endpoint.
3. Loopback-only listener.
4. Management password changed.
5. API key required and accepted.
6. Each provider's connection status and live discovered models.
7. Free-use terms and detected quota information.
8. Minimal text generation for each eligible provider.
9. A small coding request.
10. Tool calling where the candidate advertises support.
11. Safe fallback from an unavailable test candidate.
12. DSH-to-OmniRoute end-to-end request.
13. Evidence that configured routes contain no paid candidates.

## Deliverables

- A working local OmniRoute-to-DSH configuration.
- Timestamped secret-bearing backups outside the repository.
- A sanitized technical configuration summary in the repository.
- A restoration procedure that references backup locations but contains no secrets.
- A provider/model/quota/test report with explicit unresolved items and manual authorization steps.

## Manual Intervention Boundaries

Work pauses only when browser OAuth, credential rotation at an external provider, acceptance of provider terms, or another action requiring the user's identity or consent is necessary. The user will be told exactly what screen or action is required; automated work resumes afterward.
