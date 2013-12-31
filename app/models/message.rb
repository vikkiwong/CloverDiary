# encoding: utf-8
# 字段说明
# t.integer  "user_id"
# t.string   "open_id"
# t.integer  "create_time"
# t.integer  "msg_id"
# t.string   "msg_type"
# t.text     "content"
# t.string   "pic_url"
# t.float    "location_x"
# t.float    "location_y"
# t.float    "scale"
# t.text     "label"
# t.string   "title"
# t.text     "descripton"
# t.string   "url"
# t.string   "event"
# t.string   "event_key"
# t.datetime "created_at",     :null => false
# t.datetime "updated_at",     :null => false
# t.integer  "media_id"
# t.string   "format"
# t.integer  "thumb_media_id"

class Message < ActiveRecord::Base
  attr_accessible :content, :create_time, :descripton, :event, :event_key, :label, :location_x, :location_y, :msg_id, :msg_type, :open_id, 
                  :pic_url, :scale, :title, :url, :user_id, :media_id, :format, :thumb_media_id

  Infos = {
    isFinished:  "已经是最后一题啦，回复【L】重新选题！", 
    unknowQ: "不知道您选择了什么题目哟，回复l查看问题列表~",
    newQ: "给自己一个问题？请输入问题内容。\n输入【Q】取消编辑",
    alreadySave: "您的日记已保存，回复【N】进入下一题，否则继续回答本题~",
    wCancle: "已取消",
    wSaved: "问题已保存，快点回答吧~"
    wdSaved: "您的自问自答已经保存啦~，回复【L】查看问题列表"
  }

  # 当前用户回答的问题序号
  def self.current_question_order(user)
    beginning_of_today = Time.now.beginning_of_day
    last_choice_msg = self.where(user_id: user.id, msg_type: "text").where("created_at > ?", beginning_of_today)
                          .where("content in (?)", ["1", "2", "3"]).order("id desc").first   # 最后一次输入的123
    return 0 unless last_choice_msg.present?  
    return 0 unless self.where(user_id: user.id, msg_type: "text", content: "l").where("id > ?", last_choice_msg.id).count == 0  # 排除如果用户输入 l 1 2 l……
    
    n_counts = self.where(user_id: user.id, msg_type: "text", content: "n").where("id > ?", last_choice_msg.id).count # 最后一次输入123之后输入的n的次数
    (last_choice_msg.content.to_i + n_counts) > 3  ? 0 : (last_choice_msg.content.to_i + n_counts)  # 当前选择的第几个题目
  end

  # 本条微信消息发送前的最后一条消息
  def self.last_msg(user)
    self.where(user_id: user.id).order("id desc").offset(1).first    
  end
  
  # 12小时内发送过的内容为("1", "2", "3")的消息
  # def self.last_questions_msg(user)
  #   self.find_by_sql('SELECT * FROM messages 
  #                     WHERE user_id = #{user.id} AND msg_type = "text" 
  #                     AND content in ("1", "2", "3") AND created_at > DATE_SUB(NOW(), INTERVAL 12 HOUR)
  #                     ORDER BY ID DESC')
  # end

  # 12小时内发送过的内容为("1", "2", "3")最后一条消息
  # def self.last_question_msg(user)
  #   self.find_by_sql('SELECT * FROM messages 
  #                     WHERE user_id = #{user.id} AND msg_type = "text" 
  #                     AND content in ("1", "2", "3") AND created_at > DATE_SUB(NOW(), INTERVAL 12 HOUR)
  #                     ORDER BY ID DESC LIMIT 1')
  # end
end
