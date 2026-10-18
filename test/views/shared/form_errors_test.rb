require "test_helper"

# RF01 (#1): erros de validação aparecem num componente padronizado e acessível.
class SharedFormErrorsTest < ActionView::TestCase
  test "renders every error inside an alert region" do
    project = Project.new.tap(&:validate)

    render partial: "shared/form_errors", locals: { model: project }

    assert_select "#error_explanation[role=alert]" do
      assert_select "li", text: "Nome não pode ficar em branco"
    end
  end

  test "renders nothing for a valid record" do
    render partial: "shared/form_errors", locals: { model: projects(:okonomi) }

    assert_select "#error_explanation", count: 0
  end
end
