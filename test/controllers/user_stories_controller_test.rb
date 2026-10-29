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

  test "estimates that are not set are shown as a dash, and a missing RICE score as undefined (#17)" do
    story = @project.user_stories.create!(role: "gerente", action: "ver", benefit: "planejar")

    get project_path(@project)

    assert_select "##{ActionView::RecordIdentifier.dom_id(story)} [data-field=moscow]", "—"
    assert_select "##{ActionView::RecordIdentifier.dom_id(story)} [data-field=rice]", "indefinida"
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

  test "the story form has three separate fields labelled with the standard format (#9)" do
    get new_project_user_story_path(@project)

    assert_select "label[for=user_story_role]", "Como um"
    assert_select "label[for=user_story_action]", "eu quero"
    assert_select "label[for=user_story_benefit]", "para"
    assert_select "form [name='user_story[role]']", 1
    assert_select "form [name='user_story[action]']", 1
    assert_select "form [name='user_story[benefit]']", 1
  end

  test "each blank part of the story is pointed at on its own field (#9)" do
    { role: "Papel", action: "Ação", benefit: "Benefício" }.each do |field, name|
      parts = { role: "gerente", action: "ver", benefit: "planejar" }.merge(field => "")

      post project_user_stories_path(@project), params: { user_story: parts }

      assert_response :unprocessable_entity
      assert_select "#error_explanation li", /#{name} não pode ficar em branco/
      assert_select "#user_story_#{field}[aria-invalid=true]", 1
      assert_select "[aria-invalid=true]", 1
    end
  end

  test "a sprint backlog lists its stories in the standard format (#9)" do
    @story.update_columns(backlog_id: backlogs(:okonomi_sprint_one).id)

    get project_sprint_backlog_path(@project, backlogs(:okonomi_sprint_one))

    assert_select "##{ActionView::RecordIdentifier.dom_id(@story)} a",
      "Como um usuário cadastrado, eu quero entrar com e-mail e senha, para acessar meus projetos."
  end

  test "a story is linked to an epic of the same project (#11)" do
    epic = @project.epics.create!(title: "Pagamentos")

    patch project_user_story_path(@project, @story), params: { user_story: { epic_id: epic.id } }

    assert_redirected_to project_user_story_path(@project, @story)
    assert_equal epic, @story.reload.epic
  end

  test "unlinking keeps the story, now without an epic (#11)" do
    assert_no_difference -> { UserStory.count } do
      patch project_user_story_path(@project, @story), params: { user_story: { epic_id: "" } }
    end

    assert_nil @story.reload.epic
  end

  test "linking a story to another project's epic is refused (#11)" do
    patch project_user_story_path(@project, @story), params: { user_story: { epic_id: epics(:other_epic).id } }

    assert_response :unprocessable_entity
    assert_select "#error_explanation li", /deve pertencer ao projeto da história/
    assert_equal epics(:okonomi_auth), @story.reload.epic
  end

  test "the story form offers only the project's epics (#11)" do
    get edit_project_user_story_path(@project, @story)

    assert_select "select#user_story_epic_id" do
      assert_select "option", "Sem épico"
      assert_select "option[selected]", "Acesso ao sistema"
      assert_select "option", text: "Épico de outro projeto", count: 0
    end
  end

  test "the story page shows its epic (#11)" do
    get project_user_story_path(@project, @story)

    assert_select "a[href=?]", project_epic_path(@project, epics(:okonomi_auth)), "Acesso ao sistema"
  end
end
