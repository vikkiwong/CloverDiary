class AddTypeToUserQuestions < ActiveRecord::Migration
  def change
    add_column :user_questions, :qtype, :string, :default => ""

    UserQuestion.update_all(qtype: "sys")
  end
end
