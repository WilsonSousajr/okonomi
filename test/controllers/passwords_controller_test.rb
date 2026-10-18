require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_password_path
    assert_response :success
  end

  test "create" do
    post passwords_path, params: { email_address: @user.email_address }
    assert_enqueued_email_with PasswordsMailer, :reset, args: [ @user ]
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "instruções para redefinir a senha"
  end

  test "create for an unknown user redirects but sends no mail" do
    post passwords_path, params: { email_address: "missing-user@example.com" }
    assert_enqueued_emails 0
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "instruções para redefinir a senha"
  end

  test "edit" do
    get edit_password_path(@user.password_reset_token)
    assert_response :success
  end

  test "edit with invalid password reset token" do
    get edit_password_path("invalid token")
    assert_redirected_to new_password_path

    follow_redirect!
    assert_notice "link de redefinição é inválido"
  end

  test "update" do
    assert_changes -> { @user.reload.password_digest } do
      put password_path(@user.password_reset_token), params: { password: "nova-senha", password_confirmation: "nova-senha" }
      assert_redirected_to new_session_path
    end

    follow_redirect!
    assert_notice "Senha redefinida"
  end

  test "update with non matching passwords" do
    token = @user.password_reset_token
    assert_no_changes -> { @user.reload.password_digest } do
      put password_path(token), params: { password: "no", password_confirmation: "match" }
      assert_redirected_to edit_password_path(token)
    end

    follow_redirect!
    assert_notice "As senhas não conferem"
  end

  test "update with a short password explains the policy issue_80" do
    token = @user.password_reset_token
    assert_no_changes -> { @user.reload.password_digest } do
      put password_path(token), params: { password: "curta1", password_confirmation: "curta1" }
      assert_redirected_to edit_password_path(token)
    end

    follow_redirect!
    assert_notice "Senha é muito curto"
  end

  test "the reset form states the minimum length issue_80" do
    get edit_password_path(@user.password_reset_token)

    assert_select "input[name=password][minlength='8']"
    assert_select "#password_hint", "Mínimo de 8 caracteres."
  end

  private
    def assert_notice(text)
      assert_select "div", /#{text}/
    end
end
