// Runs with no dependencies:
//   node --experimental-strip-types plugins/secret-redactor/test/detect.test.mts
//
// The two lists below are the whole contract. A change to a threshold or a
// pattern is only finished when both still pass.
import { createHash, generateKeyPairSync, randomBytes, sign } from 'node:crypto'
import { makeConfig, scrubSecrets, scrubPii, restore, ed25519PublicKey, sha512 } from '../hooks/redact.ts'

const cfg = makeConfig({})
const scrub = (text: string): string => scrubPii(scrubSecrets(text, cfg), cfg)

const HIDE: readonly string[] = [
  'ANTHROPIC_API_KEY=sk-ant-api03-Zx8Q2mLpR7vT4nK9wYbF1cJhE6sAdG0uH3iO5rP',
  'export GITHUB_TOKEN=ghp_1a2B3c4D5e6F7g8H9i0JkLmNoPqRsTuVwXyZ',
  'aws_access_key_id = AKIAIOSFODNN7EXAMPLE',
  // Split so GitHub push protection does not take the fake key for a real one.
  'STRIPE_SECRET=sk_' + 'live_51H8xQ2LpR7vT4nK9wYbF1cJhE6s',
  'db: postgres://acs:S3cur3-p4ss-w0rd-here@db.example.com:5432/main',
  'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dBjftJeZ4CVPmB92K27uhbUJU1p1r_wW1gFWFOEjXk',
  'R2_SECRET_ACCESS_KEY="C3J27XDCG2LmlZGEONYlgCtjfIZ4SOcM"',
  'a bare high-entropy token z9CPVNPkNa1Hedcm4pMbXDuCL1mHoOsF here',
  'AIzaSyCjoSAqe6M7N3dSdh-uygUgSuBjkYnYhiw',
  'contact me at dana.whitfield@northwind-labs.io',
  'origin 91.198.174.192 hit the worker',
  'v6 2001:0db8:85a3:0000:0000:8a2e:0370:7334 seen',
  '-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEA1a2b3c\n-----END RSA PRIVATE KEY-----',
]

const KEEP: readonly string[] = [
  'commit 79a1e9dd8f3b2c1a4e5d6f7089abcdef01234567 landed on main',
  'sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
  'apps/nextjs/src/components/agentengineer/school/school-styles.ts',
  'http://localhost:3000/api/auth and 127.0.0.1:5432',
  'private net 192.168.1.14 and 10.0.0.7 and 172.16.4.2 and 203.0.113.9',
  'Co-Authored-By: Claude <noreply@anthropic.com>',
  'ray-amjad@users.noreply.github.com',
  'Claude Code 2.1.260 released 2026-09-04',
  'const IN_FLIGHT = new Set([QUEUED, BUILDING, INITIALIZING])',
  'npm install @anthropic-ai/claude-code --save-dev',
  'PLANETSCALE_DATABASE_URL is set in Infisical prod',
  // Stripe hands these out in public. Hiding them protects nothing.
  'monthly: "price_1Q4RmZKtVnpLXbYc82F0dTgW", productId: "prod_Rbk7HDpQ2mXvLe"',
  'only promo_1M3KpsDvNrqYTcbG7h2xWzQe is active',
  'pk_live_51H8xQ2LpR7vT4nK9wYbF1cJhE6sAdG0u',
  // Names, not keys.
  'key="archived-modules-marker"',
  'const OUTLINE_OPEN_KEY = "lesson_article_outline_open_v1";',
  'import { playerEventBatchV1Schema } from "./player-event-ingest";',
  'export function randomTimestampWithinLast14Days(): string {',
  'META_Conv_Lookalike-Customers_FreeTrial_2024Q1',
  'const chars = "abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ23456789";',
  'utm_source=youtube&utm_medium=video_description&utm_campaign=dQw4w9WgXcQ',
  'The channel ID is UCq7NmTfKbrWzXd4LpHveAJs (a channel)',
  'placeholder="you@example.com" and name@company.com',
]

let bad = 0
for (const text of HIDE) {
  if (scrub(text) === text) {
    bad++
    console.log(`MISS  ${text.split('\n')[0].slice(0, 100)}`)
  }
}
for (const text of KEEP) {
  const out = scrub(text)
  if (out !== text) {
    bad++
    console.log(`FALSE POSITIVE  ${out.slice(0, 120)}`)
  }
}

// A value always mints the same placeholder, and the placeholder always
// buys the value back.
const line = 'KEY=sk-ant-api03-Zx8Q2mLpR7vT4nK9wYbF1cJhE6sAdG0uH3iO5rP'
if (scrub(line) !== scrub(line)) {
  bad++
  console.log('DRIFT  the same value minted two placeholders')
}
if (restore(scrub(line)) !== line) {
  bad++
  console.log('LOSS  a placeholder did not buy its value back')
}

// ------------------------------------------------------------------ solana
// Every value is made here with node:crypto, so no key sits in this file.

const ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
function b58(bytes: Uint8Array): string {
  let n = 0n
  for (const b of bytes) n = (n << 8n) | BigInt(b)
  let out = ''
  while (n > 0n) {
    out = ALPHABET[Number(n % 58n)] + out
    n /= 58n
  }
  for (const b of bytes) {
    if (b !== 0) break
    out = '1' + out
  }
  return out
}
const hex = (bytes: Uint8Array): string => Buffer.from(bytes).toString('hex')

function solanaFail(what: string): void {
  bad++
  console.log(`SOLANA  ${what}`)
}

// RFC 8032, 7.1, test 1.
const rfcPub = hex(ed25519PublicKey(Buffer.from('9d61b19deffd5a60ba844af492ec2cc44449c5697b326919703bac031cae7f60', 'hex')))
if (rfcPub !== 'd75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a') {
  solanaFail(`RFC 8032 vector gave ${rfcPub}`)
}
if (hex(sha512(new Uint8Array(0))) !== createHash('sha512').update('').digest('hex')) solanaFail('sha512 of empty input')

const wallets = Array.from({ length: 50 }, () => {
  const { privateKey, publicKey } = generateKeyPairSync('ed25519')
  const seed = Buffer.from(privateKey.export({ format: 'jwk' }).d!, 'base64url')
  const pub = Buffer.from(publicKey.export({ format: 'jwk' }).x!, 'base64url')
  const sig = sign(null, randomBytes(48), privateKey)
  return { seed, pub, sig }
})

let slowest = 0
for (const { seed, pub, sig } of wallets) {
  if (hex(ed25519PublicKey(seed)) !== hex(pub)) solanaFail('derived public key differs from node:crypto')

  const address = b58(pub)
  const signature = b58(sig)
  const keypair = b58(Buffer.concat([seed, pub]))
  const t0 = performance.now()
  const keypairOut = scrub(`keypair ${keypair}`)
  slowest = Math.max(slowest, performance.now() - t0)

  for (const text of [address, `"pubkey": "${address}"`, `mint=${address}`, `owner: ${address}`]) {
    if (scrub(text) !== text) solanaFail(`public key hidden: ${scrub(text)}`)
  }
  for (const text of [signature, `"signature":"${signature}"`, `signature: ${signature}`]) {
    if (scrub(text) !== text) solanaFail(`signature hidden: ${scrub(text)}`)
  }
  for (const text of [`keypair ${keypair}`, `{"secretKey":"${keypair}"}`]) {
    if (scrub(text).includes(keypair)) solanaFail('keypair kept')
  }
  if (keypairOut.includes(keypair)) solanaFail('keypair kept')
  // A base58 seed is shaped like a public key; a key's name beside it hides it.
  const seed58 = b58(seed)
  if (seed58.length >= 40 && scrub(`PRIVATE_KEY=${seed58}`).includes(seed58)) solanaFail('named seed kept')
}
if (slowest > 50) solanaFail(`keypair check took ${slowest.toFixed(1)} ms`)

const off = makeConfig({ solana: false })
const sample = b58(wallets[0].sig)
if (scrubSecrets(sample, off) === sample) solanaFail('solana: false still shows signatures')

console.log(bad === 0 ? `ok  ${HIDE.length} hidden, ${KEEP.length} kept, round trip clean, ${wallets.length} solana wallets` : `${bad} failure(s)`)
if (bad > 0) process.exitCode = 1
