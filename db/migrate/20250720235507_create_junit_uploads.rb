class CreateJunitUploads < ActiveRecord::Migration[8.0]
  def change
    create_table :junit_uploads do |t|
      t.string :filename
      t.integer :file_size
      t.string :status
      t.datetime :uploaded_at

      t.timestamps
    end
  end
end
