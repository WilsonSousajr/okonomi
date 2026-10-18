require "application_system_test_case"

# RF05 (#5): o segundo product backlog é recusado com mensagem clara.
class ProductBacklogsTest < ApplicationSystemTestCase
  test "create the product backlog and see a second one refused" do
    project = users(:one).projects.create!(name: "Loja virtual")
    sign_in_through_form users(:one)
    assert_selector "h1", text: "Meus projetos"

    visit project_path(project)
    within("#product_backlog") { click_on "Criar product backlog" }
    fill_in "Nome", with: "Product backlog"
    click_button "Criar product backlog"
    assert_text "Product backlog criado."

    visit new_project_product_backlog_path(project)
    fill_in "Nome", with: "Outro"
    click_button "Criar product backlog"
    assert_text "Este projeto já possui um product backlog — só pode existir um por projeto."
  end
end
