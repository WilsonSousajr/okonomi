class CreateUserStories < ActiveRecord::Migration[8.1]
  def change
    create_table :user_stories do |t|
      # project_id is redundant with backlog.project_id on purpose: it lets the composite
      # foreign keys below refuse cross-project backlogs (#8) and epics (#11) in the database.
      t.references :project, null: false, foreign_key: true
      t.bigint :backlog_id, null: false
      t.bigint :epic_id
      # Three columns, never free text, so the "Como um … eu quero … para …" format holds (#9).
      t.text :role, null: false
      t.text :action, null: false
      t.text :benefit, null: false
      t.integer :story_points
      t.string :moscow, limit: 1
      t.integer :rice_reach
      # decimal, not float, so 0.25 is stored exactly (#18).
      t.decimal :rice_impact, precision: 3, scale: 2
      t.integer :rice_confidence
      t.integer :rice_effort

      t.timestamps
    end

    add_index :user_stories, :backlog_id
    add_index :user_stories, :epic_id
    add_foreign_key :user_stories, :backlogs, column: %i[project_id backlog_id], primary_key: %i[project_id id]
    add_foreign_key :user_stories, :epics, column: %i[project_id epic_id], primary_key: %i[project_id id]

    fibonacci = "0, 1, 2, 3, 5, 8, 13, 21, 34, 55"
    add_check_constraint :user_stories, "story_points IN (#{fibonacci})", name: "user_stories_story_points_domain"
    add_check_constraint :user_stories, "moscow IN ('M', 'S', 'C', 'W')", name: "user_stories_moscow_domain"
    add_check_constraint :user_stories, "rice_reach >= 0", name: "user_stories_rice_reach_domain"
    add_check_constraint :user_stories, "rice_impact IN (3, 2, 1, 0.5, 0.25)", name: "user_stories_rice_impact_domain"
    add_check_constraint :user_stories, "rice_confidence IN (100, 80, 50)", name: "user_stories_rice_confidence_domain"
    add_check_constraint :user_stories, "rice_effort IN (#{fibonacci})", name: "user_stories_rice_effort_domain"
  end
end
