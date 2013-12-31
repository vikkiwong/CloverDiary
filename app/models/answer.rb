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

  def self.get_answers_string(user, questions)
  	str = ""
  	questions.each_with_index do |q, i|
  		str += (i+1).to_s + "、" + questions[i].content + "\n"
      user_msgs = questions[i].user_msgs(user)
  		str += user_msgs.collect(&:content).join("\n") + "\n" if user_msgs.present?
  	end if questions.present?
  	str
  end

  def self.get_wdanswers_string(user, questions)
  	str = ""
  	questions.each_with_index do |q, i|
  		str += "Q：" + questions[i].content + "\n"
      user_msgs = questions[i].user_msgs(user)
      str += user_msgs.collect(&:content).join("\n") + "\n" if user_msgs.present?
  	end if questions.present?
  	str  	
  end
end
