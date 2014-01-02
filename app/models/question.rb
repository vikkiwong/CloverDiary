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
  def self.find_questions_by_random(user, n)
  	self.find_by_sql("SELECT * FROM questions WHERE user_id = 0 OR user_id = #{user.id} order by rand() LIMIT #{n}")
  end

  # 查找用户某天的系统生成问题
  def self.get_questions(user, date)
  	question_ids = UserQuestion.find_all_by_user_id_and_created_on(user.id, date).collect(&:question_id)
    questions = Question.find_all_by_id(question_ids)
  end

  # 用户某天自问自答的问题
  def self.find_wdquestions(user, date)
    question_ids = UserQuestion.find_all_by_user_id_and_created_on(user.id, date).collect(&:question_id)
    all_qids = Answer.find_by_sql("SELECT * FROM answers WHERE user_id = #{user.id} AND created_at > '#{date}' GROUP BY question_id").collect(&:question_id)
    wd_qids = all_qids.present? ? (all_qids - question_ids) : []
    Question.find_all_by_id(wd_qids)
  end

  # 用户对问题的回答
  def user_msgs(user_id)
    date = Date.today
    msg_ids = Answer.find_by_sql("SELECT * FROM answers WHERE user_id = #{user_id} AND question_id = #{self.id} AND created_at > '#{date}'").collect(&:message_id)
    Message.find_all_by_id(msg_ids)
  end
end
