<!-- readme-padrao:header -->
<!-- Banner -->
<div align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:0d1117,50:1a1a2e,100:00d9ff&height=200&section=header&text=pwa-nativo&fontSize=54&fontColor=ffffff&animation=fadeIn&fontAlignY=36&desc=Plugin%20do%20Claude%20Code%20para%20PWA%20com%20cara%20de%20app%20nativo%20no%20celular%20e%20no%20desktop&descAlignY=58&descSize=16" alt="pwa-nativo" width="100%" />
</div>

<!-- Typing -->
<div align="center">
  <img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=600&size=21&duration=2800&pause=900&color=00d9ff&center=true&vCenter=true&width=840&lines=PWA+com+cara+de+app+nativo+no+celular+e+no+desktop;Cria%2C+converte%2C+audita%2C+notifica+e+otimiza;Auditor+de+32+regras+com+arquivo+e+linha%2C+sem+rede;Next.js%2C+Vite%2C+React%2C+Supabase+e+Web+Push" alt="PWA com cara de app nativo no celular e no desktop" />
</div>

<div align="center">

  <p><strong>Do site ao app instalável, com notificação que chega e layout de app nas duas telas.</strong></p>

  <p>
    <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-00d9ff?style=for-the-badge" alt="License: MIT" /></a>
    <a href="https://docs.claude.com/en/docs/claude-code"><img src="https://img.shields.io/badge/Made%20for-Claude%20Code-D97757?style=for-the-badge&logo=anthropic&logoColor=white" alt="Made for: Claude Code" /></a>
    <img src="https://img.shields.io/badge/node-18%2B%20sem%20depend%C3%AAncia-1a1a2e?style=for-the-badge&logo=nodedotjs&logoColor=white" alt="node: 18+ sem dependência" />
    <img src="https://img.shields.io/badge/regras-32-00d9ff?style=for-the-badge" alt="regras: 32" />
  </p>

  <p>
    <a href="#por-que-existe">Por que existe</a> •
    <a href="#comandos">Comandos</a> •
    <a href="#as-sete-camadas">As sete camadas</a> •
    <a href="#auditor">Auditor</a> •
    <a href="#instalar">Instalar</a> •
    <a href="#estrutura">Estrutura</a> •
    <a href="#testes">Testes</a> •
    <a href="#licença">Licença</a>
  </p>
</div>

<br>

> **pwa-nativo** junta num plugin o que fez o precodiesel.com.br virar app: manifesto e ícones certos, service worker que abre sem internet, instalação por plataforma, notificação testada na hora e casca com dock no celular e painel lateral no desktop.

> Sem vínculo com a Anthropic. "Claude" e "Claude Code" são marcas da Anthropic.

## O que é

```yaml
produto:      plugin do Claude Code: criar, converter, auditar, notificar e otimizar PWA
camadas:      manifesto · service worker · instalação · notificações · casca nativa · dados · verificação
auditor:      32 regras, saída TOON, cache por arquivo com sha1, nunca executa código auditado
modelos:      17 arquivos: sw.js, núcleo do navegador, React, Next, Vite, CSS, Supabase, geradores
notificações: VAPID sem dependência, teste ao ligar, disparador que só avisa o que mudou
desktop:      painel lateral a partir de 768 px, screenshots wide, window-controls-overlay
instalar:     gh repo clone leonardocandiani/pwa-nativo · ./install.sh
licença:      MIT
```

<!-- /readme-padrao:header -->

Plugin do Claude Code para levar qualquer app web a PWA com cara de app nativo no celular e de app
de verdade no computador. Ele cria do zero, converte um sistema que já existe, audita, monta
notificações e otimiza. O método saiu do precodiesel.com.br, onde cada peça roda em produção.

## Por que existe

Transformar site em PWA costuma parar no manifesto: o app instala, mas abre com barra cinza no
toque, botão que fica aceso depois do dedo, fundo cortado pela barra do navegador, notificação que
ninguém sabe se chega e, no computador, o layout do celular esticado. O plugin junta o que resolveu
cada um desses pontos num método só, com código pronto e um auditor que acusa o defeito com arquivo
e linha.

## Comandos

| Comando | O que faz |
|---|---|
| `/pwa-nativo:criar <app>` | PWA do zero com as sete camadas, Next.js por padrão ou Vite |
| `/pwa-nativo:converter [pasta]` | leva um sistema web existente a PWA sem trocar o que funciona |
| `/pwa-nativo:auditar [pasta]` | roda o auditor, confere no código e no render, lista o que corrigir |
| `/pwa-nativo:notificacoes <o que avisar>` | VAPID, inscrição por aparelho, teste na hora e disparador que só avisa o que mudou |
| `/pwa-nativo:otimizar [pasta]` | corrige o que o auditor e o render apontam, com antes e depois |

O agente `auditor-pwa` faz a auditoria só leitura e confirma cada achado na linha antes de
reportar.

## As sete camadas

1. **Manifesto e ícones**: `id` fixo, ícones `any` e `maskable`, `apple-touch-icon`, prints wide e
   narrow para o convite de instalação, atalhos.
2. **Service worker**: rede primeiro para página e dado, cache primeiro para arquivo com hash,
   caches por versão; abre sem internet com o que já foi visto.
3. **Instalação**: botão próprio onde o navegador deixa (Android, Chrome e Edge no desktop), passos
   certos onde não deixa (iPhone, Safari no Mac), some quando já instalado.
4. **Notificações**: liga no toque, manda uma de teste na hora, disparador que calcula em código o
   que mudou e manda uma notificação por pessoa.
5. **Casca nativa**: dock embaixo no celular, painel lateral a partir de 768 px, área segura,
   `dvh`, toque sem atraso e sem flash, hover só onde existe mouse.
6. **Dados sem deploy**: dado que muda por agenda vai para um bucket com manifest por último, e o
   app usa o dado do build como reserva.
7. **Verificação**: auditor em 0, render em 390 e 1280 px, service worker ativo e abertura offline
   provados em script; o que só o aparelho prova fica dito como pendente.

## Auditor

```bash
node scripts/auditar.mjs <pasta>          # TOON, exit 0 limpo, 1 com erro, 2 uso errado
node scripts/auditar.mjs <pasta> --json
node scripts/auditar.mjs <pasta> --sem-cache
```

Confere 32 regras sem rede e sem dependência: manifesto (M), service worker (S), notificações
(P), instalação (I), acabamento nativo (N) e desktop (D). Cada id tem a correção em
`skills/pwa-nativo/references/regras.md`. A análise de cada arquivo fica em
`.pwa-nativo/cache.json`, validada por tamanho, data e sha1; só o que mudou é relido. O auditor
nunca executa código do projeto auditado: o manifesto em JS é convertido para JSON, e o que não for
literal vira o aviso M00.

## Instalar

```bash
gh repo clone leonardocandiani/pwa-nativo ~/projetos/pwa-nativo
~/projetos/pwa-nativo/install.sh
```

O `install.sh` roda a suíte, valida o plugin, registra o marketplace local e instala
`pwa-nativo@pwa-nativo`. Nas sessões já abertas, rode `/reload-plugins`. Precisa de Node.js 18+ e
do Claude Code.

## Estrutura

```
.claude-plugin/        plugin.json e marketplace.json
commands/              criar, converter, auditar, notificacoes, otimizar
agents/auditor-pwa.md  auditoria só leitura
skills/pwa-nativo/     método e uma referência por camada
scripts/               regras.mjs e auditar.mjs
templates/             service worker, núcleo do navegador, React, Next, Vite, CSS, Supabase, geradores
testes/                node --test testes/*.test.mjs, com exemplos bom e ruim
```

## Testes

```bash
node --test testes/*.test.mjs
```

Onze testes: o exemplo bom sai limpo, o ruim acusa cada defeito plantado com arquivo e linha, o
cache acerta e invalida (edição, só a data, arquivo apagado, versão), o ícone apagado é visto mesmo
com cache, e o manifesto malicioso não é executado.

## Licença

MIT. Veja `LICENSE`.

<!-- readme-padrao:footer -->
<br>

---

<div align="center">
  <p><strong>Feito por <a href="https://github.com/leonardocandiani">Leonardo Candiani</a></strong> · Mais projetos em <a href="https://github.com/leonardocandiani?tab=repositories">github.com/leonardocandiani</a></p>
  <p>Leonardo Candiani constrói agentes de IA que conversam, decidem e fecham negócio. Cofundador da SixQuasar, operando Proteauto, SegSmart e IACall ponta a ponta.</p>
  <a href="https://leonardocandiani.com.br">
    <img src="https://img.shields.io/badge/-Site-0d1117?style=for-the-badge&logo=safari&logoColor=00d9ff" alt="Site" />
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
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:00d9ff,50:1a1a2e,100:0d1117&height=120&section=footer&text=Obrigado%20pela%20visita%21&fontSize=18&fontColor=ffffff&fontAlignY=72" alt="Obrigado pela visita!" width="100%" />
</div>
<!-- /readme-padrao:footer -->
