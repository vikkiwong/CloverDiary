# encoding: utf-8
require "uri"
require "net/http"
require "net/https"
require "open-uri"
class TumblrController < ApplicationController
	skip_before_filter :verify_authenticity_token
	
	def index
		p "*"*10
		p params
		# get 示例
		# api_key = "tSXD9tLCnN0Zqrl0M0fRTX61kkDMa1zVQgLXP7N6PRzKzc1vbJ"
		# hostname = "cloverdiray.tumblr.com"
	 	# url = "http://api.tumblr.com/v2/blog/" + hostname + "/info?api_key=" + api_key
  	# resp = URI.parse(url).read
		# p JSON.parse(resp)["response"]

		# # post 示例
		api_key = "tSXD9tLCnN0Zqrl0M0fRTX61kkDMa1zVQgLXP7N6PRzKzc1vbJ"
		hostname = "cloverdiray.tumblr.com"
		url = "http://api.tumblr.com/v2/blog/" + hostname + "/post"
		uri = URI.parse(url)
		http = Net::HTTP.new(uri.host, uri.port)
		#http.use_ssl = true
		request = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
		request.body = {type: "text", title: "测试", body: "测试"}.to_json
		response = http.request(request)
		p response
	end

	def create
	end
end
