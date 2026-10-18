class Backlog < ApplicationRecord
  belongs_to :project
  # No dependent: option — what happens to the stories depends on the kind (#6), see the callbacks.
  has_many :user_stories

  normalizes :name, with: ->(value) { value.squish }

  enum :kind, { product: "product", sprint: "sprint" }, validate: true

  validates :name, presence: true
  # At most one product backlog per project; the partial unique index backs this up (#5).
  validates :kind, uniqueness: { scope: :project_id }, if: :product?
  validates :ends_on, comparison: { greater_than_or_equal_to: :starts_on }, if: -> { starts_on && ends_on }

  # Deleting a sprint must not orphan its stories (#6): they go back to the product
  # backlog. Deleting the product backlog deletes its stories (#5).
  before_destroy :release_stories_to_product_backlog, if: :sprint?
  before_destroy :destroy_stories, if: :product?

  private
    def release_stories_to_product_backlog
      return unless user_stories.exists?

      if (product_backlog = project.product_backlog)
        user_stories.update_all(backlog_id: product_backlog.id, updated_at: Time.current)
      else
        errors.add(:base, :stories_need_product_backlog)
        throw :abort
      end
    end

    def destroy_stories
      user_stories.destroy_all
    end
end
