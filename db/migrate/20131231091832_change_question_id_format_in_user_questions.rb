class ChangeQuestionIdFormatInUserQuestions < ActiveRecord::Migration
  def up
  	change_column :user_questions, :question_id, :integer
  end

  def down
  	change_column :user_questions, :question_id, :string
  end
end
