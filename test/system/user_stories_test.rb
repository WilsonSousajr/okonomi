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

  test "a blank part of the story is pointed at in the browser (#9)" do
    sign_in_through_form users(:one)
    assert_selector "h1", text: "Meus projetos"
    visit new_project_user_story_path(projects(:okonomi))

    fill_in "Como um", with: "cliente"
    fill_in "eu quero", with: "pagar com Pix"
    fill_in "para", with: "   "
    click_button "Criar história"

    assert_selector "#error_explanation", text: "Benefício não pode ficar em branco"
    assert_selector "#user_story_benefit[aria-invalid=true]"
    assert_no_selector "#user_story_role[aria-invalid=true]"
  end

  test "moving a story to a sprint and back through the browser (#8)" do
    sign_in_through_form users(:one)
    assert_selector "h1", text: "Meus projetos"
    visit project_user_story_path(projects(:okonomi), user_stories(:login))

    select "Sprint 1", from: "Mover para"
    click_button "Mover"
    assert_text "História movida para Sprint 1."
    assert_text "Backlog: Sprint 1"

    select "Product backlog", from: "Mover para"
    click_button "Mover"
    assert_text "História movida para Product backlog."
    assert_text "Backlog: Product backlog"
  end

  test "estimating a story through the browser (#14)" do
    sign_in_through_form users(:one)
    assert_selector "h1", text: "Meus projetos"
    visit edit_project_user_story_path(projects(:okonomi), user_stories(:login))

    select "8", from: "Story points"
    click_button "Salvar história"
    assert_text "História atualizada."
    assert_selector "[data-field=story_points]", text: "8"
  end

  test "filling part of RICE through the browser leaves the score undefined (#17)" do
    sign_in_through_form users(:one)
    assert_selector "h1", text: "Meus projetos"
    visit edit_project_user_story_path(projects(:okonomi), user_stories(:login))

    fill_in "Alcance (Reach)", with: "500"
    select "Não definido", from: "Esforço (Effort)"
    click_button "Salvar história"

    assert_text "História atualizada."
    assert_selector "[data-field=rice_reach]", text: "500"
    assert_selector "[data-field=rice]", text: "indefinida"
  end
end
