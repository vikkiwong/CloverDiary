class AddFollowedToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :followed, :boolean, :default => true
  end
end
