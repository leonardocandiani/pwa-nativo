#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

command -v node >/dev/null 2>&1 || { echo "ERRO: precisa do Node.js 18+ (brew install node)" >&2; exit 1; }
[ "$(node -p 'process.versions.node.split(".")[0]')" -ge 18 ] || { echo "ERRO: precisa do Node.js 18+; achei $(node --version)" >&2; exit 1; }
command -v claude >/dev/null 2>&1 || { echo "ERRO: precisa do Claude Code instalado (https://code.claude.com)" >&2; exit 1; }

echo "Rodando a suíte antes de instalar (local, sem rede)..."
( cd "$ROOT" && node --test testes/*.test.mjs >/dev/null ) || { echo "ERRO: suíte falhou; não instalo checkout quebrado." >&2; exit 1; }
echo "auditor: testes verdes"

claude plugin validate "$ROOT" >/dev/null
claude plugin marketplace add "$ROOT" >/dev/null 2>&1 || claude plugin marketplace update pwa-nativo >/dev/null
claude plugin install pwa-nativo@pwa-nativo >/dev/null
echo "Plugin instalado: pwa-nativo@pwa-nativo (rode /reload-plugins nas sessões abertas)"
echo "Experimente: /pwa-nativo:auditar   ou   /pwa-nativo:converter ."
