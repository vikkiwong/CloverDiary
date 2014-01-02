# encoding: utf-8
class UsersController < ApplicationController
	def show
		date  = Date.today
		user = User.find(params[:id])
		@user_id = user.id
		@sys_questions = Question.get_questions(user, date) # 系统问题
		@self_questions = Question.find_wdquestions(user, date) # 自问自答
	end
end
