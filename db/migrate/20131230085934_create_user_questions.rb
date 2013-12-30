class CreateUserQuestions < ActiveRecord::Migration
  def change
    create_table :user_questions do |t|
      t.integer :user_id
      t.string :question_id_integer
      t.boolean :active, :default => true

      t.timestamps
    end
  end
end
