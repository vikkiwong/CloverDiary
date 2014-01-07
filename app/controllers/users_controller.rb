# encoding: utf-8
class UsersController < ApplicationController
	def show
		@user = User.find_by_id(params[:id])
		#render "not_found" and return unless @user.present? && @user.open_id == params[:open_id]  # 简单验证下open_id参数
		@msgs, @w_msgs = @user.msgs(4.days.ago)
	end
end
