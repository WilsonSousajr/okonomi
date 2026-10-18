require "application_system_test_case"

# RF06 (#6): sprint backlogs pelo navegador.
class SprintBacklogsTest < ApplicationSystemTestCase
  test "sprint CRUD through the browser" do
    sign_in_through_form users(:one)
    assert_selector "h1", text: "Meus projetos"
    within("#projects") { click_on "okonomi" }

    within("#sprint_backlogs") { click_on "Nova sprint" }
    fill_in "Nome", with: "Sprint 2"
    fill_in "Objetivo", with: "Backlogs no navegador"
    click_button "Criar sprint"
    assert_text "Sprint criada."
    assert_selector "h1", text: "Sprint 2"

    click_on "Editar"
    fill_in "Nome", with: "Sprint 2 — backlogs"
    click_button "Salvar sprint"
    assert_selector "h1", text: "Sprint 2 — backlogs"

    accept_confirm { click_button "Excluir sprint" }
    assert_text "Sprint excluída."
    within("#sprint_backlogs") { assert_no_text "Sprint 2 — backlogs" }
  end
end
