# encoding: utf-8
class WechatController < ApplicationController
  def index
    render :text => params[:echostr]
  end

  def create
  	if params[:xml][:MsgType] == "text" && params[:xml][:Content] == "hi"
  		@text = "欢迎！"
  		render "welcome", :formats => :xml
  	end
  end
end
