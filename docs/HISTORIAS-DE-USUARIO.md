# okonomi — Histórias de usuário

**Artefato 4** do Trabalho Prático de Engenharia de Software (2026.2): especificação
dos requisitos funcionais por meio de histórias de usuário. Rastreado pela issue
[#28](https://github.com/WilsonSousajr/okonomi/issues/28); atende às instruções 3 e 14
e ao Critério de Avaliação 04.

| Versão | Data | Autor | Descrição |
|---|---|---|---|
| 1.0 | 18/10/2026 | José Wilson Barbosa de Sousa Júnior | Versão inicial. |

## 1. Introdução

Este documento reúne as histórias de usuário do **okonomi**. Cada um dos 19
requisitos funcionais da seção 2 do enunciado (RF01 a RF19) é descrito por
**exatamente uma** história, escrita do ponto de vista de quem usa o sistema e em
linguagem informal, no modelo **Como um … eu quero … para …**.

Cada história é também uma issue do projeto no GitHub, com o rótulo `RF`. A issue é
o cartão do quadro Kanban (artefato 1): é por ela que a história é priorizada,
estimada, implementada e verificada. As seções da 3 em diante são geradas a partir
dessas issues, e por isso o documento e o quadro dizem sempre a mesma coisa.

O que **não** cabe numa história, como os atributos de qualidade, as restrições e o
licenciamento, está no artefato 3, `REQUISITOS-NAO-FUNCIONAIS.md`
([#27](https://github.com/WilsonSousajr/okonomi/issues/27)).

### 1.1 Modelo adotado

O modelo fornecido para este artefato é `uc_specification_tpl.odt`
([`docs/RF/Templates/`](RF/Templates/)), feito para casos de uso. Ele foi adaptado
para histórias de usuário da seguinte forma:

| Seção do modelo (caso de uso) | Onde está aqui |
|---|---|
| *Use-Case Name* e *Brief Description* | Título da seção (RFnn — nome) e a **história** no formato Como um … eu quero … para … |
| *Actor Brief Descriptions* | Seção 2, Atores |
| *Preconditions* | A parte **Dado** de cada critério de aceitação |
| *Basic Flow* e *Alternative Flows* | Os critérios de aceitação: o primeiro descreve o caminho de sucesso e os demais, as alternativas e recusas |
| *Post-conditions* | A parte **então** de cada critério |
| *Special Requirements* | As notas de invariante ao fim de algumas histórias e o artefato 3 |

### 1.2 Como ler cada história

- **Requisito no enunciado:** o texto original da seção 2 do enunciado que a história atende.
- **História:** no modelo *Como um [papel] eu quero [ação] para [benefício]*.
- **Prioridade e tamanho:** etiqueta **MoSCoW** e **story points** (escala 0, 1, 2, 3, 5,
  8, 13, 21, 34, 55), os mesmos valores registrados no cartão do quadro.
- **Critérios de aceitação:** no modelo *Dado … quando … então …*. Cada critério vira
  um teste automatizado antes de a história ser considerada pronta.

## 2. Atores

| Ator | Descrição |
|---|---|
| **Visitante** | Pessoa ainda sem conta, ou ainda não autenticada. Pode criar uma conta e entrar; não tem acesso a nenhum dado de projeto. |
| **Usuário autenticado** | Qualquer membro de uma equipe ágil (Product Owner, Scrum Master ou desenvolvedor) que entrou com a sua conta. Mantém os próprios projetos, backlogs, épicos, histórias e critérios, e estima e prioriza as histórias. Só vê os dados que são seus. |

Nas histórias, o papel do usuário aparece de forma mais específica quando isso
ajuda a entender o objetivo. Exemplos: "usuário autenticado **planejando uma
iteração**" e "usuário autenticado **priorizando o backlog**".

## 3. Histórias de usuário

### RF01 — Interface gráfica web para acesso ao sistema

**Requisito no enunciado (seção 2):**

> **(1)** interface com o usuário embasada em texto (*text user interface*) ou gráfica (*graphic user interface*)

Optamos por **interface gráfica web**, servida por uma aplicação Ruby on Rails com Hotwire e Tailwind CSS.

**História.** **Como um** membro de equipe de desenvolvimento **eu quero** acessar o okonomi por um navegador web, com layout consistente e responsivo **para** gerenciar requisitos sem instalar nada na minha máquina.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 5 | [#1](https://github.com/WilsonSousajr/okonomi/issues/1) |

**Critérios de aceitação:**

1. **Dado** que o servidor está no ar, **quando** eu acesso a raiz da aplicação, **então** recebo uma página HTML renderizada com o layout da aplicação.
2. **Dado** que estou em qualquer página do sistema, **quando** eu observo a navegação, **então** vejo o mesmo cabeçalho, rodapé e identidade visual.
3. **Dado** que acesso de um dispositivo de 375px de largura, **quando** a página carrega, **então** o conteúdo permanece legível e utilizável sem rolagem horizontal.
4. **Dado** que ocorre um erro de validação, **quando** a página é re-renderizada, **então** as mensagens aparecem em um componente padronizado e acessível.

### RF02 — Criação de conta de usuário

**Requisito no enunciado (seção 2):**

> **(2)** para acessar os serviços disponibilizados, cada usuário deve criar uma conta e depois ser autenticado

Esta issue cobre a **criação da conta**. A autenticação em si é #3.

**História.** **Como um** novo usuário do okonomi **eu quero** criar uma conta informando e-mail e senha **para** passar a ter uma identidade própria no sistema e poder ser autenticado.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 3 | [#2](https://github.com/WilsonSousajr/okonomi/issues/2) |

**Critérios de aceitação:**

1. **Dado** que estou na tela de cadastro, **quando** informo e-mail válido e senha que atende à política mínima, **então** minha conta é criada e sou levado ao sistema autenticado.
2. **Dado** que informo um e-mail já cadastrado, **quando** submeto o formulário, **então** a conta não é criada e recebo mensagem indicando o conflito.
3. **Dado** que informo e-mail em formato inválido ou senha fraca, **quando** submeto o formulário, **então** a conta não é criada e vejo a mensagem de validação no campo correspondente.
4. **Dado** que uma conta foi criada, **quando** inspeciono o banco de dados, **então** a senha está armazenada como *digest*, nunca em texto puro.

### RF03 — Autenticação e acesso aos serviços

**Requisito no enunciado (seção 2):**

> **(2)** ... e depois ser autenticado
> **(3)** uma vez autenticado, o usuário tem acesso aos serviços providos pelo sistema de software

**História.** **Como um** usuário cadastrado **eu quero** entrar no sistema com minhas credenciais e sair quando quiser **para** acessar meus projetos com segurança e impedir que terceiros usem minha sessão.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 3 | [#3](https://github.com/WilsonSousajr/okonomi/issues/3) |

**Critérios de aceitação:**

1. **Dado** que possuo conta ativa, **quando** informo credenciais corretas, **então** uma sessão é criada e sou redirecionado para a lista de projetos.
2. **Dado** que informo credenciais incorretas, **quando** submeto o formulário, **então** permaneço não autenticado e recebo mensagem genérica, sem revelar se o e-mail existe.
3. **Dado** que **não** estou autenticado, **quando** acesso qualquer rota de serviço do sistema, **então** sou redirecionado para a tela de entrada.
4. **Dado** que estou autenticado, **quando** aciono "sair", **então** a sessão é encerrada e o acesso às rotas protegidas volta a ser negado.
5. **Dado** que estou autenticado, **quando** acesso um recurso de outro usuário, **então** recebo negação de acesso.

### RF04 — CRUD de projetos

**Requisito no enunciado (seção 2):**

> **(4)** possibilitar criação leitura, atualização e exclusão de projetos

**História.** **Como um** usuário autenticado **eu quero** criar, listar, editar e excluir meus projetos **para** organizar os requisitos de cada produto em um espaço separado.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 3 | [#4](https://github.com/WilsonSousajr/okonomi/issues/4) |

**Critérios de aceitação:**

1. **Dado** que estou autenticado, **quando** crio um projeto com nome preenchido, **então** o projeto é persistido e passa a aparecer na minha lista.
2. **Dado** que tento criar um projeto sem nome, **quando** submeto, **então** o projeto não é criado e vejo a mensagem de validação.
3. **Dado** que possuo projetos, **quando** acesso a listagem, **então** vejo apenas os meus projetos, nunca os de outro usuário.
4. **Dado** que abro um projeto meu, **quando** altero nome ou descrição, **então** as mudanças são persistidas.
5. **Dado** que excluo um projeto, **quando** confirmo a ação, **então** o projeto e seus backlogs, épicos e histórias associados deixam de existir.

### RF05 — CRUD de product backlog (no máximo um por projeto)

**Requisito no enunciado (seção 2):**

> **(5)** possibilitar criação leitura, atualização e exclusão de *product backlogs*, (pode existir só um *product backlog* por projeto)

**História.** **Como um** usuário autenticado dono de um projeto **eu quero** manter o product backlog do projeto **para** ter um único repositório priorizado de tudo que o produto precisa.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 5 | [#5](https://github.com/WilsonSousajr/okonomi/issues/5) |

**Critérios de aceitação:**

1. **Dado** um projeto sem product backlog, **quando** crio um, **então** ele é persistido e vinculado ao projeto.
2. **Dado** um projeto que **já possui** product backlog, **quando** tento criar um segundo, **então** a criação é recusada com mensagem explicando a restrição de unicidade.
3. **Dado** um product backlog existente, **quando** acesso o projeto, **então** vejo o backlog e as histórias nele contidas.
4. **Dado** um product backlog existente, **quando** edito seus dados, **então** as mudanças são persistidas.
5. **Dado** um product backlog existente, **quando** o excluo, **então** ele deixa de existir e o projeto volta a aceitar a criação de um novo.

> **Invariante:** a unicidade é validada no *model* e garantida por índice único no banco, não apenas no formulário.

### RF06 — CRUD de sprint backlogs (vários por projeto)

**Requisito no enunciado (seção 2):**

> **(6)** possibilitar criação leitura, atualização e exclusão de *sprint backlogs* (podem existir vários *sprint backlogs* por projeto)

**História.** **Como um** usuário autenticado dono de um projeto **eu quero** criar vários sprint backlogs no mesmo projeto **para** separar o que será feito em cada iteração do que continua no product backlog.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 3 | [#6](https://github.com/WilsonSousajr/okonomi/issues/6) |

**Critérios de aceitação:**

1. **Dado** um projeto, **quando** crio um sprint backlog com nome, **então** ele é persistido e vinculado ao projeto.
2. **Dado** um projeto que já possui sprint backlogs, **quando** crio outro, **então** a criação é aceita — não há limite de quantidade.
3. **Dado** um projeto com vários sprint backlogs, **quando** acesso o projeto, **então** vejo todos listados, cada um com suas histórias.
4. **Dado** um sprint backlog existente, **quando** edito seus dados, **então** as mudanças são persistidas.
5. **Dado** um sprint backlog existente, **quando** o excluo, **então** ele deixa de existir e as histórias que continha não ficam órfãs.

### RF07 — CRUD de histórias de usuário associadas ao product backlog

**Requisito no enunciado (seção 2):**

> **(7)** possibilitar criação leitura, atualização e exclusão de histórias de usuário (ao ser criada, história de usuário deve ser associada a *product backlog*)

**História.** **Como um** usuário autenticado **eu quero** manter histórias de usuário dentro do product backlog do projeto **para** registrar as necessidades do produto de forma rastreável.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 5 | [#7](https://github.com/WilsonSousajr/okonomi/issues/7) |

**Critérios de aceitação:**

1. **Dado** um projeto com product backlog, **quando** crio uma história, **então** ela é persistida **associada ao product backlog**.
2. **Dado** que tento criar uma história associada diretamente a um sprint backlog, **quando** submeto, **então** a criação é recusada — toda história nasce no product backlog.
3. **Dado** histórias existentes, **quando** acesso o backlog, **então** vejo todas com título, etiqueta MoSCoW, story points e pontuação RICE.
4. **Dado** uma história existente, **quando** a edito, **então** as mudanças são persistidas.
5. **Dado** uma história existente, **quando** a excluo, **então** ela e seus critérios de aceitação deixam de existir.

> **Invariante:** toda história nasce ligada a um product backlog. Movimentação posterior é tratada em #8.

### RF08 — Movimentação de histórias de usuário entre backlogs

**Requisito no enunciado (seção 2):**

> **(8)** possibilitar a movimentação de histórias de usuário entre *backlogs*

**História.** **Como um** usuário autenticado planejando uma iteração **eu quero** mover histórias entre o product backlog e os sprint backlogs do projeto **para** compor o escopo da sprint sem duplicar ou reescrever a história.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 5 | [#8](https://github.com/WilsonSousajr/okonomi/issues/8) |

**Critérios de aceitação:**

1. **Dado** uma história no product backlog, **quando** a movo para um sprint backlog do **mesmo projeto**, **então** ela passa a pertencer ao sprint backlog e some do product backlog.
2. **Dado** uma história em um sprint backlog, **quando** a movo de volta ao product backlog, **então** a operação é aceita.
3. **Dado** uma história, **quando** tento movê-la para um backlog de **outro projeto**, **então** a operação é recusada.
4. **Dado** uma história movida, **quando** consulto seus dados, **então** título, épico, critérios de aceitação, story points, MoSCoW e RICE permanecem intactos.

> **Invariante:** movimentação só é válida dentro do mesmo projeto.

### RF09 — Formato padrão da história: Como um … eu quero … para …

**Requisito no enunciado (seção 2):**

> **(9)** prover o formato padrão para história de usuário **Como um** [papel] **eu quero** [ação] **para** [benefício]

Ver também a instrução 14 da seção 4 e o Critério de Avaliação 04.

**História.** **Como um** usuário autenticado escrevendo requisitos **eu quero** que o formulário de história me guie pelo formato *Como um … eu quero … para …* **para** que toda história do projeto seja escrita na perspectiva do usuário final e em linguagem informal.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 2 | [#9](https://github.com/WilsonSousajr/okonomi/issues/9) |

**Critérios de aceitação:**

1. **Dado** o formulário de história, **quando** ele é exibido, **então** apresenta **três campos separados** — papel, ação e benefício — com os rótulos do formato padrão.
2. **Dado** que deixo qualquer um dos três campos em branco, **quando** submeto, **então** a história não é salva e o campo faltante é apontado.
3. **Dado** uma história salva, **quando** ela é exibida em qualquer listagem ou relatório, **então** seu texto é renderizado como *Como um [papel], eu quero [ação], para [benefício]*.

> **Invariante:** o formato é garantido pela **estrutura de dados** (três colunas), nunca por texto livre. É impossível gravar uma história fora do padrão.

### RF10 — CRUD de épicos

**Requisito no enunciado (seção 2):**

> **(10)** possibilitar criação leitura, atualização e exclusão de épicos

**História.** **Como um** usuário autenticado **eu quero** manter épicos no projeto **para** agrupar histórias relacionadas sob um objetivo maior do produto.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 3 | [#10](https://github.com/WilsonSousajr/okonomi/issues/10) |

**Critérios de aceitação:**

1. **Dado** um projeto, **quando** crio um épico com título, **então** ele é persistido e vinculado ao projeto.
2. **Dado** que tento criar um épico sem título, **quando** submeto, **então** a criação é recusada com mensagem de validação.
3. **Dado** épicos existentes, **quando** acesso o projeto, **então** vejo todos listados com a quantidade de histórias vinculadas.
4. **Dado** um épico existente, **quando** o edito, **então** as mudanças são persistidas.
5. **Dado** um épico existente, **quando** o excluo, **então** ele deixa de existir e as histórias que estavam vinculadas continuam existindo, apenas sem épico.

### RF11 — Vinculação de histórias de usuário a épicos

**Requisito no enunciado (seção 2):**

> **(11)** possibilitar vinculação de histórias de usuário a épicos

**História.** **Como um** usuário autenticado **eu quero** vincular uma história de usuário a um épico do projeto e desvinculá-la quando necessário **para** enxergar quanto de cada objetivo maior já está coberto por histórias.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 3 | [#11](https://github.com/WilsonSousajr/okonomi/issues/11) |

**Critérios de aceitação:**

1. **Dado** uma história e um épico do **mesmo projeto**, **quando** faço a vinculação, **então** a história passa a pertencer ao épico.
2. **Dado** uma história vinculada, **quando** a desvinculo, **então** ela permanece existindo sem épico — o vínculo é opcional.
3. **Dado** uma história, **quando** tento vinculá-la a um épico de **outro projeto**, **então** a operação é recusada.
4. **Dado** um épico, **quando** acesso sua página, **então** vejo todas as histórias vinculadas e a soma de seus story points.

### RF12 — CRUD de critérios de aceitação

**Requisito no enunciado (seção 2):**

> **(12)** possibilitar criação leitura, atualização e exclusão de critérios de aceitação de histórias de usuário

**História.** **Como um** usuário autenticado **eu quero** manter os critérios de aceitação de cada história **para** deixar explícito e verificável o que precisa ser verdade para a história ser considerada pronta.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 3 | [#12](https://github.com/WilsonSousajr/okonomi/issues/12) |

**Critérios de aceitação:**

1. **Dado** uma história existente, **quando** crio um critério de aceitação, **então** ele é persistido vinculado àquela história.
2. **Dado** uma história, **quando** adiciono vários critérios, **então** todos são aceitos e exibidos na ordem em que foram criados.
3. **Dado** um critério existente, **quando** o edito, **então** as mudanças são persistidas.
4. **Dado** um critério existente, **quando** o excluo, **então** ele deixa de existir e a história permanece intacta.
5. **Dado** que excluo a história, **quando** a exclusão é confirmada, **então** seus critérios de aceitação também deixam de existir.

### RF13 — Formato padrão do critério: Dado … quando … então …

**Requisito no enunciado (seção 2):**

> **(13)** prover o formato padrão para critério de aceitação de história de usuário **Dado** [contexto inicial ou o estado do sistema antes da ação acontecer] **quando** [ação ou evento específico que o usuário executa] **então** [resultado esperado ou a consequência daquela ação]

**História.** **Como um** usuário autenticado escrevendo critérios de aceitação **eu quero** que o formulário me guie pelo formato *Dado … quando … então …* **para** que todo critério descreva contexto, ação e resultado esperado de forma verificável.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 2 | [#13](https://github.com/WilsonSousajr/okonomi/issues/13) |

**Critérios de aceitação:**

1. **Dado** o formulário de critério, **quando** ele é exibido, **então** apresenta **três campos separados** — contexto, ação e resultado — com os rótulos do formato padrão.
2. **Dado** que deixo qualquer um dos três campos em branco, **quando** submeto, **então** o critério não é salvo e o campo faltante é apontado.
3. **Dado** um critério salvo, **quando** ele é exibido, **então** seu texto é renderizado como *Dado [contexto], quando [ação], então [resultado]*.

> **Invariante:** assim como em #9, o formato é garantido pela **estrutura de dados** (três colunas), nunca por texto livre.

### RF14 — Atribuição de story points a histórias de usuário

**Requisito no enunciado (seção 2):**

> **(14)** possibilitar atribuição de pontos de história (*story points*) a histórias de usuário

O domínio de valores permitidos é tratado em #15.

**História.** **Como um** usuário autenticado estimando o backlog **eu quero** atribuir pontos de história a uma história de usuário **para** medir seu tamanho relativo e conseguir planejar a capacidade da sprint.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 2 | [#14](https://github.com/WilsonSousajr/okonomi/issues/14) |

**Critérios de aceitação:**

1. **Dado** uma história sem estimativa, **quando** atribuo pontos de história, **então** o valor é persistido e exibido na listagem do backlog.
2. **Dado** uma história estimada, **quando** altero os pontos, **então** o novo valor substitui o anterior.
3. **Dado** uma história estimada, **quando** removo a estimativa, **então** a história volta a ficar sem pontos, sem ser invalidada — estimar é opcional.
4. **Dado** um backlog com histórias estimadas, **quando** o acesso, **então** vejo a soma dos pontos de história do backlog.

### RF15 — Domínio de story points: 0, 1, 2, 3, 5, 8, 13, 21, 34, 55

**Requisito no enunciado (seção 2):**

> **(15)** pontos de história (*story points*) podem ter os valores **0, 1, 2, 3, 5, 8, 13, 21, 34 ou 55**

**História.** **Como um** usuário autenticado estimando o backlog **eu quero** escolher os pontos de história apenas dentro da escala permitida **para** que a estimativa seja comparável entre histórias e não admita valores arbitrários.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 1 | [#15](https://github.com/WilsonSousajr/okonomi/issues/15) |

**Critérios de aceitação:**

1. **Dado** o formulário de estimativa, **quando** ele é exibido, **então** oferece somente os valores 0, 1, 2, 3, 5, 8, 13, 21, 34 e 55.
2. **Dado** que submeto um valor fora da escala (por exemplo 4, 7, 100 ou -1), **quando** a requisição chega ao servidor, **então** ela é recusada com mensagem de validação, mesmo que o formulário tenha sido contornado.
3. **Dado** o mesmo conjunto de valores, **quando** o campo Effort do critério RICE é preenchido (#18), **então** ele usa exatamente esta escala.

> **Invariante:** a escala é validada no *model*, não apenas no formulário. É o mesmo conjunto usado por Effort em RICE.

### RF16 — Atribuição de etiqueta MoSCoW (M, S, C, W)

**Requisito no enunciado (seção 2):**

> **(16)** possibilitar atribuição de etiqueta MoSCoW (**M, S, C, W**) a história de usuário

**História.** **Como um** usuário autenticado priorizando o backlog **eu quero** etiquetar cada história como Must, Should, Could ou Won't have **para** deixar explícito o que é obrigatório na entrega e o que pode ficar de fora.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 2 | [#16](https://github.com/WilsonSousajr/okonomi/issues/16) |

**Critérios de aceitação:**

1. **Dado** uma história, **quando** atribuo uma etiqueta MoSCoW, **então** o valor é persistido e exibido junto da história.
2. **Dado** o formulário, **quando** ele é exibido, **então** oferece exatamente as quatro opções M, S, C e W, com o significado de cada uma visível.
3. **Dado** que submeto um valor fora do conjunto, **quando** a requisição chega ao servidor, **então** ela é recusada com mensagem de validação.
4. **Dado** um backlog etiquetado, **quando** o acesso, **então** posso filtrar as histórias por etiqueta MoSCoW.
5. **Dado** uma história, **quando** não atribuo etiqueta, **então** ela permanece válida — a etiqueta é opcional.

### RF17 — Atribuição de critério RICE (Reach, Impact, Confidence, Effort)

**Requisito no enunciado (seção 2):**

> **(17)** possibilitar atribuição de critério RICE (*Reach, Impact, Confidence, Effort*) a história de usuário

Os domínios de cada valor estão em #18; o cálculo da pontuação está em #19.

**História.** **Como um** usuário autenticado priorizando o backlog **eu quero** registrar Reach, Impact, Confidence e Effort de uma história **para** priorizar por evidência e não por opinião.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 3 | [#17](https://github.com/WilsonSousajr/okonomi/issues/17) |

**Critérios de aceitação:**

1. **Dado** uma história, **quando** preencho os quatro campos RICE, **então** os valores são persistidos e exibidos junto da história.
2. **Dado** uma história com RICE preenchido, **quando** altero qualquer um dos quatro campos, **então** o novo valor é persistido e a pontuação é recalculada (#19).
3. **Dado** uma história, **quando** deixo o RICE em branco, **então** ela permanece válida — o preenchimento é opcional.
4. **Dado** um preenchimento parcial do RICE, **quando** submeto, **então** o comportamento definido é aplicado de forma consistente: a história é aceita e a pontuação fica indefinida.

### RF18 — Domínios dos valores RICE

**Requisito no enunciado (seção 2):**

> **(18)** critério **Reach** (Alcance) deve ser número de usuários; critério **Impact** (Impacto) deve ser 3 (massivo), 2 (alto), 1 (médio), 0.5 (baixo) ou 0.25 (mínimo); critério **Confidence** (Confiança) deve ser valor percentual 100 (alta), 80 (média) ou 50 (baixa); critério **Effort** (Esforço) deve ser valor de pontos de história (0, 1, 2, 3, 5, 8, 13, 21, 34 ou 55)

**História.** **Como um** usuário autenticado priorizando o backlog **eu quero** que cada campo RICE aceite somente os valores previstos no método **para** que as pontuações sejam comparáveis entre todas as histórias do projeto.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 2 | [#18](https://github.com/WilsonSousajr/okonomi/issues/18) |

**Critérios de aceitação:**

1. **Dado** o campo Reach, **quando** submeto valor negativo ou não inteiro, **então** a requisição é recusada com mensagem de validação.
2. **Dado** o campo Impact, **quando** submeto valor fora de {3, 2, 1, 0.5, 0.25}, **então** a requisição é recusada.
3. **Dado** o campo Confidence, **quando** submeto valor fora de {100, 80, 50}, **então** a requisição é recusada.
4. **Dado** o campo Effort, **quando** submeto valor fora da escala de pontos de história, **então** a requisição é recusada.
5. **Dado** os formulários de Impact, Confidence e Effort, **quando** exibidos, **então** oferecem apenas as opções do domínio, com o rótulo textual (massivo, alto, médio…) visível.

> **Decisão de projeto:** *Impact* é armazenado em coluna decimal (não *float*) para que 0.25 e 0.5 sejam exatos. *Confidence* é armazenado como **inteiro percentual** e convertido para fração no cálculo (#19). As validações vivem no *model*.

### RF19 — Cálculo da pontuação RICE pela fórmula (R × I × C) / E

**Requisito no enunciado (seção 2):**

> **(19)** possibilitar o cálculo de pontuação segundo o critério RICE pela fórmula **(R x I x C) / E**

**História.** **Como um** usuário autenticado priorizando o backlog **eu quero** ver a pontuação RICE calculada automaticamente e ordenar o backlog por ela **para** decidir o que fazer primeiro com base em um número comparável.

| Prioridade (MoSCoW) | Story points | Issue |
|---|---|---|
| M — Must have | 3 | [#19](https://github.com/WilsonSousajr/okonomi/issues/19) |

**Critérios de aceitação:**

1. **Dado** uma história com R=1000, I=2, C=80, E=5, **quando** consulto sua pontuação, **então** vejo **320.0** — ou seja, (1000 × 2 × 0.8) / 5.
2. **Dado** uma história com qualquer um dos quatro campos em branco, **quando** consulto sua pontuação, **então** ela é apresentada como indefinida, sem erro.
3. **Dado** uma história com **Effort = 0**, **quando** consulto sua pontuação, **então** ela é apresentada como indefinida — não ocorre divisão por zero nem exceção.
4. **Dado** um backlog com histórias pontuadas, **quando** ordeno por RICE, **então** as histórias aparecem da maior para a menor pontuação, e as indefinidas ao final.
5. **Dado** que altero qualquer campo RICE, **quando** salvo, **então** a pontuação exibida reflete imediatamente o novo valor.

> **Decisão de projeto:** *Confidence* é percentual e entra na fórmula como `C / 100.0`. `Effort = 0` produz pontuação `nil` (indefinida), nunca divisão por zero — o enunciado não define este caso e a escolha está registrada aqui e no `AGENTS.md`.
## 4. Glossário

| Termo | Significado |
|---|---|
| **História de usuário** | Descrição curta de uma necessidade, do ponto de vista de quem usa o sistema, no modelo *Como um … eu quero … para …*. |
| **Critério de aceitação** | Condição verificável para a história ser considerada pronta, no modelo *Dado … quando … então …*. |
| **Product backlog** | Lista única e priorizada de tudo o que o produto precisa. Existe no máximo um por projeto. |
| **Sprint backlog** | Recorte do que será feito numa iteração. Um projeto pode ter vários. |
| **Épico** | Agrupamento de histórias relacionadas sob um objetivo maior. |
| **Story points** | Medida relativa do tamanho de uma história, na escala 0, 1, 2, 3, 5, 8, 13, 21, 34, 55. |
| **MoSCoW** | Priorização em *Must have*, *Should have*, *Could have* e *Won't have*. |
| **RICE** | Priorização por *Reach* × *Impact* × *Confidence* ÷ *Effort*. |

## 5. Rastreabilidade

### 5.1 Requisitos do enunciado × histórias

Cada requisito funcional da seção 2 do enunciado tem exatamente uma história e uma issue.

| RF | História | Issue | MoSCoW | Story points |
|---|---|---|---|---|
| RF01 | Interface gráfica web para acesso ao sistema | [#1](https://github.com/WilsonSousajr/okonomi/issues/1) | M | 5 |
| RF02 | Criação de conta de usuário | [#2](https://github.com/WilsonSousajr/okonomi/issues/2) | M | 3 |
| RF03 | Autenticação e acesso aos serviços | [#3](https://github.com/WilsonSousajr/okonomi/issues/3) | M | 3 |
| RF04 | CRUD de projetos | [#4](https://github.com/WilsonSousajr/okonomi/issues/4) | M | 3 |
| RF05 | CRUD de product backlog (no máximo um por projeto) | [#5](https://github.com/WilsonSousajr/okonomi/issues/5) | M | 5 |
| RF06 | CRUD de sprint backlogs (vários por projeto) | [#6](https://github.com/WilsonSousajr/okonomi/issues/6) | M | 3 |
| RF07 | CRUD de histórias de usuário associadas ao product backlog | [#7](https://github.com/WilsonSousajr/okonomi/issues/7) | M | 5 |
| RF08 | Movimentação de histórias de usuário entre backlogs | [#8](https://github.com/WilsonSousajr/okonomi/issues/8) | M | 5 |
| RF09 | Formato padrão da história: Como um … eu quero … para … | [#9](https://github.com/WilsonSousajr/okonomi/issues/9) | M | 2 |
| RF10 | CRUD de épicos | [#10](https://github.com/WilsonSousajr/okonomi/issues/10) | M | 3 |
| RF11 | Vinculação de histórias de usuário a épicos | [#11](https://github.com/WilsonSousajr/okonomi/issues/11) | M | 3 |
| RF12 | CRUD de critérios de aceitação | [#12](https://github.com/WilsonSousajr/okonomi/issues/12) | M | 3 |
| RF13 | Formato padrão do critério: Dado … quando … então … | [#13](https://github.com/WilsonSousajr/okonomi/issues/13) | M | 2 |
| RF14 | Atribuição de story points a histórias de usuário | [#14](https://github.com/WilsonSousajr/okonomi/issues/14) | M | 2 |
| RF15 | Domínio de story points: 0, 1, 2, 3, 5, 8, 13, 21, 34, 55 | [#15](https://github.com/WilsonSousajr/okonomi/issues/15) | M | 1 |
| RF16 | Atribuição de etiqueta MoSCoW (M, S, C, W) | [#16](https://github.com/WilsonSousajr/okonomi/issues/16) | M | 2 |
| RF17 | Atribuição de critério RICE (Reach, Impact, Confidence, Effort) | [#17](https://github.com/WilsonSousajr/okonomi/issues/17) | M | 3 |
| RF18 | Domínios dos valores RICE | [#18](https://github.com/WilsonSousajr/okonomi/issues/18) | M | 2 |
| RF19 | Cálculo da pontuação RICE pela fórmula (R × I × C) / E | [#19](https://github.com/WilsonSousajr/okonomi/issues/19) | M | 3 |

### 5.2 Instruções e Critério de Avaliação 04

| Instrução ou item do Critério 04 | Onde é atendido |
|---|---|
| Instrução 3: adotar modelo (*template*) | Seção 1.1: o modelo `uc_specification_tpl.odt` adaptado a histórias |
| Instrução 14: criar histórias adotando o modelo *Como … Eu quero … Para …* | Seção 3, as 19 histórias |
| Cada requisito funcional descrito por história de usuário | Seção 5.1: RF01 a RF19, uma história cada |
| Cada história de usuário é descrição segundo a perspectiva do usuário final | Seção 3: todas começam pelo papel de quem usa o sistema (seção 2) |
| Cada história de usuário escrita em linguagem informal | Seção 3: frases do dia a dia, sem termos de implementação na história |
| Cada história de usuário adota o modelo *Como … Eu quero … Para …* | Seção 3: campo **História** de cada RF |
