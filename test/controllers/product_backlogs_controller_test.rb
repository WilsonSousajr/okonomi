require "test_helper"

# RF05 (#5): no máximo um product backlog por projeto.
class ProductBacklogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @project = projects(:okonomi)
    @product = backlogs(:okonomi_product)
    sign_in_as @user
  end

  test "a project without a product backlog accepts one" do
    project = @user.projects.create!(name: "Novo projeto")

    assert_difference -> { project.backlogs.product.count } => 1 do
      post project_product_backlog_path(project), params: { backlog: { name: "Product backlog", goal: "Tudo que o produto precisa" } }
    end

    assert_redirected_to project_path(project)
    assert_equal "Tudo que o produto precisa", project.reload.product_backlog.goal
  end

  test "a second product backlog is refused with a message explaining the rule" do
    assert_no_difference -> { Backlog.count } do
      post project_product_backlog_path(@project), params: { backlog: { name: "Outro" } }
    end

    assert_response :unprocessable_entity
    assert_select "#error_explanation", /Este projeto já possui um product backlog — só pode existir um por projeto/
  end

  test "the project page shows the product backlog and its stories" do
    get project_path(@project)

    assert_select "#product_backlog" do
      assert_select "h2", /Product backlog/
      assert_select "li", /entrar com e-mail e senha/
    end
  end

  test "the project page offers to create the product backlog when there is none" do
    project = @user.projects.create!(name: "Novo projeto")

    get project_path(project)

    assert_select "#product_backlog a[href=?]", new_project_product_backlog_path(project)
  end

  test "editing the product backlog persists the changes" do
    patch project_product_backlog_path(@project), params: { backlog: { name: "Backlog do produto", goal: "Meta" } }

    assert_redirected_to project_path(@project)
    assert_equal [ "Backlog do produto", "Meta" ], @product.reload.values_at(:name, :goal)
  end

  test "editing with a blank name is refused" do
    patch project_product_backlog_path(@project), params: { backlog: { name: "" } }

    assert_response :unprocessable_entity
  end

  test "the kind cannot be changed through the form" do
    patch project_product_backlog_path(@project), params: { backlog: { name: "x", kind: "sprint" } }

    assert @product.reload.product?
  end

  test "deleting it lets the project accept a new one" do
    delete project_product_backlog_path(@project)

    assert_redirected_to project_path(@project)
    assert_nil @project.reload.product_backlog

    post project_product_backlog_path(@project), params: { backlog: { name: "Novo product backlog" } }
    assert_equal "Novo product backlog", @project.reload.product_backlog.name
  end

  test "another user's project product backlog is not found" do
    other = projects(:other_project)

    get edit_project_product_backlog_path(other)
    assert_response :not_found
    assert_no_difference -> { Backlog.count } do
      delete project_product_backlog_path(other)
    end
    assert_response :not_found
  end
end
