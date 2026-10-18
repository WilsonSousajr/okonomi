require "application_system_test_case"

# RF03 (#3): entrar e sair pelo navegador.
class AuthenticationTest < ApplicationSystemTestCase
  test "sign in and out through the browser" do
    sign_in_through_form users(:one)

    within("header") { click_button "Sair" }

    within("header") { assert_link "Entrar" }
  end

  test "wrong credentials keep the visitor out with a generic message" do
    sign_in_through_form users(:one), password: SecureRandom.hex(8)

    assert_text "E-mail ou senha inválidos."
    within("header") { assert_link "Entrar" }
  end
end
