class AddTumblrAccountIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tumblr_account_id, :integer, :default => 0
  end
end
