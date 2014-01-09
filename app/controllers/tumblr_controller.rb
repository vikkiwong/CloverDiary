# encoding: utf-8
require "uri"
require "net/http"
require "net/https"
require "open-uri"
require 'securerandom'
require 'base64'
class TumblrController < ApplicationController
	skip_before_filter :verify_authenticity_token
	
	def index
		account = User.first.tumblr_account#.present?
		# Process.fork do
		# 	account.photo({source: "http://www.womenwatch-china.org/UpFileList/image/%E8%A5%BF%E8%92%99%C2%B7%E6%B3%A2%E5%A8%83.jpg"})
		# end
	end
end
