require "test_helper"

# RF07 (#7): histórias de usuário nascem no product backlog.
class UserStoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:okonomi)
    @story = user_stories(:login)
    sign_in_as users(:one)
  end

  test "a new story is created in the product backlog" do
    assert_difference -> { backlogs(:okonomi_product).user_stories.count } => 1 do
      post project_user_stories_path(@project), params: { user_story: { role: "gerente", action: "ver o backlog", benefit: "planejar a sprint" } }
    end

    story = @project.user_stories.order(:id).last
    assert_redirected_to project_user_story_path(@project, story)
    assert_equal "Como um gerente, eu quero ver o backlog, para planejar a sprint.", story.to_s
  end

  test "a story cannot be created straight into a sprint backlog (#7)" do
    post project_user_stories_path(@project), params: { user_story: { role: "gerente", action: "ver", benefit: "planejar", backlog_id: backlogs(:okonomi_sprint_one).id } }

    assert @project.user_stories.order(:id).last.backlog.product?
  end

  test "a story is refused with a message when the project has no product backlog" do
    project = users(:one).projects.create!(name: "Sem backlog")

    assert_no_difference -> { UserStory.count } do
      post project_user_stories_path(project), params: { user_story: { role: "gerente", action: "ver", benefit: "planejar" } }
    end

    assert_response :unprocessable_entity
    assert_select "#error_explanation", /Crie o product backlog antes de adicionar histórias/
  end

  test "blank parts of the story are refused" do
    post project_user_stories_path(@project), params: { user_story: { role: "", action: "ver", benefit: "" } }

    assert_response :unprocessable_entity
    assert_select "#error_explanation li", /Papel não pode ficar em branco/
    assert_select "#error_explanation li", /Benefício não pode ficar em branco/
  end

  test "the backlog shows each story with MoSCoW, story points and RICE score" do
    get project_path(@project)

    assert_select "##{ActionView::RecordIdentifier.dom_id(@story)}" do
      assert_select "a", /Como um usuário cadastrado, eu quero entrar com e-mail e senha/
      assert_select "[data-field=moscow]", "M"
      assert_select "[data-field=story_points]", "3"
      assert_select "[data-field=rice]", "53,33"
    end
  end

  test "estimates that are not set are shown as a dash" do
    story = @project.user_stories.create!(role: "gerente", action: "ver", benefit: "planejar")

    get project_path(@project)

    assert_select "##{ActionView::RecordIdentifier.dom_id(story)} [data-field=moscow]", "—"
    assert_select "##{ActionView::RecordIdentifier.dom_id(story)} [data-field=rice]", "—"
  end

  test "show displays the story in the standard format" do
    get project_user_story_path(@project, @story)

    assert_select "h1", /Como um usuário cadastrado/
  end

  test "editing a story persists the changes" do
    patch project_user_story_path(@project, @story), params: { user_story: { action: "entrar com passkey" } }

    assert_redirected_to project_user_story_path(@project, @story)
    assert_equal "entrar com passkey", @story.reload.action
  end

  test "editing cannot move the story to another backlog (moving is #8)" do
    patch project_user_story_path(@project, @story), params: { user_story: { action: "x", backlog_id: backlogs(:okonomi_sprint_one).id } }

    assert @story.reload.backlog.product?
  end

  test "deleting a story removes it and its acceptance criteria" do
    assert_difference -> { UserStory.count } => -1, -> { AcceptanceCriterion.count } => -1 do
      delete project_user_story_path(@project, @story)
    end

    assert_redirected_to project_path(@project)
  end

  test "another project's story is not found, even under my own project" do
    other = user_stories(:other_story)

    get project_user_story_path(@project, other)
    assert_response :not_found
    get project_user_story_path(projects(:other_project), other)
    assert_response :not_found
    assert_no_difference -> { UserStory.count } do
      delete project_user_story_path(@project, other)
    end
  end
end
