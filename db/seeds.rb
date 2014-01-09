# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

10.times do |i|
	TumblrAccount.create(email: "cloverdiray1314@gmail.com", password: "clover1314", user_name: "cloverdiray", blog_name: "cloverdiary" + (i+1).to_s, 
		                   blog_url: "cloverdiary" + (i+1).to_s + ".tumblr.com", consumer_key: "tSXD9tLCnN0Zqrl0M0fRTX61kkDMa1zVQgLXP7N6PRzKzc1vbJ", 
		                   consumer_secret: "TLMLM3JZJsDw4SjTSPeuCX908VYFY9Gox2b1ThCnpkBtwOjub5", oauth_token: "CjOZpQZFyOl24DurrqRbl92fAfsTHYXZdPqMN8nJTeGpRP5dlL", 
		                   oauth_token_secret: "c1EMiFb8gTRpUvlWd2JPjyhAwpUjVwtCHgZ12CcKHWxa8VQ86x")
end
