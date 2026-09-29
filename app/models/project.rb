class Project < ApplicationRecord
  belongs_to :user
  # Stories go first so their composite foreign keys never outlive a backlog or epic (#8, #11).
  has_many :user_stories, dependent: :destroy
  has_many :backlogs, dependent: :destroy
  has_one :product_backlog, -> { product }, class_name: "Backlog", inverse_of: :project
  has_many :sprint_backlogs, -> { sprint }, class_name: "Backlog", inverse_of: :project
  has_many :epics, dependent: :destroy

  normalizes :name, with: ->(value) { value.squish }

  validates :name, presence: true
end
