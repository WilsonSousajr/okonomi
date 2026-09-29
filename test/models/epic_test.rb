require "test_helper"

class EpicTest < ActiveSupport::TestCase
  test "requires a title" do
    epic = projects(:okonomi).epics.new(title: " ")
    assert_not epic.valid?
    assert epic.errors.added?(:title, :blank)
  end

  test "destroying an epic keeps its stories, unlinked" do
    story = user_stories(:login)
    epics(:okonomi_auth).destroy!
    assert_nil story.reload.epic
  end
end
