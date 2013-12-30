class Question < ActiveRecord::Base
  attr_accessible :content, :created_by

  def random(n)
  	self.last(n)
  end
end
