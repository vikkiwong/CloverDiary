# encoding: utf-8
# 字段说明
# t.string   "content"
# t.integer  "user_id",    :default => 0
# t.datetime "created_at", :null => false
# t.datetime "updated_at", :null => false
# t.boolean  "active",     :default => true
class Question < ActiveRecord::Base
  attr_accessible :content, :user_id, :active
  has_many :answers

  scope :actived, :conditions => {:active => true}
  scope :ordered, :order => "id DESC"

  # 随机n个问题
  # 只随机系统问题和自己创建的问题
  def self.find_questions_by_random(user_id, n)
    return [] unless user_id.present?
  	self.find_by_sql("SELECT * FROM questions WHERE user_id = 0 OR user_id = #{user_id} order by rand() LIMIT #{n}")
  end

  # 查找用户某天的系统生成问题，若无，则创建
  def self.find_sys_questions(user_id, date)
    return [] unless user_id.present?
    sys_qids = UserQuestion.find_all_by_user_id_and_created_on_and_qtype(user_id, date, "sys").collect(&:question_id)
    if sys_qids.blank?
      questions = find_questions_by_random(user_id, 3)
      questions.each do |q|
        UserQuestion.create(:user_id => user_id, :question_id => q.id, :created_on => Date.today, qtype: "sys")
      end if questions.present?   
      sys_qids = UserQuestion.find_all_by_user_id_and_created_on_and_qtype(user_id, date, "sys").collect(&:question_id)
    end
    questions = Question.find_all_by_id(sys_qids)
  end

  # 用户某天自问自答的问题
  def self.find_self_questions(user_id, date)
    self_qids = UserQuestion.find_all_by_user_id_and_created_on_and_qtype(user_id, date, "self").collect(&:question_id)
    Question.find_all_by_id(self_qids)
  end

  # 用户对问题的回答
  def user_msgs(user_id)
    date = Date.today
    msg_ids = Answer.find_by_sql("SELECT * FROM answers WHERE user_id = #{user_id} AND question_id = #{self.id} AND created_at > '#{date}'").collect(&:message_id)
    Message.find_all_by_id(msg_ids)
  end
end
