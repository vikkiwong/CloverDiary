# encoding: utf-8
class Question < ActiveRecord::Base
  attr_accessible :content, :created_by

  def self.find_questions(n)
  	self.last(n)
  end
end
