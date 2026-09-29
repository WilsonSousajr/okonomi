class Epic < ApplicationRecord
  belongs_to :project
  has_many :user_stories, dependent: :nullify

  normalizes :title, with: ->(value) { value.squish }

  validates :title, presence: true
end
