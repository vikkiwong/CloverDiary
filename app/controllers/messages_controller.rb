# encoding: utf-8
class MessagesController < ApplicationController
	before_filter :check_wx_legality, :only => "create"

  def index
    render :text => params[:echostr]
  end

  # 接受微信发来的消息，保存
  def create
  	# 先保存用户
  	# params[:xml][:FromUserName]

  	case params[:xml][:MsgType]
  	when "text"
  		Message.create(:open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  			             :content => params[:xml][:Content], :msg_id => params[:xml][:MsgId])
  		@text = "欢迎~"
  	when "event"
  		@text = "暂时处理不了event信息哟~"
  	when "image"
  		@text = "暂时处理不了event信息哟~"
  	when "voice"
  		@text = "暂时处理不了event信息哟~"
  	when "video"
  		@text = "暂时处理不了event信息哟~"
  	when "location"
  		@text = "暂时处理不了event信息哟~"
  	when "link"
  		@text = "暂时处理不了event信息哟~"
  	end
    
  	render "text", :formats => :xml
  end

  private
  def check_wx_legality
    array = [WX_TOKEN, params[:timestamp], params[:nonce]].sort
    render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
  end
end
