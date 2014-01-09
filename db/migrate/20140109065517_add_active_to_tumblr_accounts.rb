class AddActiveToTumblrAccounts < ActiveRecord::Migration
  def change
    add_column :tumblr_accounts, :active, :boolean, :default => false
  end
end
