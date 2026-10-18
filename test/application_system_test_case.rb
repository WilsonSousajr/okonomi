require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Signs in the way a user does, so system tests exercise the real form (#3).
  def sign_in_through_form(user, password: "password")
    visit new_session_path
    fill_in "E-mail", with: user.email_address
    fill_in "Senha", with: password
    click_button "Entrar"
  end
end
