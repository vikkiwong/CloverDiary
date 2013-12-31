class AddMessageIdToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :message_id, :integer, :null => false
    add_column :answers, :question_id, :integer, :default => 0
  end
end
