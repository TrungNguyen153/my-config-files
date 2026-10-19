import type { Register, PromptContextBlock } from 'claude-code'

// Keeps three classes of value out of the transcript: secrets, email
// addresses and IP addresses.
//
// The value is not deleted. It is put in a vault that lives in this module,
// in memory, for the session, and the transcript gets a placeholder in its
// place: `[REDACTED-SECRET-1a2b3c4d]`. The same value always mints the same
// placeholder, so the model can still tell one customer from another, and
// the placeholder is swapped back for the real value on the way into a tool
// call, so a `Bash` command or a `Write` still carries the real key.
//
// Nothing is written to disk. The vault dies with the session.

type Kind = 'SECRET' | 'EMAIL' | 'IP'

export type Config = {
  secrets: boolean
  solana: boolean
  pii: boolean
  restore: boolean
  notify: boolean
  minEntropy: number
  minLength: number
  contextMinEntropy: number
  privateIps: boolean
  allow: ReadonlySet<string>
  allowEmails: readonly string[]
  allowPrefix: readonly string[]
  denyPrefix: readonly string[]
}

// ---------------------------------------------------------------- the vault

const byValue = new Map<string, string>()
const byTag = new Map<string, string>()
let hidden = 0

const TAG = /\[REDACTED-(?:SECRET|EMAIL|IP)-[0-9a-f]{8}\]/g

function fnv1a(text: string): string {
  let h = 0x811c9dc5
  for (let i = 0; i < text.length; i++) {
    h ^= text.charCodeAt(i)
    h = Math.imul(h, 0x01000193) >>> 0
  }
  return h.toString(16).padStart(8, '0')
}

function mint(kind: Kind, value: string): string {
  hidden++
  const seen = byValue.get(value)
  if (seen) return seen
  const tag = `[REDACTED-${kind}-${fnv1a(value)}]`
  byValue.set(value, tag)
  byTag.set(tag, value)
  return tag
}

export function restore(text: string): string {
  if (byTag.size === 0) return text
  return text.replace(TAG, (tag) => byTag.get(tag) ?? tag)
}

// ------------------------------------------------------------ secret tests

// Shapes that belong to one vendor and mean one thing. These are hidden on
// sight, whatever their entropy.
const VENDOR = new RegExp(
  [
    'sk-ant-[A-Za-z0-9_-]{16,}',
    'sk-[A-Za-z0-9_-]{20,}',
    'gh[pousr]_[A-Za-z0-9]{20,}',
    'github_pat_[A-Za-z0-9_]{20,}',
    'xox[baprse]-[A-Za-z0-9-]{10,}',
    'xapp-[0-9]-[A-Za-z0-9-]{10,}',
    'A(?:KIA|SIA)[0-9A-Z]{16}',
    '[sr]k_(?:live|test)_[A-Za-z0-9]{16,}',
    'whsec_[A-Za-z0-9]{16,}',
    'AIza[0-9A-Za-z_-]{30,}',
    'ya29\\.[A-Za-z0-9_-]{20,}',
    'npm_[A-Za-z0-9]{30,}',
    'dop_v1_[a-f0-9]{40,}',
    'glpat-[A-Za-z0-9_-]{16,}',
    'shpat_[a-f0-9]{32,}',
    'SG\\.[A-Za-z0-9_-]{16,}\\.[A-Za-z0-9_-]{16,}',
    'eyJ[A-Za-z0-9_-]{8,}\\.[A-Za-z0-9_-]{8,}\\.[A-Za-z0-9_-]{8,}',
    'https://hooks\\.slack\\.com/services/[A-Za-z0-9/+_-]{16,}',
    'https://discord(?:app)?\\.com/api/webhooks/[0-9]+/[A-Za-z0-9_-]{16,}',
  ].join('|'),
  'g',
)

const PRIVATE_KEY = /-----BEGIN[^\n-]{0,40}PRIVATE KEY-----[\s\S]*?-----END[^\n-]{0,40}PRIVATE KEY-----/g

// Base64 padding rides along with the token; `=` is kept out of the run so a
// `name=value` pair does not read as one token.
// The password inside a connection string: postgres://user:PASSWORD@host.
const URL_PASSWORD = /\b([a-z][a-z0-9+.-]{1,20}:\/\/[^\s/@:]{1,80}):([^\s/@]{3,200})@/gi

// A run of the characters a key is made of. `/` and `.` are left out on
// purpose: with them in, every long file path becomes a candidate.
const CANDIDATE = /[A-Za-z0-9+_-]{12,200}={0,2}/g

// A name to the left of the candidate that says the candidate is a key.
const NAMED =
  /(?:key|token|secret|password|passwd|pwd|credential|auth|bearer|private|signature|session|cookie|dsn|salt|nonce|otp)["'\]\s]{0,4}[:=]{1,2}\s*["'`]?\s*$/i

const HEX_ONLY = /^[0-9a-f]+$/i
const DIGITS_ONLY = /^[0-9]+$/

// Prefixes that name a PUBLIC object id, not a key. Stripe hands these out in
// dashboards, invoices and source code; hiding them makes a session useless
// and protects nothing. `pk_live_` is Stripe's publishable key, also public.
// Public ids with a shape rather than a prefix: a YouTube channel id.
const PUBLIC_SHAPE = /^(?:UC[A-Za-z0-9_-]{22}|PL[A-Za-z0-9_-]{16,32})$/

const PUBLIC_PREFIX =
  /^(?:price|prod|cus|sub|sched|in|ch|pi|cs|py|re|txn|il|si|seti|evt|acct|promo|coupon|plan|card|ba|src|dp|du|iv|ii|rcpt|file|link|pm|tok|pk|test|toolu|msg|req|run|wf)_/i

// A name written in code (`archived-modules-marker`, `handleCheckoutSession`,
// `lesson_article_outline_open_v1`) reads as high entropy but is a word list.
// A key is not built out of words.
const WORD_PART = /^(?:[a-z]+[0-9]{0,3}|[A-Z][a-z]+[0-9]{0,3}|[A-Z]{2,})$/
const ALNUM_ONLY = /^[A-Za-z0-9]+$/
const SEGMENTS = /[A-Z]+(?![a-z])|[A-Z]?[a-z]+|[0-9]+/g
const WORDY = /^[A-Za-z]?[a-z]{2,}$/

// `playerEventBatchV1Schema` splits into six segments of which four are
// words; a random key splits into many segments of which almost none are.
function isCamelName(token: string): boolean {
  if (!ALNUM_ONLY.test(token)) return false
  const segs = token.match(SEGMENTS)
  if (!segs || segs.join('') !== token) return false
  const words = segs.filter((seg) => WORDY.test(seg)).length
  return words >= 2 && words >= segs.length - 2
}

function looksLikeName(token: string, named: boolean): boolean {
  if (isCamelName(token)) return true
  // Every character used once: an alphabet constant, not a key. A random key
  // of this length repeats a character with near certainty. A name beside the
  // token outweighs this, so the rule only runs when there is none.
  if (!named && token.length >= 20 && new Set(token).size === token.length) return true
  const parts = token.split(/[_-]/)
  if (parts.length >= 2 && parts.every((p) => WORD_PART.test(p))) return true
  // Three or more separated parts, two of them plain words: a naming
  // convention (`META_Conv_Lookalike-Customers_FreeTrial_2024Q1`), not a key.
  return parts.length >= 3 && parts.filter((p) => /^[A-Za-z]{4,}$/.test(p)).length >= 2
}

function entropy(text: string): number {
  const counts = new Map<string, number>()
  for (const ch of text) counts.set(ch, (counts.get(ch) ?? 0) + 1)
  let h = 0
  for (const n of counts.values()) {
    const p = n / text.length
    h -= p * Math.log2(p)
  }
  return h
}

// ------------------------------------------------------------------ solana

// Solana writes its public values in base58: a wallet, mint, program id or
// blockhash is 32 bytes (32-44 characters), a transaction signature is 64
// bytes (86-88). All of them pass the entropy test, and none is a secret.
//
// A Solana private key is 64 bytes of base58 as well: the 32-byte seed and
// then its own public key. That is the only thing that tells it from a
// signature, so the public key is derived from the first half and compared
// with the second. The hooks runtime has no synchronous crypto, hence the
// small SHA-512 and ed25519 below. They only ever see 86-88 character
// base58 runs, and each answer is cached.

type SolanaKind = 'public' | 'keypair'

const BASE58 = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
const BASE58_ONLY = /^[1-9A-HJ-NP-Za-km-z]+$/

// A name to the left that says the value is public, although NAMED also
// matches it (`pubkey:` ends in `key:`).
const PUBLIC_NAME =
  /(?:pub(?:lic)?[_ -]?key|address|addr|wallet|mint|owner|program(?:[_ -]?id)?|signature|sig|signer|payer|authority|account|blockhash|hash|txid|tx)["'\]\s]{0,4}[:=]{1,2}\s*["'`]?\s*$/i

export function base58Decode(text: string): Uint8Array | null {
  let n = 0n
  for (const ch of text) {
    const v = BASE58.indexOf(ch)
    if (v < 0) return null
    n = n * 58n + BigInt(v)
  }
  const bytes: number[] = []
  while (n > 0n) {
    bytes.push(Number(n & 0xffn))
    n >>= 8n
  }
  for (const ch of text) {
    if (ch !== '1') break
    bytes.push(0)
  }
  return Uint8Array.from(bytes.reverse())
}

// SHA-512, FIPS 180-4. The round constants are the first 64 bits of the
// fractional parts of the cube roots of the first 80 primes, and the start
// values the same of the square roots of the first 8: computed once, so no
// table of hex has to be typed in and trusted.
const M64 = (1n << 64n) - 1n
let sha512Table: { k: bigint[]; h: bigint[] } | undefined

function iroot(n: bigint, k: bigint): bigint {
  let x = 1n << (BigInt(n.toString(2).length) / k + 1n)
  for (;;) {
    const y = ((k - 1n) * x + n / x ** (k - 1n)) / k
    if (y >= x) return x
    x = y
  }
}

function sha512Constants(): { k: bigint[]; h: bigint[] } {
  if (sha512Table) return sha512Table
  const primes: bigint[] = []
  for (let c = 2n; primes.length < 80; c++) {
    if (primes.every((p) => c % p !== 0n)) primes.push(c)
  }
  sha512Table = {
    k: primes.map((p) => iroot(p << 192n, 3n) & M64),
    h: primes.slice(0, 8).map((p) => iroot(p << 128n, 2n) & M64),
  }
  return sha512Table
}

const rotr = (x: bigint, n: bigint): bigint => ((x >> n) | (x << (64n - n))) & M64

export function sha512(msg: Uint8Array): Uint8Array {
  const { k, h: start } = sha512Constants()
  const block = new Uint8Array(Math.ceil((msg.length + 17) / 128) * 128)
  block.set(msg)
  block[msg.length] = 0x80
  let bits = BigInt(msg.length) * 8n
  for (let i = block.length - 1; bits > 0n; i--) {
    block[i] = Number(bits & 0xffn)
    bits >>= 8n
  }
  const h = start.slice()
  const w = new Array<bigint>(80)
  for (let off = 0; off < block.length; off += 128) {
    for (let t = 0; t < 16; t++) {
      let v = 0n
      for (let b = 0; b < 8; b++) v = (v << 8n) | BigInt(block[off + t * 8 + b])
      w[t] = v
    }
    for (let t = 16; t < 80; t++) {
      const s0 = rotr(w[t - 15], 1n) ^ rotr(w[t - 15], 8n) ^ (w[t - 15] >> 7n)
      const s1 = rotr(w[t - 2], 19n) ^ rotr(w[t - 2], 61n) ^ (w[t - 2] >> 6n)
      w[t] = (w[t - 16] + s0 + w[t - 7] + s1) & M64
    }
    let [a, b, c, d, e, f, g, hh] = h
    for (let t = 0; t < 80; t++) {
      const s1 = rotr(e, 14n) ^ rotr(e, 18n) ^ rotr(e, 41n)
      const ch = (e & f) ^ (~e & M64 & g)
      const t1 = (hh + s1 + ch + k[t] + w[t]) & M64
      const s0 = rotr(a, 28n) ^ rotr(a, 34n) ^ rotr(a, 39n)
      const maj = (a & b) ^ (a & c) ^ (b & c)
      hh = g
      g = f
      f = e
      e = (d + t1) & M64
      d = c
      c = b
      b = a
      a = (t1 + s0 + maj) & M64
    }
    const out = [a, b, c, d, e, f, g, hh]
    for (let i = 0; i < 8; i++) h[i] = (h[i] + out[i]) & M64
  }
  const digest = new Uint8Array(64)
  h.forEach((v, i) => {
    for (let b = 7; b >= 0; b--) {
      digest[i * 8 + b] = Number(v & 0xffn)
      v >>= 8n
    }
  })
  return digest
}

// Ed25519, RFC 8032, public key from seed only. The curve constants are
// derived too: d = -121665/121666, and the base point is the one with
// y = 4/5 and an even x.
const P = (1n << 255n) - 19n
const mod = (a: bigint): bigint => ((a % P) + P) % P

function pow(base: bigint, exp: bigint): bigint {
  let r = 1n
  let b = mod(base)
  for (let e = exp; e > 0n; e >>= 1n) {
    if (e & 1n) r = (r * b) % P
    b = (b * b) % P
  }
  return r
}

const inv = (a: bigint): bigint => pow(a, P - 2n)

type Point = [bigint, bigint, bigint, bigint] // X, Y, Z, T
let curve: { d2: bigint; base: Point } | undefined

function curveConstants(): { d2: bigint; base: Point } {
  if (curve) return curve
  const d = mod(-121665n * inv(121666n))
  const y = mod(4n * inv(5n))
  const xx = mod((y * y - 1n) * inv(d * y * y + 1n))
  let x = pow(xx, (P + 3n) / 8n)
  if (mod(x * x - xx) !== 0n) x = mod(x * pow(2n, (P - 1n) / 4n))
  if (x & 1n) x = P - x
  curve = { d2: mod(2n * d), base: [x, y, 1n, mod(x * y)] }
  return curve
}

function add(p: Point, q: Point, d2: bigint): Point {
  const a = mod((p[1] - p[0]) * (q[1] - q[0]))
  const b = mod((p[1] + p[0]) * (q[1] + q[0]))
  const c = mod(p[3] * d2 * q[3])
  const d = mod(p[2] * 2n * q[2])
  const e = b - a
  const f = d - c
  const g = d + c
  const h = b + a
  return [mod(e * f), mod(g * h), mod(f * g), mod(e * h)]
}

export function ed25519PublicKey(seed: Uint8Array): Uint8Array {
  const { d2, base } = curveConstants()
  const h = sha512(seed)
  h[0] &= 248
  h[31] &= 127
  h[31] |= 64
  let s = 0n
  for (let i = 31; i >= 0; i--) s = (s << 8n) | BigInt(h[i])
  let acc: Point = [0n, 1n, 1n, 0n]
  let addend = base
  for (; s > 0n; s >>= 1n) {
    if (s & 1n) acc = add(acc, addend, d2)
    addend = add(addend, addend, d2)
  }
  const zi = inv(acc[2])
  const x = mod(acc[0] * zi)
  let y = mod(acc[1] * zi)
  const out = new Uint8Array(32)
  for (let i = 0; i < 32; i++) {
    out[i] = Number(y & 0xffn)
    y >>= 8n
  }
  out[31] |= Number(x & 1n) << 7
  return out
}

function isKeypair(bytes: Uint8Array): boolean {
  const pub = ed25519PublicKey(bytes.subarray(0, 32))
  return pub.every((v, i) => v === bytes[32 + i])
}

const solanaSeen = new Map<string, SolanaKind>()

export function solanaKind(token: string): SolanaKind | null {
  const short = token.length >= 32 && token.length <= 44
  const long = token.length >= 86 && token.length <= 88
  if (!(short || long) || !BASE58_ONLY.test(token)) return null
  const seen = solanaSeen.get(token)
  if (seen) return seen
  const bytes = base58Decode(token)
  let kind: SolanaKind | null = null
  if (short && bytes?.length === 32) kind = 'public'
  else if (long && bytes?.length === 64) kind = isKeypair(bytes) ? 'keypair' : 'public'
  if (kind) {
    if (solanaSeen.size >= 4096) solanaSeen.clear()
    solanaSeen.set(token, kind)
  }
  return kind
}

function looksSecret(token: string, before: string, cfg: Config): boolean {
  if (token.startsWith('REDACTED-')) return false
  if (cfg.allow.has(token)) return false
  if (DIGITS_ONLY.test(token)) return false
  if (PUBLIC_SHAPE.test(token)) return false
  if (PUBLIC_PREFIX.test(token) && !cfg.denyPrefix.some((p) => token.startsWith(p))) return false
  if (cfg.allowPrefix.some((p) => token.startsWith(p))) return false

  const named = NAMED.test(before)

  if (cfg.solana) {
    const sol = solanaKind(token)
    if (sol === 'keypair') return true
    // `API_KEY=` beside it still means a key that happens to be base58;
    // `pubkey:` and `signature:` do not.
    if (sol === 'public' && !(named && !PUBLIC_NAME.test(before))) return false
  }

  if (looksLikeName(token, named)) return false

  const h = entropy(token)

  // A bare hex run is a git SHA or a checksum far more often than it is a
  // key, so hex needs a name beside it before it is hidden.
  if (HEX_ONLY.test(token)) return named && token.length >= 24 && h >= cfg.contextMinEntropy

  const mixed = /[a-z]/.test(token) && /[A-Z]/.test(token) && /[0-9]/.test(token)
  if (mixed && token.length >= cfg.minLength && h >= cfg.minEntropy) return true
  // Next to a key's name the bar is lower, but the token still has to look
  // like a key: letters and digits together, not a word.
  const alnum = /[0-9]/.test(token) && /[A-Za-z]/.test(token)
  return named && alnum && token.length >= 16 && h >= cfg.contextMinEntropy
}

export function scrubSecrets(text: string, cfg: Config): string {
  let out = text
  out = out.replace(PRIVATE_KEY, (m) => mint('SECRET', m))
  out = out.replace(VENDOR, (m) => (cfg.allow.has(m) ? m : mint('SECRET', m)))
  out = out.replace(URL_PASSWORD, (m, head: string, password: string) =>
    cfg.allow.has(password) ? m : `${head}:${mint('SECRET', password)}@`,
  )
  out = out.replace(CANDIDATE, (token: string, offset: number, whole: string) => {
    const before = whole.slice(Math.max(0, offset - 64), offset)
    return looksSecret(token, before, cfg) ? mint('SECRET', token) : token
  })
  return out
}

// --------------------------------------------------------------- PII tests

const EMAIL = /[A-Za-z0-9._%+-]+@[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?(?:\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,24}/g

const OCTET = '(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])'
const IPV4 = new RegExp(`(?<![0-9.])(?:${OCTET}\\.){3}${OCTET}(?![0-9.])`, 'g')
const IPV6 = /(?<![0-9A-Za-z:])(?:[0-9A-Fa-f]{1,4}:){4,7}[0-9A-Fa-f]{1,4}(?![0-9A-Za-z:])/g

function isPrivateV4(ip: string): boolean {
  const p = ip.split('.').map(Number)
  if (p[0] === 10 || p[0] === 127 || p[0] === 0) return true
  if (p[0] === 172 && p[1] >= 16 && p[1] <= 31) return true
  if (p[0] === 192 && p[1] === 168) return true
  if (p[0] === 169 && p[1] === 254) return true
  if (p[0] === 100 && p[1] >= 64 && p[1] <= 127) return true
  if (p[0] >= 224) return true // multicast, reserved, broadcast
  if (p[0] === 198 && (p[1] === 18 || p[1] === 19)) return true // benchmarking
  // RFC 5737: ranges reserved for documentation. A fixture, never a person.
  if (p[0] === 192 && p[1] === 0 && p[2] === 2) return true
  if (p[0] === 198 && p[1] === 51 && p[2] === 100) return true
  if (p[0] === 203 && p[1] === 0 && p[2] === 113) return true
  return false
}

// Addresses that only ever stand in for a real one: form placeholders, docs
// and test fixtures. Hiding them is noise.
const EXAMPLE_DOMAIN =
  /@(?:example\.(?:com|org|net)|examples?\.[a-z]+|test|invalid|localhost|acme\.com|(?:your)?domain\.com|company\.com|email\.com|mail\.com|foo\.com|bar\.com|sample\.com|placeholder\.[a-z]+)$/i
const EXAMPLE_LOCAL = /^(?:you|your|user|username|name|email|someone|test|example|placeholder|first\.last|jane|john|alice|bob|teammate|colleague|member|admin)(?:[.+_-]?[a-z0-9]{0,12})?@/i

function allowedEmail(address: string, cfg: Config): boolean {
  const low = address.toLowerCase()
  if (low.endsWith('@users.noreply.github.com')) return true
  if (low.startsWith('noreply@') || low.startsWith('no-reply@')) return true
  if (EXAMPLE_DOMAIN.test(low) || EXAMPLE_LOCAL.test(low)) return true
  return cfg.allowEmails.some((a) => {
    const rule = a.toLowerCase().trim()
    return rule.startsWith('@') ? low.endsWith(rule) : low === rule
  })
}

export function scrubPii(text: string, cfg: Config): string {
  let out = text
  out = out.replace(EMAIL, (m) => (allowedEmail(m, cfg) || cfg.allow.has(m) ? m : mint('EMAIL', m)))
  out = out.replace(IPV4, (m) => {
    if (cfg.allow.has(m)) return m
    if (!cfg.privateIps && isPrivateV4(m)) return m
    return mint('IP', m)
  })
  out = out.replace(IPV6, (m) => {
    if (cfg.allow.has(m)) return m
    const low = m.toLowerCase()
    if (!cfg.privateIps && (low.startsWith('fe80:') || low.startsWith('fc') || low.startsWith('fd'))) return m
    return mint('IP', m)
  })
  return out
}

// ------------------------------------------------------------- the walkers

const SKIP_KEYS = new Set(['data', 'base64', 'b64_json', 'imageData', 'thumbnail'])
const MAX_STRING = 8_000_000
const MAX_DEPTH = 12

function walk(value: unknown, fn: (s: string) => string, depth = 0): unknown {
  if (typeof value === 'string') return value.length > MAX_STRING ? value : fn(value)
  if (depth >= MAX_DEPTH) return value
  if (Array.isArray(value)) return value.map((v) => walk(v, fn, depth + 1))
  if (value && typeof value === 'object') {
    const proto = Object.getPrototypeOf(value)
    if (proto !== Object.prototype && proto !== null) return value
    const out: Record<string, unknown> = {}
    for (const [k, v] of Object.entries(value as Record<string, unknown>)) {
      out[k] = SKIP_KEYS.has(k) ? v : walk(v, fn, depth + 1)
    }
    return out
  }
  return value
}

// ---------------------------------------------------------------- register

function bool(v: unknown, fallback: boolean): boolean {
  if (typeof v === 'boolean') return v
  if (v === 'true') return true
  if (v === 'false') return false
  return fallback
}

function num(v: unknown, fallback: number): number {
  const n = Number(v)
  return Number.isFinite(n) ? n : fallback
}

function strings(v: unknown): string[] {
  if (Array.isArray(v)) return v.map(String)
  if (typeof v === 'string' && v.trim()) return v.split(',').map((s) => s.trim()).filter(Boolean)
  return []
}

export function makeConfig(options: Record<string, unknown>): Config {
  return {
    secrets: bool(options.secrets, true),
    solana: bool(options.solana, true),
    pii: bool(options.pii, true),
    restore: bool(options.restoreInToolInputs, true),
    notify: bool(options.notify, true),
    minEntropy: num(options.minEntropy, 3.6),
    minLength: Math.max(8, num(options.minLength, 24)),
    contextMinEntropy: num(options.contextMinEntropy, 3.0),
    privateIps: bool(options.redactPrivateIps, false),
    allow: new Set(strings(options.allow)),
    allowEmails: strings(options.allowEmails),
    allowPrefix: strings(options.allowPrefixes),
    denyPrefix: strings(options.denyPrefixes),
  }
}

export const register: Register = (on, options) => {
  const cfg = makeConfig(options as Record<string, unknown>)

  const scrub = (text: string): string => {
    let out = text
    if (cfg.secrets) out = scrubSecrets(out, cfg)
    if (cfg.pii) out = scrubPii(out, cfg)
    return out
  }

  const secretsOnly = (text: string): string => (cfg.secrets ? scrubSecrets(text, cfg) : text)

  // 1. What the user types. A pasted key never reaches the model as itself.
  on('prompt.submit', async ($, e, next) => {
    const before = hidden
    const text = scrub(e.text)
    if (hidden > before && cfg.notify) {
      $.ui.toast(`secret-redactor: hid ${hidden - before} value(s) from the prompt`)
    }
    return next({ ...e, text })
  })

  // 2. What a tool reads back. This is where a secret usually arrives: a
  //    `cat .env`, a `Read` of a config, an API answer.
  on('tool.call', async ($, e, next) => {
    const input = cfg.restore ? (walk({ ...e }, restore) as typeof e) : e
    const r = await next(input)
    if (r.deny !== undefined) return r

    const before = hidden
    const result = walk(r.result, scrub)
    const text = r.text === undefined ? undefined : scrub(r.text)
    if (hidden === before) return r

    if (cfg.notify) $.ui.notice(e.tool_use_id, `secret-redactor: hid ${hidden - before} value(s)`)
    if (r.isError) return { isError: true as const, result, text, context: r.context }
    return { result, context: r.context }
  })

  // 3. The blocks attached to the first message (CLAUDE.md and friends).
  //    Secrets only: the email in there is the user's own, and the engine
  //    puts it there so the model knows who it is talking to.
  on('prompt.context', async ($, e, next) => {
    const r = await next(e)
    if (!cfg.secrets) return r
    const blocks: PromptContextBlock[] = r.blocks.map((b) => ({ ...b, text: secretsOnly(b.text) }))
    return { blocks }
  })
}
