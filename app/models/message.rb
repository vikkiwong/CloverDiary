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
end
