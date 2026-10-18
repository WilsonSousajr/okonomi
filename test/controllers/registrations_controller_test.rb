require "test_helper"

# RF02 (#2): criação de conta.
class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new renders the sign-up form" do
    get new_registration_path

    assert_response :success
    assert_select "h1", "Criar conta"
  end

  test "valid data creates the account and signs the user in" do
    assert_difference -> { User.count } => 1, -> { Session.count } => 1 do
      post registration_path, params: { user: { email_address: "nova@example.com", password: "senha-segura", password_confirmation: "senha-segura" } }
    end

    assert_response :redirect
    assert cookies[:session_id].present?
    follow_redirect!
    assert_select "#flash", /Conta criada com sucesso/
  end

  test "a taken e-mail is refused with a conflict message" do
    assert_no_difference -> { User.count } do
      post registration_path, params: { user: { email_address: "one@example.com", password: "senha-segura", password_confirmation: "senha-segura" } }
    end

    assert_response :unprocessable_entity
    assert_select "#error_explanation", /E-mail já está cadastrado/
  end

  test "a weak password is refused with the message on the field" do
    assert_no_difference -> { User.count } do
      post registration_path, params: { user: { email_address: "nova@example.com", password: "curta", password_confirmation: "curta" } }
    end

    assert_response :unprocessable_entity
    assert_select "#error_explanation", /Senha é muito curto/
  end

  test "an invalid e-mail is refused" do
    post registration_path, params: { user: { email_address: "sem-arroba", password: "senha-segura", password_confirmation: "senha-segura" } }

    assert_response :unprocessable_entity
    assert_select "#error_explanation", /E-mail não é válido/
  end

  test "a mismatched confirmation is refused" do
    post registration_path, params: { user: { email_address: "nova@example.com", password: "senha-segura", password_confirmation: "outra-senha" } }

    assert_response :unprocessable_entity
    assert_select "#error_explanation", /Confirmação da senha não confere/
  end
end
