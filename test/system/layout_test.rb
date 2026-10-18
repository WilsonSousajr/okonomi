require "application_system_test_case"

# RF01 (#1): layout consistente e responsivo.
class LayoutTest < ApplicationSystemTestCase
  test "every page shows the same header and footer" do
    [ root_path, new_session_path, new_password_path ].each do |path|
      visit path

      within("header") { assert_link "okonomi" }
      assert_selector "footer", text: "okonomi — gestão de requisitos com histórias de usuário"
    end
  end

  test "no horizontal scroll at 375px" do
    page.driver.browser.manage.window.resize_to(375, 812)

    [ root_path, new_session_path, new_password_path ].each do |path|
      visit path

      assert evaluate_script("document.documentElement.scrollWidth <= document.documentElement.clientWidth"),
             "#{path} scrolls horizontally at 375px"
    end
  end
end
