# encoding: utf-8
# 字段说明
# t.string   "open_id"
# t.datetime "created_at",  :null => false
# t.datetime "updated_at",  :null => false
# t.boolean  "followed",    :default => true
# t.integer  "current_qid", :default => 0
class User < ActiveRecord::Base
  attr_accessible :open_id, :followed
end
