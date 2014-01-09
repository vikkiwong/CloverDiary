class CreateTumblrAccounts < ActiveRecord::Migration
  def change
    create_table :tumblr_accounts do |t|
      t.string :email
      t.string :password
      t.string :user_name
      t.string :blog_name
      t.string :blog_url
      t.string :post_email
      t.string :consumer_key
      t.string :consumer_secret
      t.string :oauth_token
      t.string :oauth_token_secret
      
      t.timestamps
    end
  end
end
