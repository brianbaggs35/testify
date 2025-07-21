class CreateTestResults < ActiveRecord::Migration[8.0]
  def change
    create_table :test_results do |t|
      t.references :test_run, null: false, foreign_key: true
      t.references :test_case, null: false, foreign_key: true
      t.string :status
      t.text :notes
      t.datetime :executed_at

      t.timestamps
    end
  end
end
