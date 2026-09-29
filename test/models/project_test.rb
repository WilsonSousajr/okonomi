require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "requires a name" do
    project = users(:one).projects.new(name: "  ")
    assert_not project.valid?
    assert project.errors.added?(:name, :blank)
  end

  test "belongs to its owner" do
    assert_equal users(:one), projects(:okonomi).user
    assert_includes users(:one).projects, projects(:okonomi)
    assert_not_includes users(:one).projects, projects(:other_project)
  end

  test "exposes its single product backlog and its sprint backlogs" do
    project = projects(:okonomi)
    assert_equal backlogs(:okonomi_product), project.product_backlog
    assert_equal [ backlogs(:okonomi_sprint_one) ], project.sprint_backlogs.to_a
  end

  test "destroying a project destroys its backlogs, epics, stories and criteria" do
    assert_difference -> { UserStory.count } => -1, -> { AcceptanceCriterion.count } => -1,
                      -> { Backlog.count } => -2, -> { Epic.count } => -1 do
      projects(:okonomi).destroy!
    end
  end
end
