import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, rmSync, rmdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import sharp from 'sharp';
import { DiaryStore } from '../src/store.mjs';
import { createDiaryServer } from '../src/server.mjs';
import { editPhoto, ProviderFailure } from '../src/style.mjs';

const id = (n) => n.toString(16).padStart(32, '0');
const photo = await sharp({ create: { width: 80, height: 60, channels: 3, background: '#d5ddc6' } }).png().toBuffer();
const art = await sharp(photo).webp().toBuffer();
function setup(t, options) {
  const store = new DiaryStore(':memory:', options);
  t.after(() => store.close());
  const { token } = store.register(540, 'photo-transfer-v1');
  return { store, token, session: store.authenticate(token) };
}

test('only explicit versioned consent can create an anonymous identity', t => {
  const { store } = setup(t);
  assert.throws(() => store.register(540, 'no'), /invalid_consent/);
  assert.throws(() => store.authenticate('anything'), /unauthorized/);
});
test('concurrent duplicate submit creates one durable job and one call', async t => {
  const { store, session } = setup(t);
  const jobs = await Promise.all([store.submit(session, id(1), photo), store.submit(session, id(1), photo)]);
  assert.equal(jobs[0].id, jobs[1].id);
  assert.equal(store.db.prepare('SELECT COUNT(*) n FROM jobs').get().n, 1);
  const job = store.claim(); assert.ok(job); assert.equal(store.claim(), null);
  store.finish(job, { image: art }, null);
  await assert.rejects(store.submit(session, id(2), photo), /daily_limit/);
});
test('distinct simultaneous requests reserve only one daily slot', async t => {
  const { store, session } = setup(t);
  const results = await Promise.allSettled([store.submit(session, id(1), photo), store.submit(session, id(2), photo)]);
  assert.equal(results.filter(r => r.status === 'fulfilled').length, 1);
});
test('successful deletion is idempotent and cannot refund quota', async t => {
  const { store, session } = setup(t);
  await store.submit(session, id(1), photo);
  store.finish(store.claim(), { image: art }, null);
  store.remove(session.owner, id(1)); store.remove(session.owner, id(1));
  assert.equal(store.read(session.owner, id(1)).result, null);
  await assert.rejects(store.submit(session, id(2), photo), /daily_limit/);
});
test('delete while processing discards late results and upload tombstones persist', async t => {
  const { store, session } = setup(t);
  await store.submit(session, id(1), photo); const job = store.claim();
  store.remove(session.owner, id(1)); store.finish(job, { image: art }, null);
  assert.equal(store.read(session.owner, id(1)).result, null);
  store.remove(session.owner, id(2));
  assert.equal((await store.submit(session, id(2), photo)).state, 'cancelled');
});
test('failure permits retry but uncertain processing does not', async t => {
  const { store, session } = setup(t);
  await store.submit(session, id(1), photo);
  store.finish(store.claim(), null, new ProviderFailure('provider_rejected'));
  await store.submit(session, id(2), photo);
  store.finish(store.claim(), null, new ProviderFailure('provider_uncertain', true));
  await assert.rejects(store.submit(session, id(3), photo), /daily_limit/);
});
test('quota uses frozen session offset and resets at its midnight', async t => {
  let now = Date.parse('2026-09-11T14:59:59Z');
  const { store, session } = setup(t, { now: () => now });
  await store.submit(session, id(1), photo);
  store.finish(store.claim(), { image: art }, null);
  now += 1000;
  await store.submit(session, id(2), photo);
  assert.equal(store.read(session.owner, id(2)).day, '2026-09-12');
});
test('global call budget counts failed calls too', async t => {
  const { store, session } = setup(t, { maxCalls: 1 });
  await store.submit(session, id(1), photo);
  store.finish(store.claim(), null, new ProviderFailure('provider_rejected'));
  await store.submit(session, id(2), photo);
  assert.equal(store.claim(), null);
  assert.equal(store.read(session.owner, id(2)).error, 'service_limit');
});
test('metadata stripped and temporary photos expire after 24 hours', async t => {
  let now = Date.now();
  const { store, session } = setup(t, { now: () => now });
  const tagged = await sharp(photo).withMetadata({ orientation: 6 }).jpeg().toBuffer();
  await store.submit(session, id(1), tagged);
  const stored = store.read(session.owner, id(1));
  assert.equal((await sharp(stored.photo).metadata()).exif, undefined);
  store.finish(store.claim(), { image: art }, null);
  now += 86_400_001; store.cleanup();
  assert.equal(store.read(session.owner, id(1)).result, null);
  assert.equal(store.read(session.owner, id(1)).state, 'succeeded');
});
test('process restart marks in-flight calls uncertain, leaves queued jobs recoverable', async () => {
  const dir = mkdtempSync(join(tmpdir(), 'dopa-diary-'));
  const path = join(dir, 'test.sqlite'); let store;
  try {
    store = new DiaryStore(path);
    const session = store.authenticate(store.register(0, 'photo-transfer-v1').token);
    await store.submit(session, id(1), photo); store.claim(); store.close();
    store = new DiaryStore(path);
    assert.equal(store.read(session.owner, id(1)).state, 'uncertain');
    assert.equal(store.claim(), null);
  } finally {
    store?.close();
    for (const suffix of ['', '-wal', '-shm']) rmSync(path + suffix, { force: true });
    rmdirSync(dir);
  }
});
test('full deletion invalidates identity and late results', async t => {
  const { store, token, session } = setup(t);
  await store.submit(session, id(1), photo); const job = store.claim();
  store.removeAccount(session.owner); store.finish(job, { image: art }, null);
  assert.throws(() => store.authenticate(token), /unauthorized/);
  assert.equal(store.db.prepare('SELECT COUNT(*) n FROM jobs').get().n, 0);
});
test('HTTP ownership, download/ack, payload allowlist and disabled provider', async t => {
  const { store, token, session } = setup(t);
  const { server, tick } = createDiaryServer({ store, provider: async () => ({ image: art }) });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  t.after(() => new Promise(resolve => server.close(resolve)));
  const base = `http://127.0.0.1:${server.address().port}/v1`;
  const headers = { Authorization: `Bearer ${token}` };
  let response = await fetch(`${base}/sessions`, { method: 'POST', body: JSON.stringify({ offsetMinutes: 0, consentVersion: 'photo-transfer-v1', diaryText: 'must not leave device' }) });
  assert.equal(response.status, 400);
  response = await fetch(`${base}/jobs/${id(1)}`, { method: 'PUT', headers: { ...headers, 'Content-Type': 'image/png' }, body: photo });
  assert.equal(response.status, 202); await tick();
  const other = store.register(0, 'photo-transfer-v1').token;
  response = await fetch(`${base}/jobs/${id(1)}/image`, { headers: { Authorization: `Bearer ${other}` } });
  assert.equal(response.status, 404);
  response = await fetch(`${base}/jobs/${id(1)}/image`, { headers });
  assert.equal(response.status, 200); assert.equal((await response.arrayBuffer()).byteLength, art.length);
  response = await fetch(`${base}/jobs/${id(1)}/ack`, { method: 'POST', headers });
  assert.equal(response.status, 200); assert.equal(store.read(session.owner, id(1)).result, null);
});
test('real API adapter sends a fixed style and two images, never diary text; transport failures uncertain', async () => {
  let sent;
  const result = await editPhoto(photo, { key: 'test-only', fetcher: async (url, options) => {
    assert.equal(url, 'https://api.openai.com/v1/images/edits'); sent = options.body;
    return new Response(JSON.stringify({ data: [{ b64_json: art.toString('base64') }], usage: { output_tokens: 1 } }));
  } });
  assert.equal(sent.getAll('image[]').length, 2);
  assert.equal(sent.get('model'), 'gpt-image-2.5-sunburst');
  assert.equal(sent.has('diaryText'), false); assert.deepEqual(result.image, art);
  await assert.rejects(editPhoto(photo, { key: 'test-only', fetcher: async () => { throw new Error('timeout'); } }), e => e.uncertain === true);
});
