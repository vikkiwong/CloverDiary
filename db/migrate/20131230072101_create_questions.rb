class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :content
      t.integer :user_id, :default => 0

      t.timestamps
    end
  end
end
