class CreateAcceptanceCriteria < ActiveRecord::Migration[8.1]
  def change
    create_table :acceptance_criteria do |t|
      t.references :user_story, null: false, foreign_key: true
      # Three columns so the "Dado … quando … então …" format holds (#13).
      t.text :context, null: false
      t.text :action, null: false
      t.text :outcome, null: false

      t.timestamps
    end
  end
end
