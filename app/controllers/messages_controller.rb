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
    sys_questions = Question.find_sys_questions(user.id, Date.today)  # 系统生成的问题
    self_questions = Question.find_self_questions(user.id, Date.today) # 自己提的问题

    questions = sys_questions + self_questions
    qid_index = questions.collect(&:id).index(user.current_qid) # 当前在第几道题目, nil表示不在其中
    q_count = questions.count # 当前问题数量

    # user.current_qid含义  >0：在回答问题状态(question.id)， 0：不在回答问题状态， -1：自言自语, -2：推送tumblr
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
      when "CLICK_4"
        @text = Message::Infos[:saySth] and current_qid = -2
      end

    # current_id 在问题列表中，且不是最后一题，则跳转到下一题
    elsif message.msg_type == "text" && message.content.downcase == "n" &&  qid_index.present? && qid_index >= 0 && qid_index < q_count - 1
      @text = questions[qid_index+1].content and current_qid = questions[qid_index+1].id

    # 其他情况输入n，跳到问题列表
    elsif message.msg_type == "text" && ( message.content.downcase == "n" || message.content.downcase == "l")
      @title = "今天的小宝日记"
      @url = SITE_DOMAIN + '/users/' + user.id.to_s + "?open_id=" + user.open_id
      @text = Answer.get_answers_string(user.id, questions) # 系统问题 + 自问自答
      if Answer.get_whispered(user.id, Date.today).present? 
        @text += "\n——————我的自言自语——————\n"
        @text += Answer.get_whispered(user.id, Date.today) # 自言自语
      end
      current_qid = 0 and type = "picmsg"

    # 输入q，且上一条消息是点击了自问自答或者自言自语，则取消自问自答或自言自语
    elsif message.msg_type == "text" && message.content.downcase == "q" && (last_msg = Message.last_msg(user.id)).present? && ["CLICK_3", "CLICK_2", "CLICK_4"].include?(last_msg.event_key)
      @text = Message::Infos[:cancle] and current_qid = 0

    # 输入数字选择题目
    elsif message.msg_type == "text" && (i = message.content.to_i) > 0 && i <= q_count
      @text = questions[i-1].content and current_qid = questions[i-1].id

    # -2 表示需要推送到tumblr账户
    elsif user.current_qid == -2
      # 保存自言自语到tumblr账户, 这个请求比较慢，所以单开进程
      tumblr_account = user.find_account # 查找或创建 tumblr_account

      if tumblr_account.present?
        current_qid = -2 and @text = "已保存\n" + tumblr_account.blog_url
        Process.fork do 
          if message.msg_type == "text"
            tumblr_account.text({body: message.content})
          elsif message.msg_type == "image"
            tumblr_account.photo({source: message.pic_url})
          end    
        end
      else # 提示账户不足
        @text = Message::Infos[:notEnough]
      end

    # -1表示自言自语状态，保存自言自语
    elsif user.current_qid == -1
      Answer.create(user_id: user.id, message_id: message.id, question_id: 0) if message.present?
      current_qid = -1 and @text = Message::Infos[:zSaved] 

    # 保存自问的问题
    elsif message.msg_type == "text" && (last_msg = Message.last_msg(user.id)).present? && last_msg.event_key == "CLICK_2"
      question = Question.create(content: message.content, user_id: user.id)
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
  end

  # 微信验证
  def check_wx_legality
    array = [WX_TOKEN, params[:timestamp], params[:nonce]].sort
    render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
  end
end
