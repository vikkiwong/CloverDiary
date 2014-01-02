# encoding: utf-8
class UsersController < ApplicationController
	def show
		date  = Date.today
		user = User.find(params[:id])
		@user_id = user.id
		@sys_questions = Question.find_sys_questions(user.id, date) # 系统问题
		@self_questions = Question.find_self_questions(user.id, date) # 自问自答
		@whispered = Answer.get_whispered(user.id, date) #自言自语
	end
end
