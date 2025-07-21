class CreateTestSuiteTestCases < ActiveRecord::Migration[8.0]
  def change
    create_table :test_suite_test_cases do |t|
      t.references :test_suite, null: false, foreign_key: true
      t.references :test_case, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
