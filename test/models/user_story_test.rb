require "test_helper"

class UserStoryTest < ActiveSupport::TestCase
  def new_story(**attributes)
    projects(:okonomi).user_stories.new(role: "usuário", action: "criar um projeto", benefit: "organizar o trabalho", **attributes)
  end

  # Format — Como um … eu quero … para … (#9)

  test "role, action and benefit are each required (#9)" do
    story = new_story(role: "", action: " ", benefit: nil)
    assert_not story.valid?
    %i[role action benefit].each do |field|
      assert story.errors.added?(field, :blank), "#{field} should be required"
    end
  end

  test "squishes whitespace in each part" do
    story = UserStory.new(role: "  usuário   cadastrado ", action: "entrar ", benefit: " ver  ")
    assert_equal [ "usuário cadastrado", "entrar", "ver" ], [ story.role, story.action, story.benefit ]
  end

  test "renders the Como um … eu quero … para … format (#9)" do
    assert_equal "Como um usuário cadastrado, eu quero entrar com e-mail e senha, para acessar meus projetos.",
                 user_stories(:login).to_s
  end

  # Backlog placement (#7, #8)

  test "a new story lands in the project's product backlog (#7)" do
    story = new_story
    story.save!
    assert_equal backlogs(:okonomi_product), story.backlog
  end

  test "a new story cannot be created directly in a sprint backlog (#7)" do
    story = new_story(backlog: backlogs(:okonomi_sprint_one))
    assert_not story.valid?
    assert story.errors.added?(:backlog, :must_be_product_backlog)
  end

  test "a new story in a project without product backlog is rejected (#7)" do
    project = users(:one).projects.create!(name: "Sem backlog")
    story = project.user_stories.new(role: "a", action: "b", benefit: "c")
    assert_not story.valid?
    assert story.errors.added?(:backlog, :blank)
  end

  test "an existing story moves to a sprint backlog of the same project (#8)" do
    story = user_stories(:login)
    story.update!(backlog: backlogs(:okonomi_sprint_one))
    assert_equal backlogs(:okonomi_sprint_one), story.reload.backlog
  end

  test "test_moving_story_across_projects_is_rejected_issue_8" do
    story = user_stories(:login)
    story.backlog = backlogs(:other_product)
    assert_not story.valid?
    assert story.errors.added?(:backlog, :must_belong_to_same_project)
  end

  test "moving a story across projects is rejected by the database (#8)" do
    assert_raises ActiveRecord::InvalidForeignKey do
      user_stories(:login).update_column(:backlog_id, backlogs(:other_product).id)
    end
  end

  # Epics (#11)

  test "a story can be linked to an epic of its own project (#11)" do
    story = user_stories(:other_story)
    story.update!(epic: epics(:other_epic))
    assert_equal epics(:other_epic), story.reload.epic
  end

  test "linking a story to another project's epic is rejected (#11)" do
    story = user_stories(:login)
    story.epic = epics(:other_epic)
    assert_not story.valid?
    assert story.errors.added?(:epic, :must_belong_to_same_project)
  end

  test "linking a story to another project's epic is rejected by the database (#11)" do
    assert_raises ActiveRecord::InvalidForeignKey do
      user_stories(:login).update_column(:epic_id, epics(:other_epic).id)
    end
  end

  # Story points (#14, #15)

  test "accepts every story point on the scale and blank (#15)" do
    [ nil, *UserStory::STORY_POINTS ].each do |points|
      assert new_story(story_points: points).valid?, "#{points.inspect} should be accepted"
    end
  end

  test "rejects story points off the scale (#15)" do
    [ 4, 7, -1, 100 ].each do |points|
      story = new_story(story_points: points)
      assert_not story.valid?, "#{points} should be rejected"
      assert story.errors.added?(:story_points, :inclusion, value: points)
    end
  end

  test "story points off the scale are rejected by the database (#15)" do
    assert_raises ActiveRecord::CheckViolation do
      user_stories(:login).update_column(:story_points, 4)
    end
  end

  # MoSCoW (#16)

  test "accepts each MoSCoW label and blank (#16)" do
    [ nil, "M", "S", "C", "W" ].each do |label|
      assert new_story(moscow: label).valid?, "#{label.inspect} should be accepted"
    end
  end

  test "rejects any other MoSCoW label (#16)" do
    story = new_story(moscow: "X")
    assert_not story.valid?
    assert story.errors.added?(:moscow, :inclusion, value: "X")
  end

  test "an unknown MoSCoW label is rejected by the database (#16)" do
    assert_raises ActiveRecord::CheckViolation do
      user_stories(:login).update_column(:moscow, "X")
    end
  end

  # RICE domains (#17, #18)

  test "accepts every value in each RICE domain (#18)" do
    UserStory::RICE_IMPACTS.each { |impact| assert new_story(rice_impact: impact).valid?, "impact #{impact}" }
    UserStory::RICE_CONFIDENCES.each { |confidence| assert new_story(rice_confidence: confidence).valid?, "confidence #{confidence}" }
    UserStory::STORY_POINTS.each { |effort| assert new_story(rice_effort: effort).valid?, "effort #{effort}" }
    [ 0, 1, 5000 ].each { |reach| assert new_story(rice_reach: reach).valid?, "reach #{reach}" }
  end

  test "rejects values outside each RICE domain (#18)" do
    { rice_reach: [ -1, 1.5 ], rice_impact: [ 0.3, 4, 0 ], rice_confidence: [ 90, 0, 101 ], rice_effort: [ 4, 7, -1 ] }.each do |field, values|
      values.each do |value|
        assert_not new_story(field => value).valid?, "#{field} = #{value} should be rejected"
      end
    end
  end

  test "RICE values outside their domains are rejected by the database (#18)" do
    { rice_reach: -1, rice_impact: 0.3, rice_confidence: 90, rice_effort: 4 }.each do |field, value|
      UserStory.transaction(requires_new: true) do
        assert_raises(ActiveRecord::CheckViolation, "#{field} = #{value}") do
          user_stories(:login).update_column(field, value)
        end
        raise ActiveRecord::Rollback
      end
    end
  end

  test "impact 0.25 is stored exactly (#18)" do
    story = user_stories(:login)
    story.update!(rice_impact: "0.25")
    assert_equal BigDecimal("0.25"), story.reload.rice_impact
  end

  # RICE score (#19)

  test "rice score is (reach × impact × confidence%) / effort (#19)" do
    # 100 × 2 × 0.8 / 3
    assert_in_delta 53.333, user_stories(:login).rice_score, 0.001
  end

  test "rice score uses the exact minimal impact (#19)" do
    story = new_story(rice_reach: 8, rice_impact: 0.25, rice_confidence: 50, rice_effort: 1)
    assert_equal 1.0, story.rice_score
  end

  test "effort zero yields a nil rice score rather than dividing by zero (#19)" do
    story = new_story(rice_reach: 10, rice_impact: 1, rice_confidence: 100, rice_effort: 0)
    assert_nil story.rice_score
  end

  test "a blank RICE field yields a nil rice score (#19)" do
    %i[rice_reach rice_impact rice_confidence rice_effort].each do |field|
      story = user_stories(:login).dup
      story[field] = nil
      assert_nil story.rice_score, "#{field} blank"
    end
  end

  test "destroying a story destroys its acceptance criteria" do
    assert_difference -> { AcceptanceCriterion.count }, -1 do
      user_stories(:login).destroy!
    end
  end
end
