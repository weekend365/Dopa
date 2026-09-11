// LOCAL INTEGRATION TEST ONLY. No OpenAI connection and no real generated art.
import sharp from 'sharp';
import { DiaryStore } from '../src/store.mjs';
import { createDiaryServer } from '../src/server.mjs';
const store = new DiaryStore(':memory:');
const { server, tick } = createDiaryServer({ store, provider: async photo => ({ image: await sharp(photo).webp().toBuffer() }) });
const timer = setInterval(() => void tick(), 100);
server.listen(8788, '127.0.0.1', () => process.stdout.write('Dopa TEST FIXTURE on 8788. Images are test echoes, not AI artwork.\n'));
process.on('SIGINT', () => { clearInterval(timer); server.close(() => { store.close(); process.exit(0); }); });
