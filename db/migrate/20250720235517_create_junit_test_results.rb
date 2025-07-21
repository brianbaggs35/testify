class CreateJunitTestResults < ActiveRecord::Migration[8.0]
  def change
    create_table :junit_test_results do |t|
      t.references :junit_upload, null: false, foreign_key: true
      t.string :test_name
      t.string :class_name
      t.string :status
      t.text :failure_message
      t.decimal :execution_time

      t.timestamps
    end
  end
end
