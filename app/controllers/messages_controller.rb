# encoding: utf-8
class MessagesController < ApplicationController
	before_filter :check_wx_legality, :only => "create"

  def index
    render :text => params[:echostr]
  end

  # 接受微信发来的消息，保存
  def create
  	# 先保存用户
  	user = User.find_or_create_by_open_id(:open_id => params[:xml][:FromUserName])

  	# 保存消息
  	case params[:xml][:MsgType]
  	when "text"
  		Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  			             :content => params[:xml][:Content], :msg_id => params[:xml][:MsgId])
  	when "event"
  		user.followed = false and user.save if params[:xml][:Event] == "unsubscribe"   # 如果取消订阅，修改followed标识
  	when "image"
  		Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  			             :pic_url => params[:xml][:PicUrl], :media_id => params[:xml][:MediaId], :msg_id => params[:xml][:MsgId])
  	when "voice"
  		Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  			             :format => params[:xml][:Format], :media_id => params[:xml][:MediaId], :msg_id => params[:xml][:MsgId])
  	when "video"
  		Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  			             :thumb_media_id => params[:xml][:ThumbMediaId], :media_id => params[:xml][:MediaId], :msg_id => params[:xml][:MsgId])
  	when "location"
  		Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  			             :localtion_x => params[:xml][:Location_X], :localtion_y => params[:xml][:Location_Y], :scale => params[:xml][:Scale], 
  			             :lable => params[:xml][:Label], :msg_id => params[:xml][:MsgId])
  	when "link"
  		Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  			             :title => params[:xml][:Title], :description => params[:xml][:Description], :url => params[:xml][:Url], :msg_id => params[:xml][:MsgId])
  	end

    # 处理消息
    msg_handler(user, params)
  end

  private
  # 处理微信消息
  def msg_handler(user, params)
    msg_type, content = params[:xml][:MsgType], params[:xml][:Content].downcase

  	if msg_type == "text" && ["l", "1", "2", "3"].include?(content)  # 选题
      questions = get_questions(user, Date.today)
      if questions.present? && questions.count == 3
        if content == "l"   # 今天的问题
          @text = "1、" + questions[0].content + "\n2、" + questions[1].content + "\n3、" + questions[2].content
        else
          @text = questions[content.to_i - 1].content 
        end
      else
        @text = "可能有什么地方出错了，待我检查检查~"
      end
    else
  		@text = "这里应该保存回复~"
  	end
    render "text", :formats => :xml
  end

  # 查找用户某天的问题，若是查找当天且无问题记录，则创建
  def get_questions(user, date)
  	question_ids = UserQuestion.find_all_by_user_id_and_created_on(user.id, date).collect(&:question_id)
  	if date == Date.today && question_ids.blank?
  		questions = Question.find_questions(3)
  		questions.each do |q|
  			UserQuestion.create(:user_id => user.id, :question_id => q.id, :created_on => Date.today)
  		end if questions.present? 
  	else
  		questions = Question.find_all_by_id(question_ids)
  	end
  	questions
  end

  def check_wx_legality
    array = [WX_TOKEN, params[:timestamp], params[:nonce]].sort
    render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
  end
end
