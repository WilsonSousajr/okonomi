require "test_helper"

# A interface é entregue em português (#1); as mensagens de validação também.
class LocaleTest < ActiveSupport::TestCase
  test "default locale is pt-BR" do
    assert_equal :"pt-BR", I18n.default_locale
  end

  test "standard validation messages are translated" do
    project = Project.new
    project.validate

    assert_includes project.errors.full_messages, "Nome não pode ficar em branco"
  end

  test "custom user story messages are translated" do
    story = UserStory.new(project: projects(:okonomi), backlog: backlogs(:okonomi_sprint_one),
                          role: "dono", action: "agir", benefit: "ganhar")
    story.validate

    message = story.errors.full_messages_for(:backlog).first
    assert_match(/product backlog/, message)
    assert_no_match(/translation missing/i, message)
  end
end
