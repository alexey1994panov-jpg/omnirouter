// Run as the Windows account owning OmniRoute. Destination must be outside the project.
const path = require('node:path');
const fs = require('node:fs');
const userProfile = process.env.USERPROFILE;
if (!userProfile) throw new Error('USERPROFILE is not set');
const Database = require(path.join(
  process.env.APPDATA, 'npm', 'node_modules', 'omniroute', 'node_modules', 'better-sqlite3'
));
const destination = process.argv[2];
if (!destination || !path.isAbsolute(destination)) throw new Error('Absolute backup destination required');
const backupRoot = path.join(userProfile, 'OmniRoute-DSH-Backups');
const relative = path.relative(backupRoot, destination);
if (!relative || path.isAbsolute(relative) || relative === '..' || relative.startsWith(`..${path.sep}`)) throw new Error('Destination must be inside the external backup directory');
if (fs.existsSync(destination)) throw new Error('Destination already exists; choose a new snapshot filename');
const source = path.join(userProfile, '.omniroute', 'storage.sqlite');
if (path.resolve(destination).toLowerCase() === path.resolve(source).toLowerCase()) throw new Error('Cannot overwrite source');
const db = new Database(source, { readonly: true });
(async () => {
  try {
    await db.backup(destination);
    const backup = new Database(destination, { readonly: true });
    try {
      const result = backup.pragma('integrity_check', { simple: true });
      if (result !== 'ok') throw new Error('Backup integrity check failed');
      console.log(JSON.stringify({ backupIntegrity: result }));
    } finally { backup.close(); }
  } finally { db.close(); }
})().catch(() => { console.error('Database backup failed'); process.exitCode = 1; });
