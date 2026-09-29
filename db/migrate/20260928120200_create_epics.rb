class CreateEpics < ActiveRecord::Migration[8.1]
  def change
    create_table :epics do |t|
      t.references :project, null: false, foreign_key: true, index: false
      t.string :title, null: false
      t.text :description

      t.timestamps
    end

    # Target of the composite foreign key from user_stories (#11).
    add_index :epics, %i[project_id id], unique: true
  end
end
