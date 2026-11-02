require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # DEBUG #94 (temporary): chromedriver verbose log, no script inside the page.
  if ENV["DEBUG94"]
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ],
      options: { service: Selenium::WebDriver::Service.chrome(args: [ "--verbose", "--log-path=#{Rails.root.join("tmp/chromedriver-#{ENV.fetch("ROUND", "0")}.log")}" ]) }

    setup { Rails.logger.info "=== TEST START #{self.class.name}##{name}" }
  end

  def before_teardown
    Rails.logger.info "=== TEST END #{self.class.name}##{name} passed=#{passed?}" if ENV["DEBUG94"]
    super
  end

  # Signs in the way a user does, so system tests exercise the real form (#3).
  def sign_in_through_form(user, password: "password")
    visit new_session_path
    fill_in "E-mail", with: user.email_address
    fill_in "Senha", with: password
    click_button "Entrar"
  end
end
