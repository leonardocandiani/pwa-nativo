<!-- readme-padrao:header -->
<!-- Banner -->
<div align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:0d1117,50:1a1a2e,100:00d9ff&height=200&section=header&text=pwa-nativo&fontSize=54&fontColor=ffffff&animation=fadeIn&fontAlignY=36&desc=Claude%20Code%20plugin%20for%20PWAs%20that%20feel%20native%20on%20phones%20and%20desktops&descAlignY=58&descSize=16" alt="pwa-nativo" width="100%" />
</div>

<!-- Typing -->
<div align="center">
  <img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=600&size=21&duration=2800&pause=900&color=00d9ff&center=true&vCenter=true&width=840&lines=PWAs+that+feel+native+on+phones+and+desktops;Create%2C+convert%2C+audit%2C+notify+and+optimize;32-rule+auditor+with+file+and+line%2C+no+network;Next.js%2C+Vite%2C+React%2C+Supabase+and+Web+Push" alt="PWAs that feel native on phones and desktops" />
</div>

<div align="center">

  <p><strong>From website to installable app, with notifications that arrive and an app layout on both screens.</strong></p>

  <p>
    <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-00d9ff?style=for-the-badge" alt="License: MIT" /></a>
    <a href="https://docs.claude.com/en/docs/claude-code"><img src="https://img.shields.io/badge/Made%20for-Claude%20Code-D97757?style=for-the-badge&logo=anthropic&logoColor=white" alt="Made for: Claude Code" /></a>
    <img src="https://img.shields.io/badge/node-18%2B%20zero%20dependencies-1a1a2e?style=for-the-badge&logo=nodedotjs&logoColor=white" alt="node: 18+ zero dependencies" />
    <img src="https://img.shields.io/badge/rules-32-00d9ff?style=for-the-badge" alt="rules: 32" />
  </p>

  <p><a href="README.pt-BR.md">Leia em português</a></p>

  <p>
    <a href="#why-it-exists">Why it exists</a> •
    <a href="#commands">Commands</a> •
    <a href="#the-seven-layers">The seven layers</a> •
    <a href="#auditor">Auditor</a> •
    <a href="#install">Install</a> •
    <a href="#structure">Structure</a> •
    <a href="#tests">Tests</a> •
    <a href="#license">License</a>
  </p>
</div>

<br>

> **pwa-nativo** packs into one plugin what turned precodiesel.com.br into an app: correct manifest and icons, a service worker that opens offline, per-platform install, notifications tested on the spot, and a shell with a dock on the phone and a side panel on the desktop.

> Not affiliated with or endorsed by Anthropic. "Claude" and "Claude Code" are trademarks of Anthropic.

## What it is

```yaml
product:       Claude Code plugin: create, convert, audit, notify and optimize PWAs
layers:        manifest · service worker · install · notifications · native shell · data · verification
auditor:       32 rules, TOON output, per-file sha1 cache, never executes audited code
templates:     17 files: sw.js, browser core, React, Next, Vite, CSS, Supabase, generators
notifications: dependency-free VAPID, test on enable, dispatcher that only notifies what changed
desktop:       side panel from 768 px, wide screenshots, window-controls-overlay
install:       gh repo clone leonardocandiani/pwa-nativo · ./install.sh
license:       MIT
```

<!-- /readme-padrao:header -->

A Claude Code plugin that takes any web app to a PWA that feels native on the phone and like a real
app on the computer. It creates from scratch, converts an existing system, audits, sets up
notifications and optimizes. The method came out of precodiesel.com.br, where every piece runs in
production.

## Why it exists

Turning a site into a PWA usually stops at the manifest: the app installs, but it opens with a grey
bar on touch, a button that stays lit after the finger leaves, a background cut off by the browser
bar, notifications nobody knows reach the device and, on the computer, the phone layout stretched
wide. The plugin gathers what fixed each of those points into one method, with ready code and an
auditor that reports the defect with file and line.

## Commands

| Command | What it does |
|---|---|
| `/pwa-nativo:criar <app>` | PWA from scratch with the seven layers, Next.js by default or Vite |
| `/pwa-nativo:converter [folder]` | takes an existing web system to PWA without replacing what works |
| `/pwa-nativo:auditar [folder]` | runs the auditor, checks the code and the render, lists what to fix |
| `/pwa-nativo:notificacoes <what to notify>` | VAPID, per-device subscription, instant test and a dispatcher that only notifies what changed |
| `/pwa-nativo:otimizar [folder]` | fixes what the auditor and the render point out, with before and after |

The `auditor-pwa` agent runs the audit read-only and confirms each finding on the line before
reporting it.

## The seven layers

1. **Manifest and icons**: fixed `id`, `any` and `maskable` icons, `apple-touch-icon`, wide and
   narrow screenshots for the install prompt, shortcuts.
2. **Service worker**: network first for pages and data, cache first for hashed files, versioned
   caches; opens offline with what was already seen.
3. **Install**: a custom button where the browser allows it (Android, Chrome and Edge on desktop),
   the right steps where it does not (iPhone, Safari on Mac), hidden once installed.
4. **Notifications**: enabled on tap, sends a test right away, and a dispatcher that computes in
   code what changed and sends one notification per person.
5. **Native shell**: dock at the bottom on the phone, side panel from 768 px, safe area, `dvh`,
   taps with no delay and no flash, hover only where a mouse exists.
6. **Data without deploy**: data that changes on a schedule goes to a bucket with the manifest
   written last, and the app uses the build-time data as a fallback.
7. **Verification**: auditor at 0, render at 390 and 1280 px, active service worker and offline
   open proven by script; what only a real device can prove is stated as pending.

## Auditor

```bash
node scripts/auditar.mjs <folder>          # TOON, exit 0 clean, 1 with errors, 2 wrong usage
node scripts/auditar.mjs <folder> --json
node scripts/auditar.mjs <folder> --sem-cache
```

It checks 32 rules with no network and no dependencies: manifest (M), service worker (S),
notifications (P), install (I), native polish (N) and desktop (D). Each id has its fix in
`skills/pwa-nativo/references/regras.md`. The analysis of each file is kept in
`.pwa-nativo/cache.json`, validated by size, date and sha1; only what changed is read again. The
auditor never executes code from the audited project: a JS manifest is converted to JSON, and
anything that is not a literal becomes the M00 warning.

## Install

```bash
gh repo clone leonardocandiani/pwa-nativo ~/projetos/pwa-nativo
~/projetos/pwa-nativo/install.sh
```

`install.sh` runs the suite, validates the plugin, registers the local marketplace and installs
`pwa-nativo@pwa-nativo`. In sessions that are already open, run `/reload-plugins`. It needs
Node.js 18+ and Claude Code.

## Structure

```
.claude-plugin/        plugin.json and marketplace.json
commands/              criar, converter, auditar, notificacoes, otimizar
agents/auditor-pwa.md  read-only audit
skills/pwa-nativo/     the method and one reference per layer
scripts/               regras.mjs and auditar.mjs
templates/             service worker, browser core, React, Next, Vite, CSS, Supabase, generators
testes/                node --test testes/*.test.mjs, with good and bad examples
```

## Tests

```bash
node --test testes/*.test.mjs
```

Eleven tests: the good example comes out clean, the bad one reports every planted defect with file
and line, the cache hits and invalidates (edit, date only, deleted file, version), a deleted icon
is still seen despite the cache, and the malicious manifest is not executed.

## License

MIT. See `LICENSE`.

<!-- readme-padrao:footer -->
<br>

---

<div align="center">
  <p><strong>Built by <a href="https://github.com/leonardocandiani">Leonardo Candiani</a></strong> · More projects at <a href="https://github.com/leonardocandiani?tab=repositories">github.com/leonardocandiani</a></p>
  <p>Leonardo Candiani builds AI agents that talk, decide and close deals. Cofounder of SixQuasar, operating Proteauto, SegSmart and IACall end to end.</p>
  <a href="https://leonardocandiani.com.br">
    <img src="https://img.shields.io/badge/-Website-0d1117?style=for-the-badge&logo=safari&logoColor=00d9ff" alt="Website" />
  </a>
  <a href="https://github.com/leonardocandiani">
    <img src="https://img.shields.io/badge/-GitHub-0d1117?style=for-the-badge&logo=github&logoColor=00d9ff" alt="GitHub" />
  </a>
  <a href="https://instagram.com/leonardocandiani">
    <img src="https://img.shields.io/badge/-Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white" alt="Instagram" />
  </a>
  <a href="https://youtube.com/@oleonardocandiani">
    <img src="https://img.shields.io/badge/-YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white" alt="YouTube" />
  </a>
</div>

<br>

<div align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:00d9ff,50:1a1a2e,100:0d1117&height=120&section=footer&text=Thanks%20for%20stopping%20by&fontSize=18&fontColor=ffffff&fontAlignY=72" alt="Thanks for stopping by" width="100%" />
</div>
<!-- /readme-padrao:footer -->
