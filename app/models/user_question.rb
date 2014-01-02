# encoding: utf-8
# 字段说明
# t.integer  "user_id"
# t.string   "question_id"
# t.boolean  "active",      :default => true
# t.datetime "created_at",  :null => false
# t.datetime "updated_at",  :null => false
# t.date     "created_on"
# t.boolean  "finished",    :default => false  # 暂时无用字段
# t.string   "qtype",        :default => ""
class UserQuestion < ActiveRecord::Base
  attr_accessible :active, :question_id, :user_id, :created_on, :finished, :qtype
end
