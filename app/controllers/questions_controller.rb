# encoding: utf-8
class QuestionsController < ApplicationController
	def index
		@questions = Question.actived.ordered
	end

	def new
		@question = Question.new
	end

	def show
		@question = Question.find(params[:id])
	end

	def create
		question = Question.new(params[:question])
		question.user_id = 0  # 先写死
		question.save and redirect_to questions_path
	end

	def edit
		@question = Question.find(params[:id])
	end

	def update
		question = Question.find(params[:id])
		question.update_attributes(params[:question])
		redirect_to questions_path
	end

	def destroy
		question = Question.find(params[:id])
		question.active = false and question.save
		redirect_to questions_path
	end
end
