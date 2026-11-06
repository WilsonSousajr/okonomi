require "test_helper"

# The static error pages are part of the interface, which is delivered in pt-BR
# (RNF-08). They were still the generated English pages (#117).
class ErrorPagesTest < ActionDispatch::IntegrationTest
  test "another user's project shows a not found page in Portuguese issue 117" do
    sign_in_as users(:one)

    # Production shows the public page; the test environment shows the debug page
    # unless detailed exceptions are switched off for the request.
    with_production_error_pages { get project_path(projects(:other_project)) }

    assert_response :not_found
    assert_select "html[lang=pt-BR]"
    assert_select "title", text: /Página não encontrada/
    assert_no_match(/doesn't exist/, response.body)
  end

  test "every static error page is in Portuguese issue 117" do
    %w[400 404 406-unsupported-browser 422 500].each do |page|
      html = Rails.public_path.join("#{page}.html").read

      assert_includes html, '<html lang="pt-BR">', "#{page}.html"
      assert_no_match(/If you're the application owner|We're sorry|Your browser is not supported/, html, "#{page}.html")
    end
  end

  private
    def with_production_error_pages
      env_config = Rails.application.env_config
      original = env_config["action_dispatch.show_detailed_exceptions"]
      env_config["action_dispatch.show_detailed_exceptions"] = false
      yield
    ensure
      env_config["action_dispatch.show_detailed_exceptions"] = original
    end
end
