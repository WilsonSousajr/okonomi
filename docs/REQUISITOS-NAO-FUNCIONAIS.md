# okonomi — Requisitos não funcionais

**Artefato 3** do Trabalho Prático de Engenharia de Software (2026.2): especificação
dos requisitos que valem para o sistema inteiro (*system-wide requirements*). Segue a
estrutura do modelo `systemwide_req_spec.odt` ([`docs/RF/Templates/`](RF/Templates/)).
Rastreado pela issue [#27](https://github.com/WilsonSousajr/okonomi/issues/27); atende
às instruções 3 e 13 e ao Critério de Avaliação 03.

| Versão | Data | Autor | Descrição |
|---|---|---|---|
| 1.0 | 18/10/2026 | José Wilson Barbosa de Sousa Júnior | Versão inicial. |

## 1. Introdução

Os requisitos funcionais do okonomi estão nas 19 histórias de usuário do artefato 4
([`HISTORIAS-DE-USUARIO.md`](HISTORIAS-DE-USUARIO.md)). Este documento reúne o que
**não** cabe numa história: regras funcionais que valem para o sistema todo,
atributos de qualidade, interfaces, regras de negócio, restrições de projeto,
conformidade com normas e leis, licenciamento e documentação.

Cada requisito tem um identificador (**RNF-nn**), um enunciado verificável e, quando
há, a **métrica** ou o **modo de verificação**. Para classificar os atributos de
qualidade usamos o modelo de qualidade de produto da **ISO/IEC 25010**, organizado
aqui no formato FURPS+ que o modelo do documento segue.

## 2. Requisitos funcionais de todo o sistema

São regras funcionais que não pertencem a nenhuma história específica, mas que todas
as histórias respeitam.

| Id | Requisito | Verificação |
|---|---|---|
| RNF-01 | **Autenticação obrigatória.** Toda funcionalidade, exceto a página inicial, a criação de conta, a entrada e a redefinição de senha, exige um usuário autenticado. Quem não está autenticado é levado à tela de entrada com a mensagem "Entre na sua conta para continuar." | Testes de controller `anonymous …` (#3). |
| RNF-02 | **Isolamento entre usuários.** Cada usuário vê e altera só os próprios projetos e o que há dentro deles. O acesso a um recurso de outro usuário responde **404 (não encontrado)**, e não 403, para não confirmar que o recurso existe. | Testes `… is not found` em projetos, backlogs e histórias (#3–#7). |
| RNF-03 | **Mensagem de autenticação genérica.** Uma tentativa de entrada malsucedida mostra "E-mail ou senha inválidos.", sem revelar se o e-mail tem conta. | Teste `wrong password and unknown e-mail get the same generic message` (#3). |
| RNF-04 | **Política de senha.** A senha tem no mínimo 8 e no máximo 72 caracteres (o limite do bcrypt), com confirmação na criação da conta. | Testes de `User` e de cadastro (#2). |
| RNF-05 | **Limite de tentativas.** Entrada, criação de conta e pedido de redefinição de senha aceitam no máximo **10 tentativas a cada 3 minutos** por origem; depois disso o sistema responde "Muitas tentativas. Tente novamente mais tarde." | `rate_limit` nos três controllers. |
| RNF-06 | **Redefinição de senha por e-mail.** O usuário que esqueceu a senha recebe por e-mail um link que expira em **15 minutos**. A resposta da tela é a mesma exista ou não a conta. Redefinir a senha encerra todas as sessões abertas. | Testes de `PasswordsController` e do e-mail (#1). |
| RNF-07 | **Exclusão sem órfãos.** Excluir um projeto exclui tudo o que ele contém. Excluir uma sprint devolve as histórias dela ao product backlog. Excluir uma história exclui os critérios de aceitação dela. Toda exclusão pede confirmação na interface. | Testes de modelo e de controller (#4, #6, #7). |

## 3. Qualidades do sistema

### 3.1 Usabilidade

| Id | Requisito | Métrica ou verificação |
|---|---|---|
| RNF-08 | **Idioma.** Toda a interface, inclusive mensagens de validação, datas e e-mails, está em **português do Brasil**. | Locale padrão `pt-BR`; o teste `LocaleTest` falha se aparecer "translation missing". |
| RNF-09 | **Acessibilidade.** A interface busca o nível **AA da WCAG 2.2**. Todo campo tem rótulo visível ligado a ele; mensagens de erro e de retorno ficam numa região `role="alert"`/`role="status"`; a navegação funciona só com teclado; o contraste do texto é de pelo menos 4,5:1. | Revisão com as ferramentas de acessibilidade do navegador a cada tela nova; testes de sistema usam os rótulos para preencher os campos. |
| RNF-10 | **Responsividade.** Todas as telas funcionam a partir de **375 px** de largura sem rolagem horizontal. | Teste de sistema `no horizontal scroll at 375px` (#1). |
| RNF-11 | **Formatos guiados.** O formulário da história mostra os campos "Como um", "eu quero" e "para", e o do critério de aceitação mostra "Dado", "quando" e "então", para que o usuário não precise conhecer os formatos de antemão. | Histórias RF09 e RF13. |
| RNF-12 | **Facilidade de aprendizado.** Um membro de equipe ágil que nunca usou o sistema consegue, sem manual, criar a conta, um projeto, o product backlog e a primeira história em até **5 minutos**. | Roteiro do vídeo de teste de sistema (#32). |

### 3.2 Confiabilidade

| Id | Requisito | Métrica ou verificação |
|---|---|---|
| RNF-13 | **Integridade garantida pelo banco.** As regras do domínio (um product backlog por projeto, escalas fechadas, histórias e épicos sempre do mesmo projeto, formatos em colunas obrigatórias) são impostas pelo banco de dados, além do modelo. Nenhum defeito na aplicação consegue gravar um dado que as viole. | Testes que contornam o modelo e esperam o erro do banco; ver o artefato 7, seção 4. |
| RNF-14 | **Falha sem perda.** Um erro inesperado devolve uma página de erro e não deixa gravação pela metade: cada ação grava numa única transação. | Transações do Active Record; páginas `public/4xx/5xx`. |
| RNF-15 | **Cópia de segurança.** Em produção, o banco tem cópia de segurança diária mantida por pelo menos 7 dias. Perda máxima aceitável: 24 horas de dados. | Descrito no artefato 9 (infraestrutura, #33). |
| RNF-16 | **Disponibilidade.** Durante o período de avaliação, a meta é 99% de disponibilidade mensal, com a verificação de saúde em `/up`. | Monitoramento da rota `/up` pelo Kamal. |

### 3.3 Desempenho

| Id | Requisito | Métrica ou verificação |
|---|---|---|
| RNF-17 | **Tempo de resposta.** O servidor responde às páginas em até **500 ms no percentil 95**, com projetos de até 200 histórias. | Tempos registrados no log do Rails (`Completed … in N ms`). |
| RNF-18 | **Consultas indexadas.** Toda chave estrangeira tem índice. As listas de backlogs e histórias não fazem uma consulta por linha exibida. | `db/schema.rb`; revisão dos logs de SQL em desenvolvimento. |
| RNF-19 | **Capacidade.** Um único servidor com 2 vCPUs e 4 GB de RAM atende ao menos 50 usuários simultâneos. | Dimensionamento no artefato 9 (#33). |

### 3.4 Suportabilidade

| Id | Requisito | Métrica ou verificação |
|---|---|---|
| RNF-20 | **Testes automatizados.** Cada critério de aceitação de cada história tem ao menos um teste automatizado, e todo defeito corrigido ganha um teste de regressão. | Suíte Minitest e Capybara; tabela de evidências em cada issue `RF`. |
| RNF-21 | **Integração contínua.** Nenhuma mudança entra na branch `main` sem o check `ci` verde: RuboCop, Brakeman, bundler-audit, importmap audit, testes de unidade e controller e testes de sistema. | Proteção da branch `main` no GitHub. |
| RNF-22 | **Versões fixadas.** Ruby, Rails, PostgreSQL e as gems têm versões exatas, iguais em `.mise.toml`, `Gemfile.lock` e no CI. | Revisão no PR; Dependabot para atualizações. |
| RNF-23 | **Padrão de código.** O código segue o `rubocop-rails-omakase`, sem ofensas. | `bin/rubocop` no CI. |
| RNF-24 | **Instalação reproduzível.** O ambiente de desenvolvimento sobe com `docker compose up -d postgres` e `bin/setup`. A produção é implantada com um único comando do Kamal. | `README.md` e artefato 9. |

## 4. Interfaces do sistema

### 4.1 Interfaces com o usuário

#### 4.1.1 Aparência (*look & feel*)

- RNF-25: interface **gráfica web**, limpa, com fundo claro, tipografia do sistema operacional e uma única cor de destaque (azul) para as ações principais. Ações que destroem dados usam vermelho.
- RNF-26: a identidade visual é a mesma em todas as telas: cabeçalho com a marca **okonomi** e rodapé "okonomi — gestão de requisitos com histórias de usuário".

#### 4.1.2 Layout e navegação

- RNF-27: toda tela tem a mesma estrutura: **cabeçalho** (marca, "Projetos", "Entrar"/"Criar conta" ou "Sair"), **área de mensagens**, **conteúdo** e **rodapé**.
- RNF-28: a navegação segue a hierarquia do domínio: Meus projetos → projeto (product backlog e sprints) → história. Telas internas mostram uma trilha para voltar aos níveis acima.
- RNF-29: depois de entrar, o usuário vai para a página que tinha pedido ou, se não pediu nenhuma, para **Meus projetos**.

#### 4.1.3 Consistência

- RNF-30: os mesmos termos são usados em todo o sistema: *projeto*, *product backlog*, *sprint*, *história*, *épico*, *critério de aceitação*, *story points*, *MoSCoW*, *RICE*.
- RNF-31: todos os formulários usam o mesmo componente de erros (título com a quantidade de erros e lista de mensagens) e os mesmos rótulos de botão ("Criar …", "Salvar …", "Cancelar", "Excluir …").
- RNF-32: valores ainda não definidos (MoSCoW, story points, RICE) aparecem como "—".

#### 4.1.4 Personalização

- RNF-33: nesta versão não há personalização da interface (tema, idioma ou leiaute por usuário). O idioma é sempre pt-BR.

### 4.2 Interfaces com sistemas ou dispositivos externos

#### 4.2.1 Interfaces de software

| Id | Sistema externo | Uso | Protocolo |
|---|---|---|---|
| RNF-34 | **PostgreSQL 17** | Armazenamento de todos os dados, inclusive filas, cache e websockets (Solid Queue, Solid Cache, Solid Cable). | Protocolo do PostgreSQL via `libpq` (gem `pg`), porta 5432, na rede interna do servidor. |
| RNF-35 | **Servidor SMTP** | Envio do e-mail de redefinição de senha. | SMTP com TLS (porta 587). Provedor definido no artefato 9. |
| RNF-36 | **Navegador web** | Único cliente do sistema: versões atuais de Chrome, Edge, Firefox e Safari, no computador ou no celular. | HTTPS. |

O okonomi **não** integra com outras ferramentas de gestão (Jira, Trello, GitHub) e
não expõe API pública nesta versão.

#### 4.2.2 Interfaces de hardware

- RNF-37: o sistema **não usa dispositivos externos** (leitores, impressoras, sensores). A interação acontece só pelo navegador, com teclado, mouse ou toque, e funciona com qualquer dispositivo que rode um navegador atual.

#### 4.2.3 Interfaces de comunicação

- RNF-38: em produção, todo o tráfego é **HTTPS** (TLS 1.2 ou superior). HTTP é redirecionado para HTTPS (`force_ssl`), e o cabeçalho HSTS é enviado.
- RNF-39: o cookie de sessão é **assinado**, `HttpOnly`, `SameSite=Lax` e, em produção, `Secure` (#40).

## 5. Regras de negócio

Regras do domínio impostas pelo modelo **e** pelo banco (detalhes no artefato 7):

| Id | Regra | Origem |
|---|---|---|
| RN-01 | Um projeto tem **no máximo um** product backlog e **quantos sprint backlogs quiser**. | RF05, RF06 |
| RN-02 | Toda história **nasce no product backlog** do projeto e só pode ser movida para backlogs **do mesmo projeto**. | RF07, RF08 |
| RN-03 | Uma história só pode ser vinculada a um épico **do mesmo projeto**. | RF11 |
| RN-04 | A história tem três partes obrigatórias (papel, ação, benefício); o critério de aceitação tem três partes obrigatórias (contexto, ação, resultado). | RF09, RF13 |
| RN-05 | Story points e RICE Effort aceitam somente **0, 1, 2, 3, 5, 8, 13, 21, 34 ou 55**. | RF15, RF18 |
| RN-06 | MoSCoW aceita somente **M, S, C ou W**. | RF16 |
| RN-07 | Reach é um inteiro ≥ 0; Impact é **3, 2, 1, 0,5 ou 0,25**; Confidence é **100, 80 ou 50** (%). | RF18 |
| RN-08 | Pontuação RICE = (Reach × Impact × Confidence/100) ÷ Effort. Com Effort = 0, a pontuação fica indefinida ("—"), sem erro. | RF19 |
| RN-09 | O fim de uma sprint não pode ser anterior ao seu início. | RF06 |

## 6. Restrições de projeto (*design*)

| Id | Restrição | Justificativa |
|---|---|---|
| RNF-40 | Aplicação **monolítica Ruby on Rails 8.1** sobre **Ruby 3.4**, com HTML renderizado no servidor (**Hotwire**: Turbo e Stimulus) e **Tailwind CSS v4**. Sem aplicação JavaScript separada (SPA) e sem empacotador (*bundler*) de JavaScript. | Uma pessoa mantém o projeto inteiro; menos peças, menos falhas. |
| RNF-41 | Banco **PostgreSQL 17**. | Índice único parcial, chaves estrangeiras compostas, restrições `CHECK` e `decimal` exato, necessários às regras da seção 5. |
| RNF-42 | Sem **Redis** nem outro serviço de infraestrutura: filas, cache e websockets usam o próprio PostgreSQL (Solid Queue, Solid Cache, Solid Cable). | Um único servidor basta para produção. |
| RNF-43 | Autenticação com o gerador nativo do Rails 8 (`has_secure_password` com bcrypt). Sem Devise. | Menos dependências; o código é do projeto e é testado. |
| RNF-44 | Implantação com **Kamal** em contêiner Docker, servidor **Puma** atrás do **Thruster**. | Um comando implanta; ver artefato 9. |
| RNF-45 | Nenhuma credencial fica no repositório, nem mesmo um valor padrão de desenvolvimento. As credenciais vêm de variáveis de ambiente (`.env` fora do Git). | Segredo publicado é segredo vazado; o GitGuardian verifica cada commit. |
| RNF-46 | Uma nova dependência precisa ser justificada na issue, registrada no artefato 9 e ter a licença declarada na seção 8 deste documento. | Controle da superfície de ataque e do licenciamento. |

## 7. Conformidade do sistema

### 7.1 Leis

- **LGPD — Lei nº 13.709/2018 (Lei Geral de Proteção de Dados Pessoais).** O okonomi
  trata poucos dados pessoais: o **e-mail** do usuário e, em cada sessão, o **endereço
  IP** e o **navegador** (*user agent*).
  - RNF-47 (finalidade e minimização): esses dados servem só para autenticar o usuário
    e proteger a sessão. Nenhum outro dado pessoal é coletado, e nenhum dado é
    compartilhado com terceiros, exceto o envio de e-mail pelo provedor SMTP.
  - RNF-48 (segurança): a senha nunca é armazenada, só o seu *digest* bcrypt. O
    tráfego é sempre HTTPS (RNF-38).
  - RNF-49 (direitos do titular): o titular pode pedir acesso, correção ou exclusão
    dos seus dados ao responsável pelo sistema, listado na seção "Equipe" do `README.md`. Nesta versão
    a exclusão da conta é feita pelo administrador; uma tela de autoatendimento fica
    para versão futura. Ao sair, a sessão é apagada.

### 7.2 Normas e padrões aplicáveis

| Norma ou padrão | Onde se aplica |
|---|---|
| **ISO/IEC 25010** (modelo de qualidade de produto de software) | Classificação dos atributos da seção 3: usabilidade, confiabilidade, eficiência de desempenho, manutenibilidade e segurança. |
| **WCAG 2.2**, nível AA (W3C) | Acessibilidade da interface (RNF-09, RNF-10). |
| **OWASP ASVS**, nível 1 | Requisitos de segurança: senha (RNF-04), limite de tentativas (RNF-05), mensagem genérica (RNF-03), sessão (RNF-39), controle de acesso (RNF-02), proteção contra CSRF (padrão do Rails). |
| **OWASP Top 10** | Análise estática com Brakeman e auditoria de dependências (bundler-audit, importmap audit) a cada mudança (RNF-21). |
| **Conventional Commits** (adaptado: `tipo(#issue): mensagem`) | Histórico do repositório, verificado pelo *hook* `commit-msg`. |
| **Kanban** | Gestão do projeto (artefato 1, `PROCESSO.md`). |

## 8. Licenciamento

### 8.1 Licença do okonomi

- RNF-50: o código do okonomi é distribuído sob a **licença MIT**, cujo texto está no
  arquivo [`LICENSE`](../LICENSE) na raiz do repositório. A MIT permite usar, copiar,
  modificar e distribuir o software, inclusive para fins comerciais, desde que o aviso
  de *copyright* e a licença sejam mantidos. O software é fornecido "no estado em que
  se encontra", sem garantia.
- RNF-51: toda dependência incluída no sistema em produção precisa ter licença
  compatível com a MIT (permissiva). Ferramentas usadas só no desenvolvimento e no CI,
  que não são distribuídas com o sistema, podem ter outras licenças.

### 8.2 Licenças das dependências

Versões conforme o `Gemfile.lock` e o `config/importmap.rb` na data desta versão.

**Incluídas no sistema em produção:**

| Componente | Versão | Licença |
|---|---|---|
| Ruby | 3.4.10 | Ruby License / BSD-2-Clause |
| Ruby on Rails | 8.1.3.1 | MIT |
| PostgreSQL | 17 | PostgreSQL License (permissiva, semelhante à BSD/MIT) |
| pg (driver do PostgreSQL) | 1.6.3 | BSD-2-Clause |
| Puma | 8.0.2 | BSD-3-Clause |
| Thruster | 0.1.26 | MIT |
| Turbo (turbo-rails) | 2.0.23 | MIT |
| Stimulus (stimulus-rails) | 1.3.4 | MIT |
| importmap-rails | 2.2.3 | MIT |
| Propshaft | 1.3.2 | MIT |
| Tailwind CSS (tailwindcss-rails / tailwindcss-ruby) | 4.6.0 / 4.3.3 | MIT |
| Solid Queue / Solid Cache / Solid Cable | 1.7.0 / 1.0.10 / 4.0.2 | MIT |
| bcrypt | 3.1.22 | MIT |
| jbuilder | 2.15.1 | MIT |
| json | 2.21.2 | Ruby License |
| bootsnap | 1.26.0 | MIT |
| image_processing | 2.1.0 | MIT |

**Usadas só no desenvolvimento, nos testes, no CI ou na implantação** (não
distribuídas com o sistema):

| Componente | Versão | Licença |
|---|---|---|
| Kamal | 2.12.0 | MIT |
| dotenv-rails | 3.2.0 | MIT |
| Capybara | 3.40.0 | MIT |
| selenium-webdriver | 4.49.0 | Apache-2.0 |
| RuboCop (rubocop-rails-omakase) | 1.1.0 | MIT |
| Brakeman | 8.1.0 | Brakeman Public Use License |
| bundler-audit | 0.9.3 | GPL-3.0-or-later |
| debug | 1.11.1 | Ruby License / BSD-2-Clause |
| web-console | 4.3.0 | MIT |

Brakeman e bundler-audit têm licenças não permissivas, mas apenas **rodam** sobre o
código no CI e na máquina do desenvolvedor. Não são incorporados nem distribuídos com
o okonomi, então não afetam a licença MIT do sistema.

### 8.3 Avisos legais e de *copyright*

- "Copyright (c) 2026 José Wilson Barbosa de Sousa Júnior", conforme o arquivo `LICENSE`.
- Os nomes Ruby on Rails, PostgreSQL, Tailwind CSS e demais citados pertencem aos seus
  respectivos titulares.
- O enunciado e os modelos em `docs/RF/` pertencem à disciplina e não são cobertos pela
  licença do okonomi.

## 9. Documentação do sistema

| Id | Requisito |
|---|---|
| RNF-52 | Cada artefato textual é escrito em Markdown em `docs/` e entregue também em **PDF** (`docs/pdf/`), gerado por `bin/docs-pdf`. O PDF é regenerado no mesmo PR que altera o Markdown. |
| RNF-53 | O `README.md` explica o que é o sistema, como preparar o ambiente, rodar os testes e subir a aplicação. |
| RNF-54 | O `AGENTS.md` registra as convenções de código, de testes e de Git e os problemas conhecidos do ambiente, para qualquer pessoa ou agente que contribua. |
| RNF-55 | Cada requisito funcional tem uma issue com a história, os critérios de aceitação e, ao ser concluído, a evidência dos testes. O quadro Kanban mostra o estado de cada uma. |
| RNF-56 | A interface dispensa manual: rótulos, formatos guiados (RNF-11) e mensagens de erro explicam o que fazer. Não há ajuda *online* separada nesta versão. |
| RNF-57 | Comentários no código explicam o **porquê** das regras não óbvias e citam a issue de origem, por exemplo `# … (#19)`. |

## 10. Rastreabilidade

| Instrução ou item do Critério 03 | Seção |
|---|---|
| Instrução 3: adotar modelo (*template*): `systemwide_req_spec.odt` | Estrutura do documento inteiro |
| Instrução 13: informar normas, padrões, métricas etc. | 3 (métricas) e 7.2 (normas e padrões) |
| Descritos requisitos funcionais que não foram especificados nas histórias | 2 e 5 |
| Descritos atributos de qualidade requeridos (usabilidade, desempenho etc.) | 3.1 a 3.4 |
| Descritos requisitos quanto à interface com o usuário | 4.1 |
| Descritos requisitos quanto à interface com dispositivos externos | 4.2.2 |
| Descritos requisitos quanto à interface do sistema com outros sistemas | 4.2.1 e 4.2.3 |
| Relacionados aspectos aos quais o sistema deve estar conforme (normas, leis etc.) | 7 |
| Relacionadas restrições a serem observadas no projeto (*design*) | 6 |
| Descritos aspectos de licenciamento | 8 |
| Descritos requisitos quanto à documentação | 9 |
