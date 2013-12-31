# encoding: utf-8
class UserQuestion < ActiveRecord::Base
  attr_accessible :active, :question_id, :user_id, :created_on, :finished
end
