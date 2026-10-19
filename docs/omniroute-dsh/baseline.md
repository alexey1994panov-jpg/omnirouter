# OmniRoute–DSH Baseline

Captured: 2026-10-19 (Europe/Moscow)

## Installed Components

| Component | Version / path |
|---|---|
| OmniRoute | 3.8.51, global npm package |
| Node.js | 24.11.1 |
| npm | 11.6.2 |
| Codex CLI | 0.142.2 |
| DSH Desktop Harness | 0.2.1-rc.2 |
| OmniRoute data | `C:\Users\PanovAA\.omniroute` |
| Legacy DSH CLI data | `C:\Users\PanovAA\.dsh` |
| Active DSH Desktop data (discovered during integration) | `C:\Users\PanovAA\.dsh-desktop` |

## Runtime State Before Changes

- OmniRoute supervisor and server processes were running.
- Port 20128 listened on `0.0.0.0`.
- `GET /api/health` returned HTTP 200.
- Unauthenticated `GET /v1/models` returned HTTP 401.
- The startup log reported the default dashboard password was active.
- Provider connections: 0.
- Custom provider nodes: 0.
- Custom combos: 0.
- User-created API keys: 0.
- Quota snapshots: 0.
- The legacy CLI default was an external provider. The running Desktop uses a separate home and profile; see the correction below.

## Backup

Pre-change backup: `C:\Users\PanovAA\OmniRoute-DSH-Backups\20261019-omniroute-dsh-prechange`

The pre-change backup contains OmniRoute environment configuration, a consistent SQLite backup, and legacy DSH CLI settings, managed credentials, and web profile files. File sizes and SHA-256 hashes were generated after copying. The backup contains secrets and must not be shared or committed.

Correction: the active Desktop home is `.dsh-desktop`, not `.dsh`. It was discovered after the supported settings API had added OmniRoute. Its current profile, credentials, and original imported locale document were then backed up under `dsh-desktop-post-integration`. This is a post-integration snapshot, not an exact pre-change Desktop backup. Existing Desktop credentials were preserved; only a new reference was added. Exact restoration of the prior Desktop model selection is therefore not guaranteed by the initial backup.

## Known Security Findings

- OmniRoute was reachable on non-loopback interfaces.
- The dashboard used its documented default password.
- Two existing DSH provider credentials appeared in diagnostic output and must be revoked and replaced by the user.

