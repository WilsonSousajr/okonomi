require "application_system_test_case"

# RF04 (#4): CRUD de projetos pelo navegador.
class ProjectsTest < ApplicationSystemTestCase
  test "project CRUD through the browser" do
    sign_in_through_form users(:one)
    assert_selector "h1", text: "Meus projetos"

    click_on "Novo projeto"
    fill_in "Nome", with: "Loja virtual"
    fill_in "Descrição", with: "Vendas online"
    click_button "Criar projeto"
    assert_text "Projeto criado."
    assert_selector "h1", text: "Loja virtual"

    click_on "Editar"
    fill_in "Nome", with: "Loja virtual 2"
    click_button "Salvar projeto"
    assert_selector "h1", text: "Loja virtual 2"

    accept_confirm { click_button "Excluir projeto" }
    assert_text "Projeto excluído."
    assert_no_text "Loja virtual 2"
  end
end
