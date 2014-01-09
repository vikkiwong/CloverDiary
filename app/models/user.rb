# encoding: utf-8
# 字段说明
# t.string   "open_id"
# t.datetime "created_at",  :null => false
# t.datetime "updated_at",  :null => false
# t.boolean  "followed",    :default => true
# t.integer  "current_qid", :default => 0
class User < ActiveRecord::Base
  attr_accessible :open_id, :followed

  belongs_to :tumblr_account

  # 用户某天发送的全部消息,用于展示
  # == return ==
  # Array
  # [[q1, [m1, m2, m3]],[],[]...]
  def msgs(date)
    return [] unless date.present?
    answers = Answer.find_by_sql("SELECT question_id, created_at, GROUP_CONCAT(message_id) as msg_ids FROM answers WHERE user_id = #{self.id} AND Date(created_at) = Date('#{date}') GROUP BY question_id")

    ques_ids = answers.collect{|c| c.question_id if c.question_id > 0 }
  	msg_ids = answers.collect{|c| c.msg_ids.split(",")}.flatten.collect{|c| c.to_i}
  	
    questions = Question.find_all_by_id(ques_ids)
    msgs = Message.find_all_by_id(msg_ids)

    arr = []
    w_arr = []
    answers.each do |a|
      q = questions.find{|c| c.id == a.question_id }
      m = msgs.collect{|c| c if a.msg_ids.split(",").collect{|i| i.to_i}.include?(c.id) }.compact.sort_by{|s| s.id if s.present? }
      q.present? ? arr << [q, m] : w_arr = [q, m]
    end
    return arr, w_arr
  end
end
