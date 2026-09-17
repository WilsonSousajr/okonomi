require "application_system_test_case"

# Teste de fumaça do esqueleto (#21): prova que a stack inteira responde —
# Puma, Rails, Postgres, Propshaft e Tailwind — e não apenas as unidades.
class HomeTest < ApplicationSystemTestCase
  test "página inicial carrega para visitante não autenticado" do
    visit root_path

    assert_selector "h1", text: "okonomi"
    assert_link "Entrar"
  end

  test "visitante é levado à tela de entrada" do
    visit root_path
    click_on "Entrar"

    assert_selector "h1", text: "Sign in"
  end
end
