# okonomi — Projeto de interface com o usuário

**Artefato 6** do Trabalho Prático de Engenharia de Software (2026.2): projeto de
interface com o usuário, em *storyboards* compostos por *wireframes*. Rastreado pela
issue [#30](https://github.com/WilsonSousajr/okonomi/issues/30); atende às instruções
17 e 18 e ao Critério de Avaliação 06.

| Versão | Data | Autor | Descrição |
|---|---|---|---|
| 1.0 | 28/10/2026 | José Wilson Barbosa de Sousa Júnior | Versão inicial. |
| 1.1 | 04/11/2026 | José Wilson Barbosa de Sousa Júnior | Storyboards 7 (redefinição de senha) e 8 (exclusões e regras); RF01 no título do storyboard 1. |

## 1. Introdução

Cada *storyboard* descreve um cenário de uso do okonomi como uma sequência numerada
de *wireframes*. Cada *wireframe* é um esboço simples de uma tela: só a estrutura,
os rótulos e os botões. Não há cores finais nem tipografia.

**Como ler os storyboards**

- Os quadros são numerados na ordem em que o usuário passa por eles.
- A seta azul liga um quadro ao próximo, e o texto junto dela diz o que o usuário
  faz para chegar lá (clica, preenche, envia).
- Dentro de cada quadro:
  - a faixa cinza no topo é o cabeçalho, com o nome *okonomi* à esquerda e a
    navegação à direita ("Entrar · Criar conta" para visitantes, "Projetos · Sair"
    para quem está autenticado);
  - os retângulos com rótulo em cima são campos de formulário;
  - um "v" à direita indica uma lista de seleção;
  - o retângulo azul preenchido é o botão principal, e o texto azul ao lado é um
    link secundário;
  - a faixa verde é uma mensagem de sucesso e a vermelha, uma mensagem de erro;
  - a borda vermelha marca o campo que tem erro;
  - a caixa de borda grossa sobre a tela, com *Cancelar* e *OK*, é a confirmação
    que o navegador mostra antes de uma exclusão;
  - o texto entre parênteses é uma anotação do esboço, não aparece na tela.

Os rótulos e as mensagens dos esboços são os mesmos da aplicação, para que o
protótipo (artefato 8, [#32](https://github.com/WilsonSousajr/okonomi/issues/32))
siga este projeto. Os arquivos-fonte `.excalidraw` estão em
[`docs/INTERFACE/`](INTERFACE/) e podem ser abertos e editados em
[excalidraw.com](https://excalidraw.com).

**Ator:** em todos os cenários, o usuário é alguém da equipe de produto (*product
owner*, *scrum master* ou desenvolvedor), como descrito no
[documento de visão](VISAO.md).

## 2. Storyboards

### 2.1 Criar conta e autenticar (RF01, RF02, RF03)

**Cenário.** Ana ainda não tem conta. Ela se cadastra e cai direto na sua lista de
projetos. Depois sai, tenta entrar com a senha errada e recebe uma mensagem genérica,
que não diz se o e-mail existe. Por fim corrige a senha e entra.

1. **Página inicial:** um visitante vê o nome do produto e os links *Entrar* e
   *Criar conta* no cabeçalho.
2. **Criar conta:** e-mail, senha e confirmação da senha.
3. **Meus projetos:** a conta é criada, a sessão já começa e o cabeçalho passa a
   mostrar *Sair*.
4. **Entrar com erro:** a mensagem "E-mail ou senha inválidos." é a mesma para
   e-mail desconhecido e para senha errada.
5. **De volta a Meus projetos,** já autenticada.

![Storyboard 1](INTERFACE/01-conta-e-autenticacao.png)

### 2.2 Criar projeto e seu product backlog (RF04, RF05)

**Cenário.** Ana cria o projeto "Loja virtual". O projeto ainda não tem product
backlog, então a página oferece criá-lo. Depois de criado, a página do projeto mostra
o product backlog, as sprints e os épicos.

1. **Meus projetos,** com o botão *Novo projeto*.
2. **Novo projeto:** nome e descrição.
3. **Página do projeto sem product backlog,** com o botão *Criar product backlog*.
4. **Novo product backlog:** nome e objetivo.
5. **Projeto com product backlog,** ainda sem histórias. Um projeto só pode ter um
   product backlog, então a opção de criar outro não aparece mais.

![Storyboard 2](INTERFACE/02-projeto-e-product-backlog.png)

### 2.3 Escrever história e critérios de aceitação (RF07, RF09, RF12, RF13)

**Cenário.** Ana escreve uma história no formato *Como um … eu quero … para …*,
esquece o benefício e vê o campo apontado. Depois de corrigir, a história nasce no
product backlog, e ela acrescenta critérios no formato *Dado … quando … então …*.

1. **Nova história com um campo faltando:** a mensagem de erro aparece no topo e o
   campo "para" fica com borda vermelha.
2. **Página da história:** o texto completo no formato padrão, o backlog e o épico.
3. **Novo critério de aceitação:** três campos rotulados *Dado*, *quando* e *então*.
4. **Critérios listados na ordem em que foram criados,** cada um com *Editar* e
   *Excluir*.

![Storyboard 3](INTERFACE/03-historia-e-criterios.png)

### 2.4 Criar épico e vincular histórias (RF10, RF11)

**Cenário.** Ana cria o épico "Pagamentos" e vincula a ele a história do Pix. A
página do épico mostra as histórias vinculadas e a soma dos seus story points.

1. **Seção de épicos** na página do projeto.
2. **Novo épico:** título e descrição.
3. **Editar história:** o campo *Épico* lista só os épicos do projeto, mais a opção
   "Sem épico".
4. **Página do épico:** as histórias vinculadas e o total de pontos.

![Storyboard 4](INTERFACE/04-epico-e-vinculo.png)

### 2.5 Estimar e priorizar: story points, MoSCoW e RICE (RF14 a RF19)

**Cenário.** Ana estima a história em 5 pontos, etiqueta como *Must have* e preenche
o RICE (Reach 1000, Impact 2, Confidence 80%, Effort 5). A pontuação calculada é
320. Depois ela filtra o backlog pelas histórias *M* e ordena pela maior pontuação.

1. **Editar história, grupo "Estimativa e prioridade":** as listas oferecem só os
   valores permitidos, com o rótulo do método ("2 — alto", "80% — média",
   "M — Must have").
2. **História com a pontuação calculada:** (1000 × 2 × 0,8) / 5 = 320,00. Se algum
   campo ficar vazio, ou se Effort for 0, a pontuação aparece como "indefinida".
3. **Backlog filtrado por MoSCoW e ordenado por RICE:** as pontuações indefinidas
   ficam no fim da lista.

![Storyboard 5](INTERFACE/05-estimar-e-priorizar.png)

### 2.6 Criar sprint e mover histórias para a sprint (RF06, RF08)

**Cenário.** Ana planeja a "Sprint 1" e move a história do Pix do product backlog
para ela. A história chega à sprint sem perder o texto, o épico, os critérios nem as
estimativas.

1. **Nova sprint:** nome, objetivo, início e fim.
2. **Página da história:** a lista *Mover para* mostra só os outros backlogs do mesmo
   projeto.
3. **História movida:** a mensagem confirma a sprint de destino, e os dados da
   história continuam os mesmos.
4. **Página da sprint:** as histórias da sprint e o total de pontos.

![Storyboard 6](INTERFACE/06-sprint-e-movimentacao.png)

### 2.7 Redefinir a senha (RF03, RNF-06)

**Cenário.** Ana esqueceu a senha. Na tela de entrada ela pede a redefinição,
recebe uma mensagem que não revela se o e-mail está cadastrado, abre o e-mail com o
link, escolhe uma senha nova e entra com ela.

1. **Entrar,** com o link *Esqueceu a senha?* ao lado do botão.
2. **Esqueceu a senha?:** o campo *E-mail* e o botão *Enviar instruções*.
3. **Mensagem genérica:** de volta à tela de entrada, o aviso "Se existir uma conta
   com esse e-mail, enviamos as instruções para redefinir a senha." aparece tanto
   para e-mail cadastrado quanto para e-mail desconhecido.
4. **E-mail com o link:** assunto "Redefina sua senha do okonomi", o link "nesta
   página de redefinição" e o prazo "Este link expira em 15 minutos.".
5. **Redefinir senha:** *Nova senha* (mínimo de 8 caracteres) e *Repita a nova
   senha*, com o botão *Salvar*. Se as duas não forem iguais, a mensagem é "As senhas
   não conferem.".
6. **Entrar com a nova senha:** o aviso "Senha redefinida. Entre com a nova senha."
   As sessões abertas antes foram encerradas; ao entrar, Ana volta a *Meus projetos*.

![Storyboard 7](INTERFACE/07-redefinicao-de-senha.png)

### 2.8 Exclusões e regras (RF05, RF06, RF10)

**Cenário.** Ana exclui a "Sprint 1" e confere que a história volta ao product
backlog. Depois tenta criar um segundo product backlog no mesmo projeto e o sistema
recusa. Por fim exclui o épico "Pagamentos": a história continua existindo, só que
sem épico.

1. **Página da sprint,** com o botão *Excluir sprint*.
2. **Confirmação:** "Excluir a sprint? As histórias dela voltam para o product
   backlog.", com *Cancelar* e *OK*.
3. **Histórias de volta ao product backlog:** o aviso "Sprint excluída.", a história
   listada no product backlog sem perder texto, épico, critérios nem estimativas, e
   "Nenhuma sprint ainda." na seção de sprints.
4. **Segundo product backlog recusado:** a página do projeto não oferece mais o botão
   *Criar product backlog*, mas mesmo abrindo o formulário pelo endereço o envio é
   recusado com "Este projeto já possui um product backlog — só pode existir um por
   projeto.".
5. **Excluir épico:** a confirmação "Excluir o épico? As histórias dele continuam
   existindo, sem épico.".
6. **Projeto depois da exclusão:** o aviso "Épico excluído.", a história ainda no
   product backlog e "Nenhum épico ainda." na seção de épicos. Na página da história,
   o épico aparece como "sem épico".

![Storyboard 8](INTERFACE/08-exclusoes-e-regras.png)

## 3. Roteiro do vídeo de teste de sistema

O vídeo do artefato 8 (instrução 24) mostra um cenário de sucesso para cada serviço
do sistema. Os cenários são os mesmos destes storyboards (no vídeo, a redefinição de
senha vem logo depois da autenticação):

| Trecho do vídeo | Storyboard | Requisitos |
|---|---|---|
| 1. Criar conta, sair, errar a senha, entrar | 2.1 | RF01, RF02, RF03 |
| 2. Criar projeto e product backlog | 2.2 | RF04, RF05 |
| 3. Escrever história e critérios | 2.3 | RF07, RF09, RF12, RF13 |
| 4. Criar épico e vincular a história | 2.4 | RF10, RF11 |
| 5. Estimar, etiquetar, calcular RICE, filtrar e ordenar | 2.5 | RF14 a RF19 |
| 6. Criar sprint e mover a história | 2.6 | RF06, RF08 |
| 7. Redefinir a senha pelo link do e-mail | 2.7 | RF03, RNF-06 |
| 8. Excluir sprint, recusar segundo product backlog, excluir épico | 2.8 | RF05, RF06, RF10 |

## 4. Rastreabilidade

| Instrução ou item do Critério 06 | Seção |
|---|---|
| Instrução 17: projeto de interface por *storyboards* compostos por *wireframes* | 2 |
| Instrução 18: cada *wireframe* é um esboço simples de tela | 1 ("Como ler") e 2.1 a 2.8 |
| Projeto de interface composto por *storyboards* | 2 |
| Cada *storyboard* descreve um cenário de uso | 2.1 a 2.8 ("Cenário") |
| Cada *storyboard* é composto por uma sequência de *wireframes* | 2.1 a 2.8 (quadros numerados) |
| Cada *wireframe* é um esboço simples de tela | 2.1 a 2.8 (imagens) |
