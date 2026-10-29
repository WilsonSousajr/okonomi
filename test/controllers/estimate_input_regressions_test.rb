require "test_helper"

# Entradas adulteradas que a revisão final da S4/S5 encontrou (#102, #103, #104).
class EstimateInputRegressionsTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:okonomi)
    @story = user_stories(:login)
    sign_in_as users(:one)
  end

  test "test_non_integer_estimates_are_refused_not_truncated_issue_102" do
    { story_points: [ "2.5", "abc" ], rice_confidence: [ "80.9" ], rice_effort: [ "2.9" ] }.each do |field, values|
      values.each do |value|
        before = @story.reload.public_send(field)

        patch project_user_story_path(@project, @story), params: { user_story: { field => value } }

        assert_response :unprocessable_entity, "#{field}=#{value.inspect} should be refused"
        assert_equal before, @story.reload.public_send(field)
      end
    end
  end

  test "test_missing_epic_is_a_validation_error_not_a_crash_issue_103" do
    patch project_user_story_path(@project, @story), params: { user_story: { epic_id: Epic.maximum(:id).to_i + 1 } }

    assert_response :unprocessable_entity
    assert_select "#error_explanation li", /Épico/
    assert_equal epics(:okonomi_auth), @story.reload.epic
  end

  test "test_reach_above_the_integer_limit_is_refused_issue_104" do
    patch project_user_story_path(@project, @story), params: { user_story: { rice_reach: "3000000000" } }

    assert_response :unprocessable_entity
    assert_equal 100, @story.reload.rice_reach

    get edit_project_user_story_path(@project, @story)
    assert_select "input#user_story_rice_reach[max=?]", "2147483647"
  end
end
