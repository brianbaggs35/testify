class CreateTestRuns < ActiveRecord::Migration[8.0]
  def change
    create_table :test_runs do |t|
      t.string :name
      t.references :test_suite, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
