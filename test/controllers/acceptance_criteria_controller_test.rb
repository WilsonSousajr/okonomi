require "test_helper"

# RF12 (#12): CRUD de critérios de aceitação de uma história.
class AcceptanceCriteriaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:okonomi)
    @story = user_stories(:login)
    @criterion = acceptance_criteria(:login_success)
    sign_in_as users(:one)
  end

  test "creating a criterion persists it under the story" do
    assert_difference -> { @story.acceptance_criteria.count } => 1 do
      post project_user_story_acceptance_criteria_path(@project, @story),
        params: { acceptance_criterion: { context: "um usuário cadastrado", action: "erra a senha", outcome: "vê uma mensagem genérica" } }
    end

    assert_redirected_to project_user_story_path(@project, @story)
  end

  test "several criteria are accepted and listed in the order they were created" do
    [ "primeiro", "segundo" ].each do |order|
      post project_user_story_acceptance_criteria_path(@project, @story),
        params: { acceptance_criterion: { context: "contexto #{order}", action: "ação", outcome: "resultado" } }
    end

    get project_user_story_path(@project, @story)

    items = css_select("#acceptance_criteria li").map(&:text)
    assert_equal 3, items.size
    assert_match "é levado à lista dos seus projetos", items[0]
    assert_match "contexto primeiro", items[1]
    assert_match "contexto segundo", items[2]
  end

  test "editing a criterion persists the changes" do
    patch project_user_story_acceptance_criterion_path(@project, @story, @criterion),
      params: { acceptance_criterion: { outcome: "vê o painel" } }

    assert_redirected_to project_user_story_path(@project, @story)
    assert_equal "vê o painel", @criterion.reload.outcome
  end

  test "deleting a criterion removes it and keeps the story" do
    assert_difference -> { AcceptanceCriterion.count } => -1, -> { UserStory.count } => 0 do
      delete project_user_story_acceptance_criterion_path(@project, @story, @criterion)
    end

    assert_redirected_to project_user_story_path(@project, @story)
  end

  test "deleting the story removes its criteria" do
    assert_difference -> { AcceptanceCriterion.count } => -1 do
      delete project_user_story_path(@project, @story)
    end
  end

  test "criteria of another project's story are not found, even under my own project" do
    other = user_stories(:other_story)

    get new_project_user_story_acceptance_criterion_path(@project, other)
    assert_response :not_found
    assert_no_difference -> { AcceptanceCriterion.count } do
      post project_user_story_acceptance_criteria_path(@project, other),
        params: { acceptance_criterion: { context: "x", action: "y", outcome: "z" } }
    end
    assert_response :not_found
  end

  test "a criterion cannot be reached through another story of my project" do
    sibling = @project.user_stories.create!(role: "gerente", action: "ver", benefit: "planejar")

    patch project_user_story_acceptance_criterion_path(@project, sibling, @criterion),
      params: { acceptance_criterion: { outcome: "trocado" } }

    assert_response :not_found
    assert_not_equal "trocado", @criterion.reload.outcome
  end

  test "the criterion form has three separate fields labelled with the standard format (#13)" do
    get new_project_user_story_acceptance_criterion_path(@project, @story)

    assert_select "label[for=acceptance_criterion_context]", "Dado"
    assert_select "label[for=acceptance_criterion_action]", "quando"
    assert_select "label[for=acceptance_criterion_outcome]", "então"
  end

  test "each blank part of the criterion is refused and pointed at on its own field (#13)" do
    { context: "Contexto", action: "Ação", outcome: "Resultado" }.each do |field, name|
      parts = { context: "um usuário", action: "entra", outcome: "vê os projetos" }.merge(field => " ")

      assert_no_difference -> { AcceptanceCriterion.count } do
        post project_user_story_acceptance_criteria_path(@project, @story), params: { acceptance_criterion: parts }
      end

      assert_response :unprocessable_entity
      assert_select "#error_explanation li", /#{name} não pode ficar em branco/
      assert_select "#acceptance_criterion_#{field}[aria-invalid=true]", 1
      assert_select "[aria-invalid=true]", 1
    end
  end

  test "a saved criterion is shown as Dado …, quando …, então … (#13)" do
    get project_user_story_path(@project, @story)

    assert_select "##{ActionView::RecordIdentifier.dom_id(@criterion)} p",
      "Dado um usuário cadastrado na tela de login, quando ele informa e-mail e senha corretos, então é levado à lista dos seus projetos."
  end
end
