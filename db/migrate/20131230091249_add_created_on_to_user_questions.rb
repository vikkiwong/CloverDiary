class AddCreatedOnToUserQuestions < ActiveRecord::Migration
  def change
  	add_column :user_questions, :created_on, :date
  end
end
