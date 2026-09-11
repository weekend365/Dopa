import { DatabaseSync } from 'node:sqlite';
import { randomBytes, createHash } from 'node:crypto';
import sharp from 'sharp';
import { STYLE_VERSION } from './style.mjs';

const hash = (s) => createHash('sha256').update(s).digest('hex');
export class ApiError extends Error {
  constructor(code, status = 400) { super(code); this.code = code; this.status = status; }
}
export class DiaryStore {
  constructor(path, { now = Date.now, maxCalls = 25, maxSessions = 50 } = {}) {
    if (!Number.isInteger(maxCalls) || maxCalls < 1 || !Number.isInteger(maxSessions) || maxSessions < 1) throw new Error('Invalid daily limits');
    this.now = now; this.maxCalls = maxCalls; this.maxSessions = maxSessions;
    this.db = new DatabaseSync(path);
    this.db.exec(`PRAGMA journal_mode=WAL; PRAGMA secure_delete=ON;
      CREATE TABLE IF NOT EXISTS sessions(token_hash TEXT PRIMARY KEY, offset INTEGER NOT NULL, created INTEGER NOT NULL);
      CREATE TABLE IF NOT EXISTS jobs(id TEXT NOT NULL, owner TEXT NOT NULL, day TEXT NOT NULL,
        state TEXT NOT NULL, photo BLOB, result BLOB, created INTEGER NOT NULL,
        error TEXT, usage TEXT, PRIMARY KEY(owner,id));
      CREATE TABLE IF NOT EXISTS calls(day TEXT PRIMARY KEY, count INTEGER NOT NULL);
      CREATE TABLE IF NOT EXISTS registrations(day TEXT PRIMARY KEY, count INTEGER NOT NULL);`);
    // Exactly-once provider execution is not guaranteed by an HTTP connection.
    this.db.exec("UPDATE jobs SET state='uncertain', photo=NULL, error='provider_uncertain' WHERE state='processing'");
    this.cleanup();
  }
  transaction(fn) {
    this.db.exec('BEGIN IMMEDIATE');
    try { const result = fn(); this.db.exec('COMMIT'); return result; }
    catch (e) { this.db.exec('ROLLBACK'); throw e; }
  }
  day(offset = 0) { return new Date(this.now() + offset * 60_000).toISOString().slice(0, 10); }
  register(offset, consent) {
    if (!Number.isInteger(offset) || offset < -720 || offset > 840 || consent !== 'photo-transfer-v1') throw new ApiError('invalid_consent');
    return this.transaction(() => {
      const day = this.day();
      const count = this.db.prepare('SELECT count FROM registrations WHERE day=?').get(day)?.count ?? 0;
      if (count >= this.maxSessions) throw new ApiError('service_limit', 429);
      this.db.prepare('INSERT INTO registrations VALUES (?,1) ON CONFLICT(day) DO UPDATE SET count=count+1').run(day);
      const token = randomBytes(32).toString('hex');
      this.db.prepare('INSERT INTO sessions VALUES (?,?,?)').run(hash(token), offset, this.now());
      return { token };
    });
  }
  authenticate(token) {
    if (!/^[a-f0-9]{64}$/.test(token ?? '')) throw new ApiError('unauthorized', 401);
    const owner = hash(token);
    const session = this.db.prepare('SELECT * FROM sessions WHERE token_hash=?').get(owner);
    if (!session) throw new ApiError('unauthorized', 401);
    return { owner, offset: session.offset };
  }
  read(owner, id) {
    const job = this.db.prepare('SELECT * FROM jobs WHERE owner=? AND id=?').get(owner, id);
    if (!job) throw new ApiError('not_found', 404);
    return job;
  }
  view(job) { return { id: job.id, state: job.state, code: job.error, styleVersion: STYLE_VERSION }; }
  async submit(session, id, bytes) {
    if (!/^[a-f0-9]{32}$/.test(id)) throw new ApiError('invalid_id');
    const old = this.db.prepare('SELECT * FROM jobs WHERE owner=? AND id=?').get(session.owner, id);
    if (old) return this.view(old);
    let photo;
    try {
      // Decode before persisting; orientation applied, metadata stripped, bounded pixels.
      photo = await sharp(bytes, { limitInputPixels: 24_000_000, animated: false })
        .rotate().resize(1536, 1536, { fit: 'inside', withoutEnlargement: true })
        .jpeg({ quality: 88 }).toBuffer();
    } catch { throw new ApiError('invalid_image'); }
    return this.transaction(() => {
      const duplicate = this.db.prepare('SELECT * FROM jobs WHERE owner=? AND id=?').get(session.owner, id);
      if (duplicate) return this.view(duplicate);
      // Recheck after async decoding, including account deletion during upload.
      if (!this.db.prepare('SELECT 1 FROM sessions WHERE token_hash=?').get(session.owner)) throw new ApiError('unauthorized', 401);
      const day = this.day(session.offset);
      if (this.db.prepare("SELECT 1 FROM jobs WHERE owner=? AND day=? AND state NOT IN ('failed','cancelled','expired')").get(session.owner, day)) throw new ApiError('daily_limit', 409);
      const attempts = this.db.prepare('SELECT COUNT(*) AS n FROM jobs WHERE owner=? AND day=?').get(session.owner, day).n;
      if (attempts >= 3) throw new ApiError('retry_limit', 429);
      this.db.prepare("INSERT INTO jobs VALUES (?,?,?,'queued',?,NULL,?,NULL,NULL)").run(id, session.owner, day, photo, this.now());
      return this.view(this.read(session.owner, id));
    });
  }
  claim() {
    return this.transaction(() => {
      const job = this.db.prepare("SELECT * FROM jobs WHERE state='queued' ORDER BY created LIMIT 1").get();
      if (!job) return null;
      const day = this.day();
      const count = this.db.prepare('SELECT count FROM calls WHERE day=?').get(day)?.count ?? 0;
      if (count >= this.maxCalls) {
        this.db.prepare("UPDATE jobs SET state='failed',photo=NULL,error='service_limit' WHERE owner=? AND id=?").run(job.owner, job.id);
        return null;
      }
      this.db.prepare('INSERT INTO calls VALUES (?,1) ON CONFLICT(day) DO UPDATE SET count=count+1').run(day);
      this.db.prepare("UPDATE jobs SET state='processing' WHERE owner=? AND id=?").run(job.owner, job.id);
      return job;
    });
  }
  finish(job, result, error) {
    const state = error ? (error.uncertain ? 'uncertain' : 'failed') : 'succeeded';
    this.db.prepare("UPDATE jobs SET state=?,photo=NULL,result=?,error=?,usage=? WHERE owner=? AND id=? AND state='processing'")
      .run(state, result?.image ?? null, error?.code ?? null,
        result?.usage ? JSON.stringify(result.usage) : null, job.owner, job.id);
  }
  acknowledge(owner, id) {
    const job = this.read(owner, id);
    if (job.state !== 'succeeded') throw new ApiError('not_ready', 409);
    this.db.prepare('UPDATE jobs SET photo=NULL,result=NULL WHERE owner=? AND id=?').run(owner, id);
    this.checkpoint();
  }
  remove(owner, id) {
    // Tombstone even unknown IDs: a concurrent delayed upload must be rejected.
    this.db.prepare("INSERT OR IGNORE INTO jobs VALUES (?,?,?,'cancelled',NULL,NULL,?,NULL,NULL)").run(id, owner, this.day(), this.now());
    this.db.prepare("UPDATE jobs SET state=CASE WHEN state IN ('succeeded','uncertain','processing','consumed') THEN 'consumed' ELSE 'cancelled' END,photo=NULL,result=NULL,usage=NULL WHERE owner=? AND id=?")
      .run(owner, id);
    this.checkpoint();
  }
  removeAccount(owner) {
    this.transaction(() => {
      this.db.prepare('DELETE FROM jobs WHERE owner=?').run(owner);
      this.db.prepare('DELETE FROM sessions WHERE token_hash=?').run(owner);
    });
    this.checkpoint();
  }
  cleanup() {
    this.db.prepare("UPDATE jobs SET photo=NULL,result=NULL,state=CASE WHEN state='queued' THEN 'expired' ELSE state END WHERE created<?")
      .run(this.now() - 86_400_000);
    // Minimal quota/idempotency tombstones retained 7 days, never photos.
    this.db.prepare("DELETE FROM jobs WHERE created<? AND state<>'processing'").run(this.now() - 7 * 86_400_000);
    this.db.prepare('DELETE FROM calls WHERE day<?').run(new Date(this.now()-7*86_400_000).toISOString().slice(0,10));
    this.db.prepare('DELETE FROM registrations WHERE day<?').run(new Date(this.now()-7*86_400_000).toISOString().slice(0,10));
    this.checkpoint();
  }
  checkpoint() { this.db.exec('PRAGMA wal_checkpoint(TRUNCATE)'); }
  close() { this.db.close(); }
}
