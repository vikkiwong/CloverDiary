# encoding: utf-8
class Question < ActiveRecord::Base
  attr_accessible :content, :created_by

  # 随机n个问题
  def self.find_questions(n)
  	self.find_by_sql("SELECT * FROM questions order by rand() LIMIT #{n}")
  end
end
