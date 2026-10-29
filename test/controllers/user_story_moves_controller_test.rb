require "test_helper"

# RF08 (#8): mover histórias entre backlogs do mesmo projeto.
class UserStoryMovesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:okonomi)
    @story = user_stories(:login)
    @product = backlogs(:okonomi_product)
    @sprint = backlogs(:okonomi_sprint_one)
    sign_in_as users(:one)
  end

  test "a story moves from the product backlog to a sprint of the same project" do
    post project_user_story_move_path(@project, @story), params: { backlog_id: @sprint.id }

    assert_redirected_to project_user_story_path(@project, @story)
    assert_equal @sprint, @story.reload.backlog

    get project_path(@project)
    assert_select "#product_backlog ##{ActionView::RecordIdentifier.dom_id(@story)}", 0
    assert_select "##{ActionView::RecordIdentifier.dom_id(@sprint)} ##{ActionView::RecordIdentifier.dom_id(@story)}", 1
  end

  test "a story moves back from a sprint to the product backlog" do
    @story.update!(backlog: @sprint)

    post project_user_story_move_path(@project, @story), params: { backlog_id: @product.id }

    assert_redirected_to project_user_story_path(@project, @story)
    assert_equal @product, @story.reload.backlog
  end

  test "test_move_to_other_projects_backlog_is_refused_issue_8" do
    post project_user_story_move_path(@project, @story), params: { backlog_id: backlogs(:other_product).id }

    assert_response :not_found
    assert_equal @product, @story.reload.backlog
  end

  test "moving keeps the story's text, epic, criteria, story points, MoSCoW and RICE" do
    before = @story.attributes.except("backlog_id", "updated_at")
    criteria = @story.acceptance_criteria.pluck(:id)

    post project_user_story_move_path(@project, @story), params: { backlog_id: @sprint.id }

    @story.reload
    assert_equal before, @story.attributes.except("backlog_id", "updated_at")
    assert_equal criteria, @story.acceptance_criteria.pluck(:id)
    assert_equal epics(:okonomi_auth), @story.epic
  end

  test "moving another project's story is not found" do
    other = user_stories(:other_story)

    post project_user_story_move_path(@project, other), params: { backlog_id: @sprint.id }

    assert_response :not_found
    assert_equal backlogs(:other_product), other.reload.backlog
  end

  test "the story page offers the project's other backlogs as destinations" do
    get project_user_story_path(@project, @story)

    assert_select "form[action=?] select[name=backlog_id]", project_user_story_move_path(@project, @story) do
      assert_select "option", 1
      assert_select "option[value=?]", @sprint.id.to_s, "Sprint 1"
    end
  end
end
