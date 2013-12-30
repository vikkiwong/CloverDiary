# encoding: utf-8
class WechatController < ApplicationController
	before_filter :check_weixin_legality, :only => "create"
	
  def index
    render :text => params[:echostr]
  end

  def create
  	if params[:xml][:MsgType] == "text" && params[:xml][:Content] == "hi"
  		@text = "欢迎！"
  		render "welcome", :formats => :xml
  	end
  end

  private
  def check_weixin_legality
    array = [WX_TOKEN, params[:timestamp], params[:nonce]].sort
    render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
  end
end
