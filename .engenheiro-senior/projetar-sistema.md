# Projeto do sistema: plugin pwa-nativo

O sistema é um plugin do Claude Code que leva qualquer app web a PWA com cara de app nativo no
celular e de app de verdade no desktop. Ele cria do zero, converte um sistema existente, audita,
monta notificações e otimiza. O método saiu do precodiesel.com.br, que roda cada peça em produção.

## Arquitetura

Requisitos, por escrito:

- **O que faz:** cinco comandos (criar, converter, auditar, notificacoes, otimizar), uma skill com o
  método em sete camadas, um agente auditor só leitura, um auditor estático sem rede e modelos de
  código copiados para o projeto-alvo.
- **Volume esperado (suposição):** projetos de 50 a 3.000 arquivos de código; o auditor roda várias
  vezes por sessão de trabalho, a cada correção. Leitura domina: cada rodada lê o projeto inteiro e
  escreve só o arquivo de cache.
- **O que não pode falhar:** o auditor nunca executa código do projeto auditado (ele lê repositório
  alheio), nunca acusa erro que não existe no projeto bom de exemplo, e nunca deixa de ver um ícone
  apagado por causa do cache. A chave privada VAPID nunca aparece em saída de comando.

Três camadas:

1. **Conhecimento** (`skills/pwa-nativo/`): SKILL.md com o método e as regras inegociáveis; uma
   referência por camada; `regras.md` com a correção de cada id do auditor.
2. **Execução** (`commands/`, `agents/`): cada comando é um roteiro que usa a skill, os modelos e o
   auditor; o agente `auditor-pwa` confere achados sem alterar arquivo.
3. **Ferramentas** (`scripts/`, `templates/`): o auditor (Node puro, zero dependência) e os modelos
   (service worker, núcleo do navegador, componentes React, arquivos do Next, SQL do Supabase,
   geradores de chave e de ícone, disparador de notificações).

## Estrutura de componentes

| Componente | Responsabilidade |
|---|---|
| `scripts/regras.mjs` | 32 regras: 6 por arquivo (casam texto com linha) e 26 globais (decidem sobre fatos somados e o manifesto), mais M00 para manifesto não lido |
| `scripts/auditar.mjs` | lista arquivos, lê do cache o que não mudou, extrai o manifesto sem executar código, confere ícones no disco, imprime TOON, exit 0/1/2 |
| `templates/comum/public/sw.js` | estratégia por tipo de recurso, caches por versão, push e clique |
| `templates/comum/lib/pwa.js` | registro do service worker, plataforma, instalação, notificações |
| `templates/react/` | hooks e cartões de instalar e de notificações, dock e casca celular/desktop |
| `templates/next/app/` | manifesto, layout com viewport e theme-color, registro, rota de teste de push |
| `templates/supabase/push.sql` | inscrições por aparelho, funções e segredo do disparador por hash |
| `templates/scripts/` | `gerar-vapid.mjs` (sem dependência), `disparar.mjs`, `gerar-icones.sh` |
| `commands/*.md` | roteiros dos cinco comandos |
| `agents/auditor-pwa.md` | auditoria só leitura com confirmação de cada achado |

## Fluxo de dados

Uma rodada de `/pwa-nativo:auditar` de ponta a ponta:

1. O comando chama `node scripts/auditar.mjs <pasta>`.
2. `listarArquivos` percorre a pasta pulando `node_modules`, `.next`, `dist`, `.git` e afins.
3. `lerCache` abre `.pwa-nativo/cache.json`; versão diferente de `VERSAO_CACHE` descarta tudo.
4. Para cada arquivo, `analisarComCache`: tamanho e data iguais, reaproveita; mudou, lê e calcula o
   sha1; sha1 igual, reaproveita e atualiza a data; diferente, roda `analisarArquivo` (fatos e
   achados por linha) e `extrairManifesto`.
5. `varrer` soma os fatos de todos os arquivos e pega o primeiro manifesto.
6. `achadosGlobais` roda as regras globais sobre os fatos e confere no disco, sempre, cada ícone e
   print citado no manifesto.
7. `gravarCache` grava só os arquivos vistos nesta rodada (apagado sai do cache).
8. A saída TOON vai para o stdout; o agente abre cada achado na linha e confirma.

Fluxo de uma notificação no app gerado: chave na tela, permissão no toque, inscrição gravada pela
função `app_inscrever_push`, rota de teste manda a primeira notificação; o disparador agendado lê
destinatários com o segredo, decide em código o que mudou, envia uma por pessoa e descarta 404/410.

## Design de API

A "API" do sistema é a CLI do auditor e os comandos.

| Chamada | Entrada | Saída | Erros |
|---|---|---|---|
| `node scripts/auditar.mjs <pasta>` | pasta do projeto | TOON: `pasta`, `arquivos` (com reaproveitados e relidos), `resumo`, `achados[N]{id,sev,arquivo,linha,regra}`, `help` | exit 1 com algum erro; exit 2 com `code: USO` para flag desconhecida ou pasta inexistente |
| `... --json` | idem | o mesmo objeto em JSON | idem |
| `... --sem-cache` | idem | idem, sem ler nem gravar cache | idem |
| `... --ajuda` | nada | uso e exemplos | exit 0 |
| `/pwa-nativo:criar <app> [next\|vite]` | descrição do app | projeto com as sete camadas e auditor em 0 | auditor acima de 0 não fecha a entrega |
| `/pwa-nativo:converter [pasta]` | projeto existente | antes e depois do auditor | o que funciona não é trocado |
| `/pwa-nativo:auditar [pasta]` | projeto | tabela por severidade, sem alterar nada | falso positivo descartado com motivo |
| `/pwa-nativo:notificacoes <o que avisar>` | evento | VAPID, banco, rota de teste e disparador | sem login 401, sem inscrição 400, sem chaves 503, serviço recusou 502 |
| `/pwa-nativo:otimizar [pasta]` | PWA existente | antes e depois por severidade | mudança mínima por achado |
| `POST /api/push/teste` (modelo) | `{ inscricao }` e `Authorization: Bearer` | `{ enviado: true }` | 400, 401, 502 com o status do serviço de push, 503 |

## Esquema de banco de dados

O auditor não tem banco: o estado dele é o arquivo `.pwa-nativo/cache.json` na pasta auditada.

```json
{
  "versao": 1,
  "arquivos": {
    "app/layout.js": {
      "tamanho": 812, "mtimeMs": 1760620000000, "sha1": "…",
      "fatos": ["viewportCover", "themeColor"],
      "achados": [{ "id": "N06", "sev": "erro", "linha": 1 }],
      "manifesto": null
    }
  }
}
```

A chave é o caminho relativo; não há índice além do próprio objeto, porque o acesso é sempre por
caminho exato.

O app gerado ganha o esquema de `templates/supabase/push.sql`: `app.push` (uma linha por aparelho:
conta, endpoint único, chaves, data de criação e de último envio) com índice único em `endpoint` e
índice em `conta_id`; `app.config` (chave e valor, guarda o sha256 do segredo do disparador). O
acesso é só por funções `security definer`: `app_inscrever_push` (limite de 10 aparelhos por
conta), `app_cancelar_push`, `app_push_destinatarios` e `app_push_descartar`, as duas últimas
conferindo o segredo por `app.segredo_confere`.

## Estratégia de cache

Cache do auditor, por arquivo:

- **O que entra:** o resultado da análise de cada arquivo de código (fatos, achados com linha e o
  manifesto extraído).
- **Chave:** caminho relativo à pasta auditada.
- **Validade:** tamanho e data iguais reaproveitam sem ler; se mudaram, o sha1 do conteúdo decide.
  Só a data mudou (checkout, `touch`), o sha1 confirma e a análise não roda de novo.
- **Invalidação na escrita:** editar o arquivo muda o sha1 e só aquela entrada é refeita; arquivo
  apagado sai na gravação seguinte; mudar a forma do que vai para o cache sobe `VERSAO_CACHE`, que
  descarta tudo.
- **O que nunca entra:** as regras globais (dependem da soma de todos os arquivos) e a existência
  dos ícones no disco, conferida em toda rodada; com `--sem-cache`, nada é lido nem gravado.

Cache do app gerado (service worker): página com rede primeiro e casca de reserva; dado com rede
primeiro e o último visto se cair; arquivo com hash e ícone com cache primeiro; mídia em cache
próprio. Nunca entra: POST, resposta com erro, dado de conta.

Onde cada peça escala depois, sem construir agora: projetos acima de 10 mil arquivos pedem leitura
em paralelo com `worker_threads` e cache gravado por partes; times grandes podem guardar o cache
no CI por hash do lockfile; as regras por regex viram análise por AST (o `typescript` do próprio
projeto) quando o falso positivo passar a custar mais que a dependência; o disparador de
notificações vira fila (pgmq ou a fila do provedor) quando passar de alguns milhares de envios por
rodada, mantendo o descarte de 404/410.

## Código de implementação

Estado no repositório `pwa-nativo`:

- `scripts/regras.mjs` (140 linhas) e `scripts/auditar.mjs` (cerca de 210 linhas), Node puro,
  lizard sem função acima de CCN 10.
- `testes/auditar.test.mjs`: 11 testes, com exemplos `bom` e `ruim` em `testes/fixtures/`.
- `templates/`: 17 modelos; `skills/pwa-nativo/`: SKILL.md e 9 referências; 5 comandos; 1 agente.
- `install.sh`: roda a suíte, valida o plugin, registra o marketplace local e instala.

Três defeitos apareceram na prova ponta a ponta e foram corrigidos antes desta entrega:

1. `registrarServiceWorker` só registrava no evento `load`; em React e Next o efeito roda depois
   dele, e o service worker nunca era registrado. Agora registra na hora se a página já carregou.
2. `estadoNotificacoes` esperava `serviceWorker.ready`, que fica pendente para sempre sem registro;
   o cartão de notificações nunca aparecia. Agora usa `getRegistration()`.
3. O auditor avaliava o manifesto do Next com `new Function`, executando código do repositório
   auditado. Agora converte o literal para JSON sem executar; o que não for literal vira M00.

Também: `gerar-vapid.mjs` dependia do pacote `web-push` e quebrava rodado da pasta do plugin; agora
gera o par P-256 com `node:crypto`, no mesmo formato.

## Verificação

Suíte do auditor, incluindo acerto e invalidação do cache e o teste de não execução:

```
$ node --test testes/*.test.mjs
✔ projeto bom sai limpo
✔ projeto ruim acusa cada defeito plantado, com arquivo e linha
✔ cache: segunda rodada reaproveita tudo e dá o mesmo resultado
✔ cache: editar um arquivo invalida só ele e muda o resultado
✔ cache: só a data mudou, o sha1 confirma e não relê a análise
✔ cache: arquivo apagado sai do cache e leva o achado junto
✔ cache: versão diferente descarta tudo
✔ ícone apagado é sempre conferido no disco, mesmo com o manifesto em cache
✔ manifesto em JS é lido sem executar o código do projeto auditado
✔ --sem-cache não grava nada
✔ CLI: exit 0 limpo, 1 com erro, 2 em uso errado
ℹ tests 11
ℹ pass 11
ℹ fail 0
```

Mutação: desligar o reaproveitamento do cache derrubou 4 testes; voltar a executar o manifesto
derrubou o teste de não execução (10 pass, 1 fail). Restaurado, 11 de 11.

Auditor no precodiesel (projeto real, 94 arquivos) e num app Next montado só com os modelos:

```
$ node scripts/auditar.mjs /Volumes/Projetos/arquivos/diesel-brasil --sem-cache
resumo: 0 erros, 3 avisos, 1 dicas
$ node scripts/auditar.mjs <app-de-teste>
resumo: 0 erros, 0 avisos, 0 dicas
```

Prova ponta a ponta do app montado com os modelos (`next build` com Next 15.5.4, servidor local):

```
build: ✓ Compiled successfully; rotas /, /manifest.webmanifest, /api/push/teste
/sw.js 200 | /icons/icon-192.png 200 | /icons/icon-maskable-512.png 200 | /prints/tela-larga.png 200
POST /api/push/teste corpo vazio            -> 400
POST /api/push/teste sem login              -> 401
POST /api/push/teste token ruim             -> 401
POST /api/push/teste logado, endpoint falso -> 502 com status 410 do serviço de push do Google
Chrome headless 390x844: dock 0,779 390x65; painel em tela cheia; sem estouro
Chrome headless 1280x900: dock oculto; painel 480 px; conteúdo 480,0 800x900; sem estouro
service worker: registros 1, controle true, cache casca-v1
servidor derrubado (porta sem resposta): página recarregou do cache com painel e dock
beforeinstallprompt disparou: botão "Instalar agora" visível
```

O 410 do serviço de push prova que a assinatura VAPID saiu certa (chave errada daria 401 ou 403).
Pendente de aparelho, dito como pendente: a notificação aparecendo no iPhone e no Android, a
instalação pelo menu do Safari e o toque no dock em hardware real.
