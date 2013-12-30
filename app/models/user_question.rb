class UserQuestion < ActiveRecord::Base
  attr_accessible :active, :question_id_integer, :user_id
end
