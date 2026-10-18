require "application_system_test_case"

# Critério de saída da S3: projeto, backlog e história de ponta a ponta no navegador (#4, #5, #7).
class UserStoriesTest < ApplicationSystemTestCase
  test "project, product backlog and story end to end" do
    sign_in_through_form users(:one)
    assert_selector "h1", text: "Meus projetos"

    click_on "Novo projeto"
    fill_in "Nome", with: "Loja virtual"
    click_button "Criar projeto"

    within("#product_backlog") { click_on "Criar product backlog" }
    click_button "Criar product backlog"
    assert_text "Product backlog criado."

    within("#product_backlog") { click_on "Nova história" }
    fill_in "Como um", with: "cliente"
    fill_in "eu quero", with: "pagar com Pix"
    fill_in "para", with: "concluir a compra rapidamente"
    click_button "Criar história"
    assert_text "História criada."
    assert_selector "h1", text: "Como um cliente, eu quero pagar com Pix, para concluir a compra rapidamente."

    click_on "Editar"
    fill_in "eu quero", with: "pagar com cartão"
    click_button "Salvar história"
    assert_selector "h1", text: "eu quero pagar com cartão"

    click_on "Loja virtual"
    within("#product_backlog") { assert_text "Como um cliente, eu quero pagar com cartão" }

    within("#product_backlog") { click_on "Como um cliente, eu quero pagar com cartão" }
    accept_confirm { click_button "Excluir história" }
    assert_text "História excluída."
    within("#product_backlog") { assert_no_text "pagar com cartão" }
  end
end
