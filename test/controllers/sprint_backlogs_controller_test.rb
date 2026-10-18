require "test_helper"

# RF06 (#6): vários sprint backlogs por projeto.
class SprintBacklogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:okonomi)
    @sprint = backlogs(:okonomi_sprint_one)
    sign_in_as users(:one)
  end

  test "creating a sprint with a name persists it in the project" do
    assert_difference -> { @project.sprint_backlogs.count } => 1 do
      post project_sprint_backlogs_path(@project), params: { backlog: { name: "Sprint 2", goal: "Backlogs", starts_on: "2026-10-12", ends_on: "2026-10-18" } }
    end

    sprint = @project.sprint_backlogs.order(:id).last
    assert_redirected_to project_sprint_backlog_path(@project, sprint)
    assert_equal [ "Sprint 2", Date.new(2026, 10, 12) ], [ sprint.name, sprint.starts_on ]
  end

  test "creating more sprints is always accepted" do
    assert_difference -> { @project.sprint_backlogs.count } => 2 do
      post project_sprint_backlogs_path(@project), params: { backlog: { name: "Sprint 2" } }
      post project_sprint_backlogs_path(@project), params: { backlog: { name: "Sprint 3" } }
    end
  end

  test "a sprint cannot be created as a product backlog through the form" do
    post project_sprint_backlogs_path(@project), params: { backlog: { name: "Sprint 2", kind: "product" } }

    assert @project.backlogs.order(:id).last.sprint?
  end

  test "the project page lists every sprint with its stories" do
    @project.sprint_backlogs.create!(name: "Sprint 2")
    user_stories(:login).update_columns(backlog_id: @sprint.id)

    get project_path(@project)

    assert_select "#sprint_backlogs" do
      assert_select "h3", /Sprint 1/
      assert_select "h3", /Sprint 2/
      assert_select "##{ActionView::RecordIdentifier.dom_id(@sprint)} li", /entrar com e-mail e senha/
    end
  end

  test "show displays the sprint and its stories" do
    user_stories(:login).update_columns(backlog_id: @sprint.id)

    get project_sprint_backlog_path(@project, @sprint)

    assert_select "h1", "Sprint 1"
    assert_select "li", /entrar com e-mail e senha/
  end

  test "editing a sprint persists the changes" do
    patch project_sprint_backlog_path(@project, @sprint), params: { backlog: { name: "Sprint 1 — auth", goal: "Nova meta" } }

    assert_redirected_to project_sprint_backlog_path(@project, @sprint)
    assert_equal [ "Sprint 1 — auth", "Nova meta" ], @sprint.reload.values_at(:name, :goal)
  end

  test "a sprint ending before it starts shows the validation message" do
    patch project_sprint_backlog_path(@project, @sprint), params: { backlog: { starts_on: "2026-10-18", ends_on: "2026-10-12" } }

    assert_response :unprocessable_entity
    assert_select "#error_explanation", /Fim/
  end

  test "deleting a sprint keeps its stories in the product backlog" do
    story = user_stories(:login)
    story.update_columns(backlog_id: @sprint.id)

    assert_difference -> { Backlog.count } => -1, -> { UserStory.count } => 0 do
      delete project_sprint_backlog_path(@project, @sprint)
    end

    assert_redirected_to project_path(@project)
    assert_equal backlogs(:okonomi_product), story.reload.backlog
  end

  test "deleting a sprint with stories and no product backlog is refused with a message" do
    user_stories(:login).update_columns(backlog_id: @sprint.id)
    Backlog.where(id: backlogs(:okonomi_product).id).delete_all

    assert_no_difference -> { Backlog.count } do
      delete project_sprint_backlog_path(@project, @sprint)
    end

    assert_redirected_to project_sprint_backlog_path(@project, @sprint)
    assert_equal "Crie o product backlog antes de excluir uma sprint com histórias — elas voltariam para ele.", flash[:alert]
  end

  test "the product backlog cannot be reached through the sprint routes" do
    get project_sprint_backlog_path(@project, backlogs(:okonomi_product))

    assert_response :not_found
  end

  test "another project's sprint is not found, even under my own project" do
    other_sprint = projects(:other_project).sprint_backlogs.create!(name: "Sprint alheia")

    get project_sprint_backlog_path(@project, other_sprint)
    assert_response :not_found
    get project_sprint_backlog_path(projects(:other_project), other_sprint)
    assert_response :not_found
    assert_no_difference -> { Backlog.count } do
      delete project_sprint_backlog_path(@project, other_sprint)
    end
  end
end
