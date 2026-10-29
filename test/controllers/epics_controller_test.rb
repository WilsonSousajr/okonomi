require "test_helper"

# RF10 (#10): CRUD de épicos do projeto.
class EpicsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:okonomi)
    @epic = epics(:okonomi_auth)
    sign_in_as users(:one)
  end

  test "creating an epic with a title persists it in the project" do
    assert_difference -> { @project.epics.count } => 1 do
      post project_epics_path(@project), params: { epic: { title: "Pagamentos", description: "Pix e cartão" } }
    end

    epic = @project.epics.order(:id).last
    assert_redirected_to project_epic_path(@project, epic)
    assert_equal [ "Pagamentos", "Pix e cartão" ], [ epic.title, epic.description ]
  end

  test "an epic without a title is refused with a validation message" do
    assert_no_difference -> { Epic.count } do
      post project_epics_path(@project), params: { epic: { title: " " } }
    end

    assert_response :unprocessable_entity
    assert_select "#error_explanation li", /Título não pode ficar em branco/
  end

  test "the project page lists every epic with how many stories it has" do
    @project.epics.create!(title: "Pagamentos")

    get project_path(@project)

    assert_select "#epics" do
      assert_select "##{ActionView::RecordIdentifier.dom_id(@epic)}", /Acesso ao sistema.*1 história/m
      assert_select "li", /Pagamentos.*0 histórias/m
    end
  end

  test "editing an epic persists the changes" do
    patch project_epic_path(@project, @epic), params: { epic: { title: "Autenticação", description: "Login e senha" } }

    assert_redirected_to project_epic_path(@project, @epic)
    assert_equal [ "Autenticação", "Login e senha" ], [ @epic.reload.title, @epic.description ]
  end

  test "deleting an epic keeps its stories, now without an epic" do
    story = user_stories(:login)

    assert_difference -> { Epic.count } => -1, -> { UserStory.count } => 0 do
      delete project_epic_path(@project, @epic)
    end

    assert_redirected_to project_path(@project)
    assert_nil story.reload.epic
  end

  test "another project's epic is not found, even under my own project" do
    other = epics(:other_epic)

    get project_epic_path(@project, other)
    assert_response :not_found
    get project_epic_path(projects(:other_project), other)
    assert_response :not_found
    assert_no_difference -> { Epic.count } do
      delete project_epic_path(@project, other)
    end
  end

  test "the epic page lists its stories and the sum of their story points (#11)" do
    @project.user_stories.create!(role: "gerente", action: "recuperar a senha", benefit: "voltar a entrar", epic: @epic, story_points: 5)
    @project.user_stories.create!(role: "gerente", action: "sair", benefit: "proteger a conta", epic: @epic)

    get project_epic_path(@project, @epic)

    assert_select "#epic_stories li", 3
    assert_select "#epic_stories", /Como um usuário cadastrado, eu quero entrar com e-mail e senha/
    assert_select "[data-field=points_total]", "8 pontos"
  end
end
