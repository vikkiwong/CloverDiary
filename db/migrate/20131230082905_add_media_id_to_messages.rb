class AddMediaIdToMessages < ActiveRecord::Migration
  def change
  	add_column :messages, :media_id, :integer
  end
end
