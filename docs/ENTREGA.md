# Equipe, autoria e entrega

Documento exigido pela instrução 6 da seção 4 do enunciado: informa quais
artefatos foram construídos por cada membro da equipe. Registra também como as
instruções 1 a 5 são atendidas. Rastreado pela issue
[#34](https://github.com/WilsonSousajr/okonomi/issues/34); o empacotamento final
é tratado em [#35](https://github.com/WilsonSousajr/okonomi/issues/35).

## Equipe

O trabalho é realizado **individualmente** (instrução 1 permite de um a cinco
participantes).

| Nome completo | Matrícula |
|---|---|
| José Wilson Barbosa de Sousa Júnior | 241024259 |

## Autoria dos artefatos

| # | Artefato | Documento | Issue | Autor | Situação |
|---|---|---|---|---|---|
| 1 | Descrição do processo (quadro e cartões Kanban) | [`docs/PROCESSO.md`](PROCESSO.md) | [#25](https://github.com/WilsonSousajr/okonomi/issues/25) | José Wilson Barbosa de Sousa Júnior | concluído |
| 2 | Documento de visão e escopo | [`docs/VISAO.md`](VISAO.md) | [#26](https://github.com/WilsonSousajr/okonomi/issues/26) | José Wilson Barbosa de Sousa Júnior | concluído |
| 3 | Requisitos não funcionais | [`docs/REQUISITOS-NAO-FUNCIONAIS.md`](REQUISITOS-NAO-FUNCIONAIS.md) | [#27](https://github.com/WilsonSousajr/okonomi/issues/27) | José Wilson Barbosa de Sousa Júnior | concluído |
| 4 | Requisitos funcionais por histórias de usuário | [`docs/HISTORIAS-DE-USUARIO.md`](HISTORIAS-DE-USUARIO.md) | [#28](https://github.com/WilsonSousajr/okonomi/issues/28) | José Wilson Barbosa de Sousa Júnior | concluído |
| 5 | Architecture notebook | [`docs/ARQUITETURA.md`](ARQUITETURA.md) | [#29](https://github.com/WilsonSousajr/okonomi/issues/29) | José Wilson Barbosa de Sousa Júnior | concluído |
| 6 | Projeto de interface (storyboards e wireframes) | [`docs/INTERFACE.md`](INTERFACE.md) | [#30](https://github.com/WilsonSousajr/okonomi/issues/30) | José Wilson Barbosa de Sousa Júnior | concluído |
| 7 | Projeto físico do banco de dados | [`docs/BANCO-DE-DADOS.md`](BANCO-DE-DADOS.md) | [#31](https://github.com/WilsonSousajr/okonomi/issues/31) | José Wilson Barbosa de Sousa Júnior | concluído |
| 8 | Protótipo e vídeo de teste de sistema | esta aplicação | [#32](https://github.com/WilsonSousajr/okonomi/issues/32) | José Wilson Barbosa de Sousa Júnior | concluído |
| 9 | Infraestrutura de implantação | [`docs/INFRAESTRUTURA.md`](INFRAESTRUTURA.md) | [#33](https://github.com/WilsonSousajr/okonomi/issues/33) | José Wilson Barbosa de Sousa Júnior | concluído |

A coluna **Situação** acompanha o quadro Kanban: *a fazer* (Backlog ou Sprint
Backlog), *em andamento* (Doing), *em revisão* (Review) e *concluído* (Done). O
histórico de commits do repositório registra quem escreveu cada trecho de cada
artefato, e quando.

Cada documento é entregue também em **PDF** (instrução 7), em
[`docs/pdf/`](pdf/), gerado a partir do Markdown por `bin/docs-pdf`.

## Como as instruções 1 a 6 são atendidas

| Instrução | Como é atendida |
|---|---|
| **1.** Trabalho individual ou em equipe de até cinco. | Trabalho individual; ver [Equipe](#equipe). |
| **2.** Artefatos em plataforma com controle de versões. | Todos os artefatos estão no repositório Git [WilsonSousajr/okonomi](https://github.com/WilsonSousajr/okonomi). Nenhuma mudança entra no `main` sem pull request e CI verde. |
| **3.** Adotar modelos (*templates*). | Os modelos fornecidos estão versionados em [`docs/RF/Templates/`](RF/Templates/); a tabela abaixo mostra qual artefato segue qual modelo. |
| **4.** Preencher os documentos com clareza. | Cada documento segue a ordem de seções do seu modelo e termina com uma tabela que liga cada item do critério de avaliação à seção que o atende. |
| **5.** Revisar cada artefato antes da entrega. | Rotina de revisão abaixo; o modelo de pull request e o de issue de artefato trazem a caixa de revisão. |
| **6.** Informar quais artefatos cada membro construiu. | Este documento, seção [Autoria dos artefatos](#autoria-dos-artefatos). |

### Modelos adotados

| Modelo | Usado em |
|---|---|
| `vision_tpl.odt` | Artefato 2: visão e escopo |
| `systemwide_req_spec.odt` | Artefato 3: requisitos não funcionais |
| `architecture-notebook.odt` | Artefato 5: architecture notebook |
| `project_plan_tpl.odt`, `iteration_plan_tpl.odt` | Artefato 1. O documento segue as seções do plano de projeto (introdução, organização, práticas e medições, marcos e objetivos, implantação, lições aprendidas); cada marco tem plano e avaliação nas seções do plano de iteração. |
| `uc_specification_tpl.odt` | Não adotado: o enunciado pede requisitos funcionais por **histórias de usuário** (artefato 4), não por casos de uso. As histórias seguem o modelo *Como … eu quero … para …* (instrução 14). |

### Rotina de revisão (instrução 5)

Antes de cada artefato sair de **Review** para **Done**:

1. Ortografia e gramática: o documento é lido por inteiro, com corretor
   ortográfico de português.
2. Clareza: cada seção responde ao item do critério de avaliação que cobre, sem
   jargão sem explicação.
3. Consistência: números de issues, nomes de tabelas, colunas e requisitos
   batem com o código e com os demais artefatos.
4. Links: todos os links e imagens abrem no GitHub.

A revisão é registrada marcando a caixa *Revisão de ortografia e clareza* no
pull request do artefato. Nenhum PR de artefato é mesclado com essa caixa em
branco.

## Entrega

O arquivo de entrega (instruções 26 e 27) terá o nome **`ESW-241024259.ZIP`**,
formado pela matrícula do único autor. O conteúdo do pacote, os PDFs de
`docs/pdf/` (instrução 7) e as verificações finais (instrução 28) estão descritos em
[#35](https://github.com/WilsonSousajr/okonomi/issues/35).
