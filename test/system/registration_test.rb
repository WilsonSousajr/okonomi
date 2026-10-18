require "application_system_test_case"

# RF02 (#2): um visitante cria a conta pelo navegador e já entra autenticado.
class RegistrationTest < ApplicationSystemTestCase
  test "sign up through the browser lands authenticated" do
    visit root_path
    within("header") { click_link "Criar conta" }

    fill_in "E-mail", with: "nova@example.com"
    fill_in "Senha", with: "senha-segura"
    fill_in "Confirmação da senha", with: "senha-segura"
    click_button "Criar conta"

    assert_text "Conta criada com sucesso"
    within("header") { assert_button "Sair" }
  end
end
