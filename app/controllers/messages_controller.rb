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
    message = Message.create(user_id: user.id, open_id: params[:xml][:FromUserName], create_time: params[:xml][:CreateTime], msg_type: params[:xml][:MsgType], 
                             msg_id: params[:xml][:MsgId], content: params[:xml][:Content], event: params[:xml][:Event], event_key: params[:xml][:EventKey], 
                             ticket: params[:xml][:Ticket], pic_url: params[:xml][:PicUrl], media_id: params[:xml][:MediaId], format: params[:xml][:Format],
                             thumb_media_id: params[:xml][:ThumbMediaId], location_x: params[:xml][:Location_X], location_y: params[:xml][:Location_Y],
                             scale: params[:xml][:Scale], label: params[:xml][:Label], title: params[:xml][:Title], description: params[:xml][:Description],
                             url: params[:xml][:Url])
    # 处理消息
    msg_handler(user, params, message) if message.present?
  end

  private
  # 处理微信消息
  def msg_handler(user, params, message)
    content = message.content.downcase if message.content.present?
    sys_questions = Question.find_sys_questions(user.id, Date.today)  # 系统生成的问题
    self_questions = Question.find_self_questions(user.id, Date.today) # 自己提的问题

    questions = sys_questions + self_questions
    qid_index = questions.collect(&:id).index(user.current_qid) # 当前在第几道题目, nil表示不在其中
    q_count = questions.count # 当前问题数量

    # user.current_qid  >0：question.id, -2：自问自答 -3：自言自语
    # 关注
    if message.msg_type == "event" && ["subscribe", "unsubscribe"].include?(message.event)  
      tag = (message.event == "subscribe")  # true or false
      user.update_attributes(followed: tag, current_qid: 0)
      @text = Message::Infos[:sayHi]
    
    # 菜单点击 
    elsif message.msg_type == "event" && message.event == "CLICK"
      case message.event_key 
      when "CLICK_1"  # 今日记
        @text = sys_questions[0].content and current_qid = sys_questions[0].id
      when "CLICK_2"  # 自问自答
        @text = Message::Infos[:newQ] and current_qid = 0
      when "CLICK_3"  # 自言自语
        @text = Message::Infos[:zStart] and current_qid = -1
      end

    # current_id 在问题列表中，且不是最后一题，则跳转到下一题
    elsif message.msg_type == "text" && message.content == "n" &&  qid_index.present? && qid_index >= 0 && qid_index < q_count - 1
      @text = questions[qid_index+1].content and current_qid = questions[qid_index+1].id

    # 其他情况输入n，跳到问题列表
    elsif message.msg_type == "text" && message.content == "n"
      @title = "今天的三叶草日记"
      @url = SITE_DOMAIN + '/users/' + user.id.to_s
      @text = Answer.get_answers_string(user.id, questions) # 系统问题 + 自问自答
      if Answer.get_whispered(user.id, Date.today).present? 
        @text += "\n\n---------我的自言自语----------"
        @text += Answer.get_whispered(user_id, Date.today) # 自言自语
      end
      current_qid = 0 and type = "picmsg"

    # 输入q，且上一条消息是点击了自问自答或者自言自语，则取消自问自答或自言自语
    elsif message.msg_type == "text" && message.content == "q" && (last_msg = Message.last_msg(user.id)).present? && ["CLICK_3", "CLICK_2"].include?(last_msg.event_key)
      @text = Message::Infos[:cancle] and current_qid = 0

    # 输入数字选择题目
    elsif message.msg_type == "text" && (i = message.content.to_i) > 0 && i <= q_count
      @text = questions[i-1].content and current_qid = questions[i-1].id

    # -1表示自言自语状态，保存自言自语
    elsif user.current_qid == -1
      Answer.create(user_id: user.id, message_id: message.id, question_id: 0) if message.present?
      current_qid = -1 and @text = Message::Infos[:zSaved] 

    # 保存自问的问题
    elsif message.msg_type == "text" && (last_msg = Message.last_msg(user.id)).present? && last_msg.event_key == "CLICK_2"
      question = Question.create(content: content, user_id: user.id)
      UserQuestion.create(user_id: user.id, question_id: question.id, created_on: Date.today, qtype: "self")
      current_qid = question.id and @text = Message::Infos[:wSaved]  

    # 当作回答保存
    else
      if user.current_qid.present? && user.current_qid > 0
        Answer.create(user_id: user.id, message_id: message.id, question_id: user.current_qid) if message.present?
        @text = Message::Infos[:saved]
      else
        @text = Message::Infos[:unknowQ]
      end
    end

    user.current_qid = current_qid and user.save  if current_qid.present? 
    layout = ( type == "picmsg") ? "picmsg" : "text"
    render layout, :formats => :xml

   #  msg_type = params[:xml][:MsgType]
   #  content = params[:xml][:Content].downcase  if params[:xml][:Content].present?
   #  questions = Question.find_sys_questions(user, Date.today)

   #  # l：问题列表， 123：选题，n：下一题 w：提问 q：取消提问
   #  if msg_type == "text" && content == "h"   # h：帮助信息
   #    @text = Message::Infos[:helpInfo]
   #  elsif msg_type == "text" && ( content == "l" || ( content == "n" &&  Message.current_question_order(user) == 4)) # l：问题列表
   #    # 系统问题
   #    @text = "----今日记----\n"
   #    @text += Answer.get_answers_string(user.id, questions)
      
   #    # 自问自答
   #    wdquestions = Question.find_self_questions(user, Date.today)
   #    if wdquestions.present?
   #      @text += "\n----我的自言自语----\n"
   #      @text += Answer.get_wdanswers_string(user.id, wdquestions) 
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

   #  user.current_qid = current_qid and user.save  if current_qid.present? 
   #  if type.present? && type == "picmsg"
   #    render "picmsg", :formats => :xml
   #  else
   #    render "text", :formats => :xml
   #  end
   # @text = "抱歉，测试中"
   # render "text", :formats => :xml
  end

  # 微信验证
  def check_wx_legality
    array = [WX_TOKEN, params[:timestamp], params[:nonce]].sort
    render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
  end
end
