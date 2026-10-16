# pwa-nativo

Plugin do Claude Code para PWA: criar, converter, auditar, notificar e otimizar.

## Mapa

- `skills/pwa-nativo/SKILL.md`: o método (sete camadas, regras inegociáveis); `references/` tem uma
  página por camada e `regras.md` com a correção de cada id do auditor.
- `commands/`: criar, converter, auditar, notificacoes, otimizar.
- `agents/auditor-pwa.md`: auditoria só leitura.
- `scripts/regras.mjs`: as regras (por arquivo e globais). `scripts/auditar.mjs`: varredura, cache
  por arquivo em `.pwa-nativo/cache.json`, saída TOON, exit 0/1/2.
- `templates/`: código copiado para o projeto-alvo (comum, react, next, vite, css, supabase, scripts).
- `testes/`: `node --test testes/*.test.mjs` (o Node 26 não aceita a pasta como argumento).

## Regras do repositório

- Regra nova no auditor: entra em `regras.mjs`, ganha linha em `references/regras.md`, defeito
  plantado em `testes/fixtures/ruim/` e o id na lista do teste. O projeto `bom` continua limpo.
- Mudou a forma do que vai para o cache: suba `VERSAO_CACHE` em `auditar.mjs`.
- Modelos não carregam segredo nem domínio de cliente. Chave pública VAPID vazia no modelo.
- `install.sh` roda a suíte antes de instalar; suíte vermelha não instala.
