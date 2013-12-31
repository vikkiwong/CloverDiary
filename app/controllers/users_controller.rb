# encoding: utf-8
class UsersController < ApplicationController
	def show
		today  = Date.today
		qids = Answer.find_by_sql("SELECT * FROM answers WHERE user_id = #{params[:id]} AND created_at > #{today} GROUP BY question_id").collect(&:question_id)
		@questions = Question.find_all_by_id(qids)
	end
end
