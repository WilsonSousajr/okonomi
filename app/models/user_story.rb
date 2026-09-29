class UserStory < ApplicationRecord
  belongs_to :project
  belongs_to :backlog
  belongs_to :epic, optional: true
  has_many :acceptance_criteria, dependent: :destroy

  normalizes :role, :action, :benefit, with: ->(value) { value.squish }

  # The same scale is the domain of story points (#15) and of RICE Effort (#18).
  STORY_POINTS = [ 0, 1, 2, 3, 5, 8, 13, 21, 34, 55 ].freeze
  MOSCOW = %w[ M S C W ].freeze
  RICE_IMPACTS = %w[ 3 2 1 0.5 0.25 ].map { |impact| BigDecimal(impact) }.freeze
  RICE_CONFIDENCES = [ 100, 80, 50 ].freeze

  validates :role, :action, :benefit, presence: true
  validates :story_points, inclusion: { in: STORY_POINTS }, allow_nil: true
  validates :moscow, inclusion: { in: MOSCOW }, allow_nil: true
  validates :rice_reach, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :rice_impact, inclusion: { in: RICE_IMPACTS }, allow_nil: true
  validates :rice_confidence, inclusion: { in: RICE_CONFIDENCES }, allow_nil: true
  validates :rice_effort, inclusion: { in: STORY_POINTS }, allow_nil: true
  validate :created_in_product_backlog, on: :create
  validate :backlog_in_same_project
  validate :epic_in_same_project

  before_validation :default_to_product_backlog, on: :create

  def to_s = "Como um #{role}, eu quero #{action}, para #{benefit}."

  # Confidence is stored as a percentage. Effort 0 yields nil rather than dividing by
  # zero — the brief leaves that case undefined (#19).
  def rice_score
    return if [ rice_reach, rice_impact, rice_confidence, rice_effort ].any?(&:nil?) || rice_effort.zero?

    (rice_reach * rice_impact * (rice_confidence / 100.0)) / rice_effort
  end

  private
    def default_to_product_backlog
      self.backlog ||= project&.product_backlog
    end

    # A story is born in the product backlog; sprints receive it only by moving it (#7).
    def created_in_product_backlog
      errors.add(:backlog, :must_be_product_backlog) if backlog&.sprint?
    end

    def backlog_in_same_project
      errors.add(:backlog, :must_belong_to_same_project) if backlog && backlog.project_id != project_id
    end

    def epic_in_same_project
      errors.add(:epic, :must_belong_to_same_project) if epic && epic.project_id != project_id
    end
end
