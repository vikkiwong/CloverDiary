# encoding: utf-8
# 字段说明
# t.text     "content"  # 暂时无用
# t.integer  "user_id",     :default => 0
# t.datetime "created_at",  :null => false
# t.datetime "updated_at",  :null => false
# t.integer  "message_id",  :null => false
# t.integer  "question_id", :default => 0
class Answer < ActiveRecord::Base
  attr_accessible :content, :user_id, :message_id, :question_id
  belongs_to :question
  belongs_to :message

  def self.get_answers_string(user_id, questions)
  	str = ""
  	questions.each_with_index do |q, i|
  		str += "【" + (i+1).to_s + "】" + questions[i].content + "\n"
      user_msgs = questions[i].user_msgs(user_id)
  		str += user_msgs.collect{|m| m.content if m.msg_type == "text"}.join("\n").truncate(140) + "\n" if user_msgs.present?
  	end if questions.present?
  	str
  end

  def self.get_whispered(user_id, date)
  	str = "\n\n-------自言自语------"
    msg_ids = Answer.find_by_sql("SELECT * FROM answers WHERE user_id = #{user_id} AND question_id = 0 AND created_at > '#{date}'").collect(&:message_id)  # 用户某天的自言自语
    msgs = Message.find_all_by_id(msg_ids)
    msgs.collect{|m| m.content if m.msg_type == "text"}.join("\n").truncate(140) if msgs.present?
  end
end
