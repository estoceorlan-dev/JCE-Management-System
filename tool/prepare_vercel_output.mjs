import {cp, lstat, mkdir, rm, writeFile} from 'node:fs/promises';
import {basename, join, relative, resolve, sep} from 'node:path';

const repositoryRoot = resolve(import.meta.dirname, '..');
const flutterOutput = join(repositoryRoot, 'build', 'web');
const outputRoot = join(repositoryRoot, '.vercel', 'output');
const staticOutput = join(outputRoot, 'static');
assertChildPath(repositoryRoot, outputRoot);

const renderOrigin = requiredHttpsOrigin('JCE_RENDER_API_ORIGIN');
const proxySecret = process.env.JCE_WEB_PROXY_SECRET ?? '';
if (proxySecret.length < 32 || proxySecret.length > 256 || /[^\x21-\x7e]/.test(proxySecret)) {
  throw new Error('JCE_WEB_PROXY_SECRET must contain 32 to 256 printable, non-space ASCII characters.');
}
for (const file of ['index.html', 'main.dart.js', 'flutter_bootstrap.js', 'sqlite3.wasm',
  'drift_worker.js', 'canvaskit/canvaskit.js', 'canvaskit/canvaskit.wasm']) {
  if (!(await lstat(join(flutterOutput, file))).isFile()) {
    throw new Error('The Flutter web release is incomplete.');
  }
}

await rm(outputRoot, {recursive: true, force: true});
await mkdir(staticOutput, {recursive: true});
await cp(flutterOutput, staticOutput, {
  recursive: true,
  filter: async path => {
    const name = basename(path);
    if (name === '.last_build_id' || name.endsWith('.dart')) return false;
    if (name.startsWith('.') || /\.(?:env|jwk|pem|key|p12|pfx|map)$/i.test(name) ||
        (await lstat(path)).isSymbolicLink()) {
      throw new Error('The Flutter web output contains an unexpected private file or link.');
    }
    return true;
  },
});
await writeFile(
  join(outputRoot, 'config.json'),
  `${JSON.stringify({
    version: 3,
    routes: [
      {
        src: '^/v1(?:/(.*))?$',
        dest: `${renderOrigin}/v1/$1`,
        headers: {'Cache-Control': 'private, no-store'},
        transforms: [
          {
            type: 'request.headers',
            op: 'set',
            target: {key: 'x-jce-proxy-secret'},
            args: '$JCE_WEB_PROXY_SECRET',
            env: ['JCE_WEB_PROXY_SECRET'],
          },
        ],
      },
      {
        src: '^/health(?:/(.*))?$',
        dest: `${renderOrigin}/health/$1`,
        headers: {'Cache-Control': 'private, no-store'},
      },
      {
        src: '^/.*$',
        headers: {
          'Cache-Control': 'public, max-age=0, must-revalidate',
          'X-Content-Type-Options': 'nosniff',
          'X-Frame-Options': 'DENY',
          'Referrer-Policy': 'strict-origin-when-cross-origin',
        },
        continue: true,
      },
      {handle: 'filesystem'},
      {
        src: '^/(?!assets(?:/|$)|canvaskit(?:/|$)|icons(?:/|$))[^.]*$',
        methods: ['GET', 'HEAD'],
        dest: '/index.html',
      },
    ],
  }, null, 2)}\n`,
  {encoding: 'utf8', flag: 'wx'},
);

function requiredHttpsOrigin(name) {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`${name} is required.`);
  if (!URL.canParse(value)) throw new Error(`${name} must be an HTTPS origin.`);
  const parsed = new URL(value);
  if (parsed.protocol !== 'https:' || parsed.origin !== value || parsed.username || parsed.password) {
    throw new Error(`${name} must be an HTTPS origin without a path.`);
  }
  return parsed.origin;
}

function assertChildPath(parent, child) {
  const path = relative(parent, child);
  if (!path || path.startsWith(`..${sep}`) || path === '..' || resolve(parent, path) !== child) {
    throw new Error('Vercel output path escaped the repository.');
  }
}
