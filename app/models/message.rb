# encoding: utf-8
class Message < ActiveRecord::Base
  attr_accessible :content, :create_time, :descripton, :event, :event_key, :label, :location_x, :location_y, :msg_id, :msg_type, :open_id, 
                  :pic_url, :scale, :title, :url, :user_id, :media_id, :format, :thumb_media_id

  # 12小时内发送过的内容为("1", "2", "3")的消息
  def self.last_questions_msg(user)
    self.find_by_sql('SELECT * FROM messages 
                      WHERE user_id = #{user.id} AND msg_type = "text" 
                      AND content in ("1", "2", "3") AND created_at > DATE_SUB(NOW(), INTERVAL 12 HOUR)
                      ORDER BY ID DESC')
  end

  # 12小时内发送过的内容为("1", "2", "3")最后一条消息
  def self.last_question_msg(user)
    self.find_by_sql('SELECT * FROM messages 
                      WHERE user_id = #{user.id} AND msg_type = "text" 
                      AND content in ("1", "2", "3") AND created_at > DATE_SUB(NOW(), INTERVAL 12 HOUR)
                      ORDER BY ID DESC LIMIT 1')
  end

  # 当前用户回答的问题序号
  # 这个方法有漏洞，
  def self.current_question_order(user)
    beginning_of_today = Time.now.beginning_of_day
    last_choice_msg = self.where(user_id: user.id, msg_type: "text").where("created_at > ?", beginning_of_today)
                          .where("content in (?)", ["1", "2", "3"]).order("id desc").first   # 最后一次输入的123
    return 0 unless last_choice_msg.present?  
    return 0 unless self.where(user_id: user.id, msg_type: "text", content: "l").where("id > ?", last_choice_msg.id).count == 0  # 排除如果用户输入 l 1 2 l……
    
    n_counts = self.where(user_id: user.id, msg_type: "text", content: "n").where("id > ?", last_choice_msg.id).count # 最后一次输入123之后输入的n的次数
    (last_choice_msg.content.to_i + n_counts) > 3  ? 0 : (last_choice_msg.content.to_i + n_counts)  # 当前选择的第几个题目
  end
end
