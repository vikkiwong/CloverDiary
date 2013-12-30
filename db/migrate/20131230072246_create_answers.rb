class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.text :content
      t.integer :user_id, :default => 0

      t.timestamps
    end
  end
end
