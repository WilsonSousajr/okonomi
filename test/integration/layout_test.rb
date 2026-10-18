require "test_helper"

# RF01 (#1): toda página é HTML renderizado dentro do mesmo layout.
class LayoutTest < ActionDispatch::IntegrationTest
  test "root renders html with the application layout" do
    get root_path

    assert_response :success
    assert_select "html[lang=?]", "pt-BR"
    assert_select "header", text: /okonomi/
    assert_select "footer", text: /gestão de requisitos com histórias de usuário/
  end

  test "sign-in page shares the same header and footer" do
    get new_session_path

    assert_select "header", text: /okonomi/
    assert_select "footer", text: /gestão de requisitos com histórias de usuário/
  end

  test "flash messages render in the shared alert component" do
    post session_path, params: { email_address: "one@example.com", password: "wrong" }
    follow_redirect!

    assert_select "#flash [role=alert]", text: /E-mail ou senha inválidos/
  end
end
