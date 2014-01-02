class ChangeColumnsInMessages < ActiveRecord::Migration
  def up
  	change_column :messages, :msg_id, :string
  	change_column :messages, :location_x, :double
  	change_column :messages, :location_y, :double
  	change_column :messages, :media_id, :string
  end

  def down
  	change_column :messages, :msg_id, :integer
  	change_column :messages, :location_x, :float
  	change_column :messages, :location_y, :float
  	change_column :messages, :media_id, :integer
  end
end
