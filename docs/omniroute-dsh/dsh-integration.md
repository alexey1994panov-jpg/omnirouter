# DSH Desktop integration

> Provider integration remains in use, but upstream selection has changed to Kiro only. Codex is now disabled and excluded; see [README](../../README.md).

Verified 2026-10-19, DSH Harness 0.2.1-rc.2.

The running Desktop uses `%USERPROFILE%\.dsh-desktop`. The separate `.dsh` home belongs to the legacy CLI configuration and is unchanged. Desktop's settings service persists provider rows in `.dsh-desktop\profiles\web\cordis.patch.yml`; credentials live in `.dsh-desktop\.credentials.yaml`.

The native OpenAI-compatible provider is sufficient. Configuration was applied through authenticated `settings/update` and `credentials/set` Remote methods, not by editing internal files.

```yaml
customProvider: omniroute
api: openai-completions
baseURL: http://127.0.0.1:20128/v1
apiKeyEnv: OMNIROUTE_API_KEY
models:
  - DSH-Coding
  - DSH-Analysis
  - DSH-Fast
  - DSH-Auto
currentDefault: deepseek-account/deepseek-flash
contextWindow: 128000
maxTokens: 16000
```

Context and output limits are conservative client settings, not proof that every upstream has been tested at that size. The key value is held only by the managed credential service and an external DPAPI backup.

Live Desktop session `session-ca384ce6-6e42-4ebb-b5d7-ac069f7299f7` returned exactly `DSH_OMNIROUTE_OK`. Streaming was exercised by the real Desktop agent. In the same project, its `pwsh` call `Write-Output (2+3)` returned `5`, followed by `DSH_TOOL_OK:5` (events 41, 45, 48; completed at 50). The earlier ACL failure was corrected without disabling sandboxing. A separate user-temp session also passed.

Existing conversations may retain their own selected model. The default model was later switched in DSH to `deepseek-account/deepseek-flash`, which does not go through OmniRoute; the `omniroute` provider and its four routes remain configured. Select OmniRoute → DSH-Auto in any conversation where an OmniRoute route is wanted.

## Optional plugin

[`@maci0/dsh-omniroute` v0.8.3](https://github.com/maci0/dsh-omniroute/tree/v0.8.3) declares DSH `>=0.2.0-rc.2 <0.3.0`, a web client, and Node `^22.19.0 || >=24.0.0` in its [manifest](https://raw.githubusercontent.com/maci0/dsh-omniroute/v0.8.3/package.json). Its documented purpose is model/connection/quota inspection and optional picker synchronization. Manifest-level compatibility is plausible; installation and runtime compatibility with this Desktop build were not tested.

The plugin was not installed because the native provider already passed inference, streaming, and tool execution. Its management probes would require broader OmniRoute permissions; automatic catalog synchronization could also expose models beyond the four curated routes. Keeping the restricted native provider satisfies this task.

`scripts/dsh-rpc.ps1` reuses the local launch URL from the Desktop log to acquire a session, without printing its token. It must run as the same Windows user while Desktop is running. Do not use it to dump unrestricted session histories or credential files.
