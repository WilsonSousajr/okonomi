require "test_helper"

# RF17 (#17), RF18 (#18) e RF19 (#19): critério RICE da história.
class RiceTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:okonomi)
    @story = @project.user_stories.create!(role: "gerente", action: "importar histórias", benefit: "migrar de outra ferramenta")
    sign_in_as users(:one)
  end

  def rice(reach: nil, impact: nil, confidence: nil, effort: nil)
    { user_story: { rice_reach: reach, rice_impact: impact, rice_confidence: confidence, rice_effort: effort }.transform_values(&:to_s) }
  end

  test "filling the four RICE fields persists them and shows them with the story" do
    patch project_user_story_path(@project, @story), params: rice(reach: 1000, impact: "2", confidence: 80, effort: 5)

    assert_redirected_to project_user_story_path(@project, @story)
    @story.reload
    assert_equal [ 1000, BigDecimal("2"), 80, 5 ], [ @story.rice_reach, @story.rice_impact, @story.rice_confidence, @story.rice_effort ]

    follow_redirect!
    assert_select "[data-field=rice_reach]", "1000"
    assert_select "[data-field=rice_impact]", "2 (alto)"
    assert_select "[data-field=rice_confidence]", "80% (média)"
    assert_select "[data-field=rice_effort]", "5"
  end

  test "changing any RICE field persists it and the score is recalculated" do
    @story.update!(rice_reach: 1000, rice_impact: 2, rice_confidence: 80, rice_effort: 5)

    patch project_user_story_path(@project, @story), params: rice(reach: 500, impact: "2", confidence: 80, effort: 5)

    assert_equal 500, @story.reload.rice_reach
    follow_redirect!
    assert_select "[data-field=rice]", "160,00"
  end

  test "a story with RICE left blank stays valid" do
    @story.update!(rice_reach: 1000, rice_impact: 2, rice_confidence: 80, rice_effort: 5)

    patch project_user_story_path(@project, @story), params: rice

    assert_redirected_to project_user_story_path(@project, @story)
    assert_nil @story.reload.rice_reach
    assert_nil @story.rice_impact
  end

  test "a partially filled RICE is accepted and its score is undefined" do
    patch project_user_story_path(@project, @story), params: rice(reach: 1000, impact: "2")

    assert_redirected_to project_user_story_path(@project, @story)
    assert_equal 1000, @story.reload.rice_reach
    follow_redirect!
    assert_select "[data-field=rice]", "indefinida"
  end
end
