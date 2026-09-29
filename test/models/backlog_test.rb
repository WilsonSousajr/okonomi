require "test_helper"

class BacklogTest < ActiveSupport::TestCase
  test "kind is either product or sprint" do
    backlog = projects(:okonomi).backlogs.new(name: "Outro", kind: "release")
    assert_not backlog.valid?
    assert backlog.errors.added?(:kind, :inclusion, value: "release")
  end

  test "requires a name" do
    backlog = projects(:okonomi).backlogs.new(kind: "sprint", name: "")
    assert_not backlog.valid?
    assert backlog.errors.added?(:name, :blank)
  end

  test "a second product backlog in the same project is rejected by the model (#5)" do
    backlog = projects(:okonomi).backlogs.new(kind: "product", name: "Segundo")
    assert_not backlog.valid?
    assert backlog.errors.added?(:kind, :taken, value: "product")
  end

  test "a second product backlog in the same project is rejected by the database (#5)" do
    assert_raises ActiveRecord::RecordNotUnique do
      backlogs(:okonomi_sprint_one).update_column(:kind, "product")
    end
  end

  test "each project may have its own product backlog" do
    project = users(:one).projects.create!(name: "Novo")
    assert project.backlogs.create(kind: "product", name: "Product backlog").persisted?
  end

  test "a project may have many sprint backlogs (#6)" do
    backlog = projects(:okonomi).backlogs.new(kind: "sprint", name: "Sprint 2")
    assert backlog.valid?
  end

  test "a sprint cannot end before it starts" do
    backlog = backlogs(:okonomi_sprint_one)
    backlog.ends_on = backlog.starts_on - 1
    assert_not backlog.valid?
    assert backlog.errors.added?(:ends_on, :greater_than_or_equal_to, count: backlog.starts_on, value: backlog.ends_on)
  end

  test "a sprint ending before it starts is rejected by the database" do
    assert_raises ActiveRecord::CheckViolation do
      backlogs(:okonomi_sprint_one).update_column(:ends_on, Date.new(2026, 9, 1))
    end
  end

  test "an unknown kind is rejected by the database" do
    assert_raises ActiveRecord::CheckViolation do
      backlogs(:okonomi_sprint_one).update_column(:kind, "release")
    end
  end
end
