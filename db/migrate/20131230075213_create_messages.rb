class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :user_id
      t.string :open_id
      t.integer :create_time
      t.integer :msg_id
      t.string :msg_type
      t.text :content
      t.string :pic_url
      t.float :location_x
      t.float :location_y
      t.float :scale
      t.text :label
      t.string :title
      t.text :descripton
      t.string :url
      t.string :event
      t.string :event_key

      t.timestamps
    end
  end
end
