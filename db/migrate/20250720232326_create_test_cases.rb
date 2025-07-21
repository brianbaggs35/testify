class CreateTestCases < ActiveRecord::Migration[8.0]
  def change
    create_table :test_cases do |t|
      t.string :title
      t.text :description
      t.text :steps
      t.string :priority
      t.string :status

      t.timestamps
    end
  end
end
