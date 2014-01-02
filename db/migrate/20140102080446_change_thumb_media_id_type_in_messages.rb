class ChangeThumbMediaIdTypeInMessages < ActiveRecord::Migration
  def up
  	change_column :messages, :thumb_media_id, :string
  end

  def down
  	change_column :messages, :thumb_media_id, :integer
  end
end
