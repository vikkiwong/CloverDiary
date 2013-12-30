class AddFormatAndThumbMediaIdToMessages < ActiveRecord::Migration
  def change
  	add_column :messages, :format, :string
  	add_column :messages, :thumb_media_id, :integer
  end
end
