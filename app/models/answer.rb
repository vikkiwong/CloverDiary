# encoding: utf-8
class Answer < ActiveRecord::Base
  attr_accessible :content, :user_id
end
