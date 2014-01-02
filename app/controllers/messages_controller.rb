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
    message = Message.create(user_id: user.id, open_id: params[:xml][:FromUserName], create_time: params[:xml][:CreateTime], msg_type: params[:xml][:MsgType], 
                             msg_id: params[:xml][:MsgId], content: params[:xml][:Content], event: params[:xml][:Event], event_key: params[:xml][:EventKey], 
                             ticket: params[:xml][:Ticket], pic_url: params[:xml][:PicUrl], media_id: params[:xml][:MediaId], format: params[:xml][:Format],
                             thumb_media_id: params[:xml][:ThumbMediaId], localtion_x: params[:xml][:Location_X], localtion_y: params[:xml][:Location_Y],
                             scale: params[:xml][:Scale], label: params[:xml][:Label], title: params[:xml][:Title], description: params[:xml][:Description],
                             url: params[:xml][:Url])
  	# 保存消息
  	# case params[:xml][:MsgType]
  	# when "text"
  	# 	message = Message.create(user_id: user.id, open_id: params[:xml][:FromUserName], create_time: params[:xml][:CreateTime], msg_type: params[:xml][:MsgType], 
  	# 		                       content: params[:xml][:Content], :msg_id => params[:xml][:MsgId])
  	# when "event"
  	# 	user.followed = false and user.save if params[:xml][:Event] == "unsubscribe"   # 如果取消订阅，修改followed标识
   #    Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
   #                   event_key: params[:xml][:EventKey], ticket: params[:xml][:Ticket])
  	# when "image"
  	# 	message = Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  	# 		             :pic_url => params[:xml][:PicUrl], :media_id => params[:xml][:MediaId], :msg_id => params[:xml][:MsgId])
  	# when "voice"
  	# 	message = Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  	# 		             :format => params[:xml][:Format], :media_id => params[:xml][:MediaId], :msg_id => params[:xml][:MsgId])
  	# when "video"
  	# 	message = Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  	# 		             :thumb_media_id => params[:xml][:ThumbMediaId], :media_id => params[:xml][:MediaId], :msg_id => params[:xml][:MsgId])
  	# when "location"
  	# 	message = Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  	# 		             :localtion_x => params[:xml][:Location_X], :localtion_y => params[:xml][:Location_Y], :scale => params[:xml][:Scale], 
  	# 		             :label => params[:xml][:Label], :msg_id => params[:xml][:MsgId])
  	# when "link"
  	# 	message = Message.create(:user_id => user.id, :open_id => params[:xml][:FromUserName], :create_time => params[:xml][:CreateTime], :msg_type => params[:xml][:MsgType], 
  	# 		             :title => params[:xml][:Title], :description => params[:xml][:Description], :url => params[:xml][:Url], :msg_id => params[:xml][:MsgId])
  	# end

    # 处理消息
    msg_handler(user, params, message) if message.present?
  end

  private
  # 处理微信消息
  def msg_handler(user, params, message)
    if 

   #  msg_type = params[:xml][:MsgType]
   #  content = params[:xml][:Content].downcase  if params[:xml][:Content].present?
   #  questions = Question.get_questions(user, Date.today)

   #  # l：问题列表， 123：选题，n：下一题 w：提问 q：取消提问
   #  if msg_type == "text" && content == "h"   # h：帮助信息
   #    @text = Message::Infos[:helpInfo]
   #  elsif msg_type == "text" && ( content == "l" || ( content == "n" &&  Message.current_question_order(user) == 4)) # l：问题列表
   #    # 系统问题
   #    @text = "----今日记----\n"
   #    @text += Answer.get_answers_string(user, questions)
      
   #    # 自问自答
   #    wdquestions = Question.find_wdquestions(user, Date.today)
   #    if wdquestions.present?
   #      @text += "\n----我的自言自语----\n"
   #      @text += Answer.get_wdanswers_string(user, wdquestions) 
   #    end

   #    @url = SITE_DOMAIN + '/users/' + user.id.to_s
   #    @title = "今日问题回答完毕！"

   #    current_qid  = 0 and type = "picmsg"
  	# elsif msg_type == "text" && ["1", "2", "3", "n"].include?(content)  # 选题 
   #    if questions.present? && questions.count == 3
   #      if content == "n"   # ：下一题
   #        order = Message.current_question_order(user)
   #        if order == 0 
   #          current_qid = 0
   #          @text = Message::Infos[:isFinished]
   #        else
   #          @text = questions[order - 1].content
   #          current_qid = questions[order - 1].id
   #        end
   #      else  # 123：选题
   #        @text = questions[content.to_i - 1].content
   #        current_qid = questions[content.to_i - 1].id
   #      end
   #    else
   #      current_qid = 0
   #      @text = Message::Infos[:unknowQ]
   #    end
   #  elsif msg_type == "text" && content == "w"  # 自问 
   #    current_qid = 0
   #    @text = Message::Infos[:newQ]
   #  elsif msg_type == "text" && content == "q" && Message.last_msg(user).present? && Message.last_msg(user).content == "w"  #取消自问 
   #    current_qid = 0
   #    @text = Message::Infos[:wCancle]
   #  elsif msg_type == "text" && Message.last_msg(user).present? && Message.last_msg(user).content == "w" # 保存问题，并进入回答模式
   #    question = Question.create(content: content, user_id: user.id)
   #    UserQuestion.create(user_id: user.id, question_id: question.id, created_on: Date.today, qtype: "self")
   #    current_qid = question.id
   #    @text = Message::Infos[:wSaved]
   #  elsif msg_type == "text" && content == "z" # 自言自语
   #    current_qid = 0
   #    @text = Message::Infos[:zStart]
   #    # 这里还需要判断如何保存自言自语
   #  else # 这里所有内容当作回复保存
   #    if user.current_qid > 0 
   #      Answer.create(user_id: user.id, message_id: message.id, question_id: user.current_qid) if message.present?
   #      @text = Message::Infos[:saved]
   #    else
   #      @text = Message::Infos[:unknowQ]
   #    end
  	# end

    user.current_qid = current_qid and user.save  if current_qid.present? 
    if type.present? && type == "picmsg"
      render "picmsg", :formats => :xml
    else
      render "text", :formats => :xml
    end
  end

  # 微信验证
  def check_wx_legality
    array = [WX_TOKEN, params[:timestamp], params[:nonce]].sort
    render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
  end
end
