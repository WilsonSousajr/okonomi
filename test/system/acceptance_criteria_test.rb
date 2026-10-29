require "application_system_test_case"

# RF12 (#12): adicionar, editar e excluir critérios na página da história.
class AcceptanceCriteriaTest < ApplicationSystemTestCase
  test "criteria CRUD from the story page" do
    sign_in_through_form users(:one)
    assert_selector "h1", text: "Meus projetos"
    visit project_user_story_path(projects(:okonomi), user_stories(:login))

    click_on "Novo critério"
    fill_in "Dado", with: "um usuário cadastrado"
    fill_in "quando", with: "erra a senha três vezes"
    fill_in "então", with: "vê uma mensagem genérica"
    click_button "Criar critério"
    assert_text "Critério criado."
    within("#acceptance_criteria") { assert_text "Dado um usuário cadastrado, quando erra a senha três vezes, então vê uma mensagem genérica." }

    within("#acceptance_criteria li:last-child") { click_on "Editar" }
    fill_in "então", with: "vê a tela de recuperação"
    click_button "Salvar critério"
    assert_text "Critério atualizado."
    within("#acceptance_criteria") { assert_text "então vê a tela de recuperação." }

    within("#acceptance_criteria li:last-child") { accept_confirm { click_button "Excluir" } }
    assert_text "Critério excluído."
    within("#acceptance_criteria") { assert_no_text "tela de recuperação" }
  end
end
