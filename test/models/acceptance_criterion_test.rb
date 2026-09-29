require "test_helper"

class AcceptanceCriterionTest < ActiveSupport::TestCase
  test "context, action and outcome are each required (#13)" do
    criterion = user_stories(:login).acceptance_criteria.new(context: "", action: " ", outcome: nil)
    assert_not criterion.valid?
    %i[context action outcome].each do |field|
      assert criterion.errors.added?(field, :blank), "#{field} should be required"
    end
  end

  test "squishes whitespace in each part" do
    criterion = AcceptanceCriterion.new(context: "  um   usuário ", action: "entra ", outcome: " vê  ")
    assert_equal [ "um usuário", "entra", "vê" ], [ criterion.context, criterion.action, criterion.outcome ]
  end

  test "renders the Dado … quando … então … format (#13)" do
    assert_equal "Dado um usuário cadastrado na tela de login, quando ele informa e-mail e senha corretos, " \
                 "então é levado à lista dos seus projetos.",
                 acceptance_criteria(:login_success).to_s
  end
end
