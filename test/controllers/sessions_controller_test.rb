require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to projects_url
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "wrong password and unknown e-mail get the same generic message (#3)" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }
    wrong_password_alert = flash[:alert]

    post session_path, params: { email_address: "nobody@example.com", password: "password" }
    unknown_email_alert = flash[:alert]

    assert_equal "E-mail ou senha inválidos.", wrong_password_alert
    assert_equal wrong_password_alert, unknown_email_alert
  end

  test "anonymous request to a protected action is sent to sign in with a notice (#3)" do
    delete session_path

    assert_redirected_to new_session_path
    assert_equal "Entre na sua conta para continuar.", flash[:alert]
  end

  test "destroy" do
    sign_in_as(User.take)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end

  test "after signing out, protected actions are denied again (#3)" do
    sign_in_as(@user)
    delete session_path

    assert_no_difference -> { Session.count } do
      delete session_path
    end
    assert_redirected_to new_session_path
  end
end
