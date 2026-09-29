class Backlog < ApplicationRecord
  belongs_to :project
  has_many :user_stories, dependent: :destroy

  normalizes :name, with: ->(value) { value.squish }

  enum :kind, { product: "product", sprint: "sprint" }, validate: true

  validates :name, presence: true
  # At most one product backlog per project; the partial unique index backs this up (#5).
  validates :kind, uniqueness: { scope: :project_id }, if: :product?
  validates :ends_on, comparison: { greater_than_or_equal_to: :starts_on }, if: -> { starts_on && ends_on }
end
