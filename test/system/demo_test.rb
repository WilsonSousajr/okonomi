require "application_system_test_case"

# Artefato 8 (#32): the system test shown in the video. One success scenario for every
# service the prototype provides (instruction 24), run as a single walkthrough with
# on-screen captions and pauses so it can be followed. It only runs with DEMO=1, from
# bin/demo-video, which records the browser while it runs.
class DemoTest < ApplicationSystemTestCase
  DEBUG_PORT = 9333

  driven_by :selenium, using: :headless_chrome, screen_size: [ 1280, 800 ] do |options|
    options.add_argument("--remote-debugging-port=#{DEBUG_PORT}")
  end

  # Keeps the caption on screen across full page loads (sessionStorage) and Turbo
  # renders (the banner hangs off <html>, which Turbo never replaces).
  CAPTION_SCRIPT = <<~JS
    (function () {
      function render() {
        const text = sessionStorage.getItem("demoCaption")
        if (!text) return
        let banner = document.getElementById("demo-caption")
        if (!banner) {
          banner = document.createElement("div")
          banner.id = "demo-caption"
          banner.style.cssText = "position:fixed;left:0;right:0;bottom:0;z-index:99999;padding:14px 24px;" +
            "background:rgba(17,24,39,.92);color:#fff;font:600 20px/1.3 system-ui,sans-serif;text-align:center"
          document.documentElement.appendChild(banner)
        }
        banner.textContent = text
      }
      window.__renderDemoCaption = render
      document.addEventListener("DOMContentLoaded", render)
      document.addEventListener("turbo:load", render)
    })()
  JS

  STEP_PAUSE = 1.2
  PAUSE_SCALE = 1.5

  PASSWORD = "senha-da-demo-2026"
  NEW_PASSWORD = "nova-senha-da-demo-2026"

  setup do
    skip "só roda com DEMO=1 (bin/demo-video)" unless ENV["DEMO"]
    page.driver.browser.execute_cdp("Page.addScriptToEvaluateOnNewDocument", source: CAPTION_SCRIPT)
  end

  test "every service of the prototype, one success scenario each" do
    visit root_path
    caption "Teste de sistema do okonomi: um cenário de sucesso para cada serviço"
    pause 3

    # RF01, RF02, RF03
    caption "RF02: Criação de conta de usuário"
    within("header") { click_link "Criar conta" }
    type "E-mail", "ana@okonomi.dev"
    type "Senha", PASSWORD
    type "Confirmação da senha", PASSWORD
    click_button "Criar conta"
    assert_text "Conta criada com sucesso"
    pause

    caption "RF03: Autenticação (sair e entrar de novo)"
    within("header") { click_button "Sair" }
    assert_selector "h1", text: "Entrar"
    type "E-mail", "ana@okonomi.dev"
    type "Senha", PASSWORD
    click_button "Entrar"
    assert_selector "h1", text: "Meus projetos"
    pause

    caption "RF02: Redefinição de senha (pedido pelo link \"Esqueceu a senha?\")"
    within("header") { click_button "Sair" }
    click_link "Esqueceu a senha?"
    type "E-mail", "ana@okonomi.dev"
    click_button "Enviar instruções"
    assert_text "Se existir uma conta com esse e-mail, enviamos as instruções"
    pause

    # The e-mail itself is not on screen: the demo opens the link it carries.
    caption "RF02: Redefinição de senha (link recebido por e-mail)"
    visit edit_password_path(User.find_by!(email_address: "ana@okonomi.dev").password_reset_token)
    type "Nova senha", NEW_PASSWORD
    type "Repita a nova senha", NEW_PASSWORD
    click_button "Salvar"
    assert_text "Senha redefinida. Entre com a nova senha."
    type "E-mail", "ana@okonomi.dev"
    type "Senha", NEW_PASSWORD
    click_button "Entrar"
    assert_selector "h1", text: "Meus projetos"
    pause

    # RF04
    caption "RF04: CRUD de projetos (criar)"
    click_on "Novo projeto"
    type "Nome", "Loja virtual"
    type "Descrição", "Vendas online com pagamento por Pix e cartão"
    click_button "Criar projeto"
    assert_text "Projeto criado."
    assert_selector "h1", text: "Loja virtual"
    pause

    caption "RF04: CRUD de projetos (editar)"
    click_on "Editar"
    type "Nome", "Loja virtual Okonomi"
    click_button "Salvar projeto"
    assert_selector "h1", text: "Loja virtual Okonomi"
    pause

    caption "RF04: CRUD de projetos (listar e excluir)"
    within("header") { click_on "Projetos" }
    click_on "Novo projeto"
    type "Nome", "Projeto descartável"
    click_button "Criar projeto"
    assert_text "Projeto criado."
    within("header") { click_on "Projetos" }
    within("#projects") { assert_text "Loja virtual Okonomi" }
    within("#projects") { assert_text "Projeto descartável" }
    pause
    within("#projects") { click_on "Projeto descartável" }
    accept_confirm { click_button "Excluir projeto" }
    assert_text "Projeto excluído."
    within("#projects") { assert_no_text "Projeto descartável" }
    pause
    within("#projects") { click_on "Loja virtual Okonomi" }

    # RF05
    caption "RF05: Product backlog (no máximo um por projeto)"
    within("#product_backlog") { click_on "Criar product backlog" }
    type "Nome", "Product backlog"
    click_button "Criar product backlog"
    assert_text "Product backlog criado."
    pause
    project_url = current_url

    caption "RF05: Editar o product backlog"
    within("#product_backlog") { click_on "Editar" }
    type "Objetivo", "Tudo o que a loja virtual precisa fazer"
    click_button "Salvar product backlog"
    assert_text "Product backlog atualizado."
    within("#product_backlog") { assert_text "Tudo o que a loja virtual precisa fazer" }
    pause
    caption "RF05: Um segundo product backlog é recusado"
    visit "#{project_url}/product_backlog/new"
    type "Nome", "Outro product backlog"
    click_button "Criar product backlog"
    assert_text "Este projeto já possui um product backlog — só pode existir um por projeto."
    pause 3
    visit project_url

    # RF06
    caption "RF06: Sprint backlogs (vários por projeto)"
    within("#sprint_backlogs") { click_on "Nova sprint" }
    type "Nome", "Sprint 1"
    type "Objetivo", "Pagamento por Pix"
    click_button "Criar sprint"
    assert_text "Sprint criada."
    visit project_url
    within("#sprint_backlogs") { click_on "Nova sprint" }
    type "Nome", "Sprint 2"
    type "Objetivo", "Catálogo de produtos"
    click_button "Criar sprint"
    assert_text "Sprint criada."
    click_on "Editar"
    type "Nome", "Sprint 2: catálogo"
    click_button "Salvar sprint"
    assert_selector "h1", text: "Sprint 2: catálogo"
    visit project_url
    within("#sprint_backlogs") { assert_text "Sprint 1" }
    within("#sprint_backlogs") { assert_text "Sprint 2: catálogo" }
    pause

    # RF07, RF09
    caption "RF07 e RF09: História no formato \"Como um … eu quero … para …\""
    within("#product_backlog") { click_on "Nova história" }
    type "Como um", "cliente"
    type "eu quero", "pagar com Pix"
    type "para", "concluir a compra rapidamente"
    click_button "Criar história"
    assert_text "História criada."
    assert_selector "h1", text: "Como um cliente, eu quero pagar com Pix, para concluir a compra rapidamente."
    pause
    story_url = current_url

    caption "RF07: Editar a história"
    click_on "Editar"
    type "para", "concluir a compra em segundos"
    click_button "Salvar história"
    assert_selector "h1", text: "para concluir a compra em segundos"
    pause

    caption "RF07: Excluir uma história"
    visit project_url
    within("#product_backlog") { click_on "Nova história" }
    type "Como um", "visitante"
    type "eu quero", "ver um banner"
    type "para", "descartar depois"
    click_button "Criar história"
    assert_text "História criada."
    accept_confirm { click_button "Excluir história" }
    assert_text "História excluída."
    within("#product_backlog") { assert_no_text "ver um banner" }
    within("#product_backlog") { assert_text "eu quero pagar com Pix" }
    pause

    # RF08
    caption "RF08: Mover a história entre backlogs"
    visit story_url
    select "Sprint 1", from: "Mover para"
    pause 1
    click_button "Mover"
    assert_text "História movida para Sprint 1."
    assert_text "Backlog: Sprint 1"
    pause
    caption "RF08: Mover de uma sprint para outra"
    select "Sprint 2: catálogo", from: "Mover para"
    click_button "Mover"
    assert_text "História movida para Sprint 2: catálogo."
    assert_text "Backlog: Sprint 2: catálogo"
    pause
    caption "RF08: Devolver a história ao product backlog"
    select "Product backlog", from: "Mover para"
    click_button "Mover"
    assert_text "História movida para Product backlog."
    assert_text "Backlog: Product backlog"
    pause

    # RF10
    caption "RF10: CRUD de épicos"
    visit project_url
    within("#epics") { click_on "Novo épico" }
    type "Título", "Pagamentos"
    click_button "Criar épico"
    assert_text "Épico criado."
    click_on "Editar"
    type "Título", "Pagamentos e cobrança"
    click_button "Salvar épico"
    assert_text "Épico atualizado."
    assert_selector "h1", text: "Pagamentos e cobrança"
    pause
    visit project_url
    within("#epics") { click_on "Novo épico" }
    type "Título", "Épico descartável"
    click_button "Criar épico"
    assert_text "Épico criado."
    accept_confirm { click_button "Excluir épico" }
    assert_text "Épico excluído."
    within("#epics") { assert_no_text "Épico descartável" }
    pause

    # RF11
    caption "RF11: Vincular a história a um épico"
    visit story_url
    click_on "Editar"
    select "Pagamentos e cobrança", from: "Épico"
    pause 1
    click_button "Salvar história"
    assert_text "História atualizada."
    click_on "Pagamentos e cobrança"
    within("#epic_stories") { assert_text "eu quero pagar com Pix" }
    pause

    # RF12, RF13
    caption "RF12 e RF13: Critério no formato \"Dado … quando … então …\""
    visit story_url
    click_on "Novo critério"
    type "Dado", "um carrinho com produtos"
    type "quando", "o cliente escolhe Pix"
    type "então", "vê o QR Code para pagar"
    click_button "Criar critério"
    assert_text "Critério criado."
    within("#acceptance_criteria") { assert_text "Dado um carrinho com produtos, quando o cliente escolhe Pix, então vê o QR Code para pagar." }
    pause

    caption "RF12: Editar e excluir critérios"
    within("#acceptance_criteria li:last-child") { click_on "Editar" }
    type "então", "vê o QR Code e o código copia e cola"
    click_button "Salvar critério"
    assert_text "Critério atualizado."
    click_on "Novo critério"
    type "Dado", "um critério provisório"
    type "quando", "ele não é mais necessário"
    type "então", "pode ser excluído"
    click_button "Criar critério"
    assert_text "Critério criado."
    pause 1
    within("#acceptance_criteria li:last-child") { accept_confirm { click_button "Excluir" } }
    assert_text "Critério excluído."
    within("#acceptance_criteria") { assert_no_text "critério provisório" }
    within("#acceptance_criteria") { assert_text "o código copia e cola" }
    pause

    # RF14, RF15
    caption "RF14: Atribuir story points"
    visit "#{story_url}/edit"
    select "8", from: "Story points"
    pause 1
    click_button "Salvar história"
    assert_text "História atualizada."
    assert_selector "[data-field=story_points]", text: "8"
    pause

    caption "RF15: Valor fora da escala 0, 1, 2, 3, 5, 8, 13, 21, 34, 55 é recusado (4)"
    visit "#{story_url}/edit"
    force_option "Story points", "4"
    pause 1
    click_button "Salvar história"
    assert_selector "#error_explanation", text: "Story points não está incluído na lista"
    pause 3

    # RF16
    caption "RF16: Etiqueta MoSCoW"
    visit "#{story_url}/edit"
    select "M — Must have (obrigatório)", from: "MoSCoW"
    pause 1
    click_button "Salvar história"
    assert_text "História atualizada."
    assert_selector "[data-field=moscow]", text: "M"
    pause

    # RF17, RF18, RF19
    caption "RF17 e RF19: RICE e pontuação (R × I × C) / E"
    visit "#{story_url}/edit"
    type "Alcance (Reach)", "1000"
    select "2 — alto", from: "Impacto (Impact)"
    select "80% — média", from: "Confiança (Confidence)"
    select "5", from: "Esforço (Effort)"
    pause 1
    click_button "Salvar história"
    assert_text "História atualizada."
    assert_selector "[data-field=rice]", text: "320,00"
    pause 3

    caption "RF18: Valor fora do domínio de Confidence (100, 80, 50) é recusado (75)"
    visit "#{story_url}/edit"
    force_option "Confiança (Confidence)", "75"
    pause 1
    click_button "Salvar história"
    assert_selector "#error_explanation", text: "Confiança (Confidence) não está incluído na lista"
    pause 3

    caption "RF19: Com Esforço 0 a pontuação RICE fica indefinida"
    visit project_url
    within("#product_backlog") { click_on "Nova história" }
    type "Como um", "gerente"
    type "eu quero", "exportar relatórios de vendas"
    type "para", "acompanhar o faturamento"
    select "C — Could have (desejável)", from: "MoSCoW"
    type "Alcance (Reach)", "500"
    select "3 — massivo", from: "Impacto (Impact)"
    select "100% — alta", from: "Confiança (Confidence)"
    select "0", from: "Esforço (Effort)"
    pause 1
    click_button "Criar história"
    assert_text "História criada."
    assert_selector "[data-field=rice]", text: "indefinida"
    pause 3
    report_url = current_url

    caption "RF19: Com Esforço 2 a pontuação passa a (500 × 3 × 1) / 2 = 750"
    click_on "Editar"
    select "2", from: "Esforço (Effort)"
    pause 1
    click_button "Salvar história"
    assert_text "História atualizada."
    assert_selector "[data-field=rice]", text: "750,00"
    pause 3

    caption "RF16: Filtrar o backlog pela etiqueta MoSCoW (só M)"
    visit project_url
    within("#product_backlog") do
      select "M — Must have (obrigatório)", from: "MoSCoW"
      click_button "Filtrar"
    end
    within("#product_backlog") do
      assert_text "eu quero pagar com Pix"
      assert_no_text "exportar relatórios"
    end
    pause 3

    caption "RF19: Ordenar o backlog pela pontuação RICE (maior primeiro)"
    within("#product_backlog") do
      select "Todas", from: "MoSCoW"
      select "Maior RICE primeiro", from: "Ordenar"
      click_button "Filtrar"
    end
    within("#product_backlog li:first-child") { assert_text "exportar relatórios" }
    within("#product_backlog li:last-child") { assert_text "pagar com Pix" }
    pause 3

    caption "RF06: Excluir uma sprint (as histórias dela voltam ao product backlog)"
    visit report_url
    select "Sprint 1", from: "Mover para"
    click_button "Mover"
    assert_text "História movida para Sprint 1."
    visit project_url
    within("#sprint_backlogs") { click_on "Sprint 1" }
    assert_selector "h1", text: "Sprint 1"
    assert_text "exportar relatórios"
    pause
    accept_confirm { click_button "Excluir sprint" }
    assert_text "Sprint excluída."
    within("#sprint_backlogs") { assert_no_text "Sprint 1" }
    within("#product_backlog") { assert_text "exportar relatórios" }
    pause 3

    caption "RF05: Excluir o product backlog (as histórias dele vão junto)"
    within("#product_backlog") { accept_confirm { click_button "Excluir" } }
    assert_text "Product backlog excluído."
    assert_text "Este projeto ainda não tem product backlog."
    pause 3

    caption "Fim: todos os serviços demonstrados com sucesso"
    visit project_url
    pause 4
  end

  private
    def caption(text)
      page.execute_script(<<~JS, text)
        sessionStorage.setItem("demoCaption", arguments[0]);
        if (window.__renderDemoCaption) window.__renderDemoCaption();
      JS
      pause 2.5
    end

    def type(label, text)
      fill_in label, with: text
      pause 0.8
    end

    # Every navigation step waits a moment so each screen can be read in the video.
    %i[visit click_on click_link click_button select].each do |action|
      define_method(action) do |*args, **kwargs, &block|
        result = super(*args, **kwargs, &block)
        sleep STEP_PAUSE
        result
      end
    end

    # The form only offers valid values, so the out-of-domain value is added to the
    # select by script: the refusal shown comes from the server's validation.
    def force_option(label, value)
      select_box = find_field(label)
      page.execute_script(<<~JS, select_box, value)
        const option = new Option(arguments[1], arguments[1], true, true);
        arguments[0].add(option);
        arguments[0].value = arguments[1];
      JS
    end

    def pause(seconds = 2)
      sleep seconds * PAUSE_SCALE
    end
end
