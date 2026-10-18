require "test_helper"

# RF04 (#4): CRUD de projetos, sempre restrito aos projetos do usuário.
class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @project = projects(:okonomi)
    sign_in_as @user
  end

  test "index lists only my projects" do
    get projects_path

    assert_response :success
    assert_select "#projects", text: /okonomi/
    assert_select "#projects", text: /Projeto de outro usuário/, count: 0
  end

  test "creating a project with a name persists it and lists it" do
    assert_difference -> { @user.projects.count } => 1 do
      post projects_path, params: { project: { name: "Loja virtual", description: "Vendas online" } }
    end

    project = @user.projects.order(:id).last
    assert_redirected_to project_path(project)
    get projects_path
    assert_select "#projects", text: /Loja virtual/
  end

  test "creating a project without a name shows the validation message" do
    assert_no_difference -> { Project.count } do
      post projects_path, params: { project: { name: " ", description: "x" } }
    end

    assert_response :unprocessable_entity
    assert_select "#error_explanation", /Nome não pode ficar em branco/
  end

  test "show displays the project" do
    get project_path(@project)

    assert_response :success
    assert_select "h1", "okonomi"
  end

  test "updating name and description persists the changes" do
    patch project_path(@project), params: { project: { name: "okonomi 2", description: "Nova descrição" } }

    assert_redirected_to project_path(@project)
    @project.reload
    assert_equal "okonomi 2", @project.name
    assert_equal "Nova descrição", @project.description
  end

  test "updating with a blank name is refused" do
    patch project_path(@project), params: { project: { name: "" } }

    assert_response :unprocessable_entity
    assert_equal "okonomi", @project.reload.name
  end

  test "deleting a project removes its backlogs, epics, stories and criteria" do
    assert_difference -> { Project.count } => -1, -> { Backlog.count } => -2, -> { Epic.count } => -1,
                      -> { UserStory.count } => -1, -> { AcceptanceCriterion.count } => -1 do
      delete project_path(@project)
    end

    assert_redirected_to projects_path
  end

  test "another user's project is not found (#3)" do
    other = projects(:other_project)

    get project_path(other)
    assert_response :not_found
    get edit_project_path(other)
    assert_response :not_found
    patch project_path(other), params: { project: { name: "invadido" } }
    assert_response :not_found
    assert_no_difference -> { Project.count } do
      delete project_path(other)
    end
    assert_response :not_found
    assert_equal "Projeto de outro usuário", other.reload.name
  end
end

# RF03 (#3): critérios que dependem da lista de projetos.
class ProjectsAuthenticationTest < ActionDispatch::IntegrationTest
  test "anonymous visitor asking for projects is sent to sign in (#3)" do
    get projects_path

    assert_redirected_to new_session_path
  end

  test "signing in lands on the project list (#3)" do
    post session_path, params: { email_address: "one@example.com", password: "password" }

    assert_redirected_to projects_url
  end

  test "signing in returns to the page that was asked for (#3)" do
    get project_path(projects(:okonomi))
    post session_path, params: { email_address: "one@example.com", password: "password" }

    assert_redirected_to project_url(projects(:okonomi))
  end

  test "an authenticated visitor at the root goes to the project list" do
    sign_in_as users(:one)

    get root_path

    assert_redirected_to projects_path
  end
end
