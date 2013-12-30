# encoding: utf-8
class User < ActiveRecord::Base
  attr_accessible :open_id, :followed
end
