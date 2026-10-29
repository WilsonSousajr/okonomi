require "test_helper"

# RF16 (#16): etiqueta MoSCoW (M, S, C, W) na história.
class MoscowTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:okonomi)
    @story = @project.user_stories.create!(role: "gerente", action: "exportar o backlog", benefit: "compartilhar com o cliente")
    sign_in_as users(:one)
  end

  test "assigning a MoSCoW tag persists it and shows it with the story" do
    patch project_user_story_path(@project, @story), params: { user_story: { moscow: "S" } }

    assert_redirected_to project_user_story_path(@project, @story)
    assert_equal "S", @story.reload.moscow
    follow_redirect!
    assert_select "[data-field=moscow]", "S"
  end

  test "the form offers exactly M, S, C and W with their meaning visible" do
    get edit_project_user_story_path(@project, @story)

    options = css_select("select#user_story_moscow option").map { |option| [ option["value"], option.text ] }
    assert_equal [
      [ "", "Sem etiqueta" ],
      [ "M", "M — Must have (obrigatório)" ],
      [ "S", "S — Should have (importante)" ],
      [ "C", "C — Could have (desejável)" ],
      [ "W", "W — Won't have (fora desta entrega)" ]
    ], options
  end

  test "a value outside M, S, C and W is refused by the server" do
    patch project_user_story_path(@project, @story), params: { user_story: { moscow: "X" } }

    assert_response :unprocessable_entity
    assert_select "#error_explanation li", /MoSCoW não está incluído na lista/
    assert_nil @story.reload.moscow
  end

  test "a story without a tag stays valid" do
    @story.update!(moscow: "C")

    patch project_user_story_path(@project, @story), params: { user_story: { moscow: "" } }

    assert_redirected_to project_user_story_path(@project, @story)
    assert_nil @story.reload.moscow
  end

  test "the product backlog can be filtered by MoSCoW tag" do
    @story.update!(moscow: "S")

    get project_path(@project, moscow: "M")

    assert_select "#product_backlog ##{ActionView::RecordIdentifier.dom_id(user_stories(:login))}", 1
    assert_select "#product_backlog ##{ActionView::RecordIdentifier.dom_id(@story)}", 0
    assert_select "#product_backlog select[name=moscow] option[selected]", "M — Must have (obrigatório)"
  end

  test "a sprint can be filtered by MoSCoW tag" do
    sprint = backlogs(:okonomi_sprint_one)
    @story.update!(moscow: "S", backlog: sprint)
    user_stories(:login).update!(backlog: sprint)

    get project_sprint_backlog_path(@project, sprint, moscow: "S")

    assert_select "##{ActionView::RecordIdentifier.dom_id(@story)}", 1
    assert_select "##{ActionView::RecordIdentifier.dom_id(user_stories(:login))}", 0
  end

  test "an unknown filter value shows every story" do
    get project_path(@project, moscow: "Z")

    assert_select "#product_backlog ##{ActionView::RecordIdentifier.dom_id(@story)}", 1
    assert_select "#product_backlog ##{ActionView::RecordIdentifier.dom_id(user_stories(:login))}", 1
  end
end
