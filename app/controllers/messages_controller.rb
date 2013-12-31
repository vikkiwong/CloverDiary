# encoding: utf-8
class MessagesController < ApplicationController
	before_filter :check_wx_legality, :only => "create"

  def index
    render :text => params[:echostr]
  end

  # 接受微信发来的消息，保存
  def create
  	# 先查找/保存用户
  	user = User.find_or_create_by_open_id(:open_id => params[:xml][:FromUserName])

  	# 保存消息
  	case params[:xml][:MsgType]
  	when "text"
  		message = Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  			             :content => params[:xml][:Content], :msg_id => params[:xml][:MsgId])
  	when "event"
  		user.followed = false and user.save if params[:xml][:Event] == "unsubscribe"   # 如果取消订阅，修改followed标识
  	when "image"
  		message = Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  			             :pic_url => params[:xml][:PicUrl], :media_id => params[:xml][:MediaId], :msg_id => params[:xml][:MsgId])
  	when "voice"
  		message = Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  			             :format => params[:xml][:Format], :media_id => params[:xml][:MediaId], :msg_id => params[:xml][:MsgId])
  	when "video"
  		message = Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  			             :thumb_media_id => params[:xml][:ThumbMediaId], :media_id => params[:xml][:MediaId], :msg_id => params[:xml][:MsgId])
  	when "location"
  		message = Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  			             :localtion_x => params[:xml][:Location_X], :localtion_y => params[:xml][:Location_Y], :scale => params[:xml][:Scale], 
  			             :lable => params[:xml][:Label], :msg_id => params[:xml][:MsgId])
  	when "link"
  		message = Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  			             :title => params[:xml][:Title], :description => params[:xml][:Description], :url => params[:xml][:Url], :msg_id => params[:xml][:MsgId])
  	end

    # 处理消息
    msg_handler(user, params, message) if message.present?
    
  end

  private
  # 处理微信消息
  def msg_handler(user, params, message)
    msg_type, content = params[:xml][:MsgType], params[:xml][:Content].downcase
    questions = Question.get_questions(user, Date.today)

    # l：问题列表， 123：选题，n：下一题
    if msg_type == "text" && content == "l"   # l：问题列表，
      questions = questions.present? ? questions : create_questions(user, 3)
      @text = "1、" + questions[0].content + "\n2、" + questions[1].content + "\n3、" + questions[2].content  
  	elsif msg_type == "text" && ["1", "2", "3", "n"].include?(content)  # 选题 
      if questions.present? && questions.count == 3
        if content == "n"   # ：下一题
          order = Message.current_question_order
          if order == 0  
            @text = "\n已经是最后一题啦，回复l重新选题！"
          else 
            @text = questions[order - 1].content
            current_qid = questions[order - 1].id
          end
        else  # 123：选题
          @text = questions[content.to_i - 1].content
          current_qid = questions[content.to_i - 1].id
        end
      else
        @text = "不知道您选择了什么题目哟，回复l查看问题列表~"
      end
    else # 这里所有内容当作回复保存
      Answer.create(:user_id => user.id, :message_id => message.id, :question_id => user.current_qid)
  		@text = "您的日记已保存，回复n进入下一题，否则继续回答本题~"
  	end

    user.current_qid = current_qid and user.save  
    render "text", :formats => :xml
  end

  # 创建用户当天的n个问题
  def create_questions(user, n)
    questions = Question.find_questions_by_random(3)
    questions.each do |q|
      UserQuestion.create(:user_id => user.id, :question_id => q.id, :created_on => Date.today)
    end if questions.present?   
    questions
  end

  def check_wx_legality
    array = [WX_TOKEN, params[:timestamp], params[:nonce]].sort
    render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
  end
end
