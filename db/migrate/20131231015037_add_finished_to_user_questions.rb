class AddFinishedToUserQuestions < ActiveRecord::Migration
  def change
  	add_column :user_questions, :finished, :boolean, :default => false
  end
end
