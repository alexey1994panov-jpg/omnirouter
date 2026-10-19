# Provider Eligibility Review

> Initial eligibility research, not current enabled-provider inventory. Codex has since been disabled at the user's request. Only Kiro remains allowed for DSH; see [README](../../README.md).

Evidence date: 2026-10-19

Eligibility means that the selected access path cannot create an additional charge. A zero catalog price alone is not sufficient.

| Provider/access path | Status | Cost and authorization finding |
|---|---|---|
| OpenCode Free, OmniRoute keyless integration | EXCLUDED | Live `auto/coding` selected `oc/big-pickle`, but upstream returned HTTP 403 stating the free tier can only be used from within OpenCode. It is not usable by DSH through OmniRoute. |
| OpenAI Codex via ChatGPT subscription OAuth | ELIGIBLE | Authorized through official OpenAI OAuth. OmniRoute reports an active ChatGPT Plus workspace. A direct `cx/gpt-6-luna` request returned HTTP 200. No OpenAI Platform API key is configured. |
| Kiro OAuth/free allowance | ELIGIBLE | Authorized through Kiro's official Google device flow. OmniRoute reports the OAuth connection active and quota-visible. A direct `kr/qwen3-coder-next` request returned HTTP 200. This path is limited by the Kiro account allowance and has no configured payment key in OmniRoute. |
| Qoder OAuth/PAT | AUTHORIZATION REQUIRED | OmniRoute supports Qoder OAuth/PAT, but the installed documentation's “unlimited free” claim is not sufficient without account authorization and live terms/quota confirmation. Do not use a paid PAT. |
| Qwen Code subscription/OAuth | AUTHORIZATION REQUIRED | Supported by OmniRoute, but requires user authorization and live verification that the selected account path cannot incur charges. |
| Z.AI / GLM OAuth or free account | AUTHORIZATION REQUIRED | OmniRoute advertises GLM free access, but account authorization and live quota/billing inspection are required. API-key access is excluded unless billing is demonstrably impossible. |
| Kimi Code OAuth/coding plan | AUTHORIZATION REQUIRED | OmniRoute supports Kimi Code OAuth/API-key access. The direct Moonshot API is not assumed free. The currently saved DSH Moonshot credential is excluded and must be rotated because it appeared in diagnostic output. |
| Existing custom DSH provider | EXCLUDED | It bypasses OmniRoute, its endpoint and billing guarantees are not established, and its credential appeared in diagnostic output. It is preserved but will not be used by DSH routes. |
| Official DeepSeek API `deepseek-flash` | EXCLUDED | Official DeepSeek documentation prices input and output tokens and explicitly states that legacy V4 Flash IDs route to V4.1 Flash and are billed at Flash rates. |
| WorkBuddy/CodeBuddy DeepSeek V4.1 Flash promotion | EXCLUDED | DeepSeek identifies WorkBuddy as a partner, but no official third-party-agent API, transferable API key, quota, or OmniRoute integration for the promotional entitlement was verified. The reported 31 October offer therefore cannot be treated as a free OmniRoute API. |
| OpenCode Zen paid catalog | EXCLUDED BY DEFAULT | OpenCode Zen generally requires billing details and charges per request. Only model IDs explicitly marked free and available through the installed keyless OmniRoute integration may be considered after live discovery. |
| Local DeepSeek or other large local models | EXCLUDED | Explicitly prohibited by the project constraints. |

## Primary and Pinned Sources

- OmniRoute 3.8.51 user guide: <https://github.com/diegosouzapw/OmniRoute/blob/release/v3.8.51/docs/guides/USER_GUIDE.md>
- Installed OmniRoute 3.8.51 README and provider catalog under the global npm package.
- OpenCode Zen models and billing: <https://docs.opencode.ai/docs/zen/>
- OpenCode terms: <https://dev.opencode.ai/legal/terms-of-service>
- OpenAI Codex sign-in: <https://help.openai.com/en/articles/11381614-api-codex-cli-and-sign-in-with-chatgpt>
- DeepSeek V4.1 Flash announcement: <https://api-docs.deepseek.com/news/news260910/>
- DeepSeek pricing: <https://api-docs.deepseek.com/quick_start/pricing/>

## Allowlist Rule

The executable allowlist contains only live-tested `cx/*` Codex subscription models and `kr/*` Kiro allowance models. Built-in `auto/*` routes are not allowlisted because their candidate pool includes the unusable OpenCode Free path and may change independently. Custom `DSH-*` combos explicitly list eligible providers and models.


