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

  test "the estimate field offers only the allowed scale (#15)" do
    get edit_project_user_story_path(@project, @story)

    values = css_select("select#user_story_story_points option").map { |option| option["value"] }
    assert_equal [ "", "0", "1", "2", "3", "5", "8", "13", "21", "34", "55" ], values
  end

  test "a value outside the scale is refused by the server even when the form is bypassed (#15)" do
    @story.update!(story_points: 5)

    [ "4", "7", "100", "-1" ].each do |value|
      patch project_user_story_path(@project, @story), params: { user_story: { story_points: value } }

      assert_response :unprocessable_entity
      assert_select "#error_explanation li", /Story points não está incluído na lista/
      assert_equal 5, @story.reload.story_points
    end
  end

  test "RICE Effort uses exactly the story point scale (#15)" do
    inclusion = ->(attribute) { UserStory.validators_on(attribute).grep(ActiveModel::Validations::InclusionValidator).first.options[:in] }

    assert_equal UserStory::STORY_POINTS, inclusion.(:story_points)
    assert_equal UserStory::STORY_POINTS, inclusion.(:rice_effort)
  end
end
