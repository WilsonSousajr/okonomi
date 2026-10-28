require "application_system_test_case"

# RF10 (#10): criar, consultar, editar e excluir um épico no navegador.
class EpicsTest < ApplicationSystemTestCase
  test "epic CRUD through the browser" do
    sign_in_through_form users(:one)
    assert_selector "h1", text: "Meus projetos"
    visit project_path(projects(:okonomi))

    within("#epics") { click_on "Novo épico" }
    fill_in "Título", with: "Pagamentos"
    click_button "Criar épico"
    assert_text "Épico criado."
    assert_selector "h1", text: "Pagamentos"

    click_on "Editar"
    fill_in "Título", with: "Pagamentos e cobrança"
    click_button "Salvar épico"
    assert_text "Épico atualizado."
    assert_selector "h1", text: "Pagamentos e cobrança"

    accept_confirm { click_button "Excluir épico" }
    assert_text "Épico excluído."
    within("#epics") { assert_no_text "Pagamentos e cobrança" }
  end
end
