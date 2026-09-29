class AcceptanceCriterion < ApplicationRecord
  belongs_to :user_story

  normalizes :context, :action, :outcome, with: ->(value) { value.squish }

  validates :context, :action, :outcome, presence: true

  def to_s = "Dado #{context}, quando #{action}, então #{outcome}."
end
