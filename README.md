# okonomi

[![CI](https://github.com/WilsonSousajr/okonomi/actions/workflows/ci.yml/badge.svg)](https://github.com/WilsonSousajr/okonomi/actions/workflows/ci.yml)

Sistema web de **gestão de requisitos em projetos que usam histórias de usuário**.

Trabalho Prático da disciplina de **Engenharia de Software** (2026.2). O enunciado
completo está em [`docs/RF/ESW-TRABALHO-PRÁTICO.pdf`](docs/RF/ESW-TRABALHO-PRÁTICO.pdf).

## O que o sistema faz

Um usuário autenticado mantém **projetos**. Cada projeto tem **um** product backlog e
**vários** sprint backlogs. Histórias de usuário vivem em um backlog, podem ser
agrupadas em **épicos**, recebem **critérios de aceitação** e são estimadas e
priorizadas por **story points**, etiqueta **MoSCoW** e pontuação **RICE**.

Dois formatos são impostos pela estrutura de dados, não por convenção:

- **História:** *Como um [papel], eu quero [ação], para [benefício].*
- **Critério de aceitação:** *Dado [contexto], quando [ação], então [resultado].*

## Equipe

<!-- TODO: preencher com nome completo e matrícula de cada participante.
     Exigido pela instrução 6 do enunciado e usado para nomear o arquivo de
     entrega ESW-A-B-C-D-E-F.ZIP (instrução 27). Ver issues #34 e #35. -->

| Nome | Matrícula | Artefatos construídos |
|---|---|---|
| Wilson Sousa | _a preencher_ | _a preencher_ |

## Stack

| Item | Versão |
|---|---|
| Ruby | 3.4.10 |
| Rails | 8.1.3.1 |
| PostgreSQL | 17 |
| CSS | Tailwind CSS v4 |
| Front-end | Hotwire (Turbo + Stimulus), Propshaft, Importmap |
| Jobs / cache / cable | Solid Queue, Solid Cache, Solid Cable |
| Testes | Minitest + Capybara |

## Como rodar

Pré-requisitos: [mise](https://mise.jdx.dev) e Docker.

```bash
git clone https://github.com/WilsonSousajr/okonomi.git
cd okonomi

git config core.hooksPath .githooks   # ativa a validação da mensagem de commit
mise install                          # instala o Ruby 3.4.10 fixado em .mise.toml
docker compose up -d postgres         # sobe o banco
bin/setup                             # instala gems, cria e migra o banco
bin/dev                               # sobe a aplicação em http://localhost:3000
```

### Gate local

Rode tudo antes de abrir um PR. É o mesmo conjunto que a CI executa:

```bash
bin/rubocop
bin/brakeman --no-pager
bundle exec bundler-audit check --update
bin/rails test
bin/rails test:system
```

## Como o projeto é gerenciado

O gerenciamento segue o método **Kanban**, no quadro
**[okonomi (GitHub Projects)](https://github.com/users/WilsonSousajr/projects/14)**.
O quadro e os cartões são, eles próprios, um artefato avaliado (Critério de
Avaliação 01).

| Coluna | Propósito | Critério de saída |
|---|---|---|
| **Backlog** | Trabalho capturado e priorizado, ainda sem responsável. Fonte única de tudo que falta. | Escopo entendido, MoSCoW e RICE definidos |
| **Sprint Backlog** | Comprometido para a iteração atual; pronto para ser puxado. | Critérios de aceitação escritos e story points estimados |
| **Doing** | Em execução agora. Limite de WIP: 1 cartão por pessoa. | Branch aberta e vinculada à issue |
| **Review** | PR aberto, aguardando revisão e CI verde. | PR aprovado e check `ci` passando |
| **Done** | Merge no `main`, CI verde e critério de aceitação verificado. | Evidência registrada na issue |

**Toda mudança nasce de uma issue.** Nenhum commit, branch ou PR existe sem uma issue
que lhe dê contexto.

### Padrão de commit

```
tipo(#issue): mensagem
```

Tipos: `feat` `fix` `docs` `test` `refactor` `chore` `build` `ci` `perf` `style`.

```
feat(#15): restrict story points to the Fibonacci scale
fix(#8): reject moving a story to another project's backlog
docs(#31): document the acceptance_criteria table
```

O hook `.githooks/commit-msg` recusa mensagens fora do padrão.

### Rastreabilidade com o enunciado

| Enunciado | Onde está no repositório |
|---|---|
| Seção 2 — 19 requisitos funcionais | uma issue por RF, com a label `RF` |
| Seção 3 — 9 artefatos | uma issue por artefato, com a label `artefato:*` |
| Seção 4 — 30 instruções | *checkboxes* dentro das issues de artefato, #34 e #35 |
| Seção 5 — 9 critérios de avaliação | *checkboxes* na issue do artefato correspondente; as labels `artefato:*` mapeiam 1:1 com os critérios |

## Documentação

| Artefato | Documento |
|---|---|
| 1. Descrição do processo | [`docs/PROCESSO.md`](docs/PROCESSO.md) |
| 2. Visão e escopo | [`docs/VISAO.md`](docs/VISAO.md) |
| 3. Requisitos não funcionais | [`docs/REQUISITOS-NAO-FUNCIONAIS.md`](docs/REQUISITOS-NAO-FUNCIONAIS.md) |
| 4. Requisitos funcionais (histórias) | [`docs/HISTORIAS-DE-USUARIO.md`](docs/HISTORIAS-DE-USUARIO.md) |
| 5. Architecture notebook | [`docs/ARQUITETURA.md`](docs/ARQUITETURA.md) |
| 6. Projeto de interface | [`docs/INTERFACE/`](docs/INTERFACE/) |
| 7. Projeto físico do banco de dados | [`docs/BANCO-DE-DADOS.md`](docs/BANCO-DE-DADOS.md) |
| 8. Protótipo e vídeo | esta aplicação + issue #32 |
| 9. Infraestrutura de implantação | [`docs/INFRAESTRUTURA.md`](docs/INFRAESTRUTURA.md) |

Diretrizes para agentes de IA e para contribuidores: [`AGENTS.md`](AGENTS.md).
