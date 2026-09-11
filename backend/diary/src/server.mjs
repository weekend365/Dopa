import { createServer } from 'node:http';
import { mkdirSync } from 'node:fs';
import { resolve } from 'node:path';
import { pathToFileURL, fileURLToPath } from 'node:url';
import { DiaryStore, ApiError } from './store.mjs';
import { editPhoto, ProviderFailure } from './style.mjs';

async function body(req, limit) {
  if (Number(req.headers['content-length'] ?? 0) > limit) throw new ApiError('too_large', 413);
  const chunks = []; let size = 0;
  for await (const part of req) {
    size += part.length;
    if (size > limit) throw new ApiError('too_large', 413);
    chunks.push(part);
  }
  return Buffer.concat(chunks);
}

export function createDiaryServer({ store, provider, enabled = true }) {
  let processing = false;
  async function tick() {
    if (processing || !enabled) return;
    processing = true;
    try {
      store.cleanup();
      const job = store.claim();
      if (!job) return;
      try { store.finish(job, await provider(job.photo), null); }
      catch (e) { store.finish(job, null, e instanceof ProviderFailure ? e : new ProviderFailure('provider_uncertain', true)); }
    } finally { processing = false; }
  }
  const server = createServer(async (req, res) => {
    res.setHeader('Cache-Control', 'no-store');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    const send = (status, value) => { res.writeHead(status); res.end(JSON.stringify(value)); };
    try {
      const path = new URL(req.url, 'http://localhost').pathname;
      if (req.method === 'GET' && path === '/v1/health') return send(200, { enabled });
      if (req.method === 'POST' && path === '/v1/sessions') {
        if (!enabled) throw new ApiError('not_configured', 503);
        let data;
        try { data = JSON.parse(await body(req, 1024)); } catch { throw new ApiError('invalid_request'); }
        if (!data || Object.keys(data).some(k => !['offsetMinutes', 'consentVersion'].includes(k))) throw new ApiError('invalid_request');
        return send(201, store.register(data.offsetMinutes, data.consentVersion));
      }
      const session = store.authenticate(req.headers.authorization?.replace(/^Bearer /, ''));
      if (path === '/v1/session' && req.method === 'DELETE') {
        store.removeAccount(session.owner); return send(200, { deleted: true });
      }
      const match = /^\/v1\/jobs\/([a-f0-9]{32})(\/image|\/ack)?$/.exec(path);
      if (!match) throw new ApiError('not_found', 404);
      const [, id, action] = match;
      if (req.method === 'PUT' && !action) {
        if (!enabled) throw new ApiError('not_configured', 503);
        if (req.headers['content-type'] !== 'image/png') throw new ApiError('invalid_image');
        const result = await store.submit(session, id, await body(req, 10 * 1024 * 1024));
        return send(202, result);
      }
      if (req.method === 'DELETE' && !action) { store.remove(session.owner, id); return send(200, { deleted: true }); }
      if (req.method === 'POST' && action === '/ack') { store.acknowledge(session.owner, id); return send(200, { received: true }); }
      const job = store.read(session.owner, id);
      if (req.method === 'GET' && action === '/image') {
        if (job.state !== 'succeeded' || !job.result) throw new ApiError('result_expired', 410);
        res.setHeader('Content-Type', 'image/webp'); res.writeHead(200); return res.end(job.result);
      }
      if (req.method === 'GET' && !action) return send(200, store.view(job));
      throw new ApiError('not_found', 404);
    } catch (e) {
      if (!res.headersSent) send(e instanceof ApiError ? e.status : 500, { code: e instanceof ApiError ? e.code : 'internal_error' });
      else res.end();
    }
  });
  server.requestTimeout = 30_000;
  server.headersTimeout = 15_000;
  return { server, tick };
}

if (import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  mkdirSync(new URL('../data/', import.meta.url), { recursive: true });
  const store = new DiaryStore(fileURLToPath(new URL('../data/diary.sqlite', import.meta.url)), {
    maxCalls: Number(process.env.DOPA_MAX_DAILY_CALLS ?? 25),
  });
  const key = process.env.OPENAI_API_KEY;
  const { server, tick } = createDiaryServer({ store, enabled: Boolean(key), provider: photo => editPhoto(photo, { key }) });
  const timer = setInterval(() => { void tick().catch(() => { /* fixed-state recovery on restart; never log payloads */ }); }, 1000);
  const cleanup = setInterval(() => store.cleanup(), 60_000);
  server.listen(8787, '127.0.0.1', () => process.stdout.write(`Dopa diary: http://127.0.0.1:8787; image API ${key ? 'configured' : 'not configured'}\n`));
  process.on('SIGINT', () => { clearInterval(timer); clearInterval(cleanup); server.close(() => process.exit(0)); });
}
