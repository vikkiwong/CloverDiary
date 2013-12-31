class AddCurrentQidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :current_qid, :integer, :default => 0
  end
end
