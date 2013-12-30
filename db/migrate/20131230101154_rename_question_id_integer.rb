class RenameQuestionIdInteger < ActiveRecord::Migration
  def up
  	rename_column :user_questions, :question_id_integer, :question_id
  end

  def down
  	rename_column :user_questions, :question_id, :question_id_integer
  end
end
