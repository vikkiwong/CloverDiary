# encoding: utf-8
require "uri"
require "net/http"
require "net/https"
require "open-uri"

class MenuController < ApplicationController
	before_filter :get_token

	def index
		p @access_token
	end

	def create
# 		require "cgi"
# 		read_path = Rails.root + "config/menu.json"
#     menu = JSON.parse(IO.read(read_path		))
# menu = IO.read(read_path)

    
#     url = "https://api.weixin.qq.com/cgi-bin/menu/create"  #?access_token=" + @access_token
# 		uri = URI.parse(url)
# 		https = Net::HTTP.new(uri.host, uri.port)
# 		https.use_ssl = true


# 		req = Net::HTTP::Post.new(uri.path)

# 		#req["access_token"] = @access_token
# 		p menu
# 		p menu.class
# 		req.body = {:menu => menu, :access_token => @access_token}
# 		req.body = "menu=#{CGI.escape(menu)}&access_token=#{@access_token}"

# 		res = https.request(req)
# 		#res = https.post(url, data )
# 		puts res
	end

	private
	def get_token
		url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=" + APP_ID + "&secret=" + APP_SECRET
		resp = URI.parse(url).read
		@access_token = JSON.parse(resp)['access_token']
	end
end
