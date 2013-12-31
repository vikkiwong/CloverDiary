# encoding: utf-8
# 字段说明
# t.string   "content"
# t.integer  "user_id",    :default => 0
# t.datetime "created_at", :null => false
# t.datetime "updated_at", :null => false
# t.boolean  "active",     :default => true
class Question < ActiveRecord::Base
  attr_accessible :content, :user_id
  scope :actived, :conditions => {:active => true}
  scope :ordered, :order => "id DESC"

  # 随机n个问题
  def self.find_questions_by_random(n)
  	self.find_by_sql("SELECT * FROM questions order by rand() LIMIT #{n}")
  end

  # 查找用户某天的问题
  def self.get_questions(user, date)
  	question_ids = UserQuestion.find_all_by_user_id_and_created_on(user.id, date).collect(&:question_id)
    questions = Question.find_all_by_id(question_ids)
  end

  # 查找用户某天的未完成问题
  # def self.get_unfinished_questions(user, date)
  # 	question_ids = UserQuestion.find_all_by_user_id_and_created_on_and_finished(user.id, date, false).collect(&:question_id)
  #   questions = Question.find_all_by_id(question_ids)
  # end
end
