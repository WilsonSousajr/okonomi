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

  test "Reach refuses a negative or non-integer number of users (#18)" do
    [ "-1", "2.5" ].each do |value|
      patch project_user_story_path(@project, @story), params: rice(reach: value)

      assert_response :unprocessable_entity
      assert_select "#error_explanation li", /Alcance \(Reach\)/
      assert_nil @story.reload.rice_reach
    end
  end

  test "Impact, Confidence and Effort refuse values outside their domains (#18)" do
    { impact: "4", confidence: "90", effort: "4" }.each do |field, value|
      patch project_user_story_path(@project, @story), params: rice(field => value)

      assert_response :unprocessable_entity, "#{field}=#{value} should be refused"
      assert_select "#error_explanation li", /não está incluíd/
    end
    @story.reload
    assert_equal [ nil, nil, nil ], [ @story.rice_impact, @story.rice_confidence, @story.rice_effort ]
  end

  test "the Impact, Confidence and Effort fields offer only their domain, with textual labels (#18)" do
    get edit_project_user_story_path(@project, @story)

    options = ->(id) { css_select("select##{id} option").map { |option| [ option["value"], option.text ] } }
    assert_equal [ [ "", "Não definido" ], [ "3", "3 — massivo" ], [ "2", "2 — alto" ], [ "1", "1 — médio" ], [ "0.5", "0,5 — baixo" ], [ "0.25", "0,25 — mínimo" ] ],
      options.("user_story_rice_impact")
    assert_equal [ [ "", "Não definida" ], [ "100", "100% — alta" ], [ "80", "80% — média" ], [ "50", "50% — baixa" ] ],
      options.("user_story_rice_confidence")
    assert_equal [ "", "0", "1", "2", "3", "5", "8", "13", "21", "34", "55" ],
      options.("user_story_rice_effort").map(&:first)
  end

  test "a stored Impact of 0.25 is preselected when editing (#18)" do
    @story.update!(rice_impact: BigDecimal("0.25"))

    get edit_project_user_story_path(@project, @story)

    assert_select "select#user_story_rice_impact option[selected]", "0,25 — mínimo"
  end

  test "R=1000, I=2, C=80, E=5 shows a score of 320 (#19)" do
    @story.update!(rice_reach: 1000, rice_impact: 2, rice_confidence: 80, rice_effort: 5)

    get project_user_story_path(@project, @story)

    assert_select "[data-field=rice]", "320,00"
  end

  test "a blank field or Effort 0 shows the score as undefined, without error (#19)" do
    @story.update!(rice_reach: 1000, rice_impact: 2, rice_confidence: 80, rice_effort: 0)

    get project_user_story_path(@project, @story)

    assert_response :success
    assert_select "[data-field=rice]", "indefinida"
  end

  test "sorting the backlog by RICE lists the highest score first and undefined last (#19)" do
    @story.update!(rice_reach: 1000, rice_impact: 2, rice_confidence: 80, rice_effort: 5)
    undefined = @project.user_stories.create!(role: "gerente", action: "x", benefit: "y")

    get project_path(@project, sort: "rice")

    ids = css_select("#product_backlog li[id^=user_story_]").map { |item| item["id"] }
    dom_id = ->(record) { ActionView::RecordIdentifier.dom_id(record) }
    assert_equal [ dom_id.(@story), dom_id.(user_stories(:login)), dom_id.(undefined) ], ids
  end

  test "sorting can be combined with the MoSCoW filter (#16, #19)" do
    @story.update!(moscow: "M", rice_reach: 1000, rice_impact: 2, rice_confidence: 80, rice_effort: 5)
    @project.user_stories.create!(role: "gerente", action: "x", benefit: "y", moscow: "S", rice_reach: 99_999, rice_impact: 3, rice_confidence: 100, rice_effort: 1)

    get project_path(@project, sort: "rice", moscow: "M")

    ids = css_select("#product_backlog li[id^=user_story_]").map { |item| item["id"] }
    assert_equal [ ActionView::RecordIdentifier.dom_id(@story), ActionView::RecordIdentifier.dom_id(user_stories(:login)) ], ids
  end
end
