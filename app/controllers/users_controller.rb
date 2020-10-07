# frozen_string_literal: true

class UsersController < ApplicationController
   def index
    @users = Customer.order('date')

    @user_role = if session[:user_id]
                   Customer.where(id: session[:user_id]).first.role
                 else
                   'not_logged_in'
                 end

    #conditionally renders admin or user index view
    if @user_role == 'admin'
      render('index_admin')
    elsif @user_role == 'user'
      render('index_user')
    end

  end

  def create; end

  def update; end

  def dashboard; end
end
