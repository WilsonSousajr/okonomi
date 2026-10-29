require "test_helper"

# RF14 (#14) e RF15 (#15): estimativa da história em story points.
class StoryPointsTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:okonomi)
    @story = @project.user_stories.create!(role: "gerente", action: "ver o painel", benefit: "acompanhar a sprint")
    sign_in_as users(:one)
  end

  test "assigning story points persists them and shows them in the backlog" do
    patch project_user_story_path(@project, @story), params: { user_story: { story_points: "8" } }

    assert_redirected_to project_user_story_path(@project, @story)
    assert_equal 8, @story.reload.story_points
    get project_path(@project)
    assert_select "##{ActionView::RecordIdentifier.dom_id(@story)} [data-field=story_points]", "8"
  end

  test "changing the story points replaces the previous value" do
    @story.update!(story_points: 5)

    patch project_user_story_path(@project, @story), params: { user_story: { story_points: "13" } }

    assert_equal 13, @story.reload.story_points
  end

  test "removing the estimate leaves the story valid and without points" do
    @story.update!(story_points: 5)

    patch project_user_story_path(@project, @story), params: { user_story: { story_points: "" } }

    assert_redirected_to project_user_story_path(@project, @story)
    assert_nil @story.reload.story_points
  end

  test "a backlog shows the sum of its story points" do
    @story.update!(story_points: 5)

    get project_path(@project)

    assert_select "#product_backlog [data-field=points_total]", "8 pontos"
  end

  test "a sprint shows the sum of its story points" do
    sprint = backlogs(:okonomi_sprint_one)
    @story.update!(story_points: 5)
    @story.update!(backlog: sprint)

    get project_sprint_backlog_path(@project, sprint)

    assert_select "[data-field=points_total]", "5 pontos"
  end
end
