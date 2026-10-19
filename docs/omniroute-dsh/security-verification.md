# OmniRoute Security Verification

> Initial verification record. The current DSH key allows only the Kiro connection; Codex is disabled and absent from routes. See [current state](codex-disabled.md).

Verified: 2026-10-19 (Europe/Moscow)

| Check | Status | Evidence |
|---|---|---|
| OmniRoute / legacy CLI pre-change backup | PASS | Consistent SQLite backup plus configuration files; sizes and SHA-256 hashes recorded outside the repository. Active Desktop has only a post-integration snapshot; see baseline.md. |
| Loopback binding | PASS | TCP port 20128 listens on `127.0.0.1` only after restart. |
| Health endpoint | PASS | `GET /api/health` returned HTTP 200 after restart. |
| Anonymous inference access | PASS | Unauthenticated `GET /v1/models` returned HTTP 401. |
| Default management password removed | PASS | Login with `CHANGEME` returned HTTP 401 after password change and restart. |
| Replacement management secret stored | PASS | Random secret stored as a current-user DPAPI ciphertext outside the repository. |
| Dedicated DSH API key | PASS | API returned HTTP 201; the key was stored as current-user DPAPI ciphertext outside the repository. |
| Authenticated model catalog | PASS | Final authenticated `GET /v1/models` returns exactly the four `DSH-*` combos. |

Persistent non-secret environment settings:

```text
OMNIROUTE_SERVER_HOST=127.0.0.1
REQUIRE_API_KEY=true
```

The final DSH key permits only `DSH-Coding`, `DSH-Analysis`, `DSH-Fast`, and `DSH-Auto`, and only the two authorized Codex/Kiro connections. It has `self:usage`, no management scope, and no direct-model permission. Built-in `auto/*` grants were removed.

Desktop settings and credentials were written through the authenticated local DSH API, using the same settings/credentials services as its UI. No packaged application code was edited.

The project owner lacked `WRITE_OWNER`, required by DSH's Windows sandbox to set its mandatory integrity label. A backup of the original ACL was saved outside the workspace as `workspace-acl-before-dsh.xml`; a non-inheriting `WRITE_OWNER` ACE was added for the existing owner only. The sandbox then prepared its own capability grants and a real tool call succeeded. No sandbox was disabled. `Set-Acl` initially failed due to a Windows domain trust lookup; `icacls` with the numeric owner SID succeeded.

