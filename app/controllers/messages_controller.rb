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
    msg_type = params[:xml][:MsgType]
    content = params[:xml][:Content].downcase  if params[:xml][:Content].present?
    questions = Question.get_questions(user, Date.today)

    # l：问题列表， 123：选题，n：下一题 w：提问 q：取消提问
    if msg_type == "text" && content == "l"   # l：问题列表，
      # 系统问题
      questions = questions.present? ? questions : create_questions(user, 3)
      @text = Answer.get_answers_string(user, Date.today, questions)

      # 自问自答
      wdquestions = Question.find_wdquestions(user, Date.today)
      if wdquestions.present?
        @text += "---------------\n我的自言自语\n"
        @text += Answer.get_wdanswers_string(user, Date.today, wdquestions) 
      end

      @text =+= "\n<a href='/users'>显示更多</a>"
      current_qid  = 0
  	elsif msg_type == "text" && ["1", "2", "3", "n"].include?(content)  # 选题 
      if questions.present? && questions.count == 3
        if content == "n"   # ：下一题
          order = Message.current_question_order(user)
          if order == 0  
            current_qid = 0
            @text = Message::Infos[:isFinished]
          else 
            @text = questions[order - 1].content
            current_qid = questions[order - 1].id
          end
        else  # 123：选题
          @text = questions[content.to_i - 1].content
          current_qid = questions[content.to_i - 1].id
        end
      else
        current_qid = 0
        @text = Message::Infos[:unknowQ]
      end
    elsif msg_type == "text" && content == "w"  # 自问 
      current_qid = 0
      @text = Message::Infos[:newQ]
    elsif msg_type == "text" && content == "q"  # 取消自问 
      current_qid = 0
      @text = Message::Infos[:wCancle]
    elsif msg_type == "text" && Message.last_msg(user).present? && Message.last_msg(user).content == "w" # 保存问题，并进入回答模式
      question = Question.create(content: content, user_id: user.id)
      current_qid = question.id
      @text = Message::Infos[:wSaved]
    else # 这里所有内容当作回复保存
      if user.current_qid > 0 
        Answer.create(:user_id => user.id, :message_id => message.id, :question_id => user.current_qid) if message.present?
        @text = questions.collect(&:id).include?(current_qid) ? Message::Infos[:alreadySave] : Message::Infos[:wdSaved]  # 区分自问自答和系统问题的回复
      else
        @text = Message::Infos[:unknowQ]
      end
  	end

    user.current_qid = current_qid and user.save  if current_qid.present? 
    render "text", :formats => :xml
  end

  # 创建用户当天的n个问题
  def create_questions(user, n)
    questions = Question.find_questions_by_random(user, 3)
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
