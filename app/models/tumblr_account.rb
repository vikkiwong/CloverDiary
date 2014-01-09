class TumblrAccount < ActiveRecord::Base
  attr_accessible :blog_name, :blog_url, :consumer_key, :consumer_secret, :email, :oauth_token, :oauth_token_secret, :password, :post_email, :user_name

  def init
		Tumblr::Client.new({
		  :consumer_key => self.consumer_key,
		  :consumer_secret => self.consumer_secret,
		  :oauth_token => self.oauth_token,
		  :oauth_token_secret => self.oauth_token_secret
		})  	
  end

   # data:  {:title => "hi", :body => "hi"}
  def text(data)
  	client = self.init
		client.text(self.blog_url, data)
  end

  def photo(data)
  	client = self.init
		client.photo(self.blog_url, data)
  end
end
