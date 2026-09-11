import { readFile } from 'node:fs/promises';

export const STYLE_VERSION = 'dopa-gouache-v1';
export const STYLE_PROMPT = `Create a personal illustrated diary memory from image 1.
Preserve its main subjects, their count, recognizable appearance, pose, clothing,
objects, place, composition and time of day. Do not invent a different event.
Render with an original Dopa picture-book style: soft matte gouache, subtle warm
paper grain, broad gentle brush shapes, restrained cream, sage and sunlight accents.
Keep the photo's meaningful colors and lighting; night must remain night.
Image 2 is ONLY a brushwork and palette reference. Never copy its tree, garden,
plant, landscape or layout into image 1. No added faces, characters, decorative
text, captions, borders, logos, beauty retouching or glossy 3D. Output only the art.`;

export class ProviderFailure extends Error {
  constructor(code, uncertain = false) { super(code); this.code = code; this.uncertain = uncertain; }
}

export async function editPhoto(photo, { key, fetcher = fetch } = {}) {
  if (!key) throw new ProviderFailure('not_configured');
  const form = new FormData();
  form.set('model', 'gpt-image-2.5-sunburst');
  form.set('prompt', STYLE_PROMPT);
  form.set('quality', 'medium');
  form.set('size', '1024x1024');
  form.set('output_format', 'webp');
  form.set('n', '1');
  form.append('image[]', new Blob([photo], { type: 'image/jpeg' }), 'memory.jpg');
  const reference = await readFile(new URL('../../../apps/mobile/assets/garden/light_0.webp', import.meta.url));
  form.append('image[]', new Blob([reference], { type: 'image/webp' }), 'style.webp');
  let response;
  try {
    response = await fetcher('https://api.openai.com/v1/images/edits', {
      method: 'POST', headers: { Authorization: `Bearer ${key}` }, body: form,
      signal: AbortSignal.timeout(180_000),
    });
  } catch { throw new ProviderFailure('provider_uncertain', true); }
  if (!response.ok) {
    // A transport failure/5xx could occur after billing. Never blindly retry.
    throw new ProviderFailure(response.status === 429 ? 'provider_busy' : 'provider_rejected', response.status >= 500);
  }
  try {
    const data = await response.json();
    const encoded = data.data?.[0]?.b64_json;
    if (typeof encoded !== 'string' || encoded.length > 24_000_000) throw new Error();
    return { image: Buffer.from(encoded, 'base64'), usage: data.usage ?? null };
  } catch { throw new ProviderFailure('provider_uncertain', true); }
}
