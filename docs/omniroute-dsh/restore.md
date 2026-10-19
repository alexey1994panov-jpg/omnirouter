# Recovery and operation

Current preferred backup: the `kiro-only` subdirectory of the backup root below. It contains the disabled-Codex configuration. The older `configured` snapshot described below enables Codex and is historical; restoring it would undo the user's later exclusion of the subscription. See [current instructions](../../README.md).

Backup root: `C:\Users\PanovAA\OmniRoute-DSH-Backups\20261019-omniroute-dsh-prechange`. It contains secrets. Do not upload or commit it.

Its `configured` subdirectory contains the finished OmniRoute `.env` and consistent SQLite snapshot plus Desktop profile and managed credentials. The SQLite snapshot passed `integrity_check=ok`. Use this set, while both apps are stopped, to recover the configured integration instead of reverting to the empty initial router. Never mix an old database with a current WAL/SHM pair.

## Normal operation

Keep OmniRoute running at `http://127.0.0.1:20128` and use DSH provider `omniroute`, model `DSH-Auto`. Choose Coding, Analysis, or Fast when task intent is explicit. If all eligible accounts are unavailable, wait for quota reset or reauthorize the affected connection. Do not switch to the built-in root auto or add a paid provider as a workaround.

Use the password saved as `dashboard-password.dpapi` for the dashboard. It is encrypted for this Windows user. To retrieve it without printing it in a terminal, run in your own PowerShell:

```powershell
$backup = 'C:\Users\PanovAA\OmniRoute-DSH-Backups\20261019-omniroute-dsh-prechange'
$secret = ConvertTo-SecureString ((Get-Content -Raw "$backup\dashboard-password.dpapi").Trim())
$credential = [pscredential]::new('dashboard', $secret)
Set-Clipboard -Value $credential.GetNetworkCredential().Password
```

Paste into the dashboard, then run `Set-Clipboard -Value ''` to clear the clipboard.

The DSH key is already stored in Desktop credentials; no copy/paste is needed for normal use. A different Windows account or reinstalled user profile may not decrypt these backups.

## Restore OmniRoute

1. Close DSH to stop new requests. Stop OmniRoute using its CLI and confirm port 20128 has no listener.
2. Preserve a fresh copy of the current `.omniroute` directory before rollback. Do not overwrite a running SQLite database.
3. Restore the backed-up `.env` and consistent `storage.sqlite` from the backup's `omniroute` directory. Move any current `storage.sqlite-wal` and `storage.sqlite-shm` to the fresh rollback backup while the server is stopped; do not combine them with an older database.
4. The original configuration reintroduces the old management password and broad listener. Before starting, keep `OMNIROUTE_SERVER_HOST=127.0.0.1` and `REQUIRE_API_KEY=true`; change the management password through the UI after startup.
5. Start OmniRoute and verify loopback listener, health 200, anonymous models 401. Restoring the original database removes newly created connections/routes/key, so Desktop's new key will then need replacement or its provider must be removed.

## Restore or remove the Desktop integration

The initial backup of `.dsh` is the legacy CLI home; **do not copy it over `.dsh-desktop`**. Active Desktop was discovered after its settings API had been changed. Its `dsh-desktop-post-integration` snapshot can restore the working new integration, but is not a complete pre-change Desktop snapshot.

To remove the integration, use Desktop Settings → Models: choose the desired original/default provider first, then remove `omniroute`. Remove credential reference `OMNIROUTE_API_KEY` only after no provider uses it. Revoke the DSH key in OmniRoute if it is no longer needed. Existing legacy CLI providers and credentials were retained. The exact prior Desktop model selection was not captured, so choose it explicitly rather than claiming an exact rollback.

The original project ACL is saved as `workspace-acl-before-dsh.xml`. The added owner `WRITE_OWNER` right is needed for DSH sandbox preparation in this folder. Revoking that one explicit right is possible with `icacls <this exact folder> /remove:g *<owner SID>` only after verifying it still represents the sole explicit grant for that SID. Prefer an administrator reviewing the saved ACL: wholesale replacement could erase grants added later by DSH/Codex. Never reset the ACL recursively or disable sandboxing as a workaround.

## Credential rotation required

Two existing credentials from legacy DSH configuration appeared in diagnostic output during the initial audit: Moonshot and the existing custom VI provider. Revoke each at its provider, issue replacements only if you still need those services, and update their managed references in the appropriate DSH profile. Neither value is reproduced here; neither participates in the new OmniRoute routes. Rotation cannot be completed without the respective account consoles.
