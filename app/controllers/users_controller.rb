# encoding: utf-8
class UsersController < ApplicationController
	def show
		today  = Date.today
		@user_id = params[:id]
		# 系统问题
		question_ids = UserQuestion.find_all_by_user_id_and_created_on(@user_id, today).collect(&:question_id)
		@questions = Question.find_all_by_id(question_ids)
		# 自问自答
		qids = Answer.find_by_sql("SELECT * FROM answers WHERE user_id = #{params[:id]} AND created_at > #{today} GROUP BY question_id").collect(&:question_id)
		@wd_questions = Question.find_all_by_id(qids - question_ids) if qids.present?
	end
end
