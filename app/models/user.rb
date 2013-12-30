class User < ActiveRecord::Base
  attr_accessible :open_id, :followed
end
