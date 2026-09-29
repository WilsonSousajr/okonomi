class CreateBacklogs < ActiveRecord::Migration[8.1]
  def change
    create_table :backlogs do |t|
      t.references :project, null: false, foreign_key: true, index: false
      t.string :kind, null: false
      t.string :name, null: false
      t.text :goal
      t.date :starts_on
      t.date :ends_on

      t.timestamps
    end

    # Target of the composite foreign key from user_stories (#8).
    add_index :backlogs, %i[project_id id], unique: true
    # At most one product backlog per project; sprint backlogs are unlimited (#5, #6).
    add_index :backlogs, :project_id, unique: true, where: "kind = 'product'", name: "index_backlogs_one_product_per_project"
    add_check_constraint :backlogs, "kind IN ('product', 'sprint')", name: "backlogs_kind_domain"
    add_check_constraint :backlogs, "ends_on >= starts_on", name: "backlogs_ends_after_start"
  end
end
